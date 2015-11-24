LICENSE 
Copyright 2010 Raymond Camden

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
   
   
If you find this utility worthy, I have a Amazon wish list set up (www.amazon.com/o/registry/2TCL1D08EZEYE ).

Last Update: April 19, 2010
Doug Boude sent in support for getting just one page.

Last Update: April 13, 2010
Fix for getPage and 1 page PDFs by Matt Currier. 

Last Update: May 13, 2009
Reto Aeberli sent in another fix to getExtraInfo. It should better handle corrupt PDFs.

Last Update: May 13, 2009
Reto Aeberli sent in a fix to getExtraInfo. It now returns page orientation, and cleans up the temp xml file.

Last Update: February 26, 2009
Good catch by Mr.Buzzy - methods with DDX failed when cfsetting was blocking output.

Last Update: February 3, 2009
Fix by Mikkel Johansen in the getText method - works better for foreign text in PDFs.

Last Update: January 9, 2009
The getText function now returns a structure of text. Each key is a struct containing the page number and text contents. This helps with PDFs that have blank pages.

Last Update: August 12, 2008
Added getExtraInfo function.

Last Update: July 16, 2008
Edward EG. Griffiths added writeXMP, and many supporting methods, to pdfUtils. He was also responsible for readXMP.
The following are some notes concerning writeXMP support. Please read his notes carefully.

The basic principle of XMP is simple enough but the iText implementation
of it is fiddly. I've tried to make writeXMP() as simple as possible in
keeping with CF's design ethos: this has resulted in a couple of minor
restrictions that are described shortly. 

Using writeXMP
==============

CF8's iText version provides classes for 3 types of XMP metadata that
can be embedded within a PDF: PDF, Dublin Core, and XMP Basic. Each of
these classes contains a predefined, documented set of properties that
can be edited and saved into the PDF via writeXMP().

To see what XMP schemas are available, call getAvailableSchemaNames().
To retrieve the properties for a given XMP class, call its corresponding
getXYZSchemaProperties() method (where XYZ is the schema name). This
returns a comma-delimited list of property names for that schema.

Setting properties and saving the XMP data into a file is a one-step
process. Simply (!) create a CF struct containing a top-level element
that has the same name as the XMP Schema you want to use (without
spaces, eg. DublinCore), and create an element within that struct
element that's called the property name of the property you want to set.
That's it. WriteXMP() allows you to set both simple values and XMP
Arrays into XMP schemas, as per the docs - just use standard CF Arrays
as your property values for properties requiring an XMPArray and
writeXMP() will convert CF Arrays to XMPArray objects prior to writing
your PDF.

Here's an example of the struct format:

<cfset myXMP = StructNew()>

<cfset testPublisherArray = ArrayNew(1)> <cfset testPublisherArray[1] =
"PublisherArrayPos1"> <cfset testPublisherArray[2] =
"PublisherArrayPos2">

<cfset myXMP.dublinCore = StructNew()>
<cfset myXMP.dublinCore.subject  = "TheSubject"> <cfset
myXMP.dublinCore.coverage = "TheCoverage"> <cfset
myXMP.dublinCore.publisher= testPublisherArray>

<cfset myXMP.pdf = StructNew()>
<cfset myXMP.pdf.keywords = "KeywordTest"> <cfset myXMP.pdf.producer =
"ProducerTest">

The easiest way to set your metadata is to use the provided
buildEmptyMetadata() method to return a correctly-formatted and named CF
struct for you. This struct can be edited as required: once you're done,
just pass it into writeXMP() with your input and output filenames.

In its simplest form, to write a series of empty XMP metadata into each
of the 3 available schemas you can do this:

<cfset inputFile        = ExpandPath("./xmpTest_emptyXMP.pdf")>
<cfset outputFile = ExpandPath("./xmpTest_fullXMP.pdf")>
<cfset writeXMP(inputFile, outputFile, buildEmptyMetadata(), TRUE)>


The real power of XMP lies in its ability to create custom XML
namespaces for your XMP metadata: to create an XML schema that maps
exactly to your data requirements, not to some predefined and inflexible
out-of-the-box structure. This IS possible with the CFC.

