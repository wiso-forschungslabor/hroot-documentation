
Starting with version 4.0, `hroot` uses a unified environment-based configuration system. All site configurations, database settings, secrets, and third-party integrations are defined in a `.env` file at the root of the project.

A template is provided as [`.env.example`](.env.example). You should copy this file to `.env` and fill in the values for your installation.

---

##  Infrastructure & App Settings

| Variable | Default / Example | Description |
| :--- | :--- | :--- |
| `RAILS_ENV` | `production` | Set to `production` for live deployments, `development` for local testing or `staging` for the production experiment, but without actual mails/SMS being sent out to participants.  |
| `APP_PORT` | `3000` | The port the internal Rails server binds to. |
| `APP_DOMAIN` | `localhost` | The hostname of your hroot instance (e.g., `hroot.example.com`). **Do not include http:// or trailing slashes.** |
| `APP_SUBPATH` | *(empty)* | If hroot is served from a subdirectory (e.g., `/hroot`), enter it here. |
| `APP_PROTOCOL` | `https` | Set to `https` (highly recommended for production) or `http`. |
| `RAILS_LOG_LEVEL` | `info` | Logging verbosity: `debug`, `info`, `warn`, `error`, or `fatal`. |
| `PROXY_HTTP_PORT` | `80` | External HTTP port for Nginx proxy. |
| `PROXY_HTTPS_PORT` | `443` | External HTTPS port for Nginx proxy. |
| `APP_LOGO_PATH` | `mainlogo.png` | Custom logo path. Can be an asset filename, a file in `/public/`, or a full URL. |

---

##  Email & SMTP Settings

`hroot` needs outbound mail working to send confirmations, reminders, and staff updates.

| Variable | Default / Example | Description |
| :--- | :--- | :--- |
| `CONTACT_EMAIL` | `experiments@example.com` | Support and contact email address shown to participants. |
| `SENDER_EMAIL` | `experiments@example.com` | Outbound sender address (`From:` header). |
| `LOG_EMAIL` | `admin@example.com` | Email address where system alerts are sent. |
| `EXCEPTION_RECIPIENTS`| `admin@example.com` | Comma-separated email addresses that receive crash logs. |
| `MAIL_DELIVERY_METHOD`| `sendmail` | Outbound mailer backend. Options: `sendmail`, `smtp`, `test`. |
| `MAIL_PERFORM_DELIVERIES`| `true` | Set to `false` to disable outbound emails globally. |
| `SMTP_ADDRESS` | `localhost` | SMTP host (only used if `MAIL_DELIVERY_METHOD=smtp`). |
| `SMTP_PORT` | `25` | SMTP port. |
| `SMTP_DOMAIN` | *(empty)* | HELO/EHLO domain for SMTP. |
| `SMTP_USER_NAME` | *(empty)* | SMTP login username. |
| `SMTP_PASSWORD` | *(empty)* | SMTP login password. |
| `SMTP_AUTHENTICATION` | `plain` | SMTP authentication mode (e.g. `plain`, `login`). |
| `SMTP_ENABLE_STARTTLS_AUTO`| `true` | Automatically switch to TLS encryption if supported. |
| `INTERCEPTOR_EMAIL` | `admin@example.com` | Intercepts and redirects all emails to this address if `RAILS_ENV != production`. |

---

## Database Credentials

`hroot` requires MySQL (or MariaDB). In production, an external database server is recommended.

| Variable | Default / Example | Description |
| :--- | :--- | :--- |
| `DATABASE_HOST` | `db` (or `localhost`) | Database server hostname/IP. |
| `DATABASE_USERNAME` | `your-db-username` | Database user with permissions to migrate and read/write. |
| `DATABASE_PASSWORD` | `your-db-password` | Database password. |
| `DB_PORT` | `3306` | Port to access MySQL. |
| `DATABASE_NAME` | `hroot_production` | Production database name. |
| `DEVELOPMENT_DATABASE_NAME`| `hroot_development` | Development database name (optional override). |
| `TEST_DATABASE_NAME` | `hroot_test` | Test database name (optional override). |

