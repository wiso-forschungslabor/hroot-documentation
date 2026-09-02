# First Steps After Installation

Once the initial installation and Web Setup Wizard (`/setup`) are complete, `hroot` is connected to your database and outgoing mail server. To tailor the system to your laboratory's workflows, follow this recommended sequence of configuration steps in the **Site Settings** (`/options`).

---

## Table of Contents

- [Recommended Setup Sequence](#recommended-setup-sequence)
  - [1. System Branding & Regional Settings](#1-system-branding--regional-settings)
  - [2. Participant Pools & Verification Rules](#2-participant-pools--verification-rules)
  - [3. Custom Participant Fields & Master Data](#3-custom-participant-fields--master-data)
  - [4. Legal Policies & Inactivity / Retention Limits](#4-legal-policies--inactivity--retention-limits)
  - [5. Communication Matrix & Message Templates](#5-communication-matrix--message-templates)
  - [6. Laboratory Rooms & Calendars](#6-laboratory-rooms--calendars)
  - [7. Finance, Payment Methods & Cash Registers](#7-finance-payment-methods--cash-registers)
  - [8. External Integrations (Optional)](#8-external-integrations-optional)
  - [9. Staff Accounts & Permissions](#9-staff-accounts--permissions)
- [Next Steps](#next-steps)

---

## Recommended Setup Sequence

### 1. System Branding & Regional Settings
* **Location in UI**: **Site Settings $\rightarrow$ Design & Layout** (`/admin/options/design`) and **System & Plugins** (`/admin/options/language_settings`).
* **What to do**:
  * Verify system health under **System Check** (`/admin/options/check`).
  * Set your primary default language (e.g., German, English), active locales, and local timezone.
  * Upload your laboratory logo, configure brand colors, and customize the public navigation layout.
  * Toggle global feature switches (e.g., enable Admin 2-Factor Authentication, Staff Tasks, or Usability Status).
* **Detailed Documentation**: See **[Basic configuration](Basic-configuration.md)**, **[Language configuration and timezone](Language-configuration-and-timezone.md)**, and **[Settings](Settings.md)**.

---

### 2. Participant Pools & Verification Rules
* **Location in UI**: **Site Settings $\rightarrow$ Participant Pools** (`/admin/options/pools`).
* **What to do**:
  * Set up your target participant databases (e.g., a *Student Pool* requiring enrollment proof vs. a *Public / Citizen Pool* vs. an *Online Survey Pool*).
  * Configure verification modes (None, Shibboleth SSO, or Document Upload) and rules for student status expiry transitions.
* **Detailed Documentation**: See **[Pools Management](Pools-Management.md)**.

---

### 3. Custom Participant Fields & Master Data
* **Location in UI**: **Site Settings $\rightarrow$ Custom Fields** (`/admin/options/custom_fields`) and **Courses of Study** (`/admin/options/study_programs`).
* **What to do**:
  * Define lab-specific profile questions (e.g., field of study, handedness, vision impairments, smoking habits, or student ID numbers).
  * Configure field types (text, dropdown, date, checkbox), conditional display logic, and validation rules.
  * Add the list of academic majors and study fields for participant self-registration.
* **Detailed Documentation**: See **[Custom field definitions](Custom-field-definitions.md)** and **[Settings](Settings.md)**.

---

### 4. Legal Policies & Inactivity / Retention Limits
* **Location in UI**: **Site Settings $\rightarrow$ Privacy & Public Texts** (`/admin/options/privacy`, `/admin/options/public_texts`) and **Plugins / Features** (`/admin/options/features`).
* **What to do**:
  * Store localized Privacy Policies (*Datenschutzerklärung*) and Terms & Conditions (*AGB*).
  * Set **Inactivity Warning Limits** (e.g., 1st warning after 12 months) and **Grace Period Days** (reaction interval before automatic account blocking/anonymization).
  * Configure email domain restrictions and registration blacklists under **Blacklist** (`/admin/options/blacklist`).
* **Detailed Documentation**: See **[Deleting users](Deleting-users.md)** and **[Settings](Settings.md)**.

---

### 5. Communication Matrix & Message Templates
* **Location in UI**: **Site Settings $\rightarrow$ Communication Matrix** (`/admin/options/communication`) and **Participant Texts** (`/admin/options/emails_participants`).
* **What to do**:
  * Activate the notification channels (Email, SMS, Push) you wish to use for each event.
  * Customize system-wide email templates (experiment invitations, session confirmations, reminders, no-show warnings).
  * Enable multi-language email templates if your lab conducts sessions in multiple languages.
* **Detailed Documentation**: See **[Sending messages](Sending-messages.md)**, **[Invitation emails](Invitation-emails.md)**, **[Confirmation emails](Confirmation-emails.md)**, and **[Session reminder emails](Session-reminder-emails.md)**.

---

### 6. Laboratory Rooms & Calendars
* **Location in UI**: **Site Settings $\rightarrow$ Lab Locations** (`/admin/options/locations`) and **Appointment Emails (ICS)** (`/admin/options/ics_templates`).
* **What to do**:
  * Add physical lab rooms, buildings, and seat capacities for on-site experiments.
  * Customize ICS calendar invitation templates for calendar sync.
* **Detailed Documentation**: See **[Calendar](Calendar.md)** and **[Managing Experiments](Managing-Experiments.md)**.

---

### 7. Finance, Payment Methods & Cash Registers
* **Location in UI**: **Site Settings $\rightarrow$ Payment Types** (`/admin/options/payment_types`) and **Finance** (`/admin/options/finance_settings`).
* **What to do**:
  * Configure payment types (cash, bank transfer, course credits / *VP-Stunden*, or online vouchers).
  * If paying cash on-site: enable cash advances and set up physical cash drawers (*Kassenbuch* / denominations).
  * If paying via wire transfer: enable banking data collection (IBAN/BIC) and set minimum payout thresholds.
* **Detailed Documentation**: See **[Finance](Finance.md)**.

---

### 8. External Integrations (Optional)
* **Location in UI**: **Site Settings $\rightarrow$ Shibboleth Integration** (`/admin/options/shibboleth`) and **Kimai Synchronization** (`/admin/options/kimai`).
* **What to do**:
  * **Shibboleth SSO**: Enable university Single Sign-On for automated student authentication and pool assignment.
  * **Kimai**: Connect to your Kimai instance to synchronize lab helper hours, project budgets, and session expense reports.
  * **SMS / Push**: Configure SMS gateways (`sms-gate.app` or email-to-SMS) and WebPush VAPID keys for mobile notifications.
* **Detailed Documentation**: See **[Shibboleth Integration](Shibboleth-Integration.md)**, **[Kimai Integration](Kimai-Integration.md)**, and **[SMS and Push Notifications](SMS-and-Push-Notifications.md)**.

---

### 9. Staff Accounts, Roles & Permissions
* **Location in UI**: **Users** (`/admin/users`) and **Site Settings $\rightarrow$ Experimenter Settings** (`/admin/options/staff_settings`).
* **What to do**:
  * Create accounts for your laboratory team and assign them to the appropriate roles:
    * **Users / Participants**: Self-registered experimental subjects.
    * **Experimenters**: Researchers conducting sessions, inviting subjects, taking attendance, and filling lab reports.
    * **Administrators**: Lab managers managing pools, experiments, locations, email templates, custom fields, and task assignments.
    * **Banking-Administrators**: Holds all administrator capabilities plus exclusive access to sensitive financial data (viewing/editing participant `IBAN`/`BIC`, generating SEPA transfer files), managing the Kimai integration (`/options/kimai`), and full team-wide task & availability scheduling (editing all staff members' hours and reassigning/deleting any task).
  * Define default experimenter access permissions (e.g., editing sessions, viewing participant lists, contacting participants) and standard procedure templates / checklists.
* **Detailed Documentation**: See **[Roles: Users, Admins, Experimenters, Banking-Administrators](Roles:-Users,-Admins,-Experimenters.md)** and **[Staff Management](Staff-Management.md)**.

---

## Next Steps

With the basic configuration complete, you can begin regular lab operations:
* Learn how to manage studies in **[Managing Experiments](Managing-Experiments.md)**.
* Discover how to recruit subjects in **[Inviting participants](Inviting-participants.md)** and **[Assign participants from the pool](Assign-participants-from-the-pool.md)**.
* Set up check-in procedures in **[QR Code Admission](QR-Code-Admission.md)** or **[Online Waiting Room](Online-Waiting-Room.md)**.
