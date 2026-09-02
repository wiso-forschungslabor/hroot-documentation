*   [Session overview](#session-overview)
*   [General settings for sessions](#general-settings-for-sessions)
*   [Grouped sessions](#grouped-sessions)
    *   [Creating Groups](#creating-groups)
    *   [Grouped session modes](#grouped-session-modes)
    *   [Removing groups](#removing-groups)
*   [Session reminders](#session-reminders)
*   [Deleting sessions](#deleting-sessions)
*   [CSV / Batch Session Management](#csv--batch-session-management)
    *   [Batch Session Creation](#1-batch-session-creation-batch-sessions-anlegen)
    *   [Bulk Updates in Session Lists](#2-bulk-updates-in-session-lists)
    *   [Bulk Deleting](#3-bulk-deleting)

---

## Session overview

When you open an experiment you will get to the "Sessions" tab. This page provides an overview of all sessions for the selected experiment.

For each session there are three buttons.

-	The first one "edit" opens a form similar to the form for the creation of sessions, but the fields are filled with the known data. 

-	The second one "participants" opens a page that shows which users are registered for the session.

It is possible to switch between these two options through tabs on the corresponding subpages.

-	The third button "actions" opens a menu with two options:

   -	"Duplicate" creates a new session and fills all data fields with the data from the origin session. Since most sessions of an experiment are similar except their time and date, this is a quicker way than adding each session individually.

   -	"Delete" deletes a session. It is not possible to delete a session with participants.

### Create new sessions

New sessions can be created with the button "create new session" in the sessions tab of each experiment. When creating a session you are asked to provide the necessary settings as in the "General setting for sessions".

## General settings for sessions

There are several settings in the "Options" tab of each session. These settings are used to show the session in the calendar and fill invitation email etc. with the relevant information. It is stated explicitly, when they are displayed to the participants during the sign up process.

At this point it is possible to change data of a session. It is possible to reschedule a session with participants, but there is no automatic mail to the participants.

-	Start date (mandatory field!)

	Date of the session. Shown during sign up.

-	Start time (mandatory field!)

	Start time of the session. Shown during sign up.

-	Duration in minutes (mandatory field!)

	Duration indicates hows how long the session will be for the participants. Up to 240 minutes the time interval is 15 minutes, other durations are 360, 720 and 1440 minutes. The duration is used to calculate the time when the session ends. This end time is shown during sign up.

-	Participants needed (mandatory field!)

	How many participants are needed to conduct the session.

-	Reserve participants (mandatory field!)

	How many additional pool members can register to ensure that there will be enough participants for the sessions, even if not all registered pool members show up. How many reserve participants should be invited is a matter of experience and cannot be answered here.

-	Description

	Description is internal and can hold a description of the session for experimenters. It is shown only in the options page of the session.

-	Information for participants

	Information which is displayed to the participants when they register for the session. It can contain additional criteria, or other information for the participants.

-	Setup time before (mandatory field!)

	Time for preparing the lab in minutes. 5 minute intervals from zero up to 60 minutes. This time is not shown in the calendar, but will be used to check for collisions.

-	Teardown time after (mandatory field!)

	Time for i.e. cleaning the lab in minutes. 5 minute intervals from zero up to 60 minutes. This time is not shown in the calendar, but will be used to check for collisions.

-	Group size

	In the field group size administrators can set the size of groups in which the participants shall be split if this is requested. This size is not applied in the software, it is just an information for whoever conducts the session.

-	Location

	Shows a drop-down list of predefined places in which a session may take place. Administrators are able to modify the list in the options section.

## Grouped sessions

Grouped sessions can be used to either randomize the participants into sessions or for experiments where the same pool members have to participate at more then one session.

Grouped sessions have to be created like every other session.

### Creating Groups

If there are at least tow sessions with no participants signed up in an experiment. The option "Group this session with ..." is made available under Actions in the sessions overview. The sessions are then shown as "Group 1". If there are any sessions left, they will be shown as ungrouped above the first group. Ungrouped session can now be added to a group with the Actions button or grouped with another ungrouped session to another group. Which will then be shown as "Group 2" below the first one. And so on. Once there is at least one participant in any session of a group you can not add sessions to this group.

### Grouped session modes

Once you have at least one session group, mode buttons appear above the session list. The modes apply to all grouped sessions of the experiment:

-   **Randomised (Zufallszuordnung)**:
    *   **Description**: Users are randomly placed within a session in a selected group.
    *   **Workflow**: When signing up for a session group, the user agrees to participate in any session of the group. The system automatically assigns them to a session with open capacity, aiming to distribute participants evenly across all sessions of the group. They receive a confirmation and reminders only for their assigned session.
    *   *Note*: Since participants can deregister, they could theoretically cancel and sign up again to attempt to get their preferred slot.

-   **All (Kopplung)**:
    *   **Description**: Users are registered for all sessions within the group.
    *   **Workflow**: This is used for multi-part studies where the same participants must attend all session parts. When registering, the participant is automatically registered for every session in the group and receives a confirmation listing all parts, as well as reminders for each.

-   **Mix & Match (Kategorien)**:
    *   **Description**: Users choose exactly one session from each category within the group.
    *   **Workflow**: Sessions within the group are categorized (using the `category` attribute, e.g., "Part 1", "Part 2"). The participant must pick one slot that suits their schedule from each of the available categories to complete their signup.

Once there is a participant in any session of a group it is not possible to change the mode.

### Removing groups

If there are no participants in any session of a group the sessions get an option "Remove from group", which will move the session to ungrouped sessions. If there would be left only one session in the group it will be moved to ungrouped sessions as well. You have to remove sessions from a group before you can delete them.

## Session reminders

From a sessions Options tab is the Session reminders tab available. Usually reminders are managed on an experiment level and configured during creation of the experiment. With this feature you are able to manage the reminders on the session level. But keep in mind: When both experiment level reminders and session level reminders are activated, participants will get two mails per session.

After activating the check box which enables the automatic reminder email, there are three fields to configure the reminder emails.

-	The time in hours before the session begins to send out the email.

-	The subject of the email.

-	The body of the email.

How to use the email features of hroot is described in [Sending out messages](https://github.com/wiso-forschungslabor/hroot-documentation/wiki/Sending-messages)

## Deleting sessions

Sessions can be deleted only when there are no participants signed up for it and they are not grouped with other sessions. Then it is possible to delete them with the "Delete" option in "Actions" on the session overview page or with the "Delete" button on the top of the sessions page itself. This button is only shown, when it is possible to delete the session.

---

## CSV / Batch Session Management

Starting with version 4.0, `hroot` allows creating and managing multiple sessions in bulk using the **Batch Session** features.

### 1. Batch Session Creation

Experimenters can quickly instantiate and configure multiple sessions at once by navigating to the experiment's sessions tab and clicking **Batch New Session** (`sessions/batch_new`).

#### Interactive Input Grid
The interface provides a dynamic grid/table where rows representing individual sessions can be added or manipulated:
*   **Add Session**: Adds a new session row to the table.
*   **Fields per Row**:
    *   **Date**: The date of the session.
    *   **Time**: The start time of the session.
    *   **Treatment**: Lists all treatments configured for the experiment. Each treatment has a checkbox to enable it for this session and a number input for the target participant count. If multiple treatments are checked, the system automatically distributes the total needed participants among them (adjustable manually).
    *   **Category**: Only relevant for **Mix & Match** group sign-up mode (participants must register for exactly one session from each category).
    *   **Token Source**: Choose the participant token source. If set to **upload**, a file upload input appears to attach the token file directly to that row.

#### Selection and Grouping
Sessions in the grid can be grouped together using the checkboxes on the left:
*   **Group Selected**: Groups the checked sessions into a `SessionGroup` (assigned a distinct background color and group badge like *Group 1*, *Group 2*, etc.).
*   **Ungroup Selected**: Removes the grouping mapping for the checked sessions.
*   **Delete Selected**: Removes the selected rows from the batch creation list.

#### Bulk Edit Modal
To quickly apply identical settings to multiple sessions in the grid, check the sessions and click **Bulk Edit**. This opens a modal to specify:
*   **Location**: Predefined venue/room for the selected sessions.
*   **Duration**: Length of the sessions in minutes.
*   **Needed & Reserve**: Total target and reserve participant counts.
*   **Payout Settings**: Session payout amount, currency/payment types, rounding rules, and payout additions.
*   **Setup/Teardown Times**: Pre-session and post-session staff prep times.
*   **Bulk Treatment Allocation**: Enable specific treatments and distribute count splits across the selected sessions simultaneously.

Once finalized, clicking **Save Batch** verifies all sessions, checks for room collisions, and creates the sessions in bulk.

### 2. Bulk Updates in Session Lists

If multiple existing sessions need adjustment, you can check multiple sessions from the main sessions list and apply bulk actions:
- **Location & Duration**: Update the venue and length of all checked sessions.
- **Participation limits**: Adjust target needed/reserve capacities.
- **Payout configuration**: Set payout values, payment types (currencies), or rounding logic.
- **Re-allocate Treatments**: Recalculate target splits across checked sessions.

### 3. Bulk Deleting

Select multiple sessions from the index list to delete them in a single batch. The system will automatically run safety checks to prevent deletion of sessions that already contain participants, waiting lists, file uploads, or pending emails.
