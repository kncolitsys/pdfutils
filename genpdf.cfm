
<cfdocument format="pdf" filename="paristoberead.pdf" overwrite="true">
<h2>Paris Hilton</h2>

<p>
<cfoutput>
This is the text of a PDF. It has a bit of randomness (#randRange(1,100)#) in it.
</cfoutput>
</p>

<cfdocumentitem type="pagebreak" />

<h2>Fetch Adams</h2>

<p>
<cfoutput>
This is the second page. It has a bit of randomness (#randRange(1,100)#) in it.
</cfoutput>
</p>

<cfdocumentitem type="pagebreak" />

<h2>GOOOBER Adams</h2>

<p>
<cfoutput>
This is the second page. It has a bit of randomness (#randRange(1,100)#) in it.
</cfoutput>
</p>

<cfloop index="x" from="1" to="20">

<cfdocumentitem type="pagebreak" />

<cfoutput>
<h2>PAGE #x#</h2>
</cfoutput>

<p>
<cfoutput>
This is the second page. It has a bit of randomness (#randRange(1,100)#) in it.
</cfoutput>
</p>


</cfloop>

</cfdocument>