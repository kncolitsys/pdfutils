<cfset pdf = createObject("component", "pdfutils")>


<!---// START Dump our utility methods //--->
<!--- <cfdump var="#buildEmptyMetadata()#">
<cfdump var="#getDublinCoreSchemaProperties()#">
<cfdump var="#getPDFSchemaProperties()#">
<cfdump var="#getXMPBasicSchemaProperties()#"> --->
<!---// END Dump our utility methods //--->

<!---// START Build our XMP structure (manually, can also use buildEmptyMetadata()) //--->
<cfset myXMP = StructNew()>

<cfset testPublisherArray = ArrayNew(1)>
<cfset testPublisherArray[1] = "PublisherArrayPos1">
<cfset testPublisherArray[2] = "PublisherArrayPos2">

<cfset myXMP.dublinCore = StructNew()>
<cfset myXMP.dublinCore.subject  = "TheSubject">
<cfset myXMP.dublinCore.coverage = "TheCoverage">
<cfset myXMP.dublinCore.publisher= testPublisherArray>

<cfset myXMP.pdf = StructNew()>
<cfset myXMP.pdf.keywords = "KeywordTest">
<cfset myXMP.pdf.producer = "ProducerTest">

<cfset myXMP.xmpbasic = StructNew()>
<cfset myXMP.xmpbasic.advisory = "AdvisoryTest">
<cfset myXMP.xmpbasic.baseurl = "BaseURLTest">
<cfset myXMP.xmpbasic.nickname = testPublisherArray>
<cfset myXMP.xmpbasic.testPropertyDoesntExist = "This property doesn't exist so won't get written.">
<!---// END Build our XMP structure (manually, can also use buildEmptyMetadata()) //--->

<!--- 
<!---// START test cases for failures // --->
<cfset getSchemaProperties("invalidSchema")>
<cfset myXMP.xmp 			= StructNew()>
<cfset myXMP.xmp.advisory 	= "edtest1">
<cfset myXMP.xmp.baseurl 	= "edtest2">
<!---// END test cases for failures // --->
 --->

<!--- set file locations --->
<cfset inputFile 	= ExpandPath("./xmpTest_emptyXMP.pdf")>
<cfset outputFile 	= ExpandPath("./xmpTest_fullXMP.pdf")>

<cfset myCustomArray = ArrayNew(1)>
<cfset myCustomArray[1] = "Xbox 360">
<cfset myCustomArray[2] = "Playstation 3">

<cfset myCustomXMP = StructNew()>
<cfset myCustomXMP.firstName 	= "Pdf">
<cfset myCustomXMP.lastName 	= "Utils">
<cfset myCustomXMP.salutation 	= "CFC">
<cfset myCustomXMP.consolesOwned = myCustomArray>
<!--- comment the config_namespaceURI line below out to throw error --->
<cfset myCustomXMP.config_namespaceURI = "http://www.pdfutils.org/xmpCustomSchema/">

<!--- stick the custom XMP struct into the main XMP struct --->
<cfset myXMP.pdfUtils = myCustomXMP>

<!--- Display the CFC example struct with documentation --->
<cfdump var="#pdf.buildEmptyMetadata()#">

<!--- Display the input data struct --->
<cfdump var="#myXMP#">

<!--- write the data into the PDF --->
<cfset pdf.writeXMP(inputFile, outputFile, myXMP, TRUE)>

<!--- read the metadata back out of the file --->
<cfdump var="#pdf.readXMP(outputFile)#">