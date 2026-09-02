*   [1. Currency System & Payment Types](#1-currency-system--payment-types)
*   [2. Cash Advances](#2-cash-advances)
*   [3. Cash Registers & Petty Cash](#3-cash-registers--petty-cash)
*   [4. Kimai Financial Integration](#4-kimai-financial-integration)
*   [5. Banking & Payout Workflows](#5-banking--payout-workflows)
*   [6. Course Credits & Subject Pools](#6-course-credits--subject-pools)

---

## 1. Currency System & Payment Types

This feature allows compensating participants using different currencies, credit types, or points, depending on the study requirements.

### 1.1. Description
hroot supports defining custom **Payment Types**. Each payment type is linked to a specific currency code and symbol. System budgets and session layouts adapt dynamically to the selected currency.

### 1.2. Configuration
- Navigate to **Site Settings -> Payment Types** (`/admin/options/payment_types` under *Finance*).
- Create a new payment type and configure:
  - **Name Translations**: e.g., "Standard Payout" or "Credit Points".
  - **Category**: Set whether it is cash (`cash`), bank transfer (`bank`), credit-based (`credits`), or voucher-based (`voucher`).
  - **Accumulation Mode**: Direct payout per session (`direct_payout`) or accumulate in account (`accumulate_in_account`).
  - **Unit / Symbol**: e.g., `€`, `$`, or `VP` (Subject participation credit hours). Monetary amounts use standard 2-decimal formatting; credit points support decimal increments.
  - **Default Goal**: Default participation credit goal (e.g. `6.00` VP-hours).
  - **Minimum Payout Threshold**: Minimum accumulated amount required before a user can submit a payout request.

### 1.3. Typical Use Case
A research institute conducts two types of studies:
1.  A laboratory decision-making experiment paying participants real cash (using the payment type "Euro Payout" with symbol `€`).
2.  A student-only study where psychology students receive course credits (using the payment type "VP-Stunden" with symbol `VP`). Both are managed within the same system without interference.

---

## 2. Cash Advances

This feature manages the temporary provision of cash to experimenters conducting laboratory experiments.

### 2.1. Description
When participants are paid in cash immediately after a laboratory session, experimenters must receive physical cash in advance. The cash advance workflow tracks the amount of cash handed out to the experimenter, how much was paid to participants, and ensures that the remaining cash is returned and accounted for.

### 2.2. Configuration
- Enable **Vorschüsse/Budgets aktivieren** (`feature_advances`) in **Site Settings -> Finance** (`/admin/options/finance_settings`).
- When configuring an experiment session, set the payment type to a cash category and request an advance for the estimated total payout.
- Once approved, the advance is logged as "issued".
- After the session has concluded, the experimenter goes to the session report to input the actual cash payouts and settles the remaining balance.
- **Unprocessed Sessions Widget**: If an advance is issued but the session report has not been finalized and balanced, the session is flagged as "unprocessed" on the central administrator dashboard.

### 2.3. Typical Use Case
An experimenter is scheduled to run a session on Monday with 10 participants, each receiving 15 EUR. 
- The experimenter requests a cash advance of 150 EUR.
- The administrator approves and hands over the 150 EUR cash.
- During the session, 9 participants show up and receive 15 EUR each (135 EUR total). One participant does not show up.
- On the session completion page, the experimenter marks the session as finished, logs the payouts (135 EUR), and returns the remaining 15 EUR to the treasury. The administrator checks the report and marks the advance as settled, clearing the session from the "unprocessed sessions" widget on the dashboard.

---

## 3. Cash Registers & Petty Cash

This feature allows detailed auditing and denomination tracking for physical cash drawers kept in the laboratory.

### 3.1. Description
For compliance and fraud prevention, labs must balance cash registers daily. The petty cash module tracks exactly which cash drawer is used, counts the physical starting and ending denominations (bills, coins, and rolls), and logs any deviations between calculated book values and actual cash counts.

### 3.2. Configuration
- Enable **Kassenbuch aktivieren** (`feature_cash_registers`) under **Site Settings -> Finance** (`/admin/options/finance_settings`).
- Configure the allowed **Denominations** list (bills, coins, and roll counts JSON format).
- Set up one or more cash registers (e.g., "Lab Room 1 Register", "Lab Room 2 Register") under *Kassen-Verwaltung*.
- When starting a laboratory day, the experimenter must open the cash register by entering the count of all bills and coins (starting balance).
- At the end of the sessions, they count the physical cash drawer again to close the register (ending balance).
- If the register is configured in the site settings, the system will prevent closing if the deviation exceeds a defined threshold unless a remark is provided.

### 3.3. Typical Use Case
An institute operates two computer labs. Each lab has its own lockable cash box.
- The administrator configures two registers in the Site Settings: "Box Lab A" and "Box Lab B".
- On Tuesday morning, the experimenter opens "Box Lab A" and enters the denominations (e.g. 5x 20€ bills, 10x 10€ bills, and some coins = 205.50€).
- During the day, three sessions are paid out of "Box Lab A", totaling 180€ in payouts.
- In the evening, the experimenter closes the register. The system expects 25.50€ remaining. The experimenter counts the cash drawer and inputs the denominations. If the physical count is exactly 25.50€, the register closes cleanly. If a 10€ bill is missing (e.g. count is 15.50€), the system logs a deviation of -10.00€ and requires the experimenter to write a justification comment before closing.

---

## 4. Kimai Financial Integration

This feature automates the synchronization of financial projections and actual expenditures with the external time-tracking and invoicing system Kimai.

### 4.1. Description
To prevent duplicate data entry, hroot can sync project budgets and actual session expenditures directly into Kimai. This is useful for large research projects where all university expenditures must be tracked in a central ERP or project management tool.

### 4.2. Configuration
- Enable the **Kimai-Integration aktivieren** switch in **Site Settings -> Finance** (`/admin/options/finance_settings`).
- Configure host credentials and API tokens under **Site Settings -> Kimai Synchronization** (`/admin/options/kimai`).
- Map hroot experiments to Kimai Projects and hroot payment types to Kimai Activities.
- **Budget Syncing**: In the experiment's budget settings, check "Sync with Kimai". The system will update the project budget inside Kimai whenever budget limits are altered in hroot.
- **Expense Syncing**: In the session report view, clicking the **Sync with Kimai** button pushes the finalized participant payout totals and research assistant hours directly into Kimai as project expenses.

### 4.3. Typical Use Case
A department receives a 50,000 EUR third-party grant for a psychology study, which is tracked as a project in Kimai.
- The administrator creates the experiment in hroot and allocates a 5,000 EUR budget for participant payouts, syncing it to the Kimai project.
- Multiple sessions are run, resulting in 4,500 EUR paid to participants and 200 EUR in laboratory helper costs.
- After finalizing the session reports, the administrator clicks **Sync with Kimai**. The 4,700 EUR in expenditures are immediately logged as booked expenses under the Kimai project, allowing real-time tracking of the remaining grant funds.

---

## 5. Banking & Payout Workflows

This feature handles cashless payouts via bank transfers, collecting participant bank details securely and processing payout requests.

### 5.1. Description
For security and convenience, many laboratories transfer rewards directly to participants' bank accounts. hroot securely collects bank credentials (IBAN/BIC), restricts access to authorized financial personnel, and facilitates bulk payouts and exports.

### 5.2. Configuration
- **Enable Bank Data Collection**: In **Site Settings -> Finance** (`/admin/options/finance_settings`), check **Banking-Daten erfassen** (`feature_banking`) and optionally enable **BIC abfragen** (`ask_bic`) and **Banknamen abfragen** (`ask_bank`).
- **Enforce per Pool**: In **Site Settings -> Participant Pools** (`/admin/options/pools`), check **Auszahlungsdaten (IBAN/BIC) erforderlich** (`requires_banking`) for pools that require bank details for study participation.
- **Privacy & Permissions**: Bank details (`IBAN`, `BIC`, `Bank Name`, `Account Holder`) are protected and only visible to administrators with the `banking_admin` role. Standard admins and experimenters cannot see participant bank details.
- **Payout Processing**: 
  - If a payment type is configured for account accumulation, participants can submit payout requests from their dashboard once the balance reaches the minimum payout threshold.
  - Financial administrators review and approve requests under **Site Settings -> Payout Requests** (`/admin/options/payout_requests`).
  - Data can be exported using customized banking export profiles under **Site Settings -> Exports & Reports** (`/admin/options/export_profiles`).

### 5.3. Typical Use Case
A university lab operates cashless payouts:
- Banking data collection is enabled and a subject pool named "Paid Online Studies" is configured with `requires_banking=true`.
- A participant registering for this pool provides their IBAN and account holder name.
- After completing sessions, earnings accumulate in the participant's account or are recorded per session.
- The participant submits a payout request via their profile dashboard.
- The Banking-Administrator goes to **Site Settings -> Payout Requests**, reviews the pending transfers, marks them as processed, and downloads the export file to execute the wire transfers via the university banking portal.

---

## 6. Course Credits & Subject Pools

This feature tracks academic participation credits required by university curricula.

### 6.1. Description
Psychology and social science programs often require students to participate in a set number of research hours (VP-Stunden) as part of their degree. hroot allows creating credit-based payment types, assigning credit goals to students, and exporting cohort summaries for academic coordinators.

### 6.2. Configuration
- Create a payment type using a credit currency (e.g. "VP-Stunden" with symbol `VP`).
- In the user profiles or pool settings, configure the target goal (e.g. "Requirements: 6.0 VP").
- Group students into **Cohorts** (e.g., "Psychology Bachelors 2026") under the Subject Pool options.
- When students participate in credit-based sessions, their accumulated credits are automatically updated.

### 6.3. Typical Use Case
Psychology students must complete 10 hours of experiment participation (10 VP-Stunden) in their first year.
- The coordinator creates the cohort "Year 1 Psych" in the pool.
- Students sign up and participate in various lab sessions, earning credits (e.g., 1.5 VP for a 90-minute session).
- At the end of the semester, the coordinator goes to the user directory, filters by the cohort "Year 1 Psych", and exports the **Cohort Credit Report**. This spreadsheet list shows exactly how many VP-hours each student has accumulated, allowing the coordinator to instantly see who has met the 10-hour requirement.
