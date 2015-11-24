<cfcomponent displayName="PDF Utils" hint="Set of utilities to work with PDFs in ColdFusion 8" output="false">

<cffunction name="getExtraInfo" access="public" returnType="any" output="false" hint="I return additional information about a PDF, via DDX.">
	<cfargument name="pdfpath" type="string" required="true" hint="The path to the PDF file">
	<cfset var result = structNew()>
	<cfset var ddx = "">
	<cfset var inputStruct = "">
	<cfset var outputStruct = "">
	<cfset var tempxml = getTempFile(getTempDirectory(), "pdfutils")>
	<cfset var ddxVar = "">
	<cfset var myxml = "">
	<cfset var x = "">
	<cfset var node = "">
	<cfset var text = "">
	<cfset var key = "">
	
	<!--- does the file exist? --->
	<cfif not fileExists(arguments.pdfpath)>
		<cfthrow message="Unable to find pdf: #arguments.pdfpath#">
	</cfif>
	
	<!--- Create DDX --->
	<cfsavecontent variable="ddx">
<cfoutput>
<?xml version="1.0" encoding="UTF-8"?>
<DDX xmlns="http://ns.adobe.com/DDX/1.0/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://ns.adobe.com/DDX/1.0/ coldfusion_ddx.xsd">
<DocumentInformation result="Out1" source="doc1" />
</DDX>
</cfoutput>
	</cfsavecontent>
	
	<cfset ddx = trim(ddx)>
	
	<!--- Set my parameters --->
	<cfset inputStruct = {doc1="#arguments.pdfpath#"}>
	<cfset outputStruct = {Out1="#tempxml#"}>
	
	<!--- Process --->
	<cfpdf action="processddx" ddxfile="#ddx#" inputfiles="#inputStruct#" outputfiles="#outputStruct#" name="ddxVar">
	
	<cfif fileExists(tempxml)>
		<!--- read in and parse xml --->
		<cffile action="read" file="#tempxml#" variable="myxml">
		<cfset myxml = xmlParse(myxml)>
	
		<cfloop item="key" collection="#myxml.DocInfo#">
			<cfif key is "PageSizes">
				<!--- we can have N page size elements --->
				<cfset result.PageSizes = arrayNew(1)>
				<cfloop index="x" from="1" to="#arrayLen(myXML.DocInfo.PageSizes.PageSize)#">
					<cfset result.PageSizes[arrayLen(result.PageSizes)+1] = myXML.DocInfo.PageSizes.PageSize[x].xmlAttributes>
					<cfif listFirst(myXML.DocInfo.PageSizes.PageSize[x].xmlAttributes.height, '.') GT listFirst(myXML.DocInfo.PageSizes.PageSize[x].xmlAttributes.width, '.')>
						<cfset structInsert(result.PageSizes[arrayLen(result.PageSizes)], 'orientation', 'P')>
					<cfelse>
						<cfset structInsert(result.PageSizes[arrayLen(result.PageSizes)], 'orientation', 'L')>
					</cfif>
				</cfloop>
			<cfelseif key is "PageRotations">
				<!--- ditto for this guy --->
				<cfset result.PageRotations = arrayNew(1)>
				<cfloop index="x" from="1" to="#arrayLen(myXML.DocInfo.PageRotations.PageRotation)#">
					<cfset result.PageRotations[arrayLen(result.PageRotations)+1] = myXML.DocInfo.PageRotations.PageRotation[x].xmlAttributes>
				</cfloop>
			<cfelseif key is "PageLabels">
				<!--- ditto for this guy --->
				<cfset result.PageLabels = arrayNew(1)>
				<cfloop index="x" from="1" to="#arrayLen(myXML.DocInfo.PageLabels.PageLabel)#">
					<cfset result.PageLabels[arrayLen(result.PageLabels)+1] = myXML.DocInfo.PageLabels.PageLabel[x].xmlAttributes>
				</cfloop>
			<cfelse>
				<cfset result[key] = myXMl.DocInfo[key].xmlText>
			</cfif>
		</cfloop>
		<cffile action="delete" file="#tempxml#">
	<cfelse>
		<cfset result = 'Was not able to read the document information from pdf'>
	</cfif>
	<cfreturn result>
</cffunction>


