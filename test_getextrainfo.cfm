<cfset pdf = createObject("component", "pdfutils")>

<cfset mypdf = expandPath("./paristoberead.pdf")>
<cfset eInfo = pdf.getExtraInfo(mypdf)>
<cfdump var="#eInfo#">