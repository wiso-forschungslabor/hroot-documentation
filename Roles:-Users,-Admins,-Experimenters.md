### Roles: Users, Admins, Experimenters, Banking-Administrators

Users in `hroot` are categorized into four roles:

#### 1. Users
_Users_ are typically participants in experiments. They register via the signup page, verify their email address, and await study invitations. Once invited, they can view experiment details, select sessions, manage their profile data, and provide payment preferences (if required by the subject pool).

#### 2. Experimenters
_Experimenters_ have targeted permissions scoped to their assigned experiments:
- Manage sessions, send invitations/messages to registered participants, conduct session admission (check-in), and complete session lab reports.
- They do not have access to global system settings, participant banking data, or unassigned experiments.

#### 3. Administrators
_Administrators_ manage day-to-day lab and experiment operations and have broad operational access:
- **User & Pool Management**: Browse the participant database, search/filter users, activate or block accounts, manage subject pools, and export participant data.
- **Experiment Management**: Create and configure experiments, manage procedures, treatments, session groups, and assign experimenters.
- **Task Management (Staff Tasks)**: Create tasks and **delegate them to any staff member**. Admins can view all tasks across the system, and can edit, update, or delete tasks they created or that are assigned to them.
- **Staff Availabilities**: Manage their **own** working times, weekly recurring slots, and availability exceptions.
- **General Configuration**: Manage locations, default email templates, custom field definitions, and duplicate check rules.

#### 4. Banking-Administrators
_Banking-Administrators_ hold the highest privilege level in `hroot`. In addition to all standard administrator capabilities, they have exclusive access to financial governance, sensitive bank data, and comprehensive team management:

* **Sensitive Bank Data & Privacy Protection**:
  * **Participant Bank Credentials**: Only Banking-Admins can view and edit sensitive bank details (`IBAN`, `BIC`, `Bank Name`, `Account Holder`) in participant profiles. These fields are strictly hidden from standard Admins and Experimenters.
  * **SEPA & Banking Exports**: Generate SEPA XML transfer files and manage automated payout workflows.
  * **Cross-Experiment Payout Governance**: Unrestricted access to participant lists and financial booking records across all experiments (without needing explicit experimenter assignments).
  * **Cash Registers & Advances**: Full control over opening, tracking, reconciling, and closing cash registers and cash advances.
  * **Budgets**: Approve, activate, monitor, and close experiment research budgets.

* **Kimai Integration Management**:
  * Exclusive administrative access to **Site Settings > Kimai Tracking** (`/options/kimai`).
  * Link experiments to Kimai projects, map staff members to Kimai user profiles, and configure dynamic reimbursement/expense mapping rules.

* **Full Staff Management & Governance**:
  * **Team Availabilities**: View and edit the availabilities, recurring schedules, and absence exceptions of **all** staff members (standard Admins can only edit their own).
  * **Full Task Governance**: Edit, reassign, or delete **any** task on the system, including tasks created by other admins for third-party assignees.

