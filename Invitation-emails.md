Before we invite users to our experiment, we need a text for the invitation email - you can find this text in the Experiment Menu > Invitations > Email texts.

When we send out invitation emails, the system will determine which session times are still available the moment the email gets sent. In some cases, users will see a full list of sessions, in other cases some sessions might already be full or in the past, these sessions will not be included in the invitation email.

Things get even more complicated since an experiment can consist of simple sessions and session groups, and a experiment can either have randomized session groups or session groups where the user has to attend all sessions of a group (one experiment can not have both kinds of session groups).

### A simple example - an invitation without groups

To customize the invitation email, you can use a variety of variables. Let's assume you created two sessions in the near future at the location "Lab 1". In this example, there will be no session groups.

A simple invitation email could look like this:

    Hello #firstname #lastname,

    You can signup for the following sessions:

    #foreach_session
    Session #sessionindex: #date #time - #until, #location 
    #end_session
    
    Click here to signup:
    #link

    Cheers, your lab.

The variables of this email will be filled when the email is sent out. As a result, a user might get the following message:

    Hello Some User,

    You can signup for the following sessions:

    Session 1: Sep 25, 2014 10:00 - 11:30, Lab 1
    Session 2: Sep 27, 2014 10:00 - 11:30, Lab 1

    Click here to signup:
    http://www.yoursite.com/hroot/enroll/code

    Cheers, your lab.

If you want to include text only if there are actually simple sessions to signup, you can use the following block:

    #if_ungrouped_sessions
    This text will only be printed in the presence of ungrouped sessions
    #end_ungrouped_sessions
    
Place the #foreach... and the #if... tags in a separate line for best results. Click on preview to see how the variables would get filled.

In the example, the following global variables can be used at any location:

    #firstname   -> name of user
    #lastname    -> last name of user
    #link        -> link to session signup in hroot (containing a code, so the user doesn't have to login)

### Session variables

Inside the session loop, you can use the following variables to describe the session:

For dates, the variable #date can be used, optionally followed by a local identifier (to define the language of weekdays and months) and a ruby format string (to be able to fully define your own date formats). Syntax is very simple:

    #date[locale identifier]["ruby format string"]

Usage examples:

    #date                      -> Oct 12, 2014 (the date in the format of your default locale)
    #date[de]                  -> 12.10.2014 (default date format in german locale)
    #date[en]                  -> Oct 12, 2014  (default date format in english locale)

    #date["%d.%m.%Y"]          -> 12.10.2014 (using the ruby date format string and your default locale)
    #date["%A, %B %d, %Y"]     -> Sunday, October 12, 2014 (depending on your default locale)

    #date[de]["%d.%B, %Y"]     -> 12.Oktober, 2014 (date format string and german locale)
    #date[de]["%A, %d.%B, %Y"] -> Sonntag, 12.Oktober, 2014
    #date[en]["%A, %B %d, %Y"] -> Sunday, October 12, 2014 

For time, the following variables can be used, they are locale independent:

    #time                      -> 10:00 (session start time)
    #until                     -> 11:30 (session end time)
    #time["%H:%M %p"]          -> 10:00 AM (using time format)
    #until["%H:%M %p"]         -> 11:30 AM (using time format)
    #duration                  -> 90 (duration of session in minutes)

For location and more detailed description, these two variables can be used:

    #location                  -> Lab 1 (location name)
    #location_description      -> You can find the lab via ... (location description)

You can use any ruby date format string, see http://www.ruby-doc.org/core-2.1.2/Time.html#method-i-strftime. 

### Invitation emails with session groups

The invitation email gets a bit more complex, when you have session groups - in this case we have two loops - one for the groups and one for the individual sessions of the groups:

    Hello #firstname #lastname,

    You can signup for the following sessions:

    #foreach_group  
    Group Nr. #groupindex:
    #foreach_session_in_group
    Session #sessionindex: #date #time - #until, #location 
    #end_session_in_group
    #end_group    

This will result in the following email:

    Hello Some User,

    You can signup for the following sessions:

    Group Nr. 1:
    Session 1: Sep 26, 2014 10:00 - 11:30, Lab 1
    Session 2: Sep 27, 2014 10:00 - 11:30, Lab 1
    Group Nr. 2:
    Session 1: Sep 20, 2014 10:00 - 11:30, Lab 1
    Session 2: Oct 05, 2014 10:00 - 11:30, Lab 1

You can use #groupindex to include a group number and #sessionindex for a session number. The indexes start counting from 1 step by 1.

As in the simple case, you can use a surrounding if-block, which will only be included, if there are actually grouped sessions to signup for:

    #if_session_groups
    This text will only be included in the presence of session groups
    #end_session_groups
    
You can also conditinally include text if the sessions are randomized, or if the session groups are "attend all sessions"-groups

    #if_randomized_groups
    If you signup for the following session groups, you will be randomly assigned to one group
    #end_randomized_groups

    #if_unrandomized_groups
    If you signup for the following session groups, you will have to attend all sessions in the group:
    #end_unrandomized_groups

Please be aware that these template variables are implemented using simple regular expressions - this is not a real programming language, so you can't do more complicated things than these examples like iterating multiple times. If you have a more complicated use case, you should opt for a plain text explanation of your experiment setting and the signup conditions.

### A generic email for all cases

Since one experiment may have simple sessions and groups, it is now possible to combine the to variable constructs to write one email which deals with all cases:

    Hello #firstname #lastname,

    #if_ungrouped_sessions
    You can signup for the following sessions:

    #foreach_session
    Session #sessionindex: #date #time - #until, #location 
    #end_session
    #end_ungrouped_sessions

    #if_session_groups
    #if_randomized_groups
    If you signup for the following session groups, 
    you will be randomly assigned to one session of the group
    #end_randomized_groups
    #if_unrandomized_groups
    If you signup for the following session groups, you will have to attend all sessions in the group
    #end_unrandomized_groups

    #foreach_group  
    Group Nr. #groupindex:
    #foreach_session_in_group
    Session #sessionindex: #date #time - #until, #location 
    #end_session_in_group
    #end_group    
    #end_session_groups

    Click here to signup:
    #link

    Cheers, your lab.

Given an experiment with 2 simple sessions and 2 groups with two sessions each using randomized groups, the resulting email would be the following:

    Hello #firstname #lastname,

    You can signup for the following sessions:

    Session 1: Sep 25, 2014 10:00 - 11:30, Lab 1
    Session 2: Sep 27, 2014 10:00 - 11:30, Lab 1


    If you signup for the following session groups, 
    you will be randomly assigned to one session of the group
    
    Group Nr. 1:
    Session 1: Sep 26, 2014 10:00 - 11:30, Lab 1
    Session 2: Sep 27, 2014 10:00 - 11:30, Lab 1
    Group Nr. 2:
    Session 1: Sep 20, 2014 10:00 - 11:30, Lab 1
    Session 2: Oct 05, 2014 10:00 - 11:30, Lab 1

    Click here to signup:
    http://www.yoursite.com/hroot/enroll/code

    Cheers, your lab.

If either session groups or simple sessions are filled up, parts of the email would not be displayed.

Remarks:

- Please have a test experiment and send yourself an invitation email before you invite thousands of users.
- All emails in hroot are in one language only - if you want to support multiple languages in emails, use one email which contains the text for both languages. 
