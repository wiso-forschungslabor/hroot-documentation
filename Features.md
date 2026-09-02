
This page provides an overview of the main features in `hroot`, comparing legacy workflows with the new system capabilities, and highlights the major features introduced recently.

---

## 1. Comparative Features Matrix

| Area / Goal | Old (hroot 3.1) | New (hroot 4 and higher) | Advantage |
| :--- | :--- | :--- | :--- |
| **Speed & Online Studies** | Rigid scheduling with fixed laboratory appointments. | **Direct Survey Integration**: Optional immediate, asynchronous online participation.<br>**Automated checks**: Track participation status, payments & backfill sessions autonomously. | Dramatically faster data collection and higher participant reach. |
| **Payouts & Documentation** | Manual Excel sheets and disconnected tracking of payments. | **Banking Integration**: Optional bank data storage, payment tracking, and banking software export.<br>**Cash registers**: Keep track of cash payments being made in the lab. | Secure, error-free accounting and fast bulk payouts. |
| **Multi-Channel Communication** | Email-only communication. | **Multi-Channel**: Email, Web Push Notifications, and SMS integration. | Higher read-rates and significantly reduced no-show rates. |
| **Budget & Cost Control** | Isolated, static cost tables. | **Kimai Integration & Workflows**: Real-time budget tracking of Payouts and personnel costs and reporting.<br>**Budgeting**: Use centralized research budgets to keep track of costs. | Full financial transparency and automated accounting preparation. |
| **Team Organization** | External coordination via emails or third-party tools. | **Integrated Shift Planning**: Staff availability polling, Kimai integration for Absences / Holidays, Shift Plan mailing.<br>**Integrated Task Management**: Create and assign tasks to team members (optionally experiment-specific, recurring and due dates). | Seamless team coordination and responsibility tracking directly within the workspace. |
| **Data Quality & Verification** | Basic email confirmation loops with manual document verification. | **Shibboleth SSO & Document Uploads**: Optional Institutional login and ID verification. | Reliable prevention of fake accounts and AI-generated participants. |
| **Centralized Administration** | Scattered email threads to clarify experiment details. | **Messaging History & Task Hub**: Centralized notes, tasks, and participant communication logs. | A single source of truth for the entire research team. |
| **Field Reporting** | Keep track of numbers of collected participants/treatments manually (e.g. in Excel) and special occasions / anonymities. Collect additional participant data manually. | **Centralized reporting**: Overview of all sessions, costs, remarks, recruitment history. | Better overview, precise planning, and fewer assignment errors. |
| **Participant Recruitment** | Sending invitations manually (one per experiment). | **Invitation hub**: Centralized planning of invitations for multiple experiments, automatic sending. Invite for multiple experiments in one invitation at once. | Fast, streamlined scheduling. |
| **Scalability** | Manual, individual creation of sessions and payouts.<br>Manual assignment of eligible participants to the experiment. | **Batch Operations**: Bulk creation of sessions and CSV-based status/payment updates.<br>**Central Dashboard**: Keep track of running experiments with filling status, last invitations, Budgets, open tasks.<br>**Auto-assignment**: Optional auto-assignment of new participants into experiments. | Massive time savings when managing large-scale experiments, reducing manual labor to the minimum. |
| **Customization** | Customizations made in codebase. | **Extended "Settings"**: Customize the system according to your needs right from the interface: Custom Fields, Translations, Lab Procedures, Project Steps, Data Exports defined centrally. | Easily adapt hroot to local needs without coding. |
| **Deployment & Tech** | Manual, somewhat lengthy server setup. | **Docker Environments**: Fully preconfigured containers with centralized `.env` management. | Fast installation, easy system backups, and modern security (Rails 8). |

---

## 2. Major Recent Features

### A. Two-Factor Authentication (2FA) for Admins
To protect sensitive administration panels and participant databases, `hroot` features administrative **Two-Factor Authentication**:
- **Device Trust**: Once verified, admins can mark their device as trusted for **90 days**, eliminating the need for repeated code entries on secure machines.
- **Admin Reset Utility**: If an administrator is locked out (e.g., due to a lost authenticator device), other administrators can reset their 2FA settings directly from the user administration panel.

