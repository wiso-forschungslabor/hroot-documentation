### Users and roles

Users in hroot are categorized into four distinct roles:

- _Users_ (Subject / Participant accounts) are typically participants in experiments. They sign up to hroot via the registration page, confirm their email address, and receive invitations to experiments. Once invited, they can log in to register for sessions, manage their profile data, and request payouts.

- _Experimenters_ have targeted permissions scoped to their assigned experiments. They can manage sessions, send messages to registered participants, conduct session admission (check-in), and complete session lab reports. They do not have access to global system settings or unassigned experiments.

- _Administrators_ manage day-to-day lab and experiment operations. They have broad access across all parts of the system: browsing the user database, managing subject pools, creating experiments, defining task templates, and configuring general settings.

- _Banking-Administrators_ hold the highest privilege level in hroot. In addition to all standard administrator capabilities, they have exclusive access to financial governance, sensitive bank details (IBAN/BIC), SEPA transfer exports, cash advances/budgets, and full team task/availability governance.

> [!NOTE]
> The term **Staff** (*Personal*) refers collectively to all team members with administrative or experiment management capabilities (Administrators, Banking-Administrators, and Experimenters / Lab Assistants) who execute tasks, manage sessions, or record shift availabilities.

### Experiments and Sessions

Experiments are the core of the hroot system. An experiment interacts with different categories of users:
- **Assigned users**: registered pool users who are selected to receive invitations for the experiment, but have not yet necessarily signed up for a session.
- **Participants**: users who actually sign up for and participate in a specific session.
- **Experimenters**: staff members assigned to the experiment who can change experiment settings, manage sessions, take attendance, and interact with the participants.

An experiment consists of one or more sessions, each session has a number of participants and a definitive time and location. Invited users can choose a session and experimenters can keep track of people who showed up, people who didn't show up and a number of other variables.

A typical experiment has the following lifecycle: 

- The experiment is created, basic settings are entered
- The sessions are created and planned
- Users are selected for the invitation process based on various criteria
- invitations are mailed to the users and the session registration is opened
- users visit the website using a link in the invitation email and sign up for experiments
- at some point, the session registration might be closed, if the sessions are full
- 1 or 2 days in advance, the participants of a session are reminded via email
- people show up to sessions
- all sessions are finished, and experimenters keep track of the participants

Most of these steps are supported by hroot.

### Cron-Jobs

To send out emails (notifications, invitations, reminders), a background task must be installed on the hroot server. This is called a cron job. It is a small script which is executed every 5 minutes and sends out emails and performs a few maintenance tasks.

### Emails in hroot

Many of the emails in hroot can be configured (invitation emails, reminder emails). To personalize emails you can use a couple of variables to insert links, session times and user names into emails. Be aware that although the system interface can have different languages, we don't store the users language in the database. Emails are always in one language, and you have to be careful to use the correct variable for session dates, since the english date format differs from the german date format. If you want to send emails to a multilanguage group, you should send out emails containing your text in two languages.

### Configurable custom fields

In the current version of hroot, we have included a mechanism to extend the database with your own field. We currently support text fields, selection fields (1 of n / n of m value selection) and date fields. The use of the custom fields requires quite a bit of configuration mainly due to internationalization. Currently this feature is not very sophisticated, but it's a start, and we will improve it over time.

Many of the fields which are included in the base version of hroot are already using this mechanism, so it is also easy to remove fields you don't need. We have chosen the current field set, as it is the field set which ORSEE used.

### File uploads

The current version of hroot also has a file upload mechanism. This is currently restricted to administrators, we will improve this feature in the next versions. As an administrator, you can upload files to experiments and sessions and share them with other administrators.
