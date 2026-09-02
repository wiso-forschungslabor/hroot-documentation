### User display, paging and sorting

When you are logged in with the role 'admin' or 'banking_admin', you can browse all users of the system (pool members, experimenters, and administrators) using the **Users** page (7th link "Users" in the main navigation menu).

In a typical installation, the user table displays:
- Selection checkbox
- ID
- Name (Last name, First name)
- Role (User, Experimenter, Admin, Banking Admin)
- Email address & Secondary email
- Participation Code
- Created date / Registration date
- No-show count (#N)
- Show-up count (#S)
- Participations count (#P)
- Assigned Pool memberships
- Verification status / Matriculation date
- Usability status (V-Status)
- Banking details (IBAN/BIC - visible only to Banking-Admins)
- Configured Custom Fields (e.g. Gender, Degree, Course of studies, Mobile phone, etc.)
- Accumulated Payment Type totals

> [!TIP]
> You can customize which columns are visible and in what order using the **Spalten auswählen** (*Select Columns*) dropdown menu in the upper right corner of the table.

The list of users is displayed with pagination, and you can navigate pages using the pagination bar at the top/bottom. To sort by a specific column, click on the column header (click again to reverse the order). The default sort order is by last name.

### Filters

Most of the time you will search for a specific set of users using the filter controls in the **left sidebar**. 

HROOT features real-time AJAX filtering: changing a dropdown, checking a box, or typing in the text field **automatically updates the results live** without needing to click a search button. The total number of matching users is displayed directly at the top of the table.

Available filter options include:
- **Full text search**: Instant search across first name, last name, and email address.
- **Participant Pools**: Filter users belonging to specific pools (e.g. Student Pool, Public Pool).
- **Role**: Filter by user role (`user`, `experimenter`, `admin`, `banking_admin`).
- **Account status**: Filter by active, paused, unconfirmed email, blocked, or permanently deleted accounts (deleted/anonymized users are hidden by default).
- **Verification status**: Filter by Shibboleth verified, pending document review, manually confirmed, or unverified.
- **Usability Status (V-Status)**: Filter by scientific data usability classifications.
- **No show / Show up / Participation counts**: Filter by minimum or maximum number of sessions attended or missed.
- **Tags**: Find users who participated in experiment sessions tagged with specific keywords.
- **Experiments**: Filter based on assignment or participation history across specific experiments.
- **Dates**: Filter by registration date (`created_at`), date of first participation, or matriculation validity date (`matrikel_date`).
- **Duplicate accounts**: Automatically detect and list users with matching names, birthdates, or IBANs.
- **Custom fields**: Filter dynamically by any active custom attributes (Gender, Course of Study, Degree, Experience, Nationality, Languages, etc.).

You will find these same filters available on the **Assign participants** page when selecting subjects for a study.


