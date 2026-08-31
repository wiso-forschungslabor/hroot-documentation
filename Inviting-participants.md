
Once you have setup your sessions and assigned pool members to an experiment, you probably want them to sign up for sessions. To tell pool members about upcoming session there is the invitation feature. Nevertheless a participant which is assigned to an experiment can register for its sessions once registration is active, whether they got an invitation or not.

## Configuring emails for an experiment

Before you send out invitations you should addapt the email texts for the experiment according to your needs. When creating an experiment the email texts are filled with the default from the [options]. Most of the times these defaults will do, but often there some details differing from the defaults and if the defaults are changed after the creation of an experiment, the texts in the experiments are not changed. How to build the email templates is described in the [sending Messages](https://github.com/wiso-forschungslabor/hroot-documentation/wiki/Sending-messages) section.

## Sending invitations

The second option in the invitations tab is the page for starting the sending of invitation mails.

To the right it is possible to set how many mails should be send in one time interval and the time between two intervals. Sending out emails in smaller intervalls with an longer interval inbetween ensures a minimum of randomisation. Expecting pool members to only sign up after they got an invitation with information about upcoming sessions.

To the left is an overview over the number of assigned participants not in a session and the number of participants without an invitation. Based on the later there is an estimation how long the invitation process will take, with the current interval settings. The duration of sending the emails out and a maximum of emails per time interval is limited by the system. This second limitation can not be taken into account by hroot.

Generally the order in which the invitation mails will be send is randomized, but it is possible to check the box "invite participants with lesser registrations first". If this otion is used, the invitations for pool members with zero participations will be send first, with randomization between these, then the invitations for pool members with one participations and so forth.

The green button "open experiment for registration and start sending invitations" opens the experiment for registration and starts the invitation process. If some assigned participants already got an invitation they will not be invited again. Participants signed up for a session won't get an invitation as well.

Please be aware, that a short interval and a high number of mails per interval will cause some load on your mail server.

For sending invitations experimenters need the access right "manage invitations".

## Status of the invitation process

Once you have started an invitation the "Send invitations" page will show the status of the running invitation process. The following information is displayed:

-	Time and date the process was started
-	Number of emails per interval and time inbetween
-	Total number of assigned participants
-	Number of already invited participants
-	How many invitations could have been sent regarding the settings
-	How many invitations actually have been sent
-	How many participants still can get an invitation
-	How many places are still available in all of the experiments sessions

The information is updated every 60 seconds. The remaining time till the next update is shown in the upper right.

You will get this screen, even when there are no emails to be sent. For example when there are no sessions. The checks if there are mails to be send are integrated in the email process which runs usually every minute and not in the information screen.

## Stopping the invitation process

The invitation process will stop automatically if there are no more free places in all sessions of the experiment, since there would be no more session dates to include in the invitation emails. If there are no free places in an experiment when you start the invitation process, there won't be send any emails at all.

If there is an invitation process running, you can stop the process manually using the button on the status page.

Once the invitation process is stopped you can start a new one with new parameters to the remaining assigned participants without an invitation or sending new invitations to all participants (see below).

## Sending invitations again

The orange button "start sending invitations TO ALL participants" works similar to the green one, except it sends invitations to **all assigned** participants even if they already got an invitation. For this case there is a sepperate estimated duration of the invitation process to the right of the button.

The randomisation works in the same way and particpants already signed up in a session won't get an invitation.

Internaly this function just resets the information if an invitation was already sent. Therefore all information about previous invitations is removed when this button is used. 

## Opening/Closing for registration

There are two states regarding the possibility for participants to sign up for sessions. Either the registration is active or inactive. The current state is displayed in the top right corner when you are working within the context of an experiment. The button is red when registration is not possiblea and green when it is possible.

The current state is also displayed in the [experiment list](https://github.com/wiso-forschungslabor/hroot-documentation/wiki/Managing-Experiments#using-the-experiment-list).

With a click on the button in the top right corner the state can be switched from inactive to active and vice versa. When an invitation process is started, the state is set to active automaticaly.

Closing the experiment for registration does not change anything else. A already started invitation process will go on, sending out session dates which will not be available to pool members once they log in, due to the inactive registration. All already signed up participants will remain in their sessions.

Closing an experiment for registration can help you, when you have to rearrange or delete sessions. Preventing participants to sign up for sessions you want to move or delete. But remember to reopen the registration afterwards.
