Adding users can be done in two ways: Users can sign up for themselves, and you can add users manually.

### Registering as a user

Registering in hroot as an experiment participant is easy - just guide your users to the registration page (&lt;your site url&gt;/register). Users have to have a unique email address, they have to pick a password and repeat it, and they have to provide all data fields marked as mandatory (in the official version these fields are first name, last name, gender and student number, but this is configurable).

After providing all necessary data, users will have to confirm their email by visiting the url they receive in the confirmation email.

After registration and confirmation, users can log in and signup for sessions of experiments they were invited for.

The content of the start page can be configured manually, if you want to link to the registration page, simply the following link in the start page HTML:

    <a href="/register">Register now!</a>

You can edit the start page content in _Settings_ / _Texts_

### Adding users manually

As an admin, you can add new users manually without the confirmation email loop. Just click on the "Users" item in the admin menu and click "New user" on the top of the page. Fill in all necessary information and click "save" to create the user. Manually created users can log in immediately, there is no confirmation of email address, so be sure you enter the correct email address, as there is no check whether the email exists using a confirmation email.

When you manually create a user, you also have to specify a password for that user. Please provide this initial password in a safe manner - do not send passwords via email, the best way is to tell the password to the user in person. As soon as the user logs in, the password can be changed in the account settings.

### CSV User Import (Mass-Import)

For importing a large number of users at once (for example, migrating from a legacy system or registering a specific cohort), administrators can use the **CSV Import** feature:

1.  **Access the Import Tool**: Navigate to the **Users** management section in the admin menu and click the **Import Users** button (or go to `/admin/users/import`).
2.  **File Format & Template**: 
    *   Upload a standard CSV file (supported delimiters: comma `,`, semicolon `;`, tab, or pipe `|`).
    *   The file should contain a header row defining the column names.
    *   A sample template can be downloaded directly from the import page (**Download sample CSV template**).
3.  **Column Mapping & Default Pool/Cohort**: 
    *   After uploading, you will be presented with a mapping interface. You can map CSV columns to the corresponding hroot user attributes:
        *   *General fields*: Email (mandatory), First Name, Last Name, Role, Secondary Email, IBAN, BIC, Bank, Account Holder Name, Matriculation Date, and any defined custom profile fields.
        *   *Pools & Cohorts*: You can map CSV columns for **Groups / Pools** (`pool_ids`) and **Cohorts** (`cohort_ids`) using either IDs or names (comma-separated).
    *   *Default Pool & Cohort Selection*: You can also select optional default pools and a default cohort directly on the import form. All imported users will automatically be assigned to these unless overridden by a specific column entry in their CSV row.
4.  **Duplicate Detection & Conflict Handling**:
    *   **Email Uniqueness**: The system uses the email address as the primary unique identifier.
    *   **Existing Email Matches**: If a CSV row contains an email address that already exists in hroot, the existing user profile is **updated** with the newly mapped field values and pool/cohort assignments (preventing duplicate accounts under the same email address). No new password or welcome email is sent for existing accounts.
    *   **Checking for Personal Duplicates (Different Email, Same Person)**: To check whether any newly imported users are duplicates of existing participants under different email addresses (e.g. matching first name, last name, date of birth, or IBAN), navigate to the **Users** overview and use the **"Duplicates" filter** in the left sidebar. Detected duplicates are flagged with warning icons in the list and can be inspected side-by-side and merged using the **"Merge Users"** feature (see [Finding duplicate users](Finding-duplicate-users)).
5.  **Activation & Password Options**:
    *   **Activation Mode**:
        *   *Activate directly (no email)*: The accounts are activated immediately with confirmed status without sending emails.
        *   *Activate directly (send welcome email)*: The accounts are activated immediately, and a welcome email (or email to choose a password) is sent out.
        *   *Send activation email*: Users are imported as unconfirmed with an activation token and must click the link in their activation email to complete setup.
    *   **Password Handling**:
        *   Map a dedicated password column from your CSV file.
        *   *Default Password*: Assign a fixed initial password (e.g. `Start123!`) to all users without a password in the CSV.
        *   *Random Password*: Generate random secure passwords (users receive a password set link or use "Forgot password").
6.  **Preview & Validation**: 
    *   Before committing the import, a **CSV Data Preview** table displays the first rows of the uploaded file so you can inspect column values and verify your mapping.
7.  **Execution & Feedback**: 
    *   Click **Run Import** (**Import ausführen**) to execute the import.
    *   A success notice displays the total number of successfully imported and updated users.
    *   If any rows could not be processed (e.g. missing email address or field validation errors), a detailed alert message lists the exact line numbers and affected email addresses.


