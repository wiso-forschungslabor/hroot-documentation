When sending emails in hroot, it is possible to include a variety of variables to include session times, locations and information about whether a session is a single event of belongs to a group of sessions. We will discuss several examples on this section to guide you through the different possibilities.

## The Communication Matrix

The central communication matrix under `/options/communication` defines which channels (Email, SMS, or Push notification) are active and configured for each of the notification templates. 

*   **Email**: The primary communication channel. Most notification types are sent via email.
*   **SMS**: A supporting channel for urgent updates, particularly for session reminders shortly before a session starts. SMS must be configured and enabled globally before it can be activated in the matrix.
*   **Push**: Real-time push notifications for mobile devices or browsers, if configured and supported.

In the communication matrix, administrators can check/uncheck columns to determine which notification types are allowed to use which channels.

## Notification Types and Trigger Conditions

hroot supports 15 distinct notification templates. Below is the list of all templates, their purpose, who receives them, and the exact trigger conditions:

1.  **Experiment Invitation**:
    *   **Trigger**: Triggered manually by an administrator or experimenter when inviting pool members to an experiment.
    *   **Recipient**: Pool members assigned to the experiment who match the target demographic filters.
    *   **Note**: This is the standard, individual invitation email.

2.  **Digest Invitation**:
    *   **Trigger**: Sent as a complement to normal invitation emails. It bundles multiple active experiments into a single digest message. It is triggered either via a background cronjob at predefined intervals or manually.
    *   **Recipient**: Pool members who are eligible for multiple open experiments.
    *   **Purpose**: Helps reduce email volume and prevent spam.

3.  **Session Confirmation**:
    *   **Trigger**: Sent automatically immediately after a participant successfully registers for a specific session.
    *   **Recipient**: The registered participant.

4.  **First Session Reminder**:
    *   **Trigger**: Sent automatically a configurable number of days/hours before the session starts.
    *   **Recipient**: All registered participants for that session.

5.  **Second Session Reminder (SMS)**:
    *   **Trigger**: Sent automatically a short time (configurable hours/minutes) before the session starts, typically via SMS only.
    *   **Recipient**: Registered participants who have provided a mobile phone number.

6.  **QR Admission Ticket / Reminder**:
    *   **Trigger**: Sent automatically before the session, providing the participant with their individual QR code for automated check-in.
    *   **Recipient**: All registered participants for a session that uses QR code admission.

7.  **Waiting List Updates**:
    *   **Trigger**: Triggered automatically when a registered participant cancels and a person from the waiting list is promoted to a regular seat, or when the waiting list status changes.
    *   **Recipient**: The promoted participant.

8.  **Session Completion**:
    *   **Trigger**: Sent after the session has taken place, once the administrator/experimenter logs the participation statuses (e.g., attended, paid) and marks the session report.
    *   **Recipient**: Participants who completed the session.

9.  **Missing Matriculation Proof Warning**:
    *   **Trigger**: Sent automatically when a student's uploaded matriculation proof document has expired or is missing.
    *   **Recipient**: The student/user.

10. **No-Show Warning**:
    *   **Trigger**: Sent automatically when a participant is marked as "No-Show" (unexcused absence) in the session completion interface.
    *   **Recipient**: The absent participant.

11. **Inactivity Warning 1**:
    *   **Trigger**: Sent automatically after a long period of inactivity (e.g., 11 months without login/participation) to request that the user verify their profile data.
    *   **Recipient**: The inactive user.

12. **Inactivity Warning 2**:
    *   **Trigger**: Sent automatically shortly before the account is deleted due to persistent inactivity.
    *   **Recipient**: The inactive user.

13. **Choose Password Link**:
    *   **Trigger**: Sent when a new user is manually created by an administrator, or when an imported/inactive account is activated, containing a secure link to set their password.
    *   **Recipient**: The newly created or activated user.

14. **Registration Confirmation**:
    *   **Trigger**: Sent automatically immediately after a participant registers online.
    *   **Recipient**: The newly registered participant (contains a verification link to confirm the email address).

15. **Password Recovery**:
    *   **Trigger**: Sent on demand when a user clicks the "Forgot Password" link on the login page.
    *   **Recipient**: The user requesting the reset.

---

For detailed configuration of specific email types and formatting options, see:

1. [Invitation emails](Invitation-emails.md)
2. [Confirmation emails](Confirmation-emails.md)
3. [Session reminder emails](Session-reminder-emails.md)
4. [Default locale and date formats](Default-locale-and-date-formats.md)
5. [SMS and Push Notifications](SMS-and-Push-Notifications.md)
