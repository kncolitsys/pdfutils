<cfsetting enablecfoutputonly="true">
<!--- tests a fix to PDFs w/ non-English stuff in em --->
<cfset pdf = createObject("component", "pdfutils")>

<cfset mypdf = expandPath("./testpdf.pdf")>

<cfset results = pdf.getText(mypdf)>
<cfdump var="#results#">
