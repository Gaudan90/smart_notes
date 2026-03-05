# Privacy Policy

**Smart Notes**
**Effective Date:** March 5, 2026
**Last Updated:** March 5, 2026

---

## Introduction

Smart Notes ("the App") is a productivity application developed by Gaudan90 ("the Developer"). This Privacy Policy explains how the App handles your information.

**In short: Smart Notes does not collect, transmit, or share any of your personal data. Everything stays on your device.**

---

## Data Collection

### What We Do NOT Collect

Smart Notes does **not** collect, store, or transmit any of the following:

- Personal identification information (name, email, phone number)
- Location data
- Device identifiers or advertising IDs
- Usage analytics or telemetry
- Browsing history or search queries
- Contacts, photos, or media
- Financial or payment information

### What Is Stored Locally

The App stores the following data **exclusively on your device** to provide its functionality:

| Data | Storage Method | Purpose |
|------|---------------|---------|
| To-do items, habits, shopping lists, expenses, countdowns, reminders, events, meal plans, tasks | SharedPreferences | Feature functionality |
| Theme preferences (colors, dark mode, color-blind mode) | SharedPreferences | UI customization |
| Password history | SharedPreferences | Password generator history |
| PIN hash and security question | Flutter Secure Storage (encrypted) | Password history protection |
| Onboarding completion flag | SharedPreferences | First-launch experience |
| Language preference | SharedPreferences | Localization |

**Important:** The App never stores your actual PIN. Only a one-way SHA-256 hash of the PIN is stored, making it impossible to recover the original PIN from the stored data.

---

## Data Sharing

Smart Notes does **not** share your data with any third party. Specifically:

- No data is sent to the Developer's servers (there are none)
- No data is sent to analytics services
- No data is sent to advertising networks
- No data is sent to social media platforms
- No data is shared with any other application

---

## Third-Party Services

Smart Notes does **not** integrate any third-party services that collect data. The App does not use:

- Google Analytics or Firebase Analytics
- Crash reporting services (Crashlytics, Sentry, etc.)
- Advertising SDKs
- Social login providers
- Cloud storage or sync services

---

## Data Export

The App allows you to export data in the following ways:

- **Password History**: Export as PDF or TXT file via the native share sheet or save directly to a location on your device. This action is protected by PIN verification.
- **Shopping Lists**: Export as TXT file.

Exported files are created locally on your device. The Developer has no access to these files.

---

## Permissions

Smart Notes may request the following permissions:

| Permission | Purpose | Required |
|-----------|---------|----------|
| Notifications | Send reminders and planner alerts | Optional |
| Storage (Android < 10) | Save exported files to device | Optional |

You can deny or revoke these permissions at any time through your device's Settings. The App will continue to function with reduced functionality.

---

## Data Retention

All data is stored locally on your device for as long as the App is installed. When you:

- **Uninstall the App**: All data is permanently deleted by the operating system
- **Clear App Data**: All data is permanently deleted
- **Delete individual items**: Data is removed from local storage immediately

The Developer has no ability to access, retain, or recover your data.

---

## Children's Privacy

Smart Notes does not knowingly collect any personal information from children under 13 (or the applicable age in your jurisdiction). Since the App does not collect any personal data from any user, it is safe for users of all ages.

---

## Security

The App employs the following security measures:

- **PIN Protection**: Password history access requires an 8-digit PIN
- **SHA-256 Hashing**: PINs are stored as irreversible cryptographic hashes
- **Encrypted Storage**: Sensitive data (PIN hash, security question) is stored using Flutter Secure Storage, which uses Android Keystore encryption
- **No Network Access**: The App does not make any network requests, eliminating remote attack vectors

---

## Changes to This Privacy Policy

The Developer may update this Privacy Policy from time to time. Changes will be reflected in the "Last Updated" date at the top of this document. Continued use of the App after changes constitutes acceptance of the updated Privacy Policy.

---

## Contact

If you have any questions or concerns about this Privacy Policy, please contact:

- **GitHub Issues**: [https://github.com/yourusername/smart_notes/issues](https://github.com/yourusername/smart_notes/issues)

---

## Consent

By using Smart Notes, you consent to this Privacy Policy. Since the App does not collect any personal data, your use of the App does not result in any data processing.

---

*This Privacy Policy was last updated on March 5, 2026.*
