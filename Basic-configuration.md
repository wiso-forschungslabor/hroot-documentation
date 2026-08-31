Starting with version 4.0, `hroot` splits configuration settings into three distinct layers to make deployments cleaner, more secure, and easier to manage without server restarts:

1. **Infrastructure & Integration Settings (.env file)**: Handled via environment variables for secrets, database credentials, SMTP setup, and integrations (e.g., Kimai, Shibboleth, SMS Gateways).
2. **Operational & Application Settings (Web UI / Site Settings)**: Handled directly in the administrator interface (e.g., custom profile fields, participant pools, templates, feature toggles).
3. **Advanced Rails Framework Settings (`config/environments/`)**: System-level Ruby configurations (e.g., class caching, logging behavior). Administrators rarely need to touch these files.

---

## 1. Infrastructure & Integration Settings (`.env`)

Sensitive credentials and server integrations must be configured in the `.env` file located at the root of your `hroot` installation directory.

* **Email Server Configuration**: SMTP host, port, credentials, and default sender addresses are now defined in `.env` using variables such as `SMTP_ADDRESS`, `SMTP_PORT`, and `SENDER_EMAIL`.
* **Database Connection**: Database host, port, username, and password are configured using `DATABASE_HOST`, `DATABASE_USERNAME`, etc.
* **Integrations & Security**: APIs, secrets, and switches for hCaptcha, Shibboleth, Kimai, and SMS notifications are defined here.
* **Crash & Exception Notifications**: Configured using `EXCEPTION_RECIPIENTS` and `LOG_EMAIL`.

For a full list of all environment variables and how to configure them, see the [Environment Configuration](Environment-Configuration.md) page.

---

## 2. Operational & Application Settings (Web UI)

Operational rules and settings are managed dynamically through the administration web interface. To access these settings, log in as an administrator and go to **Site Settings** (or navigate directly to `/options`). 

Many settings that historically required editing Ruby code are now fully configurable in the UI:

* **Email Templates & Participant Texts**: Standard email templates (e.g., invitations, session reminders, registration confirmations) are customized dynamically in the UI under **Participant Texts** (formerly in config files).
* **Restricting Sign-up Emails**: Restricting user registrations to specific email domains (e.g., university domains) is now configured via the UI under **Blacklist** (formerly `config.email_restriction` regex).
* **Participant Profile Changes**: The option to restrict whether participants can change optional profile data after registration is now toggled via the UI under **Plugins / Features** -> *Allow optional data changes* (formerly `config.users_can_edit_optional_data`).
* **Feature Toggles**: Major application features (like Cash Registers, Shift Plans, and Matriculation Uploads) are enabled/disabled via the UI under **Plugins / Features** (formerly requiring code adjustments).
* **File Uploads**: Attachment storage is now managed automatically using Rails Active Storage (defined in `config/storage.yml`), removing the need to configure manual `config.upload_dir` paths in environment files.

For a detailed walkthrough of all options available in the administration panel, see the [Settings](Settings.md) page.

---

## 3. Advanced Rails Configuration (`config/environments/*.rb`)

The configuration files under `config/environments/` (e.g., `development.rb`, `production.rb`) are standard Rails files and define low-level framework behavior. In almost all standard installations, **you should leave these settings at their default values.**

Below is an overview of the key Rails settings defined in these files:

### Class Caching
Controls whether Ruby classes are cached in memory or reloaded on every HTTP request.
* **Development (`development.rb`)**: Class caching is disabled so changes to your code take effect immediately.
  ```ruby
  config.cache_classes = false
  ```
* **Production (`production.rb`)**: Class caching is enabled for optimal performance.
  ```ruby
  config.cache_classes = true
  ```

### Asset Pipeline
Configures how Javascript, CSS, and images are compiled, compressed, and served.
* **Development**: Assets are served uncompressed and debugging information is injected.
  ```ruby
  config.assets.debug = true
  ```
* **Production**: Assets are precompiled and compressed.

### Logging Configuration
Defines the verbosity level of system logs. Can be set in `.env` via `RAILS_LOG_LEVEL` or directly in `config/environments/production.rb`:
```ruby
config.log_level = ENV.fetch('RAILS_LOG_LEVEL', 'info').to_sym
```
Possible values include `:debug`, `:info`, `:warn`, `:error`, and `:fatal`.

---

## 4. Crash & Exception Notifications (`ExceptionNotification`)

`hroot` sends automated email alerts to administrators whenever unhandled runtime exceptions occur.

### Recipient Configuration
Configure recipient addresses in `.env` (comma-separated for multiple recipients):
```bash
EXCEPTION_RECIPIENTS=admin@example.com,dev-team@example.com
SENDER_EMAIL=experiments@example.com
```

### Filtering & Ignoring Exceptions
To suppress notifications for specific errors (e.g., crawler noise, expired sessions, or known non-critical exceptions), edit `config/environments/production.rb` where `ExceptionNotification::Rack` is configured:

```ruby
Hroot::Application.config.middleware.use ExceptionNotification::Rack,
  email: {
    email_prefix: '[hroot 4 exceptions] ',
    sender_address: %("#{ENV.fetch('SENDER_EMAIL', 'sender@example.com')}"),
    exception_recipients: ENV.fetch('EXCEPTION_RECIPIENTS', 'admin@example.com').split(',')
  },
  # 1. Ignore specific exception classes (e.g. CSRF token expiry, bad requests)
  ignore_exceptions: ExceptionNotifier.default_ignore_exceptions + [
    'ActionController::InvalidAuthenticityToken',
    'ActionController::BadRequest',
    'ActionDispatch::Http::MimeNegotiation::InvalidType'
  ],
  # 2. Ignore exceptions generated by search engine crawlers and bots
  ignore_crawlers: %w{Googlebot bingbot Baiduspider YandexBot},
  # 3. Dynamic custom filter logic (lambda)
  ignore_if: ->(env, exception) {
    # Example: Ignore errors containing a specific message or for specific paths
    exception.message =~ /HarmlessBackgroundJobTimeout/ ||
      env['REQUEST_URI'] =~ %r{/health_check}
  }
```

