<cfset myIP = CGI.REMOTE_ADDR>
<cfinvoke component="component/ipToCountry" method="ipToCountry" ipAddress="#myIP#" returnvariable="country">
<cfoutput>#myIP# = #country#</cfoutput>
