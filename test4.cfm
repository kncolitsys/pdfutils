<cfsetting enablecfoutputonly="true">
<!--- tests a fix to PDFs w/ non-English stuff in em --->
<cfset pdf = createObject("component", "pdfutils")>

<cfset mypdf = "/Users/ray/Desktop/test2.pdf">

<cfset results = pdf.getExtraInfo(mypdf)>
<cfdump var="#results#">
