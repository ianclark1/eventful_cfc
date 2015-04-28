<!---
written by Jimmy Winter, Music Arsenal.
http://www.musicarsenal.com

Please send me feedback at jimmy@musicarsenal.com. 

Copyright 2008 Jimmy Winter / Music Arsenal, Inc.

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.

--->

<cfcomponent displayname="eventful.cfc" hint="Access the Eventful API">

	<cffunction name="init" access="public" returntype="eventful">
		<cfargument name="app_key" required="Yes" type="string" />
		<cfargument name="user" required="Yes" type="string" />
		<cfargument name="password" required="Yes" type="string" />
		<cfset var requestStruct = structNew()>
		<cfset var loginStruct = structNew()>
		
		<cfset variables.app_key = Arguments.app_key />
		<cfset variables.user = Arguments.user />
		<cfset variables.password = Arguments.password/>
		<cfset variables.apiurl = "http://api.eventful.com/rest" />
		
		<cfscript>
			structInsert(requestStruct, "app_key", Arguments.app_key);
			structInsert(requestStruct, "password", Arguments.password);
			structInsert(requestStruct, "user", Arguments.user);
			loginStruct = UsersLogin();
			
			if(len(loginStruct.errordesc) eq 0) {
				variables.user_key = loginStruct.user_key;
			}
		</cfscript>
		
		<cfreturn this />
	</cffunction>
	
	<cffunction name="UsersLogin" access="public" displayname="Gets Eventful user_key">		
		<cfset var MethodToRequest = "/users/login"  />
		<cfset var urlString = ""/>
		<cfset var requestStruct = structNew()/>
		<cfset var retStruct = structNew()/>
		<cfset var returnedXML = ""/>
		<cfset var xmldoc = ""/>
		<cfset var nonce = ""/>
		<cfset var response = ""/>
		
		<cfhttp url="http://api.evdb.com/rest/users/login?app_key=#variables.app_key#" method="get" timeout="300"></cfhttp>
		<cfset returnedXML = cfhttp.fileContent/>
		<cfset xmldoc = XMLParse(cfhttp.fileContent)/>
		
		<cfset nonce = xmldoc.error.nonce.XmlText />
		<cfset response = lcase(hash(nonce & ":" & lcase(hash(variables.password, "MD5")), "MD5"))>

		<cfhttp url="http://api.evdb.com/rest/users/login?app_key=#variables.app_key#&user=#variables.user#&nonce=#nonce#&response=#response#" method="get" timeout="300"></cfhttp>
		<cfset returnedXML = cfhttp.fileContent/>
		<cfset xmldoc = XMLParse(cfhttp.fileContent)/>
			
		<cfif not structKeyExists(xmldoc, "error")>
			<cfset retStruct.success = "true" />
			<cfset retStruct.errorMessage = "" />
			<cfset retStruct.errorDesc = "" />
			<cfset retStruct.user_key = xmldoc.login.user_key.XmlText />
		<cfelse>
			<cfset retStruct.success = "false" />
			<cfset retStruct.errorMessage = xmldoc.error.XmlAttributes.string />
			<cfset retStruct.errorDesc = xmldoc.error.description.XmlText />
		</cfif>

		<cfreturn retStruct>		
	</cffunction>
	
	<cffunction name="EventsSearch" access="public" displayname="Searches Eventful events">
		<cfargument name="keywords" required="false" type="string" default="">
		<cfargument name="location" required="false" type="string" default="">
		<cfargument name="date" required="false" type="string" default="">
		<cfargument name="category" required="false" type="string" default="">
		<cfargument name="within" required="false" type="numeric" default="0">
		<cfargument name="units" required="false" type="string" default="">
		<cfargument name="count_only" required="false" type="Boolean" default="False">
		<cfargument name="sort_order" required="false" type="string" default="Date">
		<cfargument name="sort_direction" required="false" type="string" default="">
		<cfargument name="page_size" required="false" type="numeric" default="0">
		<cfargument name="page_number" required="false" type="numeric" default="0">
		
		<cfset var MethodToRequest = "/events/search"  />
		<cfset var urlString = "">
		<cfset var requestStruct = structNew()>
		
		<cfscript>
			if(len(arguments.keywords)) {
				urlString = urlString & "&keywords=" & arguments.keywords;
			}
			
			if(len(arguments.location)) {
				urlString = urlString & "&location=" & arguments.location;
			}
			
			if(len(arguments.date)) {
				urlString = urlString & "&date=" & arguments.date;
			}
			
			if(len(arguments.category)) {
				urlString = urlString & "&category=" & arguments.category;
			}
			
			if(len(arguments.within) AND arguments.within GT 0) {
				urlString = urlString & "&within=" & arguments.within;
			}
			
			if(len(arguments.units)) {
				urlString = urlString & "&units=" & arguments.units;
			}
			
			if(arguments.count_only) {
				urlString = urlString & "&count_only=" & arguments.count_only;
			}
			
			if(len(arguments.sort_order)) {
				urlString = urlString & "&sort_order=" & arguments.sort_order;
			}
			
			if(len(arguments.sort_direction)) {
				urlString = urlString & "&sort_direction=" & arguments.sort_direction;
			}
			 
			if(len(arguments.page_size) AND arguments.page_size GT 0) {
				urlString = urlString & "&page_size=" & arguments.page_size;
			}
			
			if(len(arguments.page_number) AND arguments.page_number GT 0) {
				urlString = urlString & "&page_number=" & arguments.page_number;
			}
			
			urlString = cleanString(urlString);

			structInsert(requestStruct, "MethodToRequest", MethodToRequest);
			structInsert(requestStruct, "urlString", urlString);
		</cfscript>
		
		<cfreturn sendRequest(argumentCollection=requestStruct)/>	
	</cffunction>
	
	<cffunction name="EventsNew" access="public" displayname="Creates an eventful event">
		<cfargument name="title" required="true" type="string" default="">
		<cfargument name="start_time" required="true" type="string" default="" hint="Example: 2005-07-04+17:00:00 = July 4th, 2007 5:00 PM">
		<cfargument name="stop_time" required="false" type="string" default="">
		<cfargument name="tz_olson_path" required="false" type="string" default="">
		<cfargument name="all_day" required="false" type="Numeric" default="0" hint="1 (True) or 0 (False)">
		<cfargument name="description" required="false" type="string" default="">
		<cfargument name="privacy" required="false" type="numeric" default="1" hint="1 = public, 2 = private, 3 = semi-private">
		<cfargument name="tags" required="false" type="string" default="">
		<cfargument name="free" required="false" type="Numeric" default="0" hint="1 (True) or 0 (False)">
		<cfargument name="price" required="false" type="string" default="">
		<cfargument name="venue_id" required="false" type="string" default="">
		<cfargument name="parent_id" required="false" type="string" default="">
		
		<cfset var MethodToRequest = "/events/new"  />
		<cfset var urlString = "">
		<cfset var requestStruct = structNew()>
		
		<cfscript>
			if(len(arguments.title)) {
				urlString = urlString & "&title=" & arguments.title;
			}
			
			if(len(arguments.start_time)) {
				urlString = urlString & "&start_time=" & arguments.start_time;
			}
			
			if(len(arguments.stop_time)) {
				urlString = urlString & "&stop_time=" & arguments.stop_time;
			}
			
			if(len(arguments.tz_olson_path)) {
				urlString = urlString & "&tz_olson_path=" & arguments.tz_olson_path;
			}
			
			if(len(arguments.all_day) AND arguments.all_day GT 0) {
				urlString = urlString & "&all_day=" & arguments.all_day;
			}
			
			if(len(arguments.description)) {
				urlString = urlString & "&description=" & arguments.description;
			}
			
			if(len(arguments.privacy) AND arguments.privacy GT 0) {
				urlString = urlString & "&privacy=" & arguments.privacy;
			}
			
			if(len(arguments.tags)) {
				urlString = urlString & "&tags=" & arguments.tags;
			}
			 
			if(len(arguments.free) AND arguments.free GT 0) {
				urlString = urlString & "&free=" & arguments.free;
			}
			
			if(len(arguments.price)) {
				urlString = urlString & "&price=" & arguments.price;
			}
			
			if(len(arguments.venue_id)) {
				urlString = urlString & "&venue_id=" & arguments.venue_id;
			}
			
			if(len(arguments.parent_id)) {
				urlString = urlString & "&parent_id=" & arguments.parent_id;
			}
			
			urlString = cleanString(urlString);

			structInsert(requestStruct, "MethodToRequest", MethodToRequest);
			structInsert(requestStruct, "urlString", urlString);
		</cfscript>
		
		<cfreturn sendRequest(argumentCollection=requestStruct)/>	
	</cffunction>
	
	<cffunction name="EventsModify" access="public" displayname="Modifies an eventful event">
		<cfargument name="id" required="true" type="string" default="">
		<cfargument name="title" required="false" type="string" default="">
		<cfargument name="start_time" required="false" type="string" default="" hint="Example: 2005-07-04+17:00:00 = July 4th, 2007 5:00 PM">
		<cfargument name="stop_time" required="false" type="string" default="">
		<cfargument name="tz_olson_path" required="false" type="string" default="">
		<cfargument name="all_day" required="false" type="Numeric" default="0" hint="1 (True) or 0 (False)">
		<cfargument name="description" required="false" type="string" default="">
		<cfargument name="privacy" required="false" type="numeric" default="1" hint="1 = public, 2 = private, 3 = semi-private">
		<cfargument name="tags" required="false" type="string" default="">
		<cfargument name="free" required="false" type="Numeric" default="0" hint="1 (True) or 0 (False)">
		<cfargument name="price" required="false" type="string" default="">
		<cfargument name="venue_id" required="false" type="string" default="">
		<cfargument name="parent_id" required="false" type="string" default="">
		
		<cfset var MethodToRequest = "/events/modify"  />
		<cfset var urlString = "">
		<cfset var requestStruct = structNew()>
		
		<cfscript>
			if(len(arguments.id)) {
				urlString = urlString & "&id=" & arguments.id;
			}
			
			if(len(arguments.title)) {
				urlString = urlString & "&title=" & arguments.title;
			}
			
			if(len(arguments.start_time)) {
				urlString = urlString & "&start_time=" & arguments.start_time;
			}
			
			if(len(arguments.stop_time)) {
				urlString = urlString & "&stop_time=" & arguments.stop_time;
			}
			
			if(len(arguments.tz_olson_path)) {
				urlString = urlString & "&tz_olson_path=" & arguments.tz_olson_path;
			}
			
			if(len(arguments.all_day) AND arguments.all_day GT 0) {
				urlString = urlString & "&all_day=" & arguments.all_day;
			}
			
			if(len(arguments.description)) {
				urlString = urlString & "&description=" & arguments.description;
			}
			
			if(len(arguments.privacy) AND arguments.privacy GT 0) {
				urlString = urlString & "&privacy=" & arguments.privacy;
			}
			
			if(len(arguments.tags)) {
				urlString = urlString & "&tags=" & arguments.tags;
			}
			 
			if(len(arguments.free) AND arguments.free GT 0) {
				urlString = urlString & "&free=" & arguments.free;
			}
			
			if(len(arguments.price)) {
				urlString = urlString & "&price=" & arguments.price;
			}
			
			if(len(arguments.venue_id)) {
				urlString = urlString & "&venue_id=" & arguments.venue_id;
			}
			
			if(len(arguments.parent_id)) {
				urlString = urlString & "&parent_id=" & arguments.parent_id;
			}
			
			urlString = cleanString(urlString);

			structInsert(requestStruct, "MethodToRequest", MethodToRequest);
			structInsert(requestStruct, "urlString", urlString);
		</cfscript>
		
		<cfreturn sendRequest(argumentCollection=requestStruct)/>	
	</cffunction>
	
	<cffunction name="EventsGet" access="public" displayname="Gets an eventful event">
		<cfargument name="id" required="true" type="string" default="">
		
		<cfset var MethodToRequest = "/events/get"  />
		<cfset var urlString = "">
		<cfset var requestStruct = structNew()>
		
		<cfscript>
			if(len(arguments.id)) {
				urlString = urlString & "&id=" & arguments.id;
			}
			
			urlString = cleanString(urlString);

			structInsert(requestStruct, "MethodToRequest", MethodToRequest);
			structInsert(requestStruct, "urlString", urlString);
		</cfscript>
		
		<cfreturn sendRequest(argumentCollection=requestStruct)/>
	</cffunction>
	
	<cffunction name="EventsWithdraw" access="public" displayname="Withdraws/Deletes an eventful event">
		<cfargument name="id" required="true" type="string" default="">
		<cfargument name="note" required="false" type="string" default="">
		
		<cfset var MethodToRequest = "/events/withdraw"  />
		<cfset var urlString = "">
		<cfset var requestStruct = structNew()>
		
		<cfscript>
			if(len(arguments.id)) {
				urlString = urlString & "&id=" & arguments.id;
			}
			
			if(len(arguments.note)) {
				urlString = urlString & "&note=" & arguments.note;
			}
			
			urlString = cleanString(urlString);

			structInsert(requestStruct, "MethodToRequest", MethodToRequest);
			structInsert(requestStruct, "urlString", urlString);
		</cfscript>
		
		<cfreturn sendRequest(argumentCollection=requestStruct)/>
	</cffunction>
	
	<cffunction name="VenuesNew" access="public" displayname="Creates an eventful venue">
		<cfargument name="name" required="true" type="string" default="">
		<cfargument name="address" required="false" type="string" default="">
		<cfargument name="city" required="false" type="string" default="">
		<cfargument name="region" required="false" type="string" default="">
		<cfargument name="postal_code" required="false" type="string" default="">
		<cfargument name="country" required="false" type="string" default="">
		<cfargument name="description" required="false" type="string" default="">
		<cfargument name="privacy" required="false" type="numeric" default="1" hint="1 = public, 2 = private, 3 = semi-private">
		<cfargument name="venue_type" required="false" type="string" default="">
		<cfargument name="url" required="false" type="string" default="">
		<cfargument name="url_type" required="false" type="string" default="">
		<cfargument name="parent_id" required="false" type="string" default="">	
		
		<cfset var MethodToRequest = "/venues/new"  />
		<cfset var urlString = "">
		<cfset var requestStruct = structNew()>
		
		<cfscript>
			if(len(arguments.name)) {
				urlString = urlString & "&name=" & arguments.name;
			}
			
			if(len(arguments.address)) {
				urlString = urlString & "&address=" & arguments.address;
			}
			
			if(len(arguments.city)) {
				urlString = urlString & "&city=" & arguments.city;
			}
			
			if(len(arguments.region)) {
				urlString = urlString & "&region=" & arguments.region;
			}
			
			if(len(arguments.postal_code)) {
				urlString = urlString & "&postal_code=" & arguments.postal_code;
			}
			
			if(len(arguments.country)) {
				urlString = urlString & "&country=" & arguments.country;
			}
			
			if(len(arguments.description)) {
				urlString = urlString & "&description=" & arguments.description;
			}
			
			if(len(arguments.privacy) AND arguments.privacy GT 0) {
				urlString = urlString & "&privacy=" & arguments.privacy;
			}
			
			if(len(arguments.venue_type)) {
				urlString = urlString & "&venue_type=" & arguments.venue_type;
			}
			
			if(len(arguments.url)) {
				urlString = urlString & "&url=" & arguments.url;
			}
			
			if(len(arguments.url_type)) {
				urlString = urlString & "&url_type=" & arguments.url_type;
			}
			
			if(len(arguments.parent_id)) {
				urlString = urlString & "&parent_id=" & arguments.parent_id;
			}
			
			urlString = cleanString(urlString);

			structInsert(requestStruct, "MethodToRequest", MethodToRequest);
			structInsert(requestStruct, "urlString", urlString);
		</cfscript>
		
		<cfreturn sendRequest(argumentCollection=requestStruct)/>	
	</cffunction>
	
	<cffunction name="VenuesModify" access="public" displayname="Modify an eventful venue">
		<cfargument name="id" required="true" type="string" default="">
		<cfargument name="name" required="false" type="string" default="">
		<cfargument name="address" required="false" type="string" default="">
		<cfargument name="city" required="false" type="string" default="">
		<cfargument name="region" required="false" type="string" default="">
		<cfargument name="postal_code" required="false" type="string" default="">
		<cfargument name="country" required="false" type="string" default="">
		<cfargument name="description" required="false" type="string" default="">
		<cfargument name="privacy" required="false" type="numeric" default="1" hint="1 = public, 2 = private, 3 = semi-private">
		<cfargument name="venue_type" required="false" type="string" default="">
		<cfargument name="url" required="false" type="string" default="">
		<cfargument name="url_type" required="false" type="string" default="">
		<cfargument name="parent_id" required="false" type="string" default="">	
		
		<cfset var MethodToRequest = "/venues/modify"  />
		<cfset var urlString = "">
		<cfset var requestStruct = structNew()>
		
		<cfscript>
			if(len(arguments.id)) {
				urlString = urlString & "&id=" & arguments.id;
			}
			
			if(len(arguments.name)) {
				urlString = urlString & "&name=" & arguments.name;
			}
			
			if(len(arguments.address)) {
				urlString = urlString & "&address=" & arguments.address;
			}
			
			if(len(arguments.city)) {
				urlString = urlString & "&city=" & arguments.city;
			}
			
			if(len(arguments.region)) {
				urlString = urlString & "&region=" & arguments.region;
			}
			
			if(len(arguments.postal_code)) {
				urlString = urlString & "&postal_code=" & arguments.postal_code;
			}
			
			if(len(arguments.country)) {
				urlString = urlString & "&country=" & arguments.country;
			}
			
			if(len(arguments.description)) {
				urlString = urlString & "&description=" & arguments.description;
			}
			
			if(len(arguments.privacy) AND arguments.privacy GT 0) {
				urlString = urlString & "&privacy=" & arguments.privacy;
			}
			
			if(len(arguments.venue_type)) {
				urlString = urlString & "&venue_type=" & arguments.venue_type;
			}
			
			if(len(arguments.url)) {
				urlString = urlString & "&url=" & arguments.url;
			}
			
			if(len(arguments.url_type)) {
				urlString = urlString & "&url_type=" & arguments.url_type;
			}
			
			if(len(arguments.parent_id)) {
				urlString = urlString & "&parent_id=" & arguments.parent_id;
			}
			
			urlString = cleanString(urlString);

			structInsert(requestStruct, "MethodToRequest", MethodToRequest);
			structInsert(requestStruct, "urlString", urlString);
		</cfscript>
		
		<cfreturn sendRequest(argumentCollection=requestStruct)/>	
	</cffunction>
	
	<cffunction name="VenuesGet" access="public" displayname="Gets an eventful venue">
		<cfargument name="id" required="true" type="string" default="">
		
		<cfset var MethodToRequest = "/venues/get"  />
		<cfset var urlString = "">
		<cfset var requestStruct = structNew()>
		
		<cfscript>
			if(len(arguments.id)) {
				urlString = urlString & "&id=" & arguments.id;
			}
			
			urlString = cleanString(urlString);

			structInsert(requestStruct, "MethodToRequest", MethodToRequest);
			structInsert(requestStruct, "urlString", urlString);
		</cfscript>
		
		<cfreturn sendRequest(argumentCollection=requestStruct)/>
	</cffunction>
	
	<cffunction name="VenuesWithdraw" access="public" displayname="Withdraws/Deletes an eventful venue">
		<cfargument name="id" required="true" type="string" default="">
		<cfargument name="note" required="false" type="string" default="">
		
		<cfset var MethodToRequest = "/venues/withdraw"  />
		<cfset var urlString = "">
		<cfset var requestStruct = structNew()>
		
		<cfscript>
			if(len(arguments.id)) {
				urlString = urlString & "&id=" & arguments.id;
			}
			
			if(len(arguments.note)) {
				urlString = urlString & "&note=" & arguments.note;
			}
			
			urlString = cleanString(urlString);

			structInsert(requestStruct, "MethodToRequest", MethodToRequest);
			structInsert(requestStruct, "urlString", urlString);
		</cfscript>
		
		<cfreturn sendRequest(argumentCollection=requestStruct)/>
	</cffunction>
	
	<cffunction name="VenuesSearch" access="public" displayname="Searches Eventful venues">
		<cfargument name="keywords" required="false" type="string" default="">
		<cfargument name="location" required="false" type="string" default="">
		<cfargument name="within" required="false" type="numeric" default="0">
		<cfargument name="units" required="false" type="string" default="">
		<cfargument name="count_only" required="false" type="Boolean" default="False">
		<cfargument name="sort_order" required="false" type="string" default="Date">
		<cfargument name="sort_direction" required="false" type="string" default="">
		<cfargument name="page_size" required="false" type="numeric" default="0">
		<cfargument name="page_number" required="false" type="numeric" default="0">
		
		<cfset var MethodToRequest = "/venues/search"  />
		<cfset var urlString = "">
		<cfset var requestStruct = structNew()>
		
		<cfscript>
			if(len(arguments.keywords)) {
				urlString = urlString & "&keywords=" & arguments.keywords;
			}
			
			if(len(arguments.location)) {
				urlString = urlString & "&location=" & arguments.location;
			}
			
			if(len(arguments.within) AND arguments.within GT 0) {
				urlString = urlString & "&within=" & arguments.within;
			}
			
			if(len(arguments.units)) {
				urlString = urlString & "&units=" & arguments.units;
			}
			
			if(arguments.count_only) {
				urlString = urlString & "&count_only=" & arguments.count_only;
			}
			
			if(len(arguments.sort_order)) {
				urlString = urlString & "&sort_order=" & arguments.sort_order;
			}
			
			if(len(arguments.sort_direction)) {
				urlString = urlString & "&sort_direction=" & arguments.sort_direction;
			}
			 
			if(len(arguments.page_size) AND arguments.page_size GT 0) {
				urlString = urlString & "&page_size=" & arguments.page_size;
			}
			
			if(len(arguments.page_number) AND arguments.page_number GT 0) {
				urlString = urlString & "&page_number=" & arguments.page_number;
			}
			
			urlString = cleanString(urlString);

			structInsert(requestStruct, "MethodToRequest", MethodToRequest);
			structInsert(requestStruct, "urlString", urlString);
		</cfscript>
		
		<cfreturn sendRequest(argumentCollection=requestStruct)/>	
	</cffunction>
	
	<cffunction name="cleanString" access="private" hint="Cleans the URL string before its sent to Eventful">
		<cfargument name="urlString" required="true" type="string">
		<cfset var retString = "">
		
		<cfscript>
			retString = replace(arguments.urlString, " ", "+", "ALL");
		</cfscript>
		
		<cfreturn retString>
	</cffunction>

	<cffunction name="sendRequest" access="private" hint="Sends the http request to Eventful">
		<cfargument name="MethodToRequest" required="Yes" type="string"/>
		<cfargument name="urlString" required="Yes" type="string"/>
		
		<cfset var returnedXML = ""/>
		<cfset var xmldoc = ""/>
		<cfset var retStruct = StructNew()/>
		<!--- Old Auth String <cfset var auth_string = "?app_key=" & variables.app_key & "&user=" & variables.user & "&password=" & variables.password> --->
		<cfset var auth_string = "?app_key=" & variables.app_key & "&user=" & variables.user & "&user_key=" & variables.user_key>
		<cfset var sendString = variables.apiurl & MethodToRequest & auth_string & arguments.urlString>
		
		<cfhttp url="#sendString#" method="get" timeout="300"></cfhttp>
		
		<cfset returnedXML = cfhttp.fileContent/>
	
		<!--- remove the BOM (byte order mark) from the resulting content, if it exists --->
		<cfif Asc(Left(cfhttp.fileContent,1)) EQ 65279>
			<cfset returnedXML = Right(returnedXML,Len(returnedXML)-1)/>
		</cfif> 
		
		<cftry>
			<!--- will also return the sent orignal xml in case they want to do anything else with it --->
			<cfset retStruct.returnedXML = returnedXML/>
			
			<cfset xmldoc = XMLParse(returnedXML)/>
			
			<cfif not structKeyExists(xmldoc, "error")>
				<cfset retStruct.success = "true" />
				<cfset retStruct.errorMessage = "" />
				<cfset retStruct.errorDesc = "" />
			<cfelse>
				<cfset retStruct.success = "false" />
				<cfset retStruct.errorMessage = xmldoc.error.XmlAttributes.string />
				<cfset retStruct.errorDesc = xmldoc.error.description.XmlText />
			</cfif>

	  	<cfcatch type="any">
				<cfset retStruct.success = False/>
				<cfset retStruct.resultCode = ""/>
				<cfset retStruct.messageCode = ""/>
				<cfset retStruct.messageText = "CF error processing XML"/>
				<cfset retStruct.cfcatch_message = cfcatch.message/>
				<cfset retStruct.cfcatch_detail = cfcatch.detail/>
			</cfcatch>
		</cftry>

		<cfreturn retStruct />
	</cffunction>
	
</cfcomponent>
