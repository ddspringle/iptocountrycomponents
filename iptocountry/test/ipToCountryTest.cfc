<cfcomponent displayname="ipToCountryTest"  extends="mxunit.framework.TestCase">
<cffunction name="testAdd" access="public" returntype="void">
  <cfscript>  
    ipToCountryComponent = createObject("component","/ipToCountry/component/ipToCountry");  
    expected = "UNITED STATES";  
    actual = ipToCountryComponent.ipToCountry(CGI.REMOTE_ADDR);  
    assertEquals(expected,actual);  
   </cfscript>
</cffunction>
</cfcomponent>
