<cfset pdf = createObject("component", "pdfutils")>

<!--- this xml file is not in the zip --->
<cfset mypdf = expandPath("../xmpTest_full.pdf")>
<!--- get raw xmp xml --->
<cfset xmp = pdf.readXMP(mypdf)>
<cfoutput>#htmlCodeFormat(xmp)#</cfoutput>

<!--- get xmp xml ob --->
<cfset xmp = pdf.readXMP(mypdf,true)>
<cfdump var="#xmp#">