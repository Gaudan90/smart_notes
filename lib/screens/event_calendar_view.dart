import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../controllers/event_calendar_presenter.dart';
import '../states/event_occurrence_model.dart';
import '../widget/event_calendar/event_add_dialog.dart';
import '../widget/event_calendar/event_card.dart';
import '../widget/event_calendar/event_calendar_helpers.dart';
import '../widget/event_calendar/event_details_dialog.dart';
import '../widget/event_calendar/event_occurrence_card.dart';

class EventCalendarView extends StatefulWidget {
  const EventCalendarView({super.key});

  @override
  State<EventCalendarView> createState() => _EventCalendarViewState();
}

class _EventCalendarViewState extends State<EventCalendarView>
    with SingleTickerProviderStateMixin {
  final _presenter = EventCalendarPresenter();
  late TabController _tabController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    await _presenter.loadEvents();
    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('event_calendar'.tr()),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'tab_my_events'.tr(), icon: const Icon(Icons.event_note)),
            Tab(text: 'tab_future_dates'.tr(), icon: const Icon(Icons.calendar_month)),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
        controller: _tabController,
        children: [
          _buildEventsTab(),
          _buildUpcomingTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddEventDialog,
        icon: const Icon(Icons.add),
        label: Text('new_event'.tr()),
      ),
    );
  }

  Widget _buildEventsTab() {
    if (_presenter.events.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _presenter.events.length,
      itemBuilder: (context, index) {
        final event = _presenter.events[index];
        return EventCard(
          event: event,
          totalOccurrences: _presenter.getTotalOccurrencesForEvent(event.id),
          nextOccurrence: _presenter.getNextOccurrence(event.id),
          onTap: () => _showEventDetails(event),
        );
      },
    );
  }

  Widget _buildUpcomingTab() {
    final upcomingOccurrences = _presenter.getAllUpcomingOccurrences();

    if (upcomingOccurrences.isEmpty) {
      return Center(
        child: Text('no_future_dates'.tr()),
      );
    }

    final groupedByMonth = _groupOccurrencesByMonth(upcomingOccurrences);

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: groupedByMonth.length,
      itemBuilder: (context, index) {
        final monthKey = groupedByMonth.keys.elementAt(index);
        return EventOccurrenceMonthSection(
          monthKey: monthKey,
          occurrences: groupedByMonth[monthKey]!,
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_available,
            size: 64,
            color: Theme.of(context).disabledColor,
          ),
          const SizedBox(height: 16),
          Text(
            'no_events'.tr(),
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'add_recurring_event'.tr(),
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Map<String, List<EventOccurrence>> _groupOccurrencesByMonth(
      List<EventOccurrence> occurrences,
      ) {
    final Map<String, List<EventOccurrence>> grouped = {};
    for (var occ in occurrences) {
      final monthKey =
          '${EventCalendarHelpers.getMonthName(occ.date.month)} ${occ.date.year}';
      grouped[monthKey] = grouped[monthKey] ?? [];
      grouped[monthKey]!.add(occ);
    }
    return grouped;
  }

  void _showAddEventDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => EventAddDialog(
        onAdd: ({
          required title,
          required description,
          required startDate,
          required endDate,
          required recurrenceType,
          required interval,
          required weekDays,
          occurrences,
        }) async {
          await _presenter.addEvent(
            title: title,
            description: description,
            startDate: startDate,
            endDate: endDate,
            recurrenceType: recurrenceType,
            interval: interval,
            weekDays: weekDays,
            occurrences: occurrences,
          );
        },
      ),
    );

    if (result == true && mounted) {
      setState(() {});

      final event = _presenter.events.last;
      final occurrences = _presenter.generateOccurrences(event);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'event_created'.tr(namedArgs: {'count': '${occurrences.length}'}),
          ),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _showEventDetails(event) {
    showDialog(
      context: context,
      builder: (context) => EventDetailsDialog(
        event: event,
        occurrences: _presenter.generateOccurrences(event),
        onDelete: () async {
          await _presenter.deleteEvent(event.id);
          setState(() {});
        },
      ),
    );
  }
}