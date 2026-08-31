When you are logged in with the role 'admin' or 'banking_admin', you can browse all experiments in the database using the **Experiments** page (5th link "Experiments" in the main navigation menu).

In the list overview it is possible to create a new experiment, via the menu item “New Experiment“. Moreover in a typical installation you will see:

* the name of the experiment in blue, if the experiment is active
* the name of the experiment in gray, if the experiment is done
* on the right side: information "Registration is inactive", if users cannot register for the experiment
* on the right side: information "Registration is active", if users can register for the experiment;
* on the right side: information if currently sending invitations.

If you select an experiment, an overview of all sessions (grouped and ungrouped) for the selected experiment will be shown.

In the overview you can create new sessions, edit existing sessions, view participants, duplicate sessions, and delete sessions.

### Grouping and Ungrouping Sessions
You can group or ungroup sessions in two ways:
1. **In the Sessions List**: In each session's **Actions** (*Aktionen*) dropdown menu, options to group sessions appear automatically:
   - *Group this session with...*: Displays other ungrouped sessions that currently have no participants registered.
   - *Add to group X*: Adds the session to an existing session group (provided the group has no participants yet).
   - *Remove from group*: Ungroups a session (visible for grouped sessions that have no participants yet).
2. **In Batch Creation**: When creating sessions via the **Batch-Sessions anlegen** tool (accessed via the arrow dropdown next to "New Session"), select multiple session rows and click the toolbar buttons **Markierte gruppieren** (*Group selected*) or **Gruppierung aufheben** (*Ungroup selected*).

New sessions can be created with the button "Create new session" or "Batch-Sessions anlegen". You need to enter all relevant session data, such as date and time (start and duration), participants needed, reserve participants, setup time, etc.

---

## Releasing Sessions & Auto-Opening

When an experiment has multiple sessions, administrators can manage participant registration behavior on a per-session basis and automate the opening of sessions as they fill up.

### 1. Releasing Individual Sessions for Registration
In the sessions list of an experiment, each session has a color-coded registration status button. Clicking this button cycles through three states:
*   **Open (Green, Unlock Icon)**: Registration is active. Participants can register directly. Auto-opening logic is inactive for this session.
*   **Auto (Blue, Magic/Wand Icon)**: Registration is active and the session is subject to the **Auto-Open** system. If the session is within the auto-open limit, participants can register. Otherwise, it is placed in the auto-open queue (status: **In queue**).
*   **Closed (Red, Lock Icon)**: Registration is inactive. No sign-ups are allowed.

### 2. Auto-Opening Sessions for Registration
The Auto-Open system is designed to keep only a specific number of sessions open for registration at any given time. As soon as the currently open sessions fill up (or are completed/closed), the system automatically unlocks and opens the next chronological session in the queue.

*   **Global Setting**: Set via the feature toggle **Auto-Open Sessions (count)**. This defines the default number of sessions that should be open simultaneously. Setting it to `0` disables queueing (all sessions with the "Auto" state will be open immediately).
*   **Experiment Override**: Configured per experiment via **Auto-Open Sessions (count)** in the experiment settings form. This value overrides the global setting for this specific experiment.
*   **In queue (Session opening planned)**: Sessions that are set to "Auto" but exceed the limit are marked as "In queue" and will automatically activate once earlier sessions are filled.

---

## Multipart Studies: Mix & Match and Time Gap Validation

For experiments that consist of multiple parts (e.g., Part 1, Part 2, and Part 3), sessions can be grouped together into a **Session Group**. `hroot` supports three modes for grouped sessions:
1. **All**: The participant must attend all sessions in the group (usually fixed dates/times).
2. **Randomised**: The participant signs up for the group but is randomly assigned to one of the sessions.
3. **Mix & Match (Categories)**: Sessions are assigned to categories (representing parts of the study). The participant must pick exactly one session from each category.

### Time Gap Validation
In **Mix & Match** mode, researchers can enforce specific chronological constraints and time gap limits between the chosen sessions:
- **Chronological Order**: The system automatically validates that the chosen sessions follow the chronological order of the parts (Part 1 -> Part 2 -> Part 3).
- **Minimum Gap**: Configurable in hours (e.g. `24` hours). The time difference between consecutive parts must be at least this duration. This is useful to ensure participants have enough time between parts (e.g., overnight sleep, recovery time).
- **Maximum Gap**: Configurable in hours (e.g. `48` hours). The time difference between consecutive parts must not exceed this duration. This ensures that the study parts are completed within a reasonable timeframe.

These gap limits are enforced both in the **Frontend (JavaScript)** on the confirmation page (where validation errors are displayed in real-time and block the registration button) and in the **Backend (Controller)** when processing the registration to prevent double-bookings or manipulation.

---

## Quota and Visibility Control

To control the demographic composition of participants in an experiment, `hroot` features a strict quota management system:
- **Experiment and Session Quotas**: Quotas can be defined based on user attributes (such as gender, course of study, age, matriculation status, or subject pool cohort).
- **Flexible Comparison Operators**: Quotas support comparison operators (`=`, `!=`, `>`, `<`, `>=`, `<=`). This allows matching complex ranges (e.g., age `>= 18` and age `<= 30`, or registration date comparisons).
- **Administration & Creation**: Quotas are configured via an interactive inline row editor (using a JavaScript row helper) when creating or editing experiments.
- **Quota Overrides**: In the session report form, experimenters and administrators can temporarily override quotas if manual adjustments are required for a particular session.
- **Real-Time Status Panel**: The session participants list view features a **Current Quota Status Panel** showing progress bar meters and checks for each active demographic rule to see how many slots are filled vs. remaining.
- **Validation on Registration**: Quotas are validated dynamically when a participant registers. If a specific quota is full for an experiment or session, those sessions are automatically hidden from the matching participants' dashboard to avoid registration frustration and ensure a clean participant experience. If they try to register via direct links, they will be blocked by the quota verification system.