<cffunction name="getPage" access="public" returnType="any" output="false" hint="I return one page of a PDF file as a PDF.">
	<cfargument name="pdf" type="any" required="true" hint="The PDF. Either a filename or pdf var.">
	<cfargument name="page" type="numeric" required="true" hint="Page number to get.">
	<cfset var info = "">
	<cfset var result = "">
	
	<!--- get info on the pdf --->
	<cfpdf action="getinfo" name="info" source="#arguments.pdf#">
	
	<cfif info.totalpages lt arguments.page>
		<cfthrow message="#arguments.pdf# only has #info.totalpages#. Cannot get page #arguments.page#">
	</cfif>

	<!---
	We need to tell cfpdf to delete everything BUT N. So we make a string to represent this.
	--->
	<cfif info.totalPages EQ 1>
         <cfpdf action="read" source="#arguments.pdf#" name="result">
		 <cfreturn result>
    <cfelseif arguments.page is 1 and info.totalpages gte 2>
		<cfset range = "2-#info.totalpages#">
	<cfelseif arguments.page lt info.totalpages>
		<cfset range = "1-#arguments.page-1#,#arguments.page+1#-#info.totalpages#">
	<cfelse>
		<cfset range = "1-#arguments.page-1#">
	</cfif>

	<!---
<!--- Now we make a new temp pdf, serve it with pie, and then delete it --->
<cfset newfilename = getTempFile(getTempDirectory(),"pdfeditor")>
--->

	<cfpdf action="deletePages" source="#arguments.pdf#" pages="#range#" name="result" >

	<cfreturn result>
</cffunction>

<cffunction name="getText" access="public" returnType="array" output="false" hint="I get text from a PDF file.">
       <cfargument name="pdfpath" type="string" required="true" hint="The path to the PDF file">
       <cfargument name="page" type="numeric" required="false" default="0" hint="Page number to get. If not passed in, return all">

       <cfset var results = arrayNew(1)>
       <cfset var ddx = "">
       <cfset var inputStruct = "">
       <cfset var outputStruct = "">
       <cfset var tempxml = getTempFile(getTempDirectory(), "pdfutils")>
       <cfset var ddxVar = "">
       <cfset var myxml = "">
       <cfset var x = "">
       <cfset var node = "">
       <cfset var s = "">

       <!--- does the file exist? --->
       <cfif not fileExists(arguments.pdfpath)>
               <cfthrow message="Unable to find pdf: #arguments.pdfpath#">
       </cfif>

       <!--- Create DDX --->
       <cfsavecontent variable="ddx">
<cfoutput>
<?xml version="1.0" encoding="UTF-8"?>
<DDX xmlns="http://ns.adobe.com/DDX/1.0/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://ns.adobe.com/DDX/1.0/ coldfusion_ddx.xsd">
<DocumentText result="Out1">
<PDF source="doc1"/>
</DocumentText>
</DDX>
</cfoutput>
       </cfsavecontent>

       <cfset ddx = trim(ddx)>

       <!--- Set my parameters --->
       <cfset inputStruct = {doc1="#arguments.pdfpath#"}>
       <cfset outputStruct = {Out1="#tempxml#"}>

       <!--- Process --->
       <cfpdf action="processddx" ddxfile="#ddx#" inputfiles="#inputStruct#" outputfiles="#outputStruct#" name="ddxVar">

       <!--- read in and parse xml --->
       <cffile action="read" file="#tempxml#" variable="myxml" charset="utf-8">
       <cfset myxml = xmlParse(myxml)>

       <!--- ensure valid stuff --->
       <cfif structKeyExists(myxml, "DocText") and structKeyExists(myxml.DocText,"TextPerPage") and structKeyExists(myxml.DocText.TextPerPage, "Page")>
               <!--- if we're after one valid page... --->
               <cfif arguments.page neq 0 and arrayLen(myxml.DocText.TextPerPage.Page) gte arguments.page>
			   			<cfset node = myxml.doctext.textperpage.page[arguments.page]>
                       <cfset s = structNew()>
                       <cfset s.text = node.xmltext>
                       <cfset s.pagenumber = node.xmlAttributes.pageNumber>
                       <cfset arrayAppend(results, s)>
               <cfelse><!--- we must be wanting all pages' content --->
                       <cfloop index="x" from="1" to="#arrayLen(myxml.DocText.TextPerPage.Page)#">
                               <cfset node = myxml.DocText.TextPerPage.Page[x]>
                               <cfset s = structNew()>
                               <cfset s.text = node.xmltext>
                               <cfset s.pagenumber = node.xmlAttributes.pageNumber>
                               <cfset arrayAppend(results, s)>
                       </cfloop>
               </cfif>
       </cfif>

       <cfreturn results>
