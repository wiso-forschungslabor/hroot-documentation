To install `hroot`, choose the deployment method that fits your laboratory's infrastructure, customization needs, and technical policies.

---

## Choosing Your Deployment Method

Use the comparative matrix below to decide which deployment path to follow:

### 1. Decision & Recommendation Matrix

| Deployment Method | Best For | When to Choose | Key Characteristics |
| :--- | :--- | :--- | :--- |
| **1.i. [Docker (precompiled)](Docker-(precompiled).md)**<br>*(Standard & Recommended)* | **Production Labs & Standard Setups** | Choose this if you want the **fastest, zero-touch setup** without modifying Ruby code. | • Prebuilt images from `ghcr.io`<br>• Automated secret generation<br>• Full Setup Wizard at `/setup`<br>• 1-Click In-App updates |
| **1.ii. [Docker (self-compiled)](Docker-(self-compiled).md)**<br>*(Build from Source)* | **Custom Features, Theming & Local Dev** | Choose this if your laboratory plans to **modify source code**, add custom features/CSS, or test local branches, while keeping container isolation. | • Built locally with `Dockerfile`<br>• CLI-first `.env` configuration<br>• Independent of remote registry<br>• Full Docker Compose isolation |
| **1.iii. [Manual Deployment](Manual-Deployment.md)**<br>*(Legacy Bare-Metal)* | **Environments where Docker is Forbidden** | Choose this only if institutional IT policies **prohibit Docker** on your server. | • Runs directly on host OS<br>• Native Ruby, rbenv, Passenger/Puma<br>• Manual system package maintenance |

---

### 2. Selecting Your Docker Compose Setup Mode

If you deploy using Docker (precompiled or self-compiled), select one of the following scenarios based on your server architecture:

| Scenario | Mode | Purpose | Routing & SSL Management |
| :--- | :--- | :--- | :--- |
| **A. Standard Setup** | Standalone Compose | A dedicated server hosting only one `hroot` instance. | Handled automatically by the built-in web container. |
| **B. Shared Proxy** | Multi-Instance Compose | Hosting multiple instances/labs on a single server. | Routed through a central reverse proxy with shared SSL certificates. |
| **C. App-Only** | External Host Proxy | Integrating with existing web servers on your Linux host. | Traffic is passed directly to the app container via NGINX/Apache on the host. |
| **D. External Database** | Remote DB Compose | Connecting `hroot` to an existing university MySQL server. | Uses remote database credentials configured via `.env` or `/setup`. |

---

## Detailed Installation Guides

Proceed to the step-by-step documentation for your chosen method:

1. **[Docker (precompiled)](Docker-(precompiled).md)**: Pre-built container images, zero-touch secret generation, and in-browser setup wizard.
   * *See also:* **[Docker Multi-Instance Setup](Docker-Multi-Instance-Setup.md)** for hosting multiple laboratories on one server.
2. **[Docker (self-compiled)](Docker-(self-compiled).md)**: Compiling from local source code, customizing features, and CLI-based configuration.
3. **[Manual Deployment](Manual-Deployment.md)**: Bare-metal installation on Ubuntu Linux with native Ruby, MySQL, and Phusion Passenger.
   * **[Ruby and rbenv](Ruby-and-rbenv.md)**
   * **[MySQL](MySQL.md)**
   * **[Git](Git.md)**
   * **[Production server with Phusion Passenger](Production-server-with-Phusion-Passenger.md)**
   * **[Cronjob for background task](Cronjob-for-background-task.md)**

---

## Initial Configuration & Administration

* **[Environment Configuration](Environment-Configuration.md)**: Comprehensive catalog of all `.env` environment variables and security settings.
* **[Backup and Maintenance](Backup-and-Maintenance.md)**: Database snapshot routines, updates, and maintenance tasks.
* **[Starting a local server and running automated tests](Starting-a-local-server-and-running-automated-tests.md)**: Running test suites and development servers.
* **[Basic configuration](Basic-configuration.md)**: Initial system branding and laboratory rules.
* **[Language configuration and timezone](Language-configuration-and-timezone.md)**: Configuring default locales and timezones.
* **[Custom field definitions](Custom-field-definitions.md)**: Setting up participant registration fields and questionnaires.