### B. Comprehensive Audit Logging & Action History
Powered by the `paper_trail` system, `hroot` tracks all structural and configuration changes:
- **Global Audit Trail**: Accessible under **System Check** at `/options/check`, letting administrators review changes made across the system, filtered by **Actor (Whodunnit)** and **Change Type (Item Type)**.
- **User Detail Logs**: An "Audit Log" tab is embedded in the user details page to audit participant profile edits.
- **Unified Action History**: The experiment message history has been expanded into the **Message and Action History** to record both communication logs (Email, SMS, Push) and system events.

### C. Advanced Entrance Procedures
To accommodate different laboratory protocols, `hroot` provides unified admission methods:
1. **QR-Code Admission (Check-In)**:
   - Participants receive QR check-in instructions.
   - Admission scanner interface handles automated check-ins and seat assignments.
   - Collects and confirms **Privacy Consent** at the door.
   - Automatic Push/SMS reminders are sent to participants prior to session start.
2. **Online Waiting Room & Lounge**:
   - Specifically built for online experiments to prevent over-recruitment issues.
   - Participants join a virtual lounge before the session starts, verify their phone/matriculation details, and confirm consent.
   - At session start, the system executes an automated, randomized draw (incorporating quota rules if enabled) to select active players.
   - Selected players swap tokens and are redirected to the external experiment platform.
   - Unselected players are marked as **Showup-only** (`#E` and `#R` checked) and receive the show-up fee.

### D. Interactive Task Board & Timeline Views
Improving team scheduling and lab management:
- **Kanban Board**: Drag-and-drop workflow for staff tasks, sorted by phases, with filtering by assignee and status.
- **Gantt & Timeline View**: Shows experiment session ranges alongside staff task deadlines to keep the research team aligned.
- **Multi-Assignee Support**: The `StaffTaskAssignment` model allows assigning multiple personnel members to a single task.

### E. Survey Sets & Participant Surveys
Streamlining online studies and participant profiling:
- **Survey Sets**: Administrative groups of survey questions associated with specific pools.
- **Profile & Screening Surveys**: Seamlessly integrated into user accounts, enrollment flows, and completion views.
- **Token Lists & Resolved URLs**: Allows experimenters to review tracking tokens and generated redirect links directly in enrollment and completion reports.

### F. Flexible Quota Logic & Multi-Currency Support
- **Flexible Comparison Operators**: Quotas can now use comparison operators (`=`, `!=`, `>`, `<`, `>=`, `<=`) rather than simple equality checks, enabling complex demographic rules.
- **Quota Panel & Overrides**: Includes inline javascript quota row editors, quota overrides in reports, and a live quota status panel on the participant listing view.
- **Multi-Currency**: Central budgets and cashiers now support adjusting and defining distinct currency symbols (e.g. €, $, £) per payment type.

### G. Feature Switches
To keep the administration panel clean and avoid confusion, `hroot` allows toggling system features globally via the **Feature Switches** settings tab under *System & Plugins*:
- **Staff Tasks & Availabilities**: Activates the internal shift planning, helper availability registration, and task assignment boards.
- **Kimai Integration**: Enables syncing project budgets and laboratory assistant timesheets with Kimai.
- **Usability Status (V-Status)**: Adds scientific usability flags to participants' session records.
- **Cash Registers**: Enables physical cash boxes, denominations counting, and daily close deviation checks.
- **Banking & Advances**: Activates SEPA XML exporting and cash advances tracking.
- **Matriculation Verification**: Enables student enrollment document uploads and verification workflows.
- **Two-Factor Authentication (2FA)**: Enforces TOTP-based multi-factor authentication for administrators and banking admins.

Disabling any of these switches automatically hides their associated navigation links, tabs, and widgets across the entire system.

