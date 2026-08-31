*   [Assign participants](#assign-participants)
*   [Assigned participants](#assigned-participants)
*   [History of participant assignment](#history-of-participant-assignment)
*   [7. Automatch (Auto-Assignment) & Filter Templates](#7-automatch-auto-assignment--filter-templates)

---

## Assign participants

The tab "Participants" serves as user management for the whole experiment.

Only the users who are assigned to an experiment can sign up for a session of this experiment. On the Assign new participants tab participants can be assigned to the chosen experiment. Thereby only those users are included, who are not yet assigned to the experiment. To select the pool members which should be able to participate in the experiment, there are several filters in order to match the sample criteria. It is possible to combine as many filter as you need, but it is not possible to combine multiple filters of the same category.

The following search criteria are possible:

-   No show count

	The filter “no shows” allows filtering by the times someone did not come to sessions she or he was registered for. It is possible to filter in two directions. First in the direction that the number of no shows must be smaller or equal than the given limit or the number of no shows must be greater than a given minimum.

-   Participation count

	The filter “participation” allows setting limits on how many times a pool member already participated in experiments. There are two possibilities, set a maximum or a minimum.

-   (Experiments by) Tags

	The filter "Tags" allows filtering by experiments tags. Since it is possible to use tags to categorize experiments it is also possible to filter for tags. So you can limit the participation to people who have participated in experiments with the same tags or exclude them.

	The Options are: At least or at most, filters pool members either in the direction that they must have at least the stated times participated or must have less times participated in experiments with the chosen tags. The wanted limit can be chosen in the range of zero to ten.

	The tags drop-down menu shows all tags which might be a condition to filter for. And can be searched with the text field at the top. With the “+” button one can create more conditions. With the "-" button you can remove the last tag filter definition.

-   Experiments (by name)

	The filter "experiments" allows filtering the pool according to the participation in experiments. There are several options: Include only users...

	-	…who are assigned to one of the following experiments.

		Given a list of experiments, only pool members that are associated to at least one of the experiments are shown.

	-	...who are assigned to all of the following experiments.

		Given a list of experiments, only pool members that are associated with all experiments are shown

	-	…who are not assigned to any of the following experiments.

		Given a list of experiments, only pool members are shown if they are not associated with any of the given experiments.

	-	...who have participated in at least one session of one of the following experiments.

		Given a list of experiments, only pool members are shown if they participated in at least on session of one of the given experiments.

	-	...who have participated in at least one session of all the following experiments.

		Given a list of experiments, only pool members are shown if the participated in at least one session of all of the given experiments.

	-	…who have not participated in any session of the following experiments.

		Given a list of experiments, only pool members are shown if they did not participate in any session of the given experiments.

	Under the drop-down list there is a field to enter the name of experiments. When focusing on the field all known experiments are proposed, when entering some letters the proposals are reduced to experiments containing the typed string.

-   Gender

	The filter “gender” allows filtering the pool by sex; it is possible to filter by male or female.

-   Date of birth

	The filter “Date of birth” allows selecting pool members which have been born in a specified range of time. It is necessary to indicate both month and year. But setting only one limit is possible, if just an upper or lower limit is needed.

-   Nationality

	The filter "Nationality" allows restricting the pool by countries. allows defining from which countries the subjects have to come. The filter allows limiting the pool to students of the countries if one chooses "include only" or excluding the students who come from the selected countries by selecting "exclude". It is possible to choose more than one country.

-   Experiment preferences

	The filter “experiment preference” allows focusing on pool members by the type of experiments they want to participate. There are two types defined: Online experiments and experiments conducted in a lab. This filter can be used to prevent inviting pool members to types of experiments they do not wish to participate in.

-   Beginning of studies

	The filter “beginning of studies” allows selecting a range in which the wanted pool members begun their study. It is possible to leave one of the possibilities blank if only one of the limits is required. It is necessary to indicate both month and year.

-   Experience

	The filter "experience" allows excluding or limiting the pool to pool members which stated that they already have been participated in (external) experiments. This filter does not regard experiments in the system; it is only for previous experience (before registering). 

-   Languages

	he filter "languages" allows filtering by languages the pool members have indicated. The pool members can choose as much of the predefined languages as they want to indicate that they have knowledge in this language. It is possible to filter for multiple languages. These are connected via an "or". If there is no language set by the pool member, they are excluded when include by language is used and they are not excluded when excluding by language.

-   Course of studies

	The filter "Course of study" allows restricting the pool by field of study. Maybe for an experiment it is important which field of study the participating pool members have. The filter allows limiting the pool to students of the selected field of study if one chooses "include only" or excluding the students of the stated field of study by selecting "exclude". It is possible to choose more than one field of study.

-   Degrees

	The filter “degrees” allows restricting the pool by the desired degree. Maybe for an experiment it is important which degree the participating pool members are seeking. The filter allows limiting the pool to students of the selected degree if one chooses "include only" or excluding the students of the stated degree by selecting "exclude". It is possible to choose more than one degree.

Set the filter as you need and click "Search and update result". This will lead to a list containing the subset of your pool matching the criteria. It is possible to add only a manual selection of users or, more commonly used, all pool members in the result with the buttons at the top of the list. The selected list or users will then be assigned to the experiment and an entry is made to the "History of participant assignment". This is a one time process and the criteria are not checked again at any time.

If needed, you can change the criteria and add more participants from the pool. The participants already assigned are excluded automatically. Or you can go to the "Assigned participants" page and remove users already assigned.

Once these pool members are assigned, they are able to register for one session of the experiment whenever the registration for the experiment is active.

## Assigned participants

The page "Assigned users" is structured similar to the "Assign participants" page. There is the list of search criteria as above. With one addition:

-	Session participation

	The "Session participation" filter offers four options regarding the current experiment. Include only assigned users...

	-	...who have participated

		Returns all users who have participated in a session of this experiment. Meaning their status in the session is set to "participated".

	-	...who are registered in a session

		Returns all users who have signed up for a session.

	-	...without a session

		Returns all users who have not signed up for a session.

	-	...who are registered in a session, which is not over yet

		Returns all users who have signed up for a session, which calculated end time has not yet been reached.

The list of assigned participants below the filters contains a column with the session the users are signed up. If they are not signed up for any session this column is left blank.

Again there are two buttons regarding the current result and all checked participants (if there are any). Instead of adding participants its possible to remove them from the experiment. Which means, they are not able to register for a session any more. They are removed from the session they signed up for as well, if they signed up for any. There is no mail send, to inform them about the removal.

It is possible to move participants to a session. The participation limits of the session are not checked in this case. Also there is mail send to the participant(s). If the user had signed up for another session, they will be removed from that one.

One may send emails to the complete list or checked users. For more information about this see [sending out messages](https://github.com/wiso-forschungslabor/hroot-documentation/wiki/Sending-messages).

Last it is possible to export the (filtered) list as excel or csv file. Or print it.  

## History of participant assignment

On the page "History of participant assignment" it is possible to review the time and date, the count of affected participants and the filter settings for each assignment process. Whether it was adding or removing possible participants. With a click on the time and date a list with the names and emails of all affected participants is shown. A second click removes the list.

---

## 7. Automatch (Auto-Assignment) & Filter Templates

To streamline participant recruitment, hroot provides two advanced features on the participant assignment pages:

### 7.1. Auto-Assignment (Automatch)
The **Automatch** feature automatically assigns matching participants to the experiment in the background, eliminating the need to manually search and assign pool members:
- **How it works**: When creating or editing an experiment, you define a set of demographic/profile filter criteria (e.g., age, gender, specific tags, or course of study).
- **Background Scheduler**: A background worker checks for newly registered users, newly verified student accounts, or users who update their profiles. If they match the predefined filters, they are automatically enrolled in the experiment and become eligible to register for sessions.
- **Toggle**: This can be enabled or disabled via the experiment's participant management settings.

### 7.2. Reusable Filter Templates
If you regularly run studies that require the same demographic target groups, you can save your search filters:
- **Saving Filters**: After defining your filter criteria (e.g. specific languages, degrees, and minimum participation count), click **Save Filter Template**.
- **Reusing Filters**: You can load these saved templates with a single click in future experiments, automatically populating the complex filter form.
- **Management**: Saved filter templates can be shared, edited, or deleted under the filter template management options.
