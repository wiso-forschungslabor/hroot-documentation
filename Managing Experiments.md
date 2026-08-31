*   [Using the experiment list](#using-the-experiment-list)
*   [General settings on Experiments](#general-settings-on-experiments)
*   [Experimenter privileges](#experimenter-privileges)
*   [Reserving locations for an experiment](#reserving-locations-for-an-experiment)
*   [1. Experiment-Level Settings & Inheritance](#1-experiment-level-settings--inheritance)
*   [2. Procedures & Versions](#2-procedures--versions)
*   [3. Project Steps (Phases & Tasks)](#3-project-steps-phases--tasks)
*   [4. Lab Reports & Reporting](#4-lab-reports--reporting)
*   [5. Session Team Assignment](#5-session-team-assignment)
*   [6. Treatment-Management & Reporting](#6-treatment-management--reporting)
*   [7. Auto-Assignment (Automatch) & Saved Filters](#7-auto-assignment-automatch--saved-filters)
*   [8. Grouped and Coupled Sessions](#8-grouped-and-coupled-sessions)

---

## Using the experiment list

The experiment list is accessible over the menu entry "Experiments". It delivers a complete list of all experiments sorted in two groups. The first group are active experiments with a blue title and the second one are the "closed" experiments with a grey title. The active experiments are sorted by the time of their creation, while the closed experiments are grouped behind them and are sorted by the date of their last session.

The Session list gives a set of key informations about the experiments. These informations include the name and description, the tags assigned to the experiment, as well as the assigned experimenters. In the right section are listed the information whether its possible for participants to register for free places in sessions, the total number of sessions, the date of the first and the last session and the number of currently assigned participants.

### Searching experiments

At the top of the page is a search bar to search for specific experiments. The search catches all occurrences of the states term in the name, the description, the tags and the experimenters of an experiment and reduces the list to all these experiments.

Another option is to just click on a tag of an experiment, and the filter will reduce the list to all experiments with the given tag.

### Creating new experiments

In the list overview it is possible to create a new experiment, with the button “New experiment“. First you have to set some general informations about the experiment. 

As soon as an experiment is created, sessions can be crated as well as participants and experimenters can be assigned.

## General settings on Experiments

The general settings of an existing experiment can be found on the experiments Options->General tab. Experimenters need the access right "edit common data" to access this page.

### Information

The general settings of an experiment include information about the experiment for internal usage.

-	Name (mandatory field!)

	An experiment name must be entered here. This name is only used in the backend accessible to the administrators and other experimenters.

-	Description

	An experiment description can be entered here in free text form. This is used to give a short information about the experiments in the list view, accessible for administrators and experimenters.

-	Contact information

	Experimenters contact information can be entered here. This is only visible in the general tab of an experiment.

-	Experiment is closed

	This option is used to seperate active and completed experiments in the experiments list.

-	Include this experiment in statistics

	This option has currently no function.

### Email sender

There are several emails send in connection with an experiment. (For more Info see [Emails]) Usually the default email address is used to fill the "From" address in all emails. This default address is set by the administrator during installation. When another email shall be used to label the emails it can be entered here. If this field is left empty, the default address will be used.

### Tags

Experiments can be tagged here so that they can be categorized precisely. Every experiment can have any number of tags. Existing tags are suggested during typing.

The tagging system is used to identify and group experiments during assignment of participants. Every lab has to build its own tags. It's advisable to use the experiment type for example "public good" as a tag. But the tags are not limited to this. Nevertheless every lab should create its own ruleset for the tags. Otherwise the tags would become blurred and their value greatly reduced.

### Experiment exclusion

This option can be used to exclude participants of other experiments either by name or by tag. 

**Beware: This option will just be checked when the participant tries to register for a session in this experiment. So neither will this prevent the participant to sign up for the excluded experiments afterwards, nor will this exclusion be documented.**

-	Exclude experiments by tags

	Will prevent sign up by all participants which have participated in experiments with any of the tags.

-	Exclude experiments

	Will prevent sign up by all participants which have participated in any of the named experiments.

## Experimenter privileges

The experimenters subsection of options allows assigning experimenters to an experiment. The experimenters conduct the experiment and need specific permissions to access or edit experiment details. When clicking "add people", a drop-down menu lists all assignable users (experimenters and administrators).

After adding a user, you can configure their specific access rights. An experimenter can be granted multiple rights, and multiple experimenters can be assigned to the same experiment.

### Detailed Privilege Breakdown and System Effects

The system enforces granular access controls based on the following assigned rights:

1. **edit common data (`edit_common_data`)**
   - **Effect**: Allows the experimenter to edit the experiment's name, description, contact details, tags, and settings. They can also access the "Experiment reminders" configuration to schedule automatic email/SMS reminders or edit their subjects and templates.

2. **edit privileges (`edit_privileges`)**
   - **Effect**: Grants the ability to assign other experimenters to this experiment and edit their privileges (including modifying their own rights).

3. **manage sessions (`manage_sessions`)**
   - **Effect**: Allows creating new sessions, duplicating existing sessions, creating location bookings, editing session details (e.g., needed/reserve limits, locations, payouts), and deleting sessions. This right also grants access to export session data (Excel/CSV).

4. **manage participants (`manage_participants`)**
   - **Effect**: Allows researchers to search and assign participants from the subject pool to the experiment, view registration history, and move or remove participants from sessions.

5. **manage showups / attendance (`manage_showups` / `manage_attendance`)**
   - **Effect**: Grants permission to edit the participation status on the session sheet (e.g. marking participants as "showed up", "participated", "usable", or "no-show").

6. **view personal data (`view_personal_data`)**
   - **Effect**: If this right is **granted**, the experimenter can view real-time personal information of participants (first name, last name, email, matriculation number, and custom fields). If this right is **denied**, all table columns with personal identifiers are masked or removed, showing only the internal participant's unique code to preserve anonymity.

7. **send session messages (`send_session_messages`)**
   - **Effect**: Allows sending custom bulk email messages or SMS texts directly to participants registered in a specific session.

8. **manage invitations (`manage_invitations`)**
   - **Effect**: Allows managing the invitation emails configuration, triggering manual invitation runs, setting invitation batch size thresholds, and editing the invitation/confirmation email templates.

9. **manage procedures (`manage_procedures`)**
   - **Effect**: Allows managing procedures, creating new drafts, uploading procedure assets/images, and publishing procedure versions.

The very flexible rights management system ensures that on one hand all needed actions can be performed, while on the other hand protecting participant privacy by restricting access to personal identifying data to only authorized experimenters.

On the site settings page, administrators can configure **default privileges** that are automatically assigned to any new experimenter added to a project.

## Reserving locations for an experiment

Often one wishes to reserve time in a location before actually creating the sessions. The "Booking" feature was introduced for this. After creating an experiment in the tab "Booking" bookings can be created which are not available to sign up for and are more flexible in their time and date settings. The reservation is not enforced, but they are displayed in the calendar and included in the check for overlapping sessions.

A booking consists of at least a start date, an end date and a location. If the box for "full day" is checked. Then all days from the start date to the end date are reserved. If the box is left unchecked a start time and end time can be set. In addition a description can be set to provide more information. The description is displayed in the info pop up in the calendar.

The booking tab provides a list with all reservations for this experiment. Stating the time and date for the reservation and the location. There are buttons to edit and delete the bookings.

---

## 1. Experiment-Level Settings & Inheritance

Settings defined at the **Experiment level** act as default configurations that automatically populate ("inherit") into newly created sessions.
- **Inherited Fields**: Session payout, payout increases, round-up parameters, preparation/teardown times, group size, and location.
- **Overrides**: Modifying these fields on individual sessions overrides the experiment-level defaults for that specific session without changing the parent experiment's configuration.

### Experiment Auto-Close
Experimenters can automate the closing of experiment registrations:
*   **Enable Auto-Close**: Toggle option in experiment settings.
*   **Threshold (%)**: Specify a threshold percentage. The system will automatically close registrations for all sessions (marking them closed and turning off auto-open queues) once the number of registered/confirmed participants exceeds the required treatment target by the specified threshold percent (e.g. 10% more than needed).

---

## 2. Procedures & Versions

Experimenters can define **Procedures** detailing exact steps or protocols to follow during session execution.
- **Procedure Versions**: Every publish action creates a new immutable version of the procedure.
- **Diff Comparison**: Experimenters can view a line-by-line diff comparison between different procedure versions to track changes.
- **Session Cloning**: Procedures can be cloned/copied to specific sessions and reset if needed.

---

## 3. Project Steps (Phases & Tasks)

Under the **Running Experiments** dashboard and the experiment's planning tab, researchers can define structured project steps:
- **Phases**: High-level stages of the experiment (e.g. preparation, execution, post-processing).
- **Tasks & Task Templates**: Standardized task definitions assigned to phases. These can be defined globally as templates or created specifically for a single experiment.
- **Session-specific Tasks**: Sub-tasks linked directly to a single experimental session, ensuring that all session-specific preparation or cleanup duties are performed and tracked.
- **Task Buckets & Project Templates**: Selecting a project template filters the visible task buckets to only show relevant phases. If a template is changed, the system ensures that buckets containing active tasks remain visible.
- **Recruitment Progress**: Displays real-time metrics showing the number of enrolled subjects versus the target capacity, the number of future sessions, and completed sessions.

---

## 4. Lab Reports & Reporting

The **Lab Report** tab aggregates key scientific and execution metrics after a session or experiment is complete.
- **Session Metrics**: Tracks session duration, delays, and remarks.
- **Field Observations**: Allows logging technical problems, payout increases, early payouts, vandalism/graffiti, and meeting points.
- **Team Roles & Verification**: Logs which experimenters were responsible for executing the session (`paid_by`/`counted_by` and `attended_started`), requiring explicit verification.
- **Email Dispatch**: The laboratory report is **not** sent automatically. Instead, experimenters or administrators must manually trigger the dispatch by clicking the **Send Email** button. The report is then compiled and sent directly to the email address of the triggering administrator/experimenter (confirming the payout details, cash transactions, and logged tasks).
- **Usability Status (Usable - "V")**:
  *   Experimenters can mark individual participant data as scientifically **usable**. This is represented by a checkbox on the session participants list.
  *   *Rules*: A participation can only be marked as usable if the user actually showed up and participated (cannot be usable if marked as no-show).
  *   *Metrics*: The user's total count of usable participations is tracked on their profile (`usable_count`).
  *   *Warnings*: If the total number of participated subjects differs from the number of usable subjects, the report displays a warning note indicating the mismatch.
  *   *External Sync*: When syncing hours to external tools like Kimai, researchers can toggle between syncing the absolute participated count ("T") or only the scientifically usable count ("V").
- **Finalization**: Reports can be marked as "packed" (finalized) to prevent further edits.


---

## 5. Session Team Assignment

In addition to global experiment privileges, researchers can assign specific roles to team members on a per-session basis via the **Team Assignment** popup:
- **Roles**: Administrator, Supervisor, Logic Controller, Observer, or custom roles.
- **Anonymization**: For non-admins, experimenter names can be masked in reporting views.

---

## 6. Treatment-Management & Reporting

Each experiment can define multiple **Treatments** (experimental conditions/cells) with specific targeting rules:
- **Participation Split**: Track target required participations against actual participations.
- **Socio-demographic Statistics**: Compute and display pool statistics (such as average age, gender ratios, or custom fields distribution) compared to the eligible pool.
- **Participant Remarks**: Participant feedback or remarks are integrated directly into the experiment's session reports.

---

## 7. Auto-Assignment (Automatch) & Saved Filters

To automate participant recruitment, researchers can use **Automatch**:
- **Match Criteria**: Define specific demographic/filter rules (using custom fields, age, or past participation).
- **Auto-Enrollment**: If enabled, the background scheduler automatically checks for newly registered or confirmed users matching these filters and enrolls them in the experiment.
- **Filter Templates**: Experimenters can save their custom participant search criteria as reusable filter templates.

---

## 8. Grouped and Coupled Sessions

When multiple sessions are grouped together (`SessionGroup`), administrators can set one of three signup modes:
1. **Randomized**: The participant signs up for the group and is randomized to exactly one session that has open slots.
2. **Coupled / All Sessions**: The participant registering for the group must attend all sessions within the group (useful for multi-part studies).
3. **Choose One Per Category (Mix & Match)**: The sessions in the group are split into categories (defined by the `category` attribute on sessions, e.g. "Part 1", "Part 2"). The participant selects exactly one session from each category within the group.
