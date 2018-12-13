<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<!-- WML to HTML conversion template -->
<xsl:output method="xml" indent="no" encoding="UTF-8" />

<xsl:param name="ProductInstallPath"/>

<!-- Default rule - copy whatever we find -->

  <xsl:template match="*|@*|text()|comment()|processing-instruction()">
    <xsl:copy>
      <xsl:apply-templates select="*|@*|text()|comment()|processing-instruction()"/>
    </xsl:copy>
  </xsl:template>

	<xsl:template match="wml">
		<html>
      <xsl:apply-templates select="@*" />
      <xsl:apply-templates/>
    </html>
	</xsl:template>

	<xsl:template match="card[not(preceding-sibling::card)]|template">
    <body>
      <xsl:copy>
        <xsl:apply-templates select="@*" /> 
        <xsl:apply-templates />
      </xsl:copy>
      <xsl:for-each select="following-sibling::* | following-sibling::text() | following-sibling::comment() | following-sibling::processing-instruction()">
        <xsl:copy>
          <xsl:apply-templates select="@*" />
          <xsl:apply-templates />
        </xsl:copy>
      </xsl:for-each>
    </body>
	</xsl:template>

  <xsl:template match="*[preceding-sibling::card or preceding-sibling::template]">
	</xsl:template>

  <xsl:template match="text()[preceding-sibling::card or preceding-sibling::template]">
	</xsl:template>

  <xsl:template match="comment()[preceding-sibling::card or preceding-sibling::template]">
	</xsl:template>

  <xsl:template match="processing-instruction()[preceding-sibling::card or preceding-sibling::template]">
	</xsl:template>


</xsl:stylesheet>