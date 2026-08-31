
This page describes how `hroot` integrates with external survey platforms (like Qualtrics, oTree, LimeSurvey, SoSci Survey, etc.) using tracking tokens, completion links, and automatic slot management.

## Setup Overview

For online experiments, instead of conducting them in a physical laboratory, participants can click a customized external link to start. To track whether participants actually complete the survey and reward them accordingly, `hroot` uses **Completion Links (Callbacks)**.

## Admission Type

To use Online Surveys, your Experiment or Session must have the Admission Type set to **Online-Survey (`survey`)**. For an overview of other admission procedures in `hroot`, see the [Entrance](Entrance.md) documentation.

## How it Works

1. **Start Survey Link** (`/s/:experiment_id/:token`):
   When a participant is invited to an online experiment, they receive a unique URL containing their `sessiontoken`. When clicked:
   - `hroot` checks whether the experiment deadline is active.
   - For asynchronous sessions, `hroot` dynamically checks slot capacity and reserves a slot (`reserve_slot!`).
   - If slot check passes, the participant is redirected to the external survey platform.

2. **Redirect URL with Placeholders**:
   The external survey URL set in the experiment can include dynamic placeholders which `hroot` replaces before redirecting. Available placeholders include:
   - `#participant_id` or `#token`: The unique `sessiontoken` representing the participant's slot.
   - `#return_url`: The URL the participant must be redirected to when completing/exiting the survey.

3. **Completion Callbacks** (`/c/:completion_code/:status`):
   At the end of the external survey, the participant is redirected back to the `hroot` callback URL. The status is sent in the URL path (or passed as a parameter `p` / `participant_id` / `pid`):
   - **Completed** (`completed`): The participant successfully finished the survey. The slot is finalized (`complete_slot!`), the participant is marked as `participated = true` (`#T` checked), `usable = true` (`#V` checked), and their payment is set to the experiment's default session payout.
   - **Timeout** (`timeout`), **Failed Attention Check** (`failed`), or **Screened Out** (`screened`): Since the participant did not complete or see the experiment, they receive a "Showup only" status:
     - **Showup** (`#E`) is **checked**
     - **Allow Reparticipate** (`#R`) is **checked**
     - **Participated** (`#T`) is **not checked**
     - Slot is released (`release_slot!`) and payment is set to `0`. This allows them to register for other sessions of the same experiment.
   - **Re-participation Allowed** (`re-participation`): Participant did not complete but is allowed to sign up for other sessions in the same experiment (`#E` checked, `#R` checked, `#T` unchecked).

## Slot Management & Circuit Breaker

To prevent online studies from running out of control, `hroot` features built-in guardrails:
- **Slot Reservation**: For asynchronous/online sessions, slots are reserved during participation. If a participant exits without completing, the slot is eventually timed out and released.
- **Circuit Breaker**: If `hroot` detects anomalies (like too many failed callbacks or system issues), the built-in circuit breaker triggers automatically. While triggered, no new participants can start the survey (`circuit_breaker_triggered?` returns true), protecting the research budget from automated bots or script errors.

---

## Integration Examples (Redirects)

Below are detailed configuration examples for popular survey and experiment engines. 

In `hroot`, you can define these settings under the **Public Link & Integration** section of your experiment. Use the placeholder chips to inject variables dynamically.

### 1. oTree
oTree uses a built-in room feature to assign incoming participants.
- **External Survey Link (in hroot)**:
  `https://your-otree-server.org/room/my_room?participant_label={{sessiontoken}}`
- **Retrieving the Token in oTree**:
  The `participant_label` is automatically mapped by oTree. In your Python code, you can access the token using:
  `self.participant.label`
- **Completion Redirect (in oTree)**:
  At the end of your oTree app, direct participants to the return link using a HTML button or redirect script:
  `https://hroot-server.de/completion/ABCDEF?status=complete`
  *(Where `ABCDEF` is your experiment's unique completion code, and `complete` is the completion status token).*

### 2. LimeSurvey
- **External Survey Link (in hroot)**:
  `https://your-limesurvey-server.de/index.php/123456?hroot_token={{sessiontoken}}`
- **Retrieving the Token in LimeSurvey**:
  1. Go to the survey's **Panel Integration** settings.
  2. Create a new parameter named `hroot_token` to capture it from the URL.
  3. You can reference this token in your survey using the expression `{PASSTHRU:hroot_token}`.
- **Completion Redirect (in LimeSurvey)**:
  Under **Text Elements** -> **End URL**, enter your hroot completion URL:
  `https://hroot-server.de/completion/ABCDEF?status=complete`
  Enable the option **Automatically load URL when survey complete** so participants are redirected without clicking.

### 3. Qualtrics
- **External Survey Link (in hroot)**:
  `https://your-qualtrics-domain.qualtrics.com/jfe/form/SV_abc123?hroot_token={{sessiontoken}}`
- **Retrieving the Token in Qualtrics**:
  1. Open your survey in Qualtrics and go to **Survey Flow**.
  2. Add a new element of type **Embedded Data** at the very beginning.
  3. Set its name to `hroot_token` (leave value empty; Qualtrics will capture it from the URL parameter automatically).
- **Completion Redirect (in Qualtrics)**:
  1. Go to the **End of Survey** element in your Survey Flow (or edit the block).
  2. Under options, select **Redirect to a URL...**
  3. Enter your return link: `https://hroot-server.de/completion/ABCDEF?status=complete`

### 4. Gorilla.sc
- **External Survey Link (in hroot)**:
  `https://gorilla.sc/admin/project/12345?hroot_token={{sessiontoken}}`
- **Retrieving the Token in Gorilla**:
  Gorilla captures URL parameters as fields. In your task, you can access the variable `hroot_token`.
- **Completion Redirect (in Gorilla)**:
  In the Gorilla Experiment Tree:
  1. Add a **Redirect** node at the end of your protocol.
  2. Configure the Redirect node URL to point to: `https://hroot-server.de/completion/ABCDEF?status=complete`

---

## Survey Sets & Participant Surveys

`hroot` features an integrated **Survey System** to administer profile, registration, and screening surveys directly inside the application, reducing the need for external platforms for basic participant screening.

### 1. Survey Questions & Sets
- **Survey Questions**: Admins can define custom survey questions under the admin menu. Questions support various input formats and can be paired with pools.
- **Survey Sets**: Group questions together into a `SurveySet`. Sets can be configured as administrative views, screening sets, or profile surveys.

### 2. Integration & Flows
- **Profile Surveys**: Automatically prompted on the user's dashboard or account settings.
- **Screening Surveys**: Prompted during enrollment to screen eligible participants before allowing them to sign up for specific sessions.
- **Token Lists & Resolved URLs**: Administrators and experimenters can review the generated survey tokens and resolved redirect URLs within enrollment details and completion views for troubleshooting and auditing.
- **Active/Inactive Labels**: Displays active or inactive survey labels under the session management dashboard to easily track which sessions require surveys.