---

## Secrets, Keys & Security Best Practices


Keep all secret keys, passwords, and private certificates confidential.

| Variable | Default / Example | Description |
| :--- | :--- | :--- |
| **`SECRET_KEY_BASE`** | *(64-char hex)* | **Required:** Master cryptographic secret used by Rails to sign and AES-encrypt HTTP session cookies (`_hroot_session`) and verify CSRF protection tokens. Generate with `bundle exec rails secret` or `openssl rand -hex 64`. |
| `RAILS_MASTER_KEY` | *(32-char hex)* | *Optional:* Key used to decrypt `config/credentials.yml.enc`. Since `hroot 4.0` manages all configuration via `.env`, this key is not strictly required for regular runtime unless you choose to use encrypted Rails credentials. |
| `VAPID_PUBLIC_KEY` | *(base64 key)* | Public key for Web Push notifications. |
| `VAPID_PRIVATE_KEY` | *(base64 key)* | Private key for Web Push notifications. |

---

### Security Best Practices for `.env` & Certificates

Storing credentials in the environment follows the [Twelve-Factor App](https://12factor.net/config) standard. To maintain maximum security on your production server, follow these rules:

#### 1. Restrict File Permissions on the Server
Ensure that only the operating system user running the application (or root) can read the `.env` file:
```bash
chmod 600 /path/to/hroot/.env
```

#### 2. Protecting Private Certificates & Keys
For services requiring cryptographic certificates (such as Shibboleth SAML SP private keys):
* Store `.pem` files in a dedicated, secured folder (e.g., `certs/`).
* Set restrictive permissions:
  ```bash
  chmod 600 /path/to/hroot/certs/sp-key.pem
  ```
* Reference the path in `.env` (e.g., `SHIBBOLETH_KEY_PATH=certs/sp-key.pem`).

#### 3. Never Commit `.env` to Version Control
* The `.env` file contains production secrets and is ignored by Git (`.gitignore`).
* Only the template [`.env.example`](.env.example) is committed to the repository (containing placeholder values).

#### 4. Web Server Access Protection
Ensure your web server (NGINX / Apache) blocks public HTTP requests to hidden dotfiles (`.*`) such as `.env` and `.git`. (In Docker setups, the `.env` file is outside the public web root and isolated automatically).


---

##  Security & Bot Protection (hCaptcha)

Prevent spam registrations on public sign-up pages using hCaptcha.

| Variable | Default / Example | Description |
| :--- | :--- | :--- |
| `HCAPTCHA_ENABLED` | `true` | Enables or disables hCaptcha verification. |
| `HCAPTCHA_SITE_KEY` | `YOUR_SITE_KEY` | Public site key obtained from hCaptcha dashboard. |
| `HCAPTCHA_SECRET_KEY` | `YOUR_SECRET_KEY` | Private secret key obtained from hCaptcha dashboard. |

---

##  Shibboleth (SAML SSO) & Verification

Integrates university-wide Single Sign-On and auto-verification. For an in-depth guide on the discovery modes and attribute mappings, see [Shibboleth-Integration](Shibboleth-Integration.md).

| Variable | Default / Example | Description |
| :--- | :--- | :--- |
| `SHIBBOLETH_ENABLED` | `false` | Set to `true` to enable Shibboleth integration. |
| `ENROLLMENT_VERIFICATION_ENABLED`| `true` | Requires participants to be verified (via Shibboleth or upload) before registering. |
| `SHIBBOLETH_DISCOVERY_MODE` | `embedded` | Discovery mode: `direct` (single IdP), `embedded` (in-page search), `redirect` (WAYF). |
| `SHIBBOLETH_DS_URL` | *(empty)* | Discovery service URL (used when `SHIBBOLETH_DISCOVERY_MODE=redirect`). |
| `SHIBBOLETH_SP_ENTITY_ID`| *(URL)* | Your Service Provider Entity ID. |
| `SHIBBOLETH_IDP_ENTITY_ID`| *(URL)* | Your Identity Provider Entity ID (primary/default institution). |
| `SHIBBOLETH_PREFERRED_IDP_NAME` | `Universität Hamburg` | Preferred institution display name in embedded discovery. |
| `SHIBBOLETH_IDP_SSO_TARGET_URL`| *(URL)* | Redirection endpoint for SAML authentication request. |
| `SHIBBOLETH_IDP_SLO_TARGET_URL`| *(URL)* | Single Logout (SLO) endpoint of the IdP (optional). |
| `SHIBBOLETH_CERT_PATH` | `/rails/certs/sp-cert.pem` | Absolute path to the SP certificate file. |
| `SHIBBOLETH_KEY_PATH` | `/rails/certs/sp-key.pem` | Absolute path to the SP private key file. |
| `SHIBBOLETH_IDP_CERT_PATH` | `/rails/certs/idp-cert.pem` | Absolute path to the IdP certificate file (optional). |
| `OMNIAUTH_FULL_HOST` | *(URL)* | Callback base URL (usually matches APP_PROTOCOL + APP_DOMAIN). |

---

##  Kimai Integration

Supports synchronizing experiments and tracking session durations/budgets with the Kimai time tracker.

| Variable | Default / Example | Description |
| :--- | :--- | :--- |
| `KIMAI_BASE_URL` | `https://kimai.org/` | URL of your Kimai time tracking server. |
| `KIMAI_API_TOKEN` | *(token)* | API token generated in Kimai for the synchronization user. |

---

##  SMS Reminders & Gateway

Send automated text message reminders to participants prior to experiment sessions.

| Variable | Default / Example | Description |
| :--- | :--- | :--- |
| `SMS_FEATURE_ENABLED` | `false` | Enable or disable SMS functionality. |
| `SMS_SEND_MODE` | `api` (or `email`) | `:api` calls direct webhooks; `:email` forwards SMS requests via email. |
| `SMS_GATEWAY_EMAIL` | *(email)* | Gateway recipient address for email-based SMS. |
| `SMS_EMAIL_SUBJECT_PREFIX`| `smsjb:` | Prefix header prepended to the email-SMS subjects. |
| `SMS_GATEWAY_API_URL` | *(URL)* | SMS gate API endpoint (e.g. `https://sms-gate.app/api/...`). |
| `SMS_GATEWAY_API_USERNAME`| `hroot` | SMS gate API authentication username. |
| `SMS_GATEWAY_API_PASSWORD`| *(password)* | SMS gate API authentication password. |
| `SMS_INTERCEPTOR_NUMBER`| *(phone)* | Redirects all outgoing SMS to this number in non-production environments. |

---

## Docker Deployment & Auto-Updater Settings


Configure the image repository and tracking branch for Docker container deployments and the In-App Update Checker.

| Variable | Default / Example | Description |
| :--- | :--- | :--- |
| `HROOT_IMAGE` | `ghcr.io/wiso-forschungslabor/hroot:latest` | Docker image pulled by `docker-compose.yml` for `web` and `cron` services. Set to your custom fork image (e.g. `ghcr.io/<account>/hroot:latest`) when using custom builds. |
| `UPDATE_GITHUB_REPO` | `wiso-forschungslabor/hroot` | GitHub repository (`owner/repo`) checked by the In-App Update Checker (`/admin/options/check`) for new commits. |
| `UPDATE_BRANCH` | `master` | Git branch tracked for release updates and version comparisons. |
| `UPDATE_WEBHOOK_URL` | *(empty)* | Optional webhook URL triggered by the In-App Update button to invoke an external updater daemon. |
| `UPDATE_WEBHOOK_SECRET` | *(empty)* | Optional secret token sent in the `X-HROOT-Token` header for update webhook authentication. |

