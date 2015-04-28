

<cfset eventful = CreateObject("component","eventful").init(app_key = "xxx", user = "xxx", password = "xxx")>

<cfinvoke component="#eventful#" method="EventsSearch" returnvariable="result">
	<cfinvokeargument name="location" value="Omaha">
	<cfinvokeargument name="page_size" value="5">
</cfinvoke>

<!--- 
<cfinvoke component="#eventful#" method="EventsNew" returnvariable="result">
	<cfinvokeargument name="title" value="The Lepers">
	<cfinvokeargument name="start_time" value="2008-10-15+21:00:00">
	<cfinvokeargument name="venue_id" value="V0-001-000162480-6">
</cfinvoke>
--->
<!---
<cfinvoke component="#eventful#" method="EventsModify" returnvariable="result">
	<cfinvokeargument name="id" value="E0-001-016191090-8">
	<cfinvokeargument name="title" value="The Lepers Last Show">
</cfinvoke>
--->
<!--- 
<cfinvoke component="#eventful#" method="EventsWithdraw" returnvariable="result">
	<cfinvokeargument name="id" value="E0-001-016191126-2">
	<cfinvokeargument name="note" value="Duplicate">
</cfinvoke>
--->
<!---
<cfinvoke component="#eventful#" method="EventsGet" returnvariable="result">
	<cfinvokeargument name="id" value="E0-001-016191126-2">
</cfinvoke>
--->
<!--- 
<cfinvoke component="#eventful#" method="VenuesNew" returnvariable="result">
	<cfinvokeargument name="name" value="Old Dundee">
	<cfinvokeargument name="address" value="4964 Dodge Street">
	<cfinvokeargument name="city" value="Omaha">
	<cfinvokeargument name="region" value="Nebraska">
	<cfinvokeargument name="postal_code" value="68132">
	<cfinvokeargument name="country" value="United States">
	<cfinvokeargument name="description" value="Occasional Concerts">
	<cfinvokeargument name="privacy" value="1">
	<cfinvokeargument name="venue_type" value="Bar/Night Club">
</cfinvoke>
--->
<!---
<cfinvoke component="#eventful#" method="VenuesModify" returnvariable="result">
	<cfinvokeargument name="id" value="V0-001-000167363-5">
	<cfinvokeargument name="name" value="Omaha Dormant Venue">
	<cfinvokeargument name="address" value="N/A">
	<cfinvokeargument name="city" value="Omaha">
</cfinvoke>
--->
<!---
<cfinvoke component="#eventful#" method="VenuesGet" returnvariable="result">
	<cfinvokeargument name="id" value="V0-001-000167363-5">
</cfinvoke>
--->
<!---
<cfinvoke component="#eventful#" method="VenuesWithdraw" returnvariable="result">
	<cfinvokeargument name="id" value="V0-001-000167363-5">
	<cfinvokeargument name="note" value="Invalid Venue">
</cfinvoke>
--->
<!--- 
<cfinvoke component="#eventful#" method="VenuesSearch" returnvariable="result">
	<cfinvokeargument name="keywords" value="49">
	<cfinvokeargument name="location" value="Omaha NE">
</cfinvoke>
--->

<cfdump var="#XMLParse(result.returnedXML)#" label="xmlparsed">
<cfdump var="#result#">



