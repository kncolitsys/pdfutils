<cfset pdf = createObject("component", "pdfutils")>

<cfset mypdf = expandPath("./paristoberead.pdf")>

<cfset page2 = pdf.getPage(mypdf, 2)>
<cfdump var="#page2#">

<cfpdf action="write" source="page2" destination="page2.pdf" overwrite="true">
