<?xml version='1.0' encoding='UTF-8'?>
<!-- taxon to html conversion -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

<xsl:output method="xml" indent="yes" encoding="UTF-8" />

<xsl:param name="ProductInstallPath"/>

<!-- Default rule - copy whatever we find -->

	<xsl:template match="*|@*|text()|comment()|processing-instruction()">
	<xsl:copy>
	<xsl:apply-templates select="*|@*|text()|comment()|processing-instruction()"/>
	</xsl:copy>
	</xsl:template>

	<xsl:template match="taxon">
	<html>
	<head>
	<title>
		<xsl:for-each  select="sys"><xsl:sort data-type="number" select="@rank" order="descending"/><xsl:value-of select="."/> -	</xsl:for-each>
	</title>
	</head>
    <body>
    	<table border="0" cellspacing="10" cellpadding="10">
		<tr><td class="tdhead" colspan="2">Systematics</td></tr>
		<tr><td class="tdhead" colspan="2"><h1><xsl:value-of select="title"/></h1> </td></tr>		
		<xsl:for-each select="sys"><xsl:sort data-type="number" select="@rank" order="descending"/>
		<tr><td><xsl:element name="font"><xsl:attribute name="size"><xsl:value-of select="@rank"/></xsl:attribute><xsl:value-of select="@name"/></xsl:element>
		</td>
		<td><xsl:element name="font"><xsl:attribute name="size"><xsl:value-of select="@rank"/></xsl:attribute><xsl:value-of select="."/></xsl:element>
		</td></tr>
		</xsl:for-each>
		<xsl:for-each select="descriptions/description"><xsl:sort data-type="number" select="." order="ascending"/>
		<tr><td colspan="2">Description (<xsl:value-of select="@xml:lang"/>)</td></tr>
		<tr><td colspan="2">
		<textarea cols="80" rows="10">
		<xsl:value-of select="."/>
		</textarea>
		</td></tr>
		</xsl:for-each>		
		</table>
		Date: <xsl:value-of select="date"/>
		<xsl:apply-templates select="synonyms"/>
		<xsl:apply-templates select="authors"/>		
		<xsl:apply-templates select="publications"/>
		<xsl:apply-templates select="plants"/>
		<xsl:apply-templates select="symbiosises"/>
		<xsl:apply-templates select="distributions"/>
		<xsl:apply-templates select="collections"/>
		<xsl:apply-templates select="x-metadata"/>
    </body>
    </html>
	</xsl:template>

	<xsl:template match="synonyms">
    	<table border="0" cellspacing="10" cellpadding="10">
		<tr><td class="tdhead" colspan="4">Synonyms</td></tr>
		<tr><td>#</td><td>Name</td><td>Language</td><td>Option</td></tr>		
		<xsl:for-each select="name"><xsl:sort data-type="text" select="name" order="ascending"/>
		<tr><td><xsl:number/></td><td><xsl:value-of select="."/></td><td><xsl:value-of select="@xml:lang"/></td><td><xsl:value-of select="@option"/></td></tr>
		</xsl:for-each>
		</table>
	</xsl:template>

	<xsl:template match="plants">
    	<table border="0" cellspacing="10" cellpadding="10">
		<tr><td class="tdhead" colspan="4">Plants</td></tr>
		<tr><td>#</td><td>Name</td><td>Descripyion</td><td>Option</td></tr>
		<xsl:for-each select="name"><xsl:sort data-type="text" select="name" order="ascending"/>
		<tr><td><xsl:number/></td><td><xsl:value-of select="."/></td><td><xsl:value-of select="@xml:lang"/></td><td><xsl:value-of select="@option"/></td></tr>
		</xsl:for-each>
		</table>
	</xsl:template>

	<xsl:template match="publications">
    	<table border="0" cellspacing="10" cellpadding="10">
		<tr><td class="tdhead" colspan="4">Publications</td></tr>
		<tr><td>#</td><td>Author</td><td>Title</td><td>Year</td></tr>
		<xsl:for-each select="publication"><xsl:sort data-type="text" select="publiaction" order="ascending"/>
		<tr><td><xsl:number/></td>
		<td><xsl:for-each select="authors"><xsl:call-template name="pauthors"/></xsl:for-each></td>
		<td><xsl:value-of select="description"/></td>
		<td><xsl:value-of select="dc-metadata"/></td></tr>
		</xsl:for-each>
		</table>
	</xsl:template>


	<xsl:template match="distributions">
    	<table border="0" cellspacing="10" cellpadding="10">
		<tr><td class="tdhead" colspan="5">Distributions</td></tr>
		<tr><td>#</td><td>Area</td><td>Location</td><td>Language</td><td>Description</td></tr>		
		<xsl:for-each select="distribution"><xsl:sort data-type="text" select="area/@name" order="ascending"/>
