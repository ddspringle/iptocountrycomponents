<cfcomponent>
<cffunction name="ipToCountry" access="public" returntype="string">
  <cfargument name="ipAddress" type="string" required="no" default="#CGI.REMOTE_ADDR#" hint="IP address to convert to country in decimal or IP notation.">
  <!--- include Application --->
  <cfinclude template="../Application.cfm">
  <!--- check passed ipAddress notation --->
  <cfif isNumeric(ARGUMENTS.ipAddress) Is False>
    <!--- set default value of caluculated IP address to 0 --->
    <cfset ipValue = 0>
    <!--- set the default start exponent value --->
    <cfset power = 3>
    <!--- loop through each octet of the IP address --->
    <cfloop from="1" to="4" index="iX">
      <!--- get the value from the provided IP address --->
      <cfset thisOctet = ListGetAt(ARGUMENTS.ipAddress,iX,'.')>
      <!--- multiply the current octet of the IP address --->
      <!--- times (256 to the power of the exponent (1^3,2^2,3^1,4^0) --->
      <cfset calcOctet = (thisOctet * (256^power))>
      <!--- add the calculated value to the decimal long --->
      <cfset ipValue = ipValue + calcOctet>
      <!--- decrease the power for the next octet --->
      <cfset power = power - 1>
      <!--- loop back to the next octet --->
    </cfloop>
    <!--- otherwise, already decimal notation, just lookup --->
    <cfelse>
    <!--- set ipValue to decimal value passed in ipAddress --->
    <cfset ipValue = ARGUMENTS.ipAddress>
    <!--- end notation check --->
  </cfif>
  <!--- query database for countryID --->
  <cfquery name="qGetCountryId" datasource="#ds#" username="#un#" password="#pw#">
SELECT countryID FROM a_ipaddresses WHERE fromIP <= '#ipValue#' AND toIP >= '#ipValue#'
</cfquery>
  <!--- query database for country --->
  <cfquery name="qGetCountry" datasource="#ds#" username="#un#" password="#pw#">
SELECT country FROM a_countries WHERE countryID = '#qGetCountryId.countryID#'
</cfquery>
  <!--- return the country --->
  <cfreturn qGetCountry.country>
</cffunction>
</cfcomponent>