</cffunction>

<cffunction name="readXMP" output="false" access="public" returntype="any" description="I read XMP metadata from a PDF file.">
	<cfargument name="fileName" required="true" type="string" displayname="fileName" hint="The absolute path and filename of the PDF to be read.">
	<cfargument name="returnAsXML" required="false" type="boolean" default="false" displayname="returnAsXML" hint="Set whether to return XMP data as a CF XML struct. If not, returns a simple string.">
	
	<!--- local scope internal vars --->
	<cfset var local = StructNew()>
	
	<!--- validate argument input - does file exist? --->
	<cfif not fileExists(arguments.fileName)>
		<cfthrow type="pdfUtils.readXMP.fileNotFound" message="PDF file not found." detail="The file specified, #arguments.fileName#, does not exist.">
	</cfif>
	
	<!--- set container for XMP data --->
	<cfset local.xmpData = "">
	
	<!--- try to read the metadata --->
	<cftry>
	
		<!--- create and instantiate the itext PDFReader --->
		<cfset local.reader = createObject("java", "com.lowagie.text.pdf.PdfReader")>
		<cfset local.reader.init(arguments.fileName)>
		
		<!--- read metadata from PDFReader (getMetaData() returns ByteArray, can't treat as XML) --->
		<cfset local.metaByteArray = local.reader.getMetaData()>
		
		<!--- if the struct key exists, then we have read metadata from the PDF --->
		<cfif StructKeyExists(local, "metaByteArray")>
			
			<!--- create a Java string from the byte array --->
			<cfset local.xmpData = createObject("java", "java.lang.String").init(local.metaByteArray)>
			
			<!--- do we want XMP returned as string or XML? --->
			<cfif arguments.returnAsXML>
				<cfset local.xmpData = XMLParse(local.xmpData)>
			</cfif>
	
		</cfif>
		
		<!--- close the reader --->
		<cfset local.reader.close()>
	
		<!--- catch unexpected exceptions, particularly from iText --->
		<cfcatch type="any">

			<cfset local.errorMessage 	= cfcatch.message>
			<cfset local.errorDetail 	= cfcatch.detail>

			<!--- we may get extended error info back from the iText object: it's useful so use in preference to the Object Instantiation useless error that CF throws --->
			<cfif StructKeyExists(cfcatch,"Cause") and StructKeyExists(cfcatch.Cause,"Cause") and StructKeyExists(cfcatch.Cause.Cause,"Message")>
				
				<cfif Trim(cfcatch.Cause.Cause.Message) is "PDF header signature not found.">
					<!--- file supplied is not a valid PDF file so overwrite obscure CF error messages --->
					<cfset local.errorMessage= "Supplied file is not a valid PDF.">	
					<cfset local.errorDetail = "The supplied file, #arguments.fileName#, is not a valid PDF file. #cfcatch.Cause.Cause.Message#">	
				<cfelse>
					<!--- don't know what this error is, so just output as much detail as possible --->		
					<cfset local.errorDetail = local.errorDetail & " " & cfcatch.Cause.Cause.Message>
				</cfif>
				
			</cfif>
			
			<cfthrow type="pdfUtils.readXMP.exceptionCaught" message="#local.errorMessage#" detail="#local.errorDetail#">
		</cfcatch>
		
	</cftry>	

	<cfreturn local.xmpData>	
</cffunction>

<cffunction name="getAvailableSchemaNames" access="public" output="false" returntype="string" displayname="getAvailableSchemaNames" description="I return a comma-delimited list of valid XMP Schemas available within CF8's iText implementation.">
	<!--- create instance data containing allowable schemas list: this assumes CF8's version of iText so no PdfA1Schema or XMPMMSchema --->
	<!--- note that schema names are CASE SENSITIVE --->
	<cfreturn "DublinCore,Pdf,XmpBasic">	
</cffunction>


<cffunction name="getSchemaProperties" access="private" output="false" returntype="string" description="getSchemaProperties" hint="I return a comma-delimited list of metadata properties for the requested schema, if it exists.">
	<cfargument name="schemaName" type="string" required="true" hint="Name of the schema to get properties for.">
	<cfset var local = StructNew()>
	<cfset local.schemaObj = instantiateValidSchema(arguments.schemaName)>
	<cfreturn getPropertyNames(local.schemaObj)>
</cffunction>


<cffunction name="getDublinCoreSchemaProperties" access="public" output="false" returntype="string" description="getDublinCoreProperties" hint="I return a comma-delimited list of Dublin Core Schema metadata properties.">
	<cfset var local = StructNew()>
	<cfset local.schemaObj = instantiateValidSchema("DublinCore")>
	<cfreturn getPropertyNames(local.schemaObj)>
</cffunction>


<cffunction name="getPDFSchemaProperties" access="public" output="false" returntype="string" description="getPDFSchemaProperties" hint="I return a comma-delimited list of PDF Schema metadata properties.">
	<cfset var local = StructNew()>
	<cfset local.schemaObj = instantiateValidSchema("PDF")>
	<cfreturn getPropertyNames(local.schemaObj)>
</cffunction>


<cffunction name="getXMPBasicSchemaProperties" access="public" output="false" returntype="string" description="getXMPBasicSchemaProperties" hint="I return a comma-delimited list of XMP Basic Schema metadata properties.">
	<cfset var local = StructNew()>
	<cfset local.schemaObj = instantiateValidSchema("XMPBasic")>
	<cfreturn getPropertyNames(local.schemaObj)>
</cffunction>


<cffunction name="buildEmptyMetadata" access="public" output="false" returntype="struct" displayname="getEmptyMetadataStruct" description="I return an empty CF struct containing a struct element per available CF8 XMP schema, then an element per available property for that XMP schema.">

	<cfset var local = StructNew()>
	<cfset local.xmpStruct = StructNew()>

	<!--- get available schema names, loop through, create element for each --->
	<cfset local.schemaNames = getAvailableSchemaNames()>
	
	<cfloop list="#local.schemaNames#" index="local.schema">
		<cfset local.xmpStruct[local.schema] = StructNew()>
		<!--- get prop names for current schema, loop through, create element for each --->
		<cfset local.properyNames = getSchemaProperties(local.schema)>
		<cfloop list="#local.properyNames#" index="local.property">
			<cfset local.xmpStruct[local.schema][local.property] = "">
		</cfloop>
	</cfloop>
	
	<cfset StructAppend(local.xmpStruct,buildCustomMetadataExample())>
	
	<cfreturn local.xmpStruct>
</cffunction>


<cffunction name="buildCustomMetadataExample" access="private" output="false" returntype="struct" displayname="getEmptyMetadataStruct" description="I return an empty CF struct containing a struct element per available CF8 XMP schema, then an element per available property for that XMP schema.">

	<cfset var local 		= StructNew()>
	<cfset local.xmpStruct 	= StructNew()>
	<cfset local.customKey	= "pdfutils">
	
	<cfset local.myCustomArray 		= ArrayNew(1)>
	<cfset local.myCustomArray[1] 	= "Xbox 360">
	<cfset local.myCustomArray[2] 	= "Playstation 3">
	
	<cfset local.xmpStruct[local.customKey] 				= StructNew()>
	<cfset local.xmpStruct[local.customKey].explanation		= "This is an example pdfUtils XMP Custom Schema struct. Populate it with simple values and 1D arrays. Add, edit or delete struct keys as required.">
	<cfset local.xmpStruct[local.customKey].documentation	= "The struct name is used as the namespace prefix (eg. #local.customKey#). This struct MUST contain a key called #getNamespaceConfigKeyname()# which must contain the namespace URI.">
	<cfset local.xmpStruct[local.customKey].firstName 		= "Pdf">
	<cfset local.xmpStruct[local.customKey].lastName 		= "Utils">
	<cfset local.xmpStruct[local.customKey].salutation 		= "CFC">
	<cfset local.xmpStruct[local.customKey].consolesOwned 	= local.myCustomArray>
	<!--- comment the config_namespaceURI line below out to throw error --->
	<cfset local.xmpStruct[local.customKey][getNamespaceConfigKeyname()] = "http://www.pfutils.org/xmpCustomSchema/">	
	
	<cfreturn local.xmpStruct>
</cffunction>


<cffunction name="getPropertyNames" access="private" output="false" returntype="string" displayname="getPropertyNames" description="I return a comma-delimited list of property names available within the supplied class.">
	<cfargument name="javaClass" displayname="javaClass" type="Any" required="true" hint="The Java object to interrogate.">
	<cfargument name="sortList" displayname="sortList" type="boolean" default="TRUE" required="false" hint="Whether or not to alpha sort the property names (in ascending order).">
	
	<cfset var local= StructNew()>
	<cfset var i	= 0>
	
	<cftry>
	
		<cfset local.propertyNames = "">
		
		<!--- if it's an object, get the Java class and extract its fields via introspection --->
		<cfif isObject(arguments.javaClass)>
			<cfset local.myClass	= arguments.javaClass.getClass()>
			<cfset local.fields		= local.myClass.getFields()>
			<cfloop from="1" to="#ArrayLen(local.fields)#" index="i">
				<cfset local.propertyNames = ListAppend("#local.propertyNames#", "#local.fields[i].getName()#", ",")>
			</cfloop>
			<!--- sort the list? default is true --->
			<cfif arguments.sortList>
				<cfset local.propertyNames = ListSort("#local.propertyNames#","TEXT","ASC")>		
			</cfif>
		</cfif>	
	
	<cfcatch type="any">
		<cfthrow type="pdfUtils.getPropertyNames.exceptionCaught" message="#cfcatch.message#" detail="#cfcatch.detail#">
	</cfcatch>	
	</cftry>	

	<cfreturn local.propertyNames>
</cffunction>


<cffunction name="instantiateValidSchema" access="private" output="false" returntype="any" displayname="instantiateValidSchema" hint="I return an instantiated schema object for the requested XML schema, checking first that it's a valid schema.">
	<cfargument name="schema" type="string" required="true" displayname="schema" hint="The name of an XMP schema that is valid within CF8's version of iText: use getAvailableSchemaNames() for a list.">
	
	<!--- does this schema exist? --->
	<cfif not ListFindNoCase(getAvailableSchemaNames(),arguments.schema)>
		<cfthrow type="pdfUtils.instantiateValidSchema.exceptionCaught" message="Specified XMP Schema not found." detail="The XMP Schema specified, #arguments.schema#, is not available in this CF version of iText.">
	</cfif>
	
	<cftry>
	
		<!--- must ensure that case is correctly matched so use replaceList --->	
		<cfset local.schema = ReplaceList(LCase(Trim("#arguments.schema#")),LCase(getAvailableSchemaNames()),getAvailableSchemaNames()) & "Schema">
		<cfset local.schema = ReplaceNoCase(local.schema,"SchemaSchema","Schema")>
		
		<!--- create the schema object... --->
		<cfset local.schemaObj = createObject("java","com.lowagie.text.xml.xmp.#local.schema#")>
		
	<cfcatch type="any">
		<cfthrow type="pdfUtils.instantiateValidSchema.exceptionCaught" message="#cfcatch.message#" detail="#cfcatch.detail#">
	</cfcatch>	
	</cftry>	
	
	<cfreturn local.schemaObj>
</cffunction>	


<cffunction name="setXMPPropertiesFromStruct" access="private" output="false" returntype="any" displayname="setPropertieaFromStruct" hint="I take a CF struct containing property elements, and use the values of each element to set the value of the corresponding property in the chosen XMP schema.">
	<cfargument name="properties" type="struct" required="true" displayname="properties" hint="A correctly-formatted CF struct containing elements that correspond to XMP properties.">
	<cfargument name="schema" type="string" required="true" displayname="schema" hint="The name of an XMP schema that is valid within CF8's version of iText: use getAvailableSchemaNames() for a list.">
	
	<cfset var local = StructNew()>
	
	<!--- does this schema exist? --->
	<cfif not ListFindNoCase(getAvailableSchemaNames(),arguments.schema)>
		<cfthrow type="pdfUtils.setXMPPropertiesFromStruct.exceptionCaught" message="Specified XMP Schema not found." detail="The XMP Schema specified, #arguments.schema#, is not available.">
	</cfif>
	
	<cftry>

		<!--- create the schema object... --->
		<cfset local.schemaObj = instantiateValidSchema(arguments.schema)>
		
		<!--- ...then get the property list --->
		<cfset local.propertyList = getPropertyNames(local.schemaObj)>
		
		<!--- loop through supplied struct, check element exists in property list for schema, try to setProperty for that element --->
		<cfif isStruct(arguments.properties)>
			<cfloop collection="#arguments.properties#" item="local.element">
				<!--- if element exists in the schema, try to setProperty with the value. if an array, convert to XMPArray first --->
				<cfif ListFindNoCase(local.propertyList,local.element)>
					<cfset local.elementValue = arguments.properties[local.element]>
					<!--- if this struct element is an Array, convert to iText XMPArray --->
					<cfif IsArray(local.elementValue)>
						<cfset local.elementValue = createXMPArray(local.elementValue)>			
					</cfif>
					<!--- ensure that only simple values and arrays can be added to schemas --->
					<cfif IsArray(local.elementValue) or IsSimpleValue(local.elementValue)>
						<cfset local.schemaObj.setProperty(local.schemaObj[UCase(local.element)],local.elementValue)>
					</cfif>
				</cfif>
			</cfloop>
		</cfif>
	
	<cfcatch type="any">
		<cfthrow type="pdfUtils.setXMPPropertiesFromStruct.exceptionCaught" message="#cfcatch.message#" detail="#cfcatch.detail#">
	</cfcatch>	
	</cftry>
	
	<cfreturn local.schemaObj>
</cffunction>


<cffunction name="createXMPArray" access="private" output="false" returntype="any" displayname="createXMPArray" hint="I create an iText XMPArray from a simple 2D CF array." description="I create an iText XMPArray from a simple 2D CF array.">
	<cfargument name="cfArray" displayname="cfArray" required="true" type="Array" hint="A 2D CF array, containing only simple values, to be converted into an iText XMPArray">
	<cfargument name="arrayOrder" displayname="arrayOrder" type="string" required="false" default="UNORDERED" hint="Define the ordering of the output XMPArray: ORDERED, UNORDERED or ALTERNATIVE. Default is UNORDERED, as per iText docs.">
	
	<cfset var local = StructNew()>
	
	<cftry>
	
		<cfif not isArray(arguments.cfArray)>
			<cfthrow type="pdfUtils.createXMPArray.invalidCfArray" message="Invalid supplied CF Array." detail="The variable passed to createXMPArray is not a valid array. createXMPArray accepts a valid 2D ColdFusion Array.">
		</cfif>
	
		<!--- create the iText XMPArray class --->
		<cfset local.xmpObj = CreateObject("java","com.lowagie.text.xml.xmp.XmpArray")>
		
		<!--- retrieve the field names for available order types --->
		<cfset local.availableOrderTypes = getPropertyNames(local.xmpObj)>
		
		<cfif not ListFindNoCase(local.availableOrderTypes,arguments.arrayOrder)>
			<cfthrow type="pdfUtils.createXMPArray.invalidArrayOrder" message="Invalid supplied XMPArray order." detail="The variable passed to createXMPArray is not a valid XMPArray order. Valid XMPArray orders are #local.availableOrderTypes#.">
		</cfif>
		
		<!--- INIT the class depending on whether we want an ordered array or not --->
		<cfset local.xmpArray = local.xmpObj.init(local.xmpObj[arguments.arrayOrder])>			
		
		<!--- loop through our CF array, throw error on non-simple values, add simple values to XMPArray --->
		<!--- need to XMLFormat() the simple values --->
		<cfloop from="1" to="#ArrayLen(arguments.cfArray)#" index="local.arrayCount">
			<cfif isSimpleValue(arguments.cfArray[local.arrayCount])>
				<cfset local.xmpArray.add(XMLFormat(arguments.cfArray[local.arrayCount]))>
			<cfelse>
				<cfthrow type="pdfUtils.createXMPArray.invalidArray" message="Supplied CF Array contains complex values." detail="A non-simple value has been detected within the supplied CF Array. iText's XMPArray accepts only simple values: please supply only 2D CF Arrays containing simple values.">
			</cfif>
		</cfloop>
	
	<cfcatch type="any">
		<cfthrow type="pdfUtils.createXMPArray.exceptionCaught" message="#cfcatch.message#" detail="#cfcatch.detail#">
	</cfcatch>	
	</cftry>	
	
	<cfreturn local.xmpArray>
</cffunction>


<cffunction name="getNamespaceConfigKeyname" access="private" output="false" returntype="string" displayname="getNamespaceConfigKeyname" hint="I return the name of the struct key that needs to be present in order to pass a namespace URI into a custom XMP schema.">
	<cfreturn "config_namespaceURI">
</cffunction>


<cffunction name="writeXMP" access="public" output="false" returntype="Any" displayname="writeXMP" hint="I use itext's PDFStamper to add XMP metadata to an existing PDF">
	<cfargument name="inputFile" required="true" type="string" displayname="fileName" hint="The absolute path and filename of the PDF to be read.">
	<cfargument name="outputFile" required="true" type="string" displayname="fileName" hint="The absolute path and filename of the PDF to be output.">
	<cfargument name="properties" type="struct" required="true" displayname="properties" hint="A correctly-formatted CF struct containing elements that correspond to XMP schemas and their properties.">
	<cfargument name="overwrite" required="false" default="FALSE" type="boolean" displayname="overwrite" hint="Whether to overwrite the specified output file, if it already exists.">
	
	<cfset var local 		= StructNew()>
	<cfset local.success 	= TRUE>
	<!--- set the namespace identifier's struct key for custom schemas --->
	<cfset local.nsConfigKey= getNamespaceConfigKeyname()>
	<!--- set a content store var for custom schema data --->
	<cfset local.content	= "">
	
	<!--- validate --->
	<cfif not FileExists(arguments.inputFile)>
		<!--- throw error, input file doesn't exist --->
		<cfthrow type="pdfUtils.writeXMP.missingInputFile" message="The specified input PDF file cannot be found." detail="The input file specified, #arguments.inputFile#, cannot be found in the filesystem.">
	</cfif>
	
	<cfif (arguments.overwrite is FALSE) and FileExists(arguments.outputFile)>
		<!--- throw error as file already exists --->
		<cfthrow type="pdfUtils.writeXMP.outputFileExists" message="The specified output PDF file already exists." detail="The output file specified, #arguments.outputFile#, already exists in the filesystem.">
	</cfif>	
	
	<cftry>
	
		<!--- create a reader, read the existing PDF --->
		<cfset local.reader = createObject("java", "com.lowagie.text.pdf.PdfReader").init(arguments.inputFile)>
		<!--- create a fileOutputStream for the stamper --->
		<cfset local.os = createObject("java", "java.io.FileOutputStream").init(arguments.outputFile)>
		<!--- create a stamper --->
	    <cfset local.stamper = createObject("java", "com.lowagie.text.pdf.PdfStamper").init(local.reader, local.os)>   
		<!--- create and init a byteOutputStream ready for our XMP data --->
		<cfset local.bos = CreateObject("java","java.io.ByteArrayOutputStream").init()>
		<!--- create an XMPWriter using our byteoutputstream --->
		<cfset local.xmp = CreateObject("java","com.lowagie.text.xml.xmp.XmpWriter").init(local.bos)>
		
		<!--- build the XMPMetadata objects from the input CF struct --->	
		<!--- NOTE: only 1 instance of each kind of metadata is allowed here: only 1 x PDF, 1 x DublinCore, 1 x XMPBasic etc. --->
		<!--- There may be examples where multiple XMPs are needed so refactor this loop if required --->
		<cfloop collection="#arguments.properties#" item="local.item">
		
			<!--- does iText have a class for this schema, or is it a custom schema? --->
			<cfif ListFindNoCase(getAvailableSchemaNames(),local.item)>
			
				<!--- use the iText class, we have a known schema --->
				<!--- create a local metadata object from the CF struct --->
				<cfset local.xmpMetaObj[local.item] = setXMPPropertiesFromStruct(arguments.properties[local.item],local.item)>
				<!--- add metadata object to XMPWriter as RDF --->
				<cfset local.xmp.addRdfDescription(local.xmpMetaObj[local.item])>
				
			<cfelse>
			
				<!--- it's a custom schema so parse the struct and concatenate the content --->
				<!--- local.item is the namespace prefix (eg. rcml) --->
				<cfset local.currentItem = arguments.properties[local.item]>
				<cfset local.item = XMLFormat(LCase(local.item))>
				
				<!--- concatenate the namespace string - throw error if can't find a namespace (reqd by W3C spec) --->
				<cfif StructKeyExists(local.currentItem,local.nsConfigKey)>
					<cfset local.namespace = "xmlns:#local.item#='#XMLFormat(local.currentItem[local.nsConfigKey])#'">
				<cfelse>
					<cfthrow type="pdfUtils.writeXMP.missingCustomNamespaceURI" message="The namespace URI for custom schema #local.item# cannot be found." detail="Custom schema #local.item# requires a namespace URI to be passed in its content structure. The required struct key #local.nsConfigKey# is missing.">
				</cfif>		
				
				<!--- loop through the content struct, build an XMP tag with prefix from each struct key --->
				<!--- explicitly ignore the namespace config key --->
				<cfloop collection="#local.currentItem#" item="local.theKey">
					<cfif local.theKey is not local.nsConfigKey>
						<cfset local.currentContentItem = local.currentItem[local.theKey]>					
						<cfset local.tagName = "#local.item#:#LCase(local.theKey)#">
						<cfif IsSimpleValue(local.currentContentItem)>
							<cfset local.currentContentItem = XMLFormat(local.currentContentItem)>
						</cfif>
						<cfif IsArray(local.currentContentItem)>
							<cfset local.currentContentItem = createXMPArray(local.currentContentItem).toString()>
						</cfif>
						<!--- concatenate the latest XMP tag from our custom struct into the content string for this custom schema --->
						<cfif IsSimpleValue(local.currentContentItem)>
							<cfset local.content = local.content & "<#XMLFormat(local.tagName)#>#local.currentContentItem#</#XMLFormat(local.tagName)#>">
						</cfif>
					</cfif>
				</cfloop>
				
				<!--- add metadata object to XMPWriter as RDF --->
				<cfset local.xmp.addRdfDescription(toString(local.namespace),toString(local.content))>
		
			</cfif>
		</cfloop>
		
		<!--- close the xmpwriter before adding to stamper --->
		<cfif StructKeyExists(local,"xmp")>
			<cfset local.xmp.close()>
		</cfif>	
	
		<!--- stuff our XMP metadata into the stamper --->
		<cfset local.stamper.setXmpMetadata(local.bos.toByteArray())>
		
		<!--- tidy up --->
		<cfif StructKeyExists(local,"reader")>
			<cfset local.reader.close()>
		</cfif>
		
		<cfif StructKeyExists(local,"stamper")>
			<cfset local.stamper.close()>
		</cfif>
	
		<cfif StructKeyExists(local,"bos")>
			<cfset local.bos.close()>
		</cfif>	
			
		<cfif StructKeyExists(local,"os")>
			<cfset local.os.close()>
		</cfif>
	
		<!--- catch unexpected exceptions, particularly from iText --->
		<cfcatch type="any">

			<cfset local.errorMessage 	= cfcatch.message>
			<cfset local.errorDetail 	= cfcatch.detail>

			<!--- we may get extended error info back from the iText object: it's useful so use in preference to the Object Instantiation useless error that CF throws --->
			<cfif StructKeyExists(cfcatch,"Cause") and StructKeyExists(cfcatch.Cause,"Cause") and StructKeyExists(cfcatch.Cause.Cause,"Message")>
				
				<cfif Trim(cfcatch.Cause.Cause.Message) is "PDF header signature not found.">
					<!--- file supplied is not a valid PDF file so overwrite obscure CF error messages --->
					<cfset local.errorMessage= "Supplied file is not a valid PDF.">	
					<cfset local.errorDetail = "The supplied file, #arguments.inputFile#, is not a valid PDF file. #cfcatch.Cause.Cause.Message#">	
				<cfelse>
					<!--- don't know what this error is, so just output as much detail as possible --->		
					<cfset local.errorDetail = local.errorDetail & " " & cfcatch.Cause.Cause.Message>
				</cfif>
				
			</cfif>
			
			<cfthrow type="pdfUtils.writeXMP.exceptionCaught" message="#local.errorMessage#" detail="#local.errorDetail#">
		</cfcatch>
	</cftry>	
	       
	<cfreturn local.success>
</cffunction>

</cfcomponent>