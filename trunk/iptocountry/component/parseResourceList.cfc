<cfcomponent>
<cffunction name="parseResourceList" access="public" returntype="query">
  <cfargument name="sourceText" type="string" required="yes" hint="I am the text from the readIpToCountryCsv.cfm routines.">
  <cfset returnData = QueryNew("from,to,registry,assigned,country2lc,country3lc,country")>
  <cfset tempQ = QueryAddRow(returnData)>
  <cfset tempQ = QuerySetCell(returnData, "from", "#Replace(ListGetAt(ARGUMENTS.sourceText,1),'"','','ALL')#")>
  <cfset tempQ = QuerySetCell(returnData, "to", "#Replace(ListGetAt(ARGUMENTS.sourceText,2),'"','','ALL')#")>
  <cfset tempQ = QuerySetCell(returnData, "registry", "#Replace(ListGetAt(ARGUMENTS.sourceText,3),'"','','ALL')#")>
  <cfset tempQ = QuerySetCell(returnData, "assigned", "#Replace(ListGetAt(ARGUMENTS.sourceText,4),'"','','ALL')#")>
  <cfset tempQ = QuerySetCell(returnData, "country2lc", "#Replace(ListGetAt(ARGUMENTS.sourceText,5),'"','','ALL')#")>
  <cfset tempQ = QuerySetCell(returnData, "country3lc", "#Replace(ListGetAt(ARGUMENTS.sourceText,6),'"','','ALL')#")>
  <cfset tempQ = QuerySetCell(returnData, "country", "#Replace(ListGetAt(ARGUMENTS.sourceText,7),'"','','ALL')#")>
  <cfreturn returnData>
</cffunction>
</cfcomponent>
Replace(