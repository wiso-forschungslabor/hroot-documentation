This page describes all available settings and configurations in `hroot` for both administrators (via the web interface under the **Site Settings** menu) and developers/sysadmins (via configuration files).

> [!TIP]
> Setting up a fresh installation? See the **[First steps after installation](First-steps-after-installation.md)** checklist for the recommended step-by-step configuration order.

*   [1. Where to Configure: UI vs. Config Files](#1-where-to-configure-ui-vs-config-files)
*   [2. UI-Based Configuration Pages](#2-ui-based-configuration-pages)
    *   [2.1. Participants & Master Data](#21-participants--master-data)
    *   [2.2. Experiment](#22-experiment)
    *   [2.3. Staff & Permissions](#23-staff--permissions)
    *   [2.4. Finance](#24-finance)
    *   [2.5. Communication & Texts](#25-communication--texts)
    *   [2.6. System & Plugins](#26-system--plugins)
*   [3. Server Configuration: .env vs. production.rb](#3-server-configuration-env-vs-productionrb)
    *   [3.1. Environment Variables (.env file)](#31-environment-variables-env-file)
    *   [3.2. Ruby Environment Configuration (production.rb)](#32-ruby-environment-configuration-productionrb)

---

## 1. Where to Configure: UI vs. Config Files

`hroot` splits settings into two categories:
*   **System/Infrastructure Configs:** Located in environment configuration files (e.g., `config/environments/production.rb` or `.env` file). These require a server restart to take effect.
*   **Operational & Site Settings:** Configured directly via the web UI under **Site Settings** in the admin menu. These take effect immediately.

---

## 2. UI-Based Configuration Pages

Administrators with `admin` or `banking_admin` roles can access the settings tabs at `/options` (or via the **Site Settings** link in the side navigation menu). The options are grouped into six main sections:

### 2.1. Participants & Master Data (*Teilnehmer & Stammdaten*)

This section contains settings for participant pool segmentation, profile parameters, duplicate detection, surveys, registration rules, and blacklist settings.

*   **Participant Pools** (*Teilnehmerpools*):
    Allows segmenting subjects into distinct databases (e.g., student pool, general public pool, online survey pool). Detailed settings can be found in the [Pools Management](Pools-Management.md) page.
*   **Custom Fields (User)** (*Benutzerdefinierte Felder*):
    Extends the participant profile database with custom, lab-specific questions (e.g., handedness, native language, vision impairments, or smoking habits) using text inputs, checkboxes, text areas, or dropdown lists. Custom fields are automatically integrated into the recruitment filter dashboard.
*   **Duplicate Users** (*Doppelte Benutzer*):
    Configures automated duplicate detection rules (e.g. matching identical names, birthday combinations, or IBANs) to prevent duplicate registrations and flag multi-account users. See [Finding duplicate users](Finding-duplicate-users.md) for full details.
*   **Profile & Screening Surveys** (*Profil- & Screening-Umfragen*):
    Defines administrative groups of survey questions associated with specific pools. These are seamlessly integrated into user accounts, enrollment flows, and completion views. Tokens and resolved redirect URLs can be reviewed directly in enrollment/completion reports.
*   **Courses of Study** (*Studiengänge*):
    Maintains the list of academic majors (e.g., Economics, Psychology, Medicine) appearing in a dropdown during participant self-registration. They are critical for filtering target demographics during recruitment.
*   **Blacklist** (*Blacklist*):
    Defines spam prevention and security rules, including IP filters, email domain bans, and manual user account blocks.

### 2.2. Experiment (*Experiment*)

This section governs the physical laboratory configuration, procedural flows, templates, and reporting structures for conducting experiments.

*   **Lab Locations** (*Labor-Räume*):
    Manages physical laboratories (**Locations**) and addresses (**Buildings**) where sessions are conducted. Short names are used in calendars, and building details are injected into email placeholders like `#location_building`.
*   **Experiment Settings** (*Experimenteinstellungen*):
    Sets global rules and defaults specifically related to experiment conduction, recruitment policies, and participant status.
*   **Project Steps** (*Projektschritte & Vorlagen*):
    If Staff Tasks are enabled, allows defining project templates grouping task buckets and milestones together. Selecting a template automatically instantiates its timeline checklists when starting a new experiment project.
*   **Procedure Templates** (*Ablaufvorlagen*):
    Create and manage workflow templates containing step-by-step checklists for experimental procedures that can be attached to experiments.
*   **Exports & Reports** (*Exporte & Berichte*):
    Allows creating customized participant and session data export structures (CSV/Excel), letting administrators choose which columns (e.g. Email, IBAN, Custom Fields) should be included when downloading data files.
*   **Appointment Emails (ICS)** (*Termin-Mails (ICS)*):
    Define templates for the ICS calendar feeds. Customize the title, location, and description formats using placeholders like `#experiment_name`, `#session_time`, or `#assigned_helpers`.
*   **Lab Report Template** (*Lab Report Template*):
    Allows customizing the structure and layout of the finalized session reports generated by researchers after concluding an experiment.

### 2.3. Staff & Permissions (*Personal & Rechte*)

Configure staff roles, global permissions, staff-facing texts, and scheduling/availability options.

*   **Experimenter Settings** (*Experimentatoreinstellungen*):
    The root settings page. Houses default access levels for newly created experimenter accounts (e.g., editing sessions, viewing participant lists, downloading reports, or contacting participants) which can be overridden per experiment. Also displays the health status of system background runners (cron jobs: invitation mailing, mail queue, session reminders).
*   **Staff & Admin Emails** (*Mitarbeiter- & Admin-Texte*):
    Defines default system-wide boilerplate email templates for communicating with research helpers, coordinators, and administrators.
*   **Shift Plan** (*Dienstplan*):
    If Staff Tasks are enabled, configures templates and default mail subjects for dispatching shift schedules to the lab staff.

### 2.4. Finance (*Finanzen*)

This section configures currencies, payment options, cash drawers, and syncing endpoints with accounting systems.

*   **Finance** (*Finanzeinstellungen*):
    Defines switches for cash registers, advances/budgets, banking collection (BIC/Bank name), baseline check dates, and petty cash denominations (counts for specific bills, coins, and rolls).
*   **Payment Types** (*Bezahlarten*):
    Configures compensation methods (e.g., standard payout or credit points), currency symbols, units, default goals, and connects payment types to automated voucher pools (e.g., Amazon vouchers).
*   **Payout Requests** (*Auszahlungsanträge*):
    A ledger listing all participant payout requests submitted from their dashboards. Admins can approve, reject, or mark requests as paid, and export bulk files.
*   **Kimai Synchronization** (*Kimai-Synchronisation*):
    If Kimai Integration is enabled, configures host credentials and connection variables for the external time-tracking system. Detailed routing can be found in the [Kimai Integration](Kimai-Integration.md) page.

### 2.5. Communication & Texts (*Kommunikation & Texte*)

Manage email templates, terms of use, privacy policies, languages, and translation overrides.

*   **Communication Matrix** (*Kommunikationsmatrix*):
    Manages which automated notifications (Email, SMS, Web Push) are active for each transaction type or system event.
*   **Participant Texts** (*Teilnehmer-Texte*):
    Maintains system-wide boilerplate templates (e.g., invitation, confirmation, reminder, waiting list promotion) that are copied into new experiments on startup.
*   **Privacy agreements** (*Datenschutzerklärung*):
    Configures the legal privacy statements localized in German and English, linked in the registration form and public footer.
*   **Translation** (*Übersetzungen*):
    Manages interface localization dynamically. Supports a live-edit mode (pencil icons in the UI) to edit translation keys directly as database overrides or write them to YAML files.
*   **Texts** (*Öffentliche Texte & AGB*):
    Stores markdown and HTML templates for public and user-facing landing pages, such as Terms & Conditions, the welcome text, or the start page.

### 2.6. System & Plugins (*System & Plugins*)

Exposes low-level health checks, global module switches, design theming, and layout builders.

*   **System Check** (*System-Check*):
    Validates directory permissions, database migrations, mail delivery status, and exposes the global security Audit Trail (powered by `paper_trail`) listing all model additions, updates, and deletes by actor.
*   **Plugins / Features** (*Plugins / Features*):
    Global switches to toggle optional modules on or off system-wide:
    - *Staff Tasks (Aufgabenverwaltung)*: Activates task templates, project steps, and checklists.
    - *Incoming Emails (Posteingang)*: Enables inbox tracking and IMAP processing.
    - *Staff Availabilities (Mitarbeiter-Verfügbarkeiten)*: Activates internal shift planning, task assignments, and availability polling.
    - *Usability Status (Verwendbarkeits-Status V)*: Enables marking participant data scientific usability.
    - *Admin Two-Factor Authentication (2FA)*: Enables administrative multi-factor login. All users with `admin` and `banking_admin` roles must set up a TOTP authenticator (Google Authenticator, Bitwarden).
    - *Site Configuration & Inactivity Limits*: Configures optional profile data editing, footer privacy link, multilingual email templates, and automated participant inactivity thresholds (months until 1st warning, grace period days between warnings before account blocking; see [Deleting users](Deleting-users.md)).
    
    *Note: Disabling any of these switches automatically hides their associated navigation links, tabs, and widgets.*
*   **Dashboard Layout** (*Dashboard-Layout*):
    Customizes the layout grid of widgets on the administrative home dashboard for different user roles (Admins, Users, Experimenters) or individual personal views.
*   **Design & Layout** (*Design & Layout*):
    Allows customizing the look and feel of hroot to match institutional corporate design (typography, font families, font sizes, heading styles, brand colors, logo uploads, and Shibboleth button styling).

---

## 3. Server Configuration: .env vs. production.rb

`hroot` uses the `dotenv` pattern. Almost all deployment-specific and sensitive variables are configured in a local `.env` file (copied from `.env.example` during installation). These values are then parsed and mapped inside `config/environments/production.rb`.

### 3.1. Environment Variables (.env file)

Always store secrets, paths, domains, and specific connection configurations in `.env`. The file is split into the following categories:

#### 3.1.1. Infrastructure & Domain Settings
*   `RAILS_ENV`: Set to `production` for production environments.
*   `APP_PORT`: The internal port the application listens on (default: `3000`).
*   `APP_DOMAIN`: The domain name without protocol (e.g. `hroot.example.com`).
*   `APP_SUBPATH`: Optional, if running hroot under a sub-path (e.g., `/hroot`).
*   `APP_PROTOCOL`: Protocol used, usually `https`.
*   `PROXY_HTTP_PORT` / `PROXY_HTTPS_PORT`: Ports exposed by the Nginx proxy container.

#### 3.1.2. E-Mail & SMTP Configuration
*   `CONTACT_EMAIL`: The support address shown to participants.
*   `SENDER_EMAIL`: The outbound sender address (From header).
*   `LOG_EMAIL` / `EXCEPTION_RECIPIENTS`: Addresses where admin logs and system error reports are sent.
*   `MAIL_DELIVERY_METHOD`: Delivery protocol (`smtp`, `sendmail`, or `test`).
*   `MAIL_PERFORM_DELIVERIES`: Set to `true` to enable outbound email delivery.
*   `SMTP_ADDRESS` / `SMTP_PORT` / `SMTP_DOMAIN` / `SMTP_USER_NAME` / `SMTP_PASSWORD`: Standard SMTP credentials if `MAIL_DELIVERY_METHOD=smtp` is selected.
*   `SMTP_AUTHENTICATION` / `SMTP_ENABLE_STARTTLS_AUTO`: Security policies for the SMTP server.
*   `INTERCEPTOR_EMAIL`: In non-production environments, all emails are redirected to this address to avoid sending real messages to users during testing.

#### 3.1.3. Secrets & Encryption Keys
*   `RAILS_MASTER_KEY`: Decrypts `config/credentials.yml.enc`.
*   `SECRET_KEY_BASE`: Used for signing and encrypting session cookies.
*   `VAPID_PUBLIC_KEY` / `VAPID_PRIVATE_KEY`: Keys used to sign Web Push notifications (generate via `bundle exec rails runner "puts WebPush.generate_key"`).

#### 3.1.4. Database Connection
*   `DATABASE_HOST`: Set to `db` when using Docker, or `localhost` / remote IP for bare-metal servers.
*   `DATABASE_USERNAME` / `DATABASE_PASSWORD`: Credentials for the MySQL database.
*   `DATABASE_NAME` / `PRODUCTION_DATABASE_NAME`: Database names (defaults to `hroot_production`).

#### 3.1.5. hCaptcha Spam Protection
*   `HCAPTCHA_ENABLED`: Set to `true` to enable captcha checks on registration.
*   `HCAPTCHA_SITE_KEY` / `HCAPTCHA_SECRET_KEY`: Keys retrieved from hcaptcha.com.

#### 3.1.6. Shibboleth SSO Integration
*   `SHIBBOLETH_ENABLED`: Enable Single Sign-On.
*   `SHIBBOLETH_USE_DISCOVERY_SERVICE`: Toggle discovery service usage.
*   `SHIBBOLETH_SP_ENTITY_ID` / `SHIBBOLETH_IDP_ENTITY_ID` / `SHIBBOLETH_IDP_SSO_TARGET_URL`: SAML Entity IDs and endpoint URLs.
*   `SHIBBOLETH_CERT_PATH` / `SHIBBOLETH_KEY_PATH`: Absolute paths to the Service Provider SSL certificates.
*   `OMNIAUTH_FULL_HOST`: OmniAuth callback target URL.

#### 3.1.7. Kimai Time-Tracking Integration
*   `KIMAI_BASE_URL`: URL to your Kimai instance.
*   `KIMAI_API_TOKEN`: The API access token for authentication.

#### 3.1.8. SMS Gateway Configuration
*   `SMS_FEATURE_ENABLED`: Enable SMS notifications for sessions.
*   `SMS_SEND_MODE`: Mode of delivery (`api` for direct gateway requests, or `email` for email-to-SMS).
*   `SMS_GATEWAY_API_URL` / `SMS_GATEWAY_API_USERNAME` / `SMS_GATEWAY_API_PASSWORD`: Direct API settings (usually for `sms-gate.app`).
*   `SMS_GATEWAY_EMAIL` / `SMS_EMAIL_SUBJECT_PREFIX`: Gateway email target and prefix settings.

---

### 3.2. Ruby Environment Configuration (`config/environments/production.rb`)

While the `.env` file provides the variables, the Ruby configuration file defines *how* Rails loads them, handles asset compilation, caching, and sets server-wide rules that do not change between server restarts.

The following configurations remain in `production.rb`:

1.  **I18n Locales List & Default Locale:**
    *   Specifies which languages are compiled and loaded, and sets the system default language (e.g., German):
        ```ruby
        config.locales = [:en, :de, :es]
        config.locale_names = { en: 'English (en)', de: 'Deutsch (de)', es: 'Español (es)' }
        config.i18n.default_locale = :de
        ```
2.  **Custom Field Definitions (`config.customfields`):**
    *   Defines the structure of participant registration forms (e.g., gender selections, birthdate dates, matriculation number, study fields, hand preference, native languages) and maps options to indices in the database.
3.  **Active Record & Caching Controls:**
    *   Standard Rails behavior optimizations for production (e.g., `config.cache_classes = true`, `config.eager_load = true`, `config.assets.js_compressor = :terser`).
4.  **Middleware Registrations:**
    *   Sets up system exception monitoring frameworks (e.g., `ExceptionNotification::Rack` wrapping error reporting recipients).
5.  **Default URL Options:**
    *   Directs how Rails constructs full URL helpers dynamically in background processes (like links in emails). Code maps the `.env` settings into:
        ```ruby
        Rails.application.routes.default_url_options[:host] = domain
        ```
