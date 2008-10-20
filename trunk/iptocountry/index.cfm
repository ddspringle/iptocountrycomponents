<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>IpToCountry Components</title>
</head>
<body style="font-family:Verdana, Arial, Helvetica, sans-serif; font-size:12px;">
<h1>IpToCountry Components</h1>
<p>This package consists of two components and two Coldfusion pages. One is used to import the IpToCountry.csv file from <a href="http://software77.net/geoip-software.htm" target="_blank">WebNet77</a> into either a MySQL or MSSQL database. The other is used to get the country information from the database once it is imported.</p>
<h2>importIpToCountryCsv</h2>
<p>The importIpToCountryCsv.cfm page utilizes the parseResourceList.cfc component to separated the comma delimited list retreived from the IpToCountry.csv file. The process is designed to use session variables and direct Java manupiulation via use of CreateObject to import a limited number of records at a time. This prevents the Coldfusion page from timing out and ensures that all of the records are read properly. NOTE: Some hosts do not support the use of the CreateObject or associated object functions available in Coldfusion, check with your hosting provider to ensure they allow, or can allow, the use of direct Java manipulation of your files. </p>
<p>Application.cfm contains two paramaters for importIpToCountryCsv.cfm:</p>
<ul>
  <li>fileChars
    <ul>
      <li>The number of characters to use from the filename to make a session hash. Default is 8.</li>
    </ul>
  </li>
  <li>iBlockCount
    <ul>
      <li>The number of records to process at once. Default is 2000.</li>
    </ul>
  </li>
</ul>
<p>To import the IpToCountry.csv file from <a href="http://software77.net/geoip-software.htm" target="_blank">WebNet77</a> into your SQL server database you need to take the following steps:</p>
<ol>
  <li>Download the IpToCountry.csv file from <a href="http://software77.net/geoip-software.htm">WebNet77</a> (or use the one provided)</li>
  <li>Publish the IpToCountry.csv file to the /ipToCountry/sql folder of this package </li>
  <li>Create a database on your SQL Server (Microsoft SQL 2000 or MySQL 5)</li>
  <li>Assign a user and password to the database with read and write permissions</li>
  <li>Update the datasource (ds), username (un) and password (pw) variables in Application.cfm</li>
  <li>For Microsoft SQL Server 2000 implementations
    <ul>
      <li><a href="importIpToCountryCsv.cfm?mode=MSSQL">Import into MSSQL</a> (does not drop the database tables)</li>
      <li><a href="importIpToCountryCsv.cfm?mode=MSSQL&amp;force=True">Import into MSSQL (force)</a> (drops the dataabase tables)</li>
    </ul>
  </li>
  <li>For Sun MySQL Server 5 implementations
    <ul>
      <li><a href="importIpToCountryCsv.cfm?mode=MySQL">Import into MySQL</a> (does not drop the database tables)</li>
      <li><a href="importIpToCountryCsv.cfm?mode=MySQL&amp;force=True">Import into MySQL (force)</a> (drops the dataabase tables)</li>
    </ul>
  </li>
</ol>
<h2>Usage</h2>
<p>To use the data once it is imported into your SQL server, you invoke the ipToCountry.cfc component with the IP address you want to know the country of. An <a href="usage.cfm" target="_blank">example file</a> is provided to demonstrate how this component can be easily implemented to retreive the name of your country. An example of how to implement this in your own code would be:</p>
<p style="font-family:'Courier New', Courier, monospace">&lt;cfinvoke component=&quot;component/ipToCountry&quot; method=&quot;ipToCountry&quot; ipAddress=&quot;#myIP#&quot; returnvariable=&quot;country&quot;&gt;</p>
<h2>Virtual Solutions Group</h2>
<p>This package is licensed under a Creative Commons Attribution-Non Commercial 3.0 license. If you use this package in your software, website or web application please give credit to Virtual Solutions Group and link to the project page on Google Code.</p>
</body>
</html>
