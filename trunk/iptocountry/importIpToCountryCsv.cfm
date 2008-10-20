<!--- set params --->
<cfparam name="URL.CFID" default="">
<cfparam name="URL.mode" default="">
<cfparam name="URL.force" default="false">
<!--- set the current queryString --->
<cfset queryString = Iif(CGI.QUERY_STRING NEQ "",DE("&"&CGI.QUERY_STRING),DE(""))>
<!--- check for existence of CFID --->
<cfif URL.CFID EQ "">
  <!--- if not present, redirect and make present --->
  <cflocation url="#CGI.SCRIPT_NAME#?gc=#Hash(RandRange(1,100),'MD5')##queryString#" addtoken="true">
</cfif>
<!--- HTML --->
<cfoutput>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Coldfusion IpToCountry.csv Import Utility</title>
</head>
<body>
</cfoutput>
<!--- check for existence of mode --->
<cfif URL.mode EQ "">
  <cfoutput>
    <h1 style="color:##FF0000">ERROR! You must specify a mode to use this script</h1>
    <p>Specify one of the following currently supported modes</p>
    <ul>
      <li>Use: <span style="font-family:'Courier New', Courier, monospace;">&amp;mode=MSSQL</span> on the URL for Microsoft SQL Server 2000 mode (or <a href="#CGI.SCRIPT_NAME#?mode=MSSQL#queryString#">Click Here</a>)</li>
      <li>Use: <span style="font-family:'Courier New', Courier, monospace;">&amp;mode=MySQL</span> on the URL for Sun MySQL Server mode (or <a href="#CGI.SCRIPT_NAME#?mode=MySQL#queryString#">Click Here</a>)</li>
    </ul>
  </cfoutput>
  <cfabort>
</cfif>
<!--- check if forcing the deletion of tables --->
<cfif URL.force IS True>
  <!--- try to drop the ipaddresses table --->
  <cftry>
    <!--- drop the table --->
    <cfquery name="qDropTable" datasource="#ds#" username="#un#" password="#pw#">
DROP TABLE a_ipaddresses
</cfquery>
    <!--- catch JIC --->
    <cfcatch type="database">
      <!--- do nothing --->
    </cfcatch>
  </cftry>
  <!--- try to drop the countries table --->
  <cftry>
    <!--- drop the table --->
    <cfquery name="qDropTable" datasource="#ds#" username="#un#" password="#pw#">
DROP TABLE a_countries
</cfquery>
    <!--- catch JIC --->
    <cfcatch type="database">
      <!--- do nothing --->
    </cfcatch>
  </cftry>
  <!--- try to drop the registries table --->
  <cftry>
    <!--- drop the table --->
    <cfquery name="qDropTable" datasource="#ds#" username="#un#" password="#pw#">
DROP TABLE a_registries
</cfquery>
    <!--- catch JIC --->
    <cfcatch type="database">
      <!--- do nothing --->
    </cfcatch>
  </cftry>
</cfif>
<!--- 
Set for 10 mins. 
This cfsetting will over ride what is set in CFAdminsitrator
--->
<cfsetting enablecfoutputonly="true" requesttimeout="600">
<!--- path to the messages file --->
<cfset sourceFile = expandpath("sql/IpToCountry.csv") >
<!--- hash to use as a key --->
<cfset sourceFileHash = Left(Hash(sourceFile,'MD5'),5) & Left(Hash(Right(sourceFile,fileChars),'MD5'),5)>
<!--- put it in the SESSION scope to persist it over requests --->
<cfif not structKeyExists(SESSION,sourceFileHash)>
  <cfset SESSION[sourceFileHash] = structNew()>
  <cfset SESSION[sourceFileHash].oReader = createObject("java", "java.io.FileReader")>
  <cfset SESSION[sourceFileHash].oReader.init( sourceFile )>
  <cfset SESSION[sourceFileHash].oLog = createObject("java", "java.io.LineNumberReader")>
  <cfset SESSION[sourceFileHash].oLog.init( SESSION[sourceFileHash].oReader )>
  <cfset SESSION[sourceFileHash].totalLines = 0>
  <cfset SESSION[sourceFileHash].lastRunTime = 0>
  <cfset SESSION[sourceFileHash].startTime = '#DateFormat(Now(),'yyyy-mm-dd')# #TimeFormat(Now(),'HH:mm:ss')#'>
  <cfset SESSION[sourceFileHash].totalRunTime = 0>
