<cfapplication name="ipToCountry" clientmanagement="yes" sessionmanagement="yes" setclientcookies="yes" setdomaincookies="yes" sessiontimeout="900" applicationtimeout="900" clientstorage="Cookie">
<!--- CF DSN --->
<cfset ds = "mysqlcf_iptocountry">
<!--- DS Username --->
<cfset un = "iptocountry">
<!--- DS Password --->
<cfset pw = "$uG@rD@ddy">
<!--- set number of characters to use for hash --->
<cfset fileChars = 8>
<!--- The number of lines in the file to read in at a time --->
<cfset iBlockCount = 2000>