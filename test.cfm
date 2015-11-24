<cfset pdf = createObject("component", "pdfutils")>

<cfset mypdf = expandPath("./paristoberead.pdf")>

<cfset results = pdf.getText(mypdf,2)>
<cfdump var="#results#">

<p><hr/><p>

<cfset mypdf = expandPath("./test.pdf")>
<cfset results = pdf.getText(mypdf)>
<cfdump var="#results#">