</cfif>
<!--- output header --->
<cfoutput>
  <h1>Coldfusion IpToCountry.csv Import Utility</h1>
  <ul>
    <cfif URL.mode EQ "MSSQL">
      <li>Microsoft SQL Server 2000 Mode (use <span style="font-family:'Courier New', Courier, monospace;">&amp;mode=MySQL</span> for MySQL mode)</li>
      <cfelseif URL.mode EQ "MySQL">
      <li>Sun MySQL Mode (use <span style="font-family:'Courier New', Courier, monospace;">&amp;mode=MSSQL</span> for Microsoft SQL Server 2000 mode)</li>
    </cfif>
    <cfif URL.force IS True>
      <li>Forcing deletion of existing tables</li>
      <cfelseif URL.force IS False>
      <li>Keeping existing tables (use &amp;force=true to delete)</li>
    </cfif>
    <li>Processing #iBlockCount# records per run</li>
    <li>Start Time: #DateFormat(SESSION[sourceFileHash].startTime,'mm.dd.yyyy')# #TimeFormat(SESSION[sourceFileHash].startTime,'hh:mm:ss tt')#</li>
  </ul>
</cfoutput>
<!--- Use this flag to indicate if there is more in the file --->
<cfset bEndOfFile = false>
<!--- Set a boolean to be used in the condidtion --->
<cfset canCountinue = true>
<!---                                                              --->
<!--- Check for ipaddresses table, drop and create if non-existent --->
<!---                                                              --->
<cftry>
  <!--- check if table already exists --->
  <cfquery name="qGetIp" datasource="#ds#" username="#un#" password="#pw#">
SELECT * FROM a_ipaddresses WHERE registryID = 999999999
</cfquery>
  <!--- catch non-existence of the database --->
  <cfcatch type="database">
    <!--- try to drop the table (JIC) --->
    <cftry>
      <!--- drop the table --->
      <cfquery name="qDropTable" datasource="#ds#" username="#un#" password="#pw#">
DROP TABLE a_ipaddresses
</cfquery>
      <!--- catch JIC --->
      <cfcatch type="database">
        <!--- do nothing --->
      </cfcatch>
    </cftry>
    <!--- check if Microsoft SQL Mode --->
    <cfif URL.mode EQ "MSSQL">
      <!--- try to create the database (MSSQL) --->
      <cftry>
        <!--- create the ipaddresses table --->
        <cfquery name="qCreateIpAddressesTable" datasource="#ds#" username="#un#" password="#pw#">
CREATE TABLE [dbo].[a_ipaddresses] (
[fromIP] decimal(10, 0) NOT NULL,
[toIP] decimal(10, 0) NOT NULL,
[registryID] decimal(10, 0) NOT NULL,
[assigned] datetime NOT NULL,
[countryID] decimal(10, 0) NOT NULL)
ON [PRIMARY]
</cfquery>
        <!--- catch any database errors --->
        <cfcatch type="database">
          <!--- Output the error details --->
          <cfoutput> #cfcatch.Detail#<br />
            #cfcatch.Message# </cfoutput>
          <!--- and stop processing --->
          <cfabort>
          <!--- end catching the create --->
        </cfcatch>
      </cftry>
      <!--- check if MySQL Mode --->
      <cfelseif URL.mode EQ "MySQL">
      <!--- try to create the database (MySQL) --->
      <cftry>
        <!--- create the ipaddresses table --->
        <cfquery name="qCreateIpAddressesTable" datasource="#ds#" username="#un#" password="#pw#">
