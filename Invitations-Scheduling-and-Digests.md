
This page describes the **Invitation Scheduling** features, **Digest Invitations**, and **Weekly Digests** in `hroot`.

---

## 1. Scheduled Invitations (Planen von Einladungen)

Instead of sending invitations to participants immediately, experimenters can plan and schedule invitations for future delivery.

- **Delayed Delivery**: Experimenters can set a specific date and time for invitations to go out.
- **Queue Management**: The invitations are added to a scheduled invitations queue (`ScheduledInvitation`). A background cronjob processes this queue and sends out the emails when the designated time is reached.
- **Controls**: Scheduled invitations can be edited, stopped, or sent immediately via the invitations administration panel (`invitations/:id`).

---

## 2. Digest Invitations (Sammel-Einladungen)

If a participant is eligible for multiple experiments, sending separate emails for each can overwhelm their inbox. **Digest Invitations** solve this by grouping invitations together.

- **Collated Email**: Instead of multiple emails, a single email is generated summarizing all currently available/open sessions for which the user is eligible.
- **Configuration**: These can be sent immediately or automatically in batches based on configured rules.

---

## 3. Weekly Digests for Experimenters

To keep researchers updated on their running studies, `hroot` sends an automatic **Weekly Digest** email.

- **Content**: The digest contains key metrics of the past week, such as:
  - Total participations.
  - Active and upcoming sessions.
  - Recruited users.
  - Budget status updates.
- **Settings**: The frequency (e.g. weekly) and specific weekday (e.g., Monday morning) for the weekly digest can be configured globally under Site Settings.
