
The **QR-Code Admission (`qr_code`)** system is designed to streamline and automate participant check-ins at the physical laboratory door, reducing queue times and manual entry errors.

---

## How It Works

1.  **Code Distribution**: When a participant registers for a session configured with the QR-Code Admission type, they automatically receive a unique QR code.
    *   The QR code is embedded in the registration confirmation email.
    *   It is displayed on their participant dashboard under their active sessions.
    *   It is included in automated session reminders (sent via Push/SMS if enabled).
2.  **Door Scan**: At the lab entrance, the experimenter opens the **Admission Scanner** page on a mobile device, tablet, or laptop equipped with a camera.
3.  **Automatic Verification**:
    *   Scanning the participant's QR code verifies their registration in real-time.
    *   **Privacy Consent**: The scanner interface displays a prompt asking for the participant's confirmation of the study's privacy policy at the door.
    *   **Seat Assignment**: Upon confirmation, the system dynamically assigns a cubicle/seat number to the participant from the active location layout.
    *   **Database Check-in**: The participant's attendance status is set to `showed_up = true` and `participated = true` instantly.

---

## Configuration & Options

To utilize QR-Code Admission, configure the following settings in your Experiment or Session:

*   **Admission Type**: Set to `qr_code`.
*   **Notification Reminders**:
    *   Under experiment settings, enable **QR Check-in Notices for Participants**.
    *   Configure **QR Admission Reminder via Push/SMS** to automatically dispatch the QR codes via push notifications or SMS gateway a set duration before the session begins.
*   **Location Seat Layout**:
    *   Ensure the assigned **Location** in Site Settings has a list of active seat numbers or seat ranges defined, so the dynamic seat allocator can assign seats sequentially without duplicates.
*   **Permissions**:
    *   The scanner page requires camera access permissions in the browser of the tablet or mobile device being used at the door.
