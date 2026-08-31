
In `hroot`, you can configure how participants are admitted and checked into experiment sessions. This behavior is defined at the experiment or session level using the **Admission Type (`admission_type`)** setting.

Depending on whether your study is conducted in a physical laboratory, asynchronously online, or synchronously online with high concurrent traffic, you can select the most appropriate admission procedure.

---

## The Four Admission Types

### 1. Classic / Manual (`classic`)
*   **Best for**: Standard physical laboratory experiments with manual registration checklists.
*   **How it works**: Experimenters manage attendance using traditional printed lists or manually checking off participants in the web interface. 
*   **UI Impact**: The special online "Admission" and "Queue" tabs are hidden on the session detail pages since check-in is handled manually.

### 2. QR-Code Admission (`qr_code`)
*   **Best for**: Physical laboratory experiments where you want to automate and speed up the check-in process at the door.
*   **How it works**: Participants receive a unique QR code in their registration and reminder emails. At the lab door, experimenters scan these QR codes using a tablet or webcam to confirm attendance, collect privacy consent, and assign seats automatically.
*   **Details**: For setup and options, see [QR Code Admission](QR-Code-Admission.md).

### 3. Online Waiting Room (`waiting_room`)
*   **Best for**: Synchronous online experiments (like multiplayer oTree sessions) that suffer from high show-up variance and require strict quota balancing.
*   **How it works**: Participants join a virtual waiting lounge before the session starts. At the scheduled time, the system performs a randomized draw (taking quotas into account) to select the exact number of needed players. Drawn players are redirected to the study, while unselected players are paid a show-up fee and released.
*   **Details**: For setup and options, see [Online Waiting Room](Online-Waiting-Room.md).

### 4. Online Survey (`survey`)
*   **Best for**: Asynchronous, individual online studies (like Qualtrics or LimeSurvey questionnaires).
*   **How it works**: Participants register for a session slot or click a public registration link, then immediately start the survey. The system tracks slots, handles callback redirects on completion, and releases timed-out reservations.
*   **Details**: For setup and options, see [Online Surveys and Completion Links](Online-Surveys-and-Completion-Links.md).
