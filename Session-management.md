*   [List of participants](#list-of-participants)
*   [Icons and crossed users](#icons-and-crossed-users)
*   [Sending mails to participants](#sending-mails-to-participants)
*   [Documentating participation](#documentating-participation)
*   [Move participants to other sessions](#move-participants-to-other-sessions)
*   [Remove participants from sessions](#remove-participants-to-other-sessions)
*   [Self removal of participants](#self-removal-of-participants)
*   [Bulk Participant Status & Payout Import (CSV-Status-Import)](#bulk-participant-status--payout-import-csv-status-import)

---

## List of participants

There are several ways to access the list of participants of a session. In the session overview is the number of participants linked to the list. From the Options tab of a session you can switch to the Session participants. Other links are in the Dashboard, in the calendar and in the detail view of an participant.

The list contains all users who have signed up for the session, with the following information:

-	Info Icons
-	Name
-	Email
-	Course of studies
-	Gender
-	Number of No-shows (#N)
-	Number of Participations (#P)

Followed by five columns to store information about their participation in this session, which is explained [below].

By default the list is sorted alphabetically by surname. But it is possible to sort it by any other column. Surname is then used as secondary sort for ties. 

With the Data button at the top right it is possible to print the list or export it to excel or csv file. When you print the list, the columns printed are different from the ones on screen. You will get:

-	Name
-	Mobile phone number
-	Gender

And the five columns to document the participation in this session. In additon to that there will be header with the time, date an place of the session, but not its name.

The export to file option will result in a file containing more information than it is possible to fit on screen or paper. The content does not differ between excel and csv file.


## Icons and crossed users

The first column of the participant list displays information and warning icons indicating the status of the user's account or verification:

*   💬 **Comment Bubble**: Indicates that a comment or note is attached to this user profile. Hovering over the icon displays the text.
*   ✉️ **Envelope**: Signals that this user has been sent an invitation email. *(Note: This status might be cleared when using "Invite all users" bulk functions, so the icon may sometimes be missing even if invited).*
*   🚩 **Flag**: Indicates that a reminder email has been sent to the user.
*   ⚠️ **Exclamation Mark**: Represents a potential duplicate account:
    *   **Duplicate name check**: Triggered when another user in the pool has the same first and last name.
    *   **Duplicate birthday check**: Triggered when another user has the same birthday.
*   💶 **Euro Sign**: Indicates a duplicate IBAN check (another user account has registered the identical bank account details).
*   ❓ **Question Mark**: Indicates that the user has not set a password yet (common for newly imported/created users).
*   🔇 **Volume Off**: Indicates that the user has opted out of receiving invitation emails.
*   🔗 **Link Icon**: Indicates that the student status has been successfully verified via **Shibboleth** login.
*   ⏳ **Hourglass**: Indicates that the user has uploaded enrollment documents, and a **manual verification** by an administrator is pending.
*   📅 **Calendar**: Indicates that there is no proof of a valid matriculation date (matriculation date is null).
*   🌐 **Globe**: Indicates that the user registered using a public registration link.
*   🕒 **Clock**: Indicates that the user has not signed in for more than one year (inactivity warning).
*   🔒 **Lock**: Indicates that the user account is currently blocked (e.g. due to too many no-shows).
*   🗑️ **Trash Can Icon**: Indicates that the user is permanently deleted (personal data removed, but record kept for statistics/accounting).
*   🚫 **Crossed Circle**: Indicates that the user was imported from a legacy system but has not been activated yet. They are shown in grey.

Crossed out users will also be shown in grey. These users have been marked as deleted, but are kept in the database for documentation purposes.

## Sending mails to participants

From the session list it is possible to send a message to all session participants or the ones you have checked with the checkbox at the beginning of the line. Since this message is in the context of a session it is possible to use session variables as explained in [sending messages](https://github.com/wiso-forschungslabor/hroot-documentation/wiki/Sending-messages). Also these mails will be added to the message history of the experiment

You can change the subject and body of the email to the default reminder text by one click.

## Documentating participation

The five columns at the end of the list can be used to document the participation in the session (labeled by their shortcuts, e.g., N, E/S, T/P, V, R):

- **N - No-Show (`noshow`)**: The participant did not show up for the session.
- **E / S - Show-Up (`showup`)**: The participant showed up for the session (either in person or online), but did not participate (e.g., due to overbooking or being not drawn from the waiting room lobby).
- **T / P - Participated (`participated`)**: The participant showed up and completed the experiment/session.
- **V - Usable (`usable`)**: The participant's data is scientifically usable. This can only be checked if the participant showed up and participated.
- **R - Allow Re-participation (`allow_reparticipate`)**: The participant is allowed to register for another session of this experiment.

### Checkbox Interaction Rules
- Checking **Participated** automatically checks **Show-Up** and unchecks **No-Show**.
- Checking **No-Show** automatically unchecks **Show-Up**, **Participated**, and **Usable**.
- Checking **Usable** requires **Participated** to be checked.

### Show-Up Only Logic
For automation systems (like the Online Waiting Room and Online Surveys):
- **Show-Up Only**: If a participant does not get drawn in a waiting room draw, or if they time out, fail an attention check, or are screened out during an online survey, they are marked as **Show-Up Only**:
  - **Show-Up (`#E` / `showup`)** is **checked**
  - **Allow Re-participation (`#R` / `allow_reparticipate`)** is **checked**
  - **Participated (`#T` / `participated`)** is **unchecked**
  - **No-Show (`#N` / `noshow`)** is **unchecked**
  - Since they did not actually participate in/see the experiment, allowing re-participation enables them to sign up for subsequent sessions of the same experiment.

The text boxes for Number and amount can be used to document the seating number in the lab and the total amount earned. These values are currently not used in hroot, but they can be exported. In the future they might be used for statistics or to analyse participants over different experiments.

## Move participants to other sessions

When you have selected at least one participant, by checking the box at the front of the line, you can move the participants to another session or session group, if there is any. It is possible to move a participant to any session of the same experiment, regardless wether the number of maximum participants is reached or not. There are no checks applied. Also there is no information send to the user of this change. Only a reminder is sent, if a reminder is activated and the reminder has passed the due date.

## Remove participants from sessions

When you have selected at least one participant, by checking the box at the front of the line, you can remove the participants from the session. They will also get no information about this removal, but since they are only removed from the session and are still assigned to the experiment, they can sign up for another session of the experiment, if there is one still available.

## Self removal of participants

Participants can deregister from a session while it is still 24 hours before the start of the session. 

*   **Configuring the Time Window**: This time window (cancellation deadline) is not fixed. Administrators and experimenters can customize it on a per-experiment basis. In the experiment's settings under **Participant Management**, adjust the **Cancellation Deadline (hours)** field. By default, it is set to `24` hours.
*   **Disabling Self-Deregistration**: If you want to prevent participants from cancelling their registrations themselves, you can set the **Cancellation Deadline (hours)** to a very large number (for example, `9999` hours). This sets the deadline far in the future, effectively disabling the deregistration option for participants, so only administrators/experimenters can remove them manually.

---

## Bulk Participant Status & Payout Import

For experiments with many participants, manually checking boxes for show-ups, payouts, and seat numbers on the session sheet can be tedious. hroot provides a bulk import feature to update participant variables via CSV upload or direct text pasting:

### 1. Accessing the Import Interface
- Navigate to the experiment dashboard and click on the **Participants** tab.
- Click the **Batch Set Status** button. This interface is accessible to administrators and experimenters who possess the `manage_showups` (Participation Documentation) privilege.

### 2. CSV Structure & Formats
The import requires a structured CSV format. The parser automatically detects delimiters (comma, semicolon, tab, or pipe) and decimal formats.
- **Mandatory Identifiers**: Each row must contain a column to identify the participant. The system looks for and matches against:
  - **Code**: The unique 6-character participant code (preferred for anonymity).
  - **Email**: The email address of the participant.
  - **ID**: The user's database ID.
- **Supported Variable Columns**:
  - **Status / Participation**: Can set the status to `noshow` (N), `showup` (S), or `participated` (P/T). The importer respects the same checkbox validation rules as the manual form.
  - **Usable (V)**: Indicates if the session data is scientifically usable (values: `true`, `1`, `y`, or `yes`).
  - **Payout (Auszahlung)**: Sets the payout amount earned in the session. The parser automatically handles numeric variables and local decimal separators.
  - **Seat Number (Sitzplatz)**: Sets the assigned cubicle or seat code.
  - **Allow Re-participation (R)**: Toggles whether the participant is permitted to sign up for another session within this experiment.

### 3. Step-by-Step Import Workflow
1.  **Prepare the Data**: Create an Excel or CSV sheet with the participant codes, payout values, and participation statuses.
2.  **Upload or Paste**:
    - **Upload File**: Select and upload the `.csv` file.
    - **Paste Text**: Copy the rows from your spreadsheet and paste them directly into the large text field.
3.  **Preview and Verify**:
    - The system parses the CSV data and displays a preview grid.
    - It highlights matched participants and shows the proposed updates side-by-side with their current status.
    - Any invalid codes, format errors, or duplicates are flagged as warnings.
4.  **Confirm and Commit**: Verify the preview lists and click **Commit Batch Status** to write the updates to the database in bulk. A summary screen displays the number of updated records.