<tr><td><xsl:number/></td>
<td><xsl:value-of select="area/@name"/></td>
<td><xsl:value-of select="area/location"/></td>
<td><xsl:value-of select="area/location/@xml:lang"/> <xsl:value-of select="area/description/@xml:lang"/></td>
<td><xsl:value-of select="area/description"/></td></tr>
		</xsl:for-each>
		</table>
	</xsl:template>


	<xsl:template name="pauthors" match="authors">
    	<table border="0" cellspacing="10" cellpadding="10">
		<tr><td class="tdhead" colspan="2">Authors</td></tr>
		<xsl:for-each select="person"><xsl:sort data-type="text" select="name" order="ascending"/>
		<xsl:call-template name="pperson"/>		
		</xsl:for-each>
		</table>
	</xsl:template>

	<xsl:template name="pperson">
		<tr><td class="tdhead" colspan="2"><h3><xsl:value-of select="name"/></h3>
		<xsl:if test="not (string-length(@date) = 0)"><xsl:value-of select="@date"/></xsl:if>
		<xsl:if test="not (string-length(degree) = 0)"><xsl:value-of select="birthday"/></xsl:if>
		<xsl:if test="not (string-length(description) = 0)"><xsl:value-of select="description"/></xsl:if>
		</td></tr>
		<xsl:if test="not (string-length(degree) = 0)">
		<tr><td>Degree:</td><td><xsl:value-of select="degree"/></td></tr>
		</xsl:if>
		<xsl:if test="not (string-length(position) = 0)">
		<tr><td>Position:</td><td><xsl:value-of select="position"/></td></tr>
		</xsl:if>
		<xsl:if test="not (string-length(department) = 0)">
		<tr><td>Department:</td><td><xsl:value-of select="department"/></td></tr>
		</xsl:if>
		<xsl:if test="not (string-length(institute) = 0)">
		<tr><td>Institute:</td><td><xsl:value-of select="institute"/></td></tr>
		</xsl:if>
		<xsl:if test="not (string-length(phone) = 0)">
		<tr><td>phone:</td><td><xsl:value-of select="phone"/></td></tr>
		</xsl:if>
		<xsl:if test="not (string-length(mail) = 0)">
		<tr><td>mail:</td><td><xsl:value-of select="mail"/></td></tr>
		</xsl:if>
		<xsl:if test="not (string-length(email) = 0)">
		<tr><td>email:</td><td><xsl:element name="a"><xsl:attribute name="href">mailto:<xsl:value-of select="email"/></xsl:attribute><xsl:value-of select="email"/></xsl:element></td></tr>
		</xsl:if>
		<xsl:if test="not (string-length(memo) = 0)">
		<tr><td>memo:</td><td><xsl:value-of select="x-metadata"/></td></tr>
		</xsl:if>
	</xsl:template>

<xsl:template match="text()[preceding-sibling::card or preceding-sibling::template]">
</xsl:template>

<xsl:template match="comment()[preceding-sibling::card or preceding-sibling::template]">
</xsl:template>

<xsl:template match="processing-instruction()[preceding-sibling::card or preceding-sibling::template]">
</xsl:template>


</xsl:stylesheet>