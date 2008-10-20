<cfcomponent displayname="parseResourceListTest"  extends="mxunit.framework.TestCase">
<cffunction name="testAdd" access="public" returntype="void">
  <cfscript>  
    parseResourceListComponent = createObject("component","/ipToCountry/component/parseResourceList");  
    actual = parseResourceListComponent.parseResourceList('from,to,registry,assigned,country2lc,country3lc,country');  
    assertIsQuery(actual);
   </cfscript>
</cffunction>
</cfcomponent>
