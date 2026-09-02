
This page describes the **SMS Reminders**, **Custom SMS Messages**, and **Web Push Notifications** systems in `hroot` version 4.0.

> [!NOTE]
> All SMS and Push notifications features can be toggled on/off in Site Settings (Features switches) and are subject to user-specific preference toggles inside their participant profiles.

---

## 1. SMS Reminders (SMS-Reminder)

To improve attendance rates, `hroot` can automatically send text message reminders to participants before a session begins.

- **Dual Reminders**: The system supports two separate reminder triggers:
  - **First SMS Reminder**: Sent at a configured number of hours before the session start (e.g. 48 hours).
  - **Second SMS Reminder**: Sent closer to the session start (e.g. 2 hours) as a final warning.
- **Custom Templates**: Default SMS text templates can be defined globally under Site Settings (Options > Emails) and overridden on a per-experiment level.
- **Opt-In/Out**: Participants can manage their mobile numbers and opt in or out of SMS reminders under their profile settings (`account/sms_reminder`).

---

## 2. Custom SMS Messages (SMS-Nachrichten)

Experimenters with the `send_session_messages` privilege can send direct custom SMS messages to participants:
- **Individual SMS**: Send a custom text message to a specific registered participant via the session participants action menu.
- **Bulk SMS**: Send a text announcement to all participants registered in a session at once.

---

## 3. Web Push Notifications

Participants using modern desktop or mobile browsers can subscribe to Web Push Notifications.

- **VAPID Keys**: Built-in VAPID keys (`VAPID_PUBLIC_KEY`, `VAPID_PRIVATE_KEY` in `.env`) handle encryption handshake between the server and the browser push service.
- **Subscription Prompt**: Users are prompted to allow push notifications when logging in or via a prompt on their account panel (`account/push_prompt`).
- **Push Notification Types**:
  - **Invitations**: Notifies when invited to a new experiment.
  - **Digests**: Notifies when a new digest list is compiled.
  - **Confirmations**: Triggers upon registration confirmation.
  - **Waiting List**: Alerts when a seat becomes available on a session's waiting list.
  - **Reminders**: Standard browser-level session reminders.
  - **Warnings**: Alerts on no-shows or account retention (e.g., 1-year inactivity warnings).

---

## 4. Gateway Integration & Developer Interception

## 4. Gateway Integration & Server Setup (`sms-gate.app`)

Outbound SMS is handled via direct API integrations to external gateways like [sms-gate.app](https://sms-gate.app) (private server edition).

### Option A: Hosting the Gateway Server on a Subdomain (Recommended)
This runs the gateway on a clean subdomain (e.g., `sms.your-hroot-domain.com`) to avoid any routing or asset conflicts with the main application.

1. Configure your `.env` file:
   * `SMS_FEATURE_ENABLED=true`
   * `SMS_SEND_MODE=api`
   * `SMS_GATEWAY_DOMAIN=sms.your-hroot-domain.com`
   * `SMS_GATEWAY_API_URL=https://sms.your-hroot-domain.com/api/3rdparty/v1/messages`
   * `SMS_GATEWAY_API_PASSWORD=your-secret-gateway-password`
   * `SMS_GATEWAY_API_USERNAME=hroot`
2. Start the services via `docker compose up -d`.

### Option B: Hosting the Gateway Server on a Custom Port (No Subdomain)
If you do not want to set up an alias/subdomain, you can expose the gateway on a custom port on your existing domain (e.g., `https://your-hroot-domain.com:8080`).

> [!IMPORTANT]
> **Firewall requirement:** The custom port (e.g. `8080`) must be explicitly opened in your server's firewall (e.g. `sudo ufw allow 8080/tcp`) and mapped in your docker-compose or reverse-proxy configuration.

1. **Nginx Proxy Configuration** (for port 8080):
   ```nginx
   server {
       listen 8080 ssl;
       server_name your-hroot-domain.com;
       
       # Use the same SSL certificate files as your main domain
       ssl_certificate /path/to/cert.pem;
       ssl_certificate_key /path/to/key.pem;

       location / {
           proxy_pass http://sms-gateway:3000;
           proxy_set_header Host $host;
           proxy_set_header X-Real-IP $remote_addr;
           proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
           proxy_set_header X-Forwarded-Proto $scheme;
       }
   }
   ```
2. Configure your `.env` file:
   * `SMS_FEATURE_ENABLED=true`
   * `SMS_SEND_MODE=api`
   * `SMS_GATEWAY_API_URL=https://your-hroot-domain.com:8080/api/3rdparty/v1/messages`
   * `SMS_GATEWAY_API_PASSWORD=your-secret-gateway-password`
   * `SMS_GATEWAY_API_USERNAME=hroot`

---

## 5. Pairing the Smartphone (Server Mode)

To send SMS messages using either Server Option A or B, you must pair an Android smartphone:
1. **Install App**: Install the official **Android SMS Gateway** app on your Android device (available via Play Store or https://sms-gate.app/).
2. **Prepare Pairing**:
   * Define `SMS_GATEWAY_API_URL` (the URL of your gateway server) and `SMS_GATEWAY_PRIVATE_TOKEN` (a secure secret token of your choice used for pairing) in your `.env` file.
3. **Configure App**:
   * Open the app on your Android device, navigate to *Settings* -> *Cloud server*.
   * Enter the exact same **API URL** and **Private Token** that you configured in `.env`.
4. **Enter API Credentials in hroot**:
   * Once the app connects successfully, the system generates API credentials for message dispatch.
   * Add this username and password to your `.env` file as `SMS_GATEWAY_API_USERNAME` and `SMS_GATEWAY_API_PASSWORD`.
5. **Check Connection Status**:
   * In the `hroot` administration panel, go to **Site Settings > Communication** (`/options/communication`).
   * Directly above the test SMS form, you will see the live connection status of your smartphone (Online/Offline, device name, and last seen timestamp).

---

## 6. Option C: Local Server Mode (No Gateway Server Container Needed)

If both your `hroot` server and the Android phone reside on the **same local network/WiFi** (e.g., local developer machine or local university lab network), you can completely bypass hosting a gateway server. The smartphone app itself starts a built-in web server.

1. In the Android SMS Gateway app settings, enable **Local Server** mode.
2. The app will generate and display:
   * A local HTTP address (e.g., `http://192.168.1.50:8080`)
   * A random `Username`
   * A random `Password`
3. Configure your `hroot` `.env` file to point directly to the phone:
   ```ini
   SMS_FEATURE_ENABLED=true
   SMS_SEND_MODE=api
   SMS_GATEWAY_API_URL=http://<YOUR_PHONE_IP>:<PORT>/message  # e.g., http://192.168.1.50:8080/message
   SMS_GATEWAY_API_USERNAME=<Username_from_app>
   SMS_GATEWAY_API_PASSWORD=<Password_from_app>
   ```
4. `hroot` will now send POST requests directly to the phone's IP address. No background docker container or server setup is required.

---

## 7. Developer Interception (Non-Production)

In development or staging environments, real SMS and Push notifications are intercepted to avoid spamming actual phone numbers:
*   **SMS Interception**: Configured via `SMS_INTERCEPTOR_NUMBER` in `.env`.
*   **Push Interception**: Configured via `INTERCEPTOR_EMAIL` in `.env`.
*   When active, real outbound messages are blocked, and notification payloads are printed directly to the environment logs for verification.

