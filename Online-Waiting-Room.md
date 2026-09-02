
The **Online Waiting Room (`waiting_room`)** is a virtual lounge system specifically designed for synchronous online experiments (such as multiplayer oTree or z-Tree/clir experiments) where participant show-up rates fluctuate, but a precise number of active players is required to start a session.

---

## The Workflow

1.  **Lobby Open**: A virtual lounge page opens on the participant's dashboard a set number of minutes before the scheduled session start.
2.  **Joining & Consent**: Participants click to enter the waiting room lounge.
    *   They are prompted to confirm their identity (confirming phone number and/or matriculation details if required).
    *   They must confirm privacy/participation consent.
    *   A live status screen informs them to wait for the draw.
3.  **The Draw**:
    *   **Automated Draw**: Once the draw time is reached, `hroot` background cron tasks execute a randomized selection of participants.
    *   **Manual Draw**: The experimenter can initiate the draw manually from the session dashboard.
    *   **Quota Integration**: If quotas are defined, the draw algorithm dynamically checks quotas to ensure the selected player group matches demographic targets.
4.  **Token Swap & Redirect**:
    *   Drawn participants are immediately redirected to the active experiment URL with their unique participation tokens.
5.  **Showup-only Payments**:
    *   Participants who joined the lounge but were not drawn are automatically marked as **Show-Up Only** (`#E` checked, `#R` checked, `#T` unchecked).
    *   They are automatically credited the configured show-up fee.
    *   Their reservation slots are released, allowing them to register for future sessions of the same experiment.

---

## Configuration & Options

When editing an Experiment or Session, you can configure the following waiting room parameters:

### Timings & Windows
*   **Waiting Room Opens (Minutes Before)**: How early participants can join the virtual lounge (default: `30` minutes).
*   **Waiting Room Closes (Minutes After)**: Deadline for joining. Late participants cannot enter the lounge after this timeframe (default: `1` minute after start).
*   **Reading Puffer (Minutes)**: Grants reading/instruction buffer minutes.
*   **Draw Duration (Seconds)**: Active duration for the randomized draw screen countdown (default: `120` seconds).

### Draw & Quotas
*   **Draw Mode**: Choose between `manual` (experimenter starts the draw) or `auto` (automated cron-based draw).
*   **Draw Delay (Minutes)**: Delay after the session start time before the automated draw triggers (default: `5` minutes).
*   **Draw Size / Participants Needed**: The number of active players to draw for the session.
*   **Waiting Room Quota Mode**: Toggles whether quota matching rules should be strictly enforced during the draw.

### Verification Checkboxes
*   **Confirm Phone**: Asks participants to confirm and verify their phone number upon entering the lounge.
*   **Confirm Matriculation**: Asks participants to confirm their student matriculation number.
*   **Waiting Room Show-Up Fee**: The amount paid to unselected participants who joined the lounge but were not drawn.
*   **Waiting Room Redirect URLs**: The destination URL where drawn players are sent (with token placeholders).

---

## Background Architecture
The Online Waiting Room relies on background tasks:
*   A background cron task runs every minute to clean up timed-out lounges, handle automated draws, and process payouts.
*   The **Payout Importer** utility can be used by financial administrators to review and import waiting room show-up payouts in bulk into the cash registers system.
