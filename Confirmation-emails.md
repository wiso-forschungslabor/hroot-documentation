When the user has picked a session or a session group, he will receive a confirmation email. Again we have to provide variables for different cases:

### The user picked a simple session or a randomized group ###

In this case, you can use the following variables, this code will display a simple session, or the session a user was randomized to in case of a randomized group session. If the user has picked an unrandomized session group, this code will not be included.

    Hello #firstname #lastname

    #if_single_session

    You have signed up for the following session:
    #date #time - #until, #location 

    Location:
    #location_description

    #end_single_session


### The user picked a session group ###

The following code can be used to display the group of sessions a user signed up for:

    #if_session_group

    You have signed up for the following sessions:

    #foreach_session
    #date #time - #until, #location 

    Location:
    #location_description

    #end_session

    #end_session_group

The preview will display the group case if groups are present, and the single session case otherwise.
