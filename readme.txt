A ColdFusion Interface to the Eventful/EVDB API

This CFC includes basic access to the Eventful/EVDB API.

Methods included are:
/users/login
/events/search
/events/new
/events/modify
/events/get
/events/withdraw
/venues/new
/venues/modify
/venues/get
/venues/withdraw
/venues/search

I have used this CFC to distribute concert information added to Music Arsenal as well as a coule of small implementations. Once a string is passed to the EVDB REST API this component parses the results and returns as a struct.

Eventful Developer API information and key signup available at:
http://api.eventful.com/

Requirements

ColdFusion 6+
Eventful API Application key

