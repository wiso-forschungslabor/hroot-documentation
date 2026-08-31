
With the new version of hroot the calendar got a overhaul.

## Calendar overview

In the calendar each session is displayed with the name of the experiment and the starting time. The square next to the starting time is color coded to signal the sign up status of the session. It is red while not enough participants have signed up for the session, it will get orange when the required number of participants has been reached and turn green when the reserve participant seats are filled as well.

In the week view there is additional information displayed, namely end time, location and experimenters when applicable.

If sessions at the same location overlap in time (including setup and teardown times), the system automatically detects the collision and marks them with a warning icon in the calendar. When hovering over an overlapping session, all conflicting sessions are dynamically highlighted in red.

## Navigating the calendar

The calendar can be navigated by the buttons above it. The two buttons to the right switch between a month and week view. When switching to the week view the first week of the month will be shown. In the month view each session is reduced to a single entry, while in the week view the actual the session is expanded to span the reserved time.

The arrows switch to the respective week/month before or after. The today button sets the calendar to the month or day containing the current day.

By default all locations are shown in the calendar. With the dropdown menu you can select a location to be shown in the calendar. All sessions with another or no location are then removed from the calendar.

After clicking a session a pop up shows more information on the session. Including the exact duration of the session, the location, experimenters, actual numbers of participants signed up, required and reserve, setup and tear down time and links to the participants and the options page of the session.

## Settings of the calendar

At the bottom of the calendar is a link to the options page where every user can make individual settings to their calendar display.

Possible settings are:

-	Day start/end

	The hours of the day included in the week view of the calendar.

-	Weekdays and Week start

	The days of the week which shall be included in both the week and month view. As well as the day the week shall start with.

-	Slots in week mode
	
	The size of the time slots displayed in the week view. Selectable are 15 and 30 minute slots.

-	Colorize sessions by experiment

	Whether to assign a automatic color to each experiment and color each session of the experiment in this color or to display all session in grey.

At the bottom of the clendar options page a link is displayed to include the calendar in an external calendar.

## Blocking of locations

In addition to sessions it is now possible to reserve time slots in a location for an experiment. The reservation has to be made in the context of an experiment, therefore the booking has to be made on the experiments page. Bookings can span entire days or even multiple days.

Bookings are always displayed in grey. They will be included in checks for overlapping and will get an warning sign as well.

Similar to the session when clicking on the booking a pop up with more information appears. There are also links to edit the booking and list of all bookings for the respective experiment. The booking can be deleted from there with two clicks, there will be security message to confirm this action.

---

## External Calendar Integration & ICS Templates

Starting with version 4.0, `hroot` offers enhanced ICS integration for syncing schedules with external calendar software (like Outlook, Google Calendar, Apple Calendar):

### 1. ICS Calendar Exports
- **Global ICS Calendar**: Exposes a subscription feed of all lab sessions for system administrators.
- **Experiment-specific ICS Feed**: Exposes calendar feeds filtered by specific experiments.
- **Personal Calendar Links**: Users can generate a secure, tokenized personal link (`home/personal_calendar/:key`) to sync only their own assigned sessions and staff tasks directly to their private devices.

### 2. Custom ICS Templates
Under **Site Settings -> Appointment Emails (ICS)** (*Termin-Mails (ICS)* / `options/calendar_templates`), administrators can customize the content and formatting of the exported ICS calendar entries using template anchors (such as `#experiment_name`, `#session_info`, or `#location`).