CREATE TABLE `a_ipaddresses` (
  `fromIP` int(10) unsigned NOT NULL,
  `toIP` int(10) unsigned NOT NULL,
  `registryID` int(10) unsigned NOT NULL,
  `assigned` datetime NOT NULL default '0000-00-00 00:00:00',
  `countryID` int(10) unsigned NOT NULL,
  PRIMARY KEY  (`fromIP`,`toIP`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin
</cfquery>
        <!--- catch any database errors --->
        <cfcatch type="database">
          <!--- Output the error details --->
          <cfoutput> #cfcatch.Detail#<br />
            #cfcatch.Message# </cfoutput>
          <!--- and stop processing --->
          <cfabort>
          <!--- end catching the create --->
        </cfcatch>
      </cftry>
      <!--- end which mode --->
    </cfif>
    <!--- end catching checking for existence of ipaddresses --->
  </cfcatch>
</cftry>
<!---                                                            --->
<!--- Check for countries table, drop and create if non-existent --->
<!---                                                            --->
<cftry>
  <!--- check if table already exists --->
  <cfquery name="qGetCountry" datasource="#ds#" username="#un#" password="#pw#">
SELECT * FROM a_countries WHERE countryID = 999999999
</cfquery>
  <!--- catch non-existence of the database --->
  <cfcatch type="database">
    <!--- try to drop the table (JIC) --->
    <cftry>
      <!--- drop the table --->
      <cfquery name="qDropTable" datasource="#ds#" username="#un#" password="#pw#">
DROP TABLE a_countries
</cfquery>
      <!--- catch JIC --->
      <cfcatch type="database">
        <!--- do nothing --->
      </cfcatch>
    </cftry>
    <!--- check if Microsoft SQL Mode --->
    <cfif URL.mode EQ "MSSQL">
      <!--- try to create the database (MSSQL) --->
      <cftry>
        <!--- create the countries table --->
        <cfquery name="qCreateCountriesTable" datasource="#ds#" username="#un#" password="#pw#">
CREATE TABLE [dbo].[a_countries] (
[countryID] decimal(10, 0) NOT NULL,
[country2lc] char(2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[country3lc] char(3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[country] varchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL)
ON [PRIMARY]
</cfquery>
        <!--- catch any database errors --->
        <cfcatch type="database">
          <!--- Output the error details --->
          <cfoutput> #cfcatch.Detail#<br />
            #cfcatch.Message# </cfoutput>
          <!--- and stop processing --->
          <cfabort>
          <!--- end catching the create --->
        </cfcatch>
      </cftry>
      <!--- check if MySQL Mode --->
      <cfelseif URL.mode EQ "MySQL">
      <!--- try to create the database (MySQL) --->
      <cftry>
        <!--- create the ipaddresses table --->
        <cfquery name="qCreateCountriesTable" datasource="#ds#" username="#un#" password="#pw#">
CREATE TABLE `a_countries` (
  `countryID` int(10) unsigned NOT NULL,
  `country2lc` char(2) character set latin1 NOT NULL,
  `country3lc` char(3) character set latin1 NOT NULL,
  `country` tinytext character set latin1 NOT NULL,
  PRIMARY KEY  (`countryID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin
</cfquery>
        <!--- catch any database errors --->
        <cfcatch type="database">
          <!--- Output the error details --->
          <cfoutput> #cfcatch.Detail#<br />
            #cfcatch.Message# </cfoutput>
          <!--- and stop processing --->
          <cfabort>
          <!--- end catching the create --->
        </cfcatch>
      </cftry>
      <!--- end which mode --->
    </cfif>
    <!--- end catching checking for existence of ipaddresses --->
  </cfcatch>
</cftry>
<!---                                                             --->
<!--- Check for registries table, drop and create if non-existent --->
<!---                                                             --->
<cftry>
  <!--- check if table already exists --->
  <cfquery name="qGetRegistry" datasource="#ds#" username="#un#" password="#pw#">
SELECT * FROM a_registries WHERE registryID = 999999999
</cfquery>
  <!--- catch non-existence of the database --->
  <cfcatch type="database">
    <!--- try to drop the table (JIC) --->
    <cftry>
      <!--- drop the table --->
      <cfquery name="qDropTable" datasource="#ds#" username="#un#" password="#pw#">
DROP TABLE a_registries
</cfquery>
      <!--- catch JIC --->
      <cfcatch type="database">
        <!--- do nothing --->
      </cfcatch>
    </cftry>
    <!--- check if Microsoft SQL Mode --->
    <cfif URL.mode EQ "MSSQL">
      <!--- try to create the database (MSSQL) --->
      <cftry>
        <!--- create the registries table --->
        <cfquery name="qCreateRegistriesTable" datasource="#ds#" username="#un#" password="#pw#">
CREATE TABLE [dbo].[a_registries] (
[registryID] decimal(10, 0) NOT NULL,
[registry] varchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL)
ON [PRIMARY]
</cfquery>
        <!--- catch any database errors --->
        <cfcatch type="database">
          <!--- Output the error details --->
          <cfoutput> #cfcatch.Detail#<br />
            #cfcatch.Message# </cfoutput>
          <!--- and stop processing --->
          <cfabort>
          <!--- end catching the create --->
        </cfcatch>
      </cftry>
      <!--- check if MySQL Mode --->
      <cfelseif URL.mode EQ "MySQL">
      <!--- try to create the database (MySQL) --->
      <cftry>
        <!--- create the ipaddresses table --->
        <cfquery name="qCreateRegistriesTable" datasource="#ds#" username="#un#" password="#pw#">
CREATE TABLE `a_registries` (
  `registryID` int(10) unsigned NOT NULL,
  `registry` tinytext character set latin1 NOT NULL,
  PRIMARY KEY  (`registryID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin
</cfquery>
        <!--- catch any database errors --->
        <cfcatch type="database">
          <!--- Output the error details --->
          <cfoutput> #cfcatch.Detail#<br />
            #cfcatch.Message# </cfoutput>
          <!--- and stop processing --->
          <cfabort>
          <!--- end catching the create --->
        </cfcatch>
      </cftry>
      <!--- end which mode --->
    </cfif>
    <!--- end catching checking for existence of ipaddresses --->
  </cfcatch>
</cftry>
<!--- show processing information --->
<cfif SESSION[sourceFileHash].totalLines EQ 0>
  <cfset verb = "Starting">
  <cfelse>
  <cfset verb = "Continuing">
</cfif>
<cfoutput>
  <h2>#verb# at row #SESSION[sourceFileHash].totalLines+1#</h2>
  <p>Last run time: #SESSION[sourceFileHash].lastRunTime#ms</p>
</cfoutput>
<!--- Timing variable --->
<cfset tcOne = getTickCount()>
<!--- set row counter --->
<cfset iCount   = 0>
<!--- loop while more rows to process --->
<cfloop condition="#canCountinue#">
  <!--- Using the line number reader in the SESSION scope --->
  <cfset sourceLine = SESSION[sourceFileHash].oLog.readLine()>
  <!--- Check if the line exists, if it doesn't, we are at the end of the file --->
  <cfset canCountinue = isDefined( "sourceLine" )>
  <cfif canCountinue >
    <cfif Left(sourceLine,1) NEQ "##" AND sourceLine NEQ "">
      <!--- Parse the line read in --->
      <cfinvoke component="component/parseResourceList" method="parseResourceList" sourceText="#sourceLine#" returnvariable="myQuery">
      <!--- get the registrar --->
      <cfquery name="qGetRegistrar" datasource="#ds#" username="#un#" password="#pw#">
SELECT * FROM a_registries WHERE registry = '#myQuery.registry#'
</cfquery>
      <!--- check for existence of registrar --->
      <cfif qGetRegistrar.RecordCount EQ 0>
        <!--- if registrar doesn't already exist in the database --->
        <!--- get the max registryID --->
        <cfquery name="qGetMaxId" datasource="#ds#" username="#un#" password="#pw#">
SELECT MAX(registryID) AS reg FROM a_registries
</cfquery>
        <!--- if the max registryID is NULL (new database) --->
        <cfif qGetMaxId.reg EQ "">
          <!--- set the new registryID to 1 --->
          <cfset newRegId = 1>
          <cfelse>
          <!--- otherwise, set it to the max plus one --->
          <cfset newRegId = qGetMaxId.reg + 1>
        </cfif>
        <!--- put the registry into the database --->
        <cfquery name="qPutRegistrar" datasource="#ds#" username="#un#" password="#pw#">
INSERT INTO a_registries (registryID, registry) VALUES ('#newRegId#', '#myQuery.registry#')
</cfquery>
        <!--- get the registrar, again --->
        <cfquery name="qGetRegistrar" datasource="#ds#" username="#un#" password="#pw#">
SELECT registryID FROM a_registries WHERE registry = '#myQuery.registry#'
</cfquery>
        <!--- end checking for existence of registry --->
      </cfif>
      <!--- get the country --->
      <cfquery name="qGetCountry" datasource="#ds#" username="#un#" password="#pw#">
SELECT countryID FROM a_countries WHERE country2lc = '#myQuery.country2lc#'
</cfquery>
      <!--- check for existence of country --->
      <cfif qGetCountry.RecordCount EQ 0>
        <!--- if country doesn't already exist in the database --->
        <!--- get the max countryID --->
        <cfquery name="qGetMaxId" datasource="#ds#" username="#un#" password="#pw#">
SELECT MAX(countryID) AS cnt FROM a_countries
</cfquery>
        <!--- if the max countryID is NULL (new database) --->
        <cfif qGetMaxId.cnt EQ "">
          <!--- set the new countryID to 1 --->
          <cfset newCatId = 1>
          <cfelse>
          <!--- otherwise, set it to the max plus one --->
          <cfset newCatId = qGetMaxId.cnt + 1>
        </cfif>
        <!--- put the country into the database --->
        <cfquery name="qPutCountry" datasource="#ds#" username="#un#" password="#pw#">
INSERT INTO a_countries (countryID, country2lc, country3lc, country) VALUES ('#newCatId#', '#myQuery.country2lc#', '#myQuery.country3lc#', '#myQuery.country#')
</cfquery>
        <!--- get the country, again --->
        <cfquery name="qGetCountry" datasource="#ds#" username="#un#" password="#pw#">
SELECT countryID FROM a_countries WHERE country2lc = '#myQuery.country2lc#'
</cfquery>
        <!--- end checking for existence of country --->
      </cfif>
      <!--- check if Microsoft SQL Mode --->
      <cfif URL.mode EQ "MSSQL">
        <!--- try to put the values --->
        <cftry>
          <!--- put ipaddress range into the database --->
          <!--- with countryID and registryID from queries --->
          <cfquery name="qPutRecord" datasource="#ds#" username="#un#" password="#pw#">
INSERT INTO a_ipaddresses (fromIP, toIP, registryID, assigned, countryID) VALUES ('#myQuery.from#', '#myQuery.to#', '#qGetRegistrar.registryID#', dateadd(ss, #myQuery.assigned#, '19700101'), '#qGetCountry.countryID#')
</cfquery>
          <!--- catch any database errors --->
          <cfcatch type="database">
            <!--- Output the error details --->
            <cfoutput> #cfcatch.Detail#<br />
              #cfcatch.Message# </cfoutput>
            <!--- and stop processing --->
            <cfabort>
            <!--- end catching the create --->
          </cfcatch>
        </cftry>
        <!--- check if MySQL Mode --->
        <cfelseif URL.mode EQ "MySQL">
        <!--- try to insert the values --->
        <cftry>
          <!--- put ipaddress range into the database --->
          <!--- with countryID and registryID from queries --->
          <cfquery name="qPutRecord" datasource="#ds#" username="#un#" password="#pw#">
INSERT INTO a_ipaddresses (fromIP, toIP, registryID, assigned, countryID) VALUES ('#myQuery.from#', '#myQuery.to#', '#qGetRegistrar.registryID#', FROM_UNIXTIME(#myQuery.assigned#), '#qGetCountry.countryID#')
</cfquery>
          <!--- catch any database errors --->
          <cfcatch type="database">
            <!--- Output the error details --->
            <cfoutput> #cfcatch.Detail#<br />
              #cfcatch.Message# </cfoutput>
            <!--- and stop processing --->
            <cfabort>
            <!--- end catching the create --->
          </cfcatch>
        </cftry>
        <!--- end checking mode --->
      </cfif>
      <!--- increase the counter --->
      <cfset iCount = iCount + 1>
      <!--- output processing feedback --->
      <cfoutput>## </cfoutput>
      <cfflush>
      <!--- Is this the end? If so, stop the loop --->
      <cfset canCountinue = ( iCount LT iBlockCount)>
    </cfif>
    <cfelse>
    <!--- We have reached the end of the file --->
    <cfset bEndOfFile = true>
  </cfif>
</cfloop>
<!--- calculate the end time --->
<cfset tcTwo = getTickCount()>
<!--- set last run time --->
<cfset SESSION[sourceFileHash].lastRunTime = tcTwo - tcOne>
<!--- set total run time --->
<cfset SESSION[sourceFileHash].totalRunTime = SESSION[sourceFileHash].totalRunTime + SESSION[sourceFileHash].lastRunTime>
<!--- check for end of file --->
<cfif NOT bEndOfFile>
  <!--- 
May be some logging code here to.
EG:
<cffile action="append" file="[mylog file]" output="#now()# - completed up to row #iUpperLimit#">
--->
  <!--- set the totalLines processed to the current line number --->
  <cfset SESSION[sourceFileHash].totalLines = SESSION[sourceFileHash].oLog.getlineNumber()>
  <!--- Foward the template back to itself to continue. Use a JS forward, as we are cfflushing to let the user know what is going on --->
  <cfoutput>
    <script type="text/javascript" language="JavaScript">
document.location = document.location;
</script>
  </cfoutput>
  <cfelse>
  <!--- end of file --->
  <!--- output results to user --->
  <cfoutput>
    <h1>Process Complete!</h1>
    <ul>
      <li>End Time: #DateFormat(Now(),'mm.dd.yyyy')# #TimeFormat(Now(),'hh:mm:ss tt')#</li>
      <li>Total Run Time: #Int(SESSION[sourceFileHash].totalRunTime/1000)# seconds</li>
    </ul>
    <br />
    <br />
    Thank you for using the Coldfusion IpToCountry.csv Import Utility. </cfoutput>
  <!--- Close the .csv file --->
  <cfset SESSION[sourceFileHash].oLog.close()>
  <!--- destroy the struct --->
  <cfset structDelete( SESSION , sourceFileHash)>
</cfif>
<cfoutput>
</body>
</html>
</cfoutput>