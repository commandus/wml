<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0" xmlns:dc="http://purl.org/metadata/dublin_core" xmlns:oebpackage="http://openebook.org/namespaces/oeb-package/1.0/">
	<!-- OPF to html conversion -->
	<xsl:output method="xml" indent="no" encoding="UTF-8" />
	<xsl:key name="distinct" match="item" use="@id"/>
	<xsl:template  name="bstyle"  match="/package/guide/reference[@type='other.ms-titleimage-standard']">
		<style>body{background-image: url('
			<xsl:value-of select="@href"/>
		'); background-repeat: no-repeat}
		</style>
	</xsl:template>
	<xsl:template match="/package/guide/reference[@type='other.ms-coverimage-standard']">
		<img border="0">
			<xsl:attribute name="src">
				<xsl:value-of select="@href"/>
			</xsl:attribute>
		</img>
	</xsl:template>
	<xsl:template match="/">
		<html>
			<head>
				<link href="default.css" type="text/css" rel="stylesheet"/>
				<title>
					<xsl:value-of select="//dc-metadata/dc:Title"/> by
					<xsl:value-of select="//dc-metadata/dc:Creator"/>
				</title>
				<xsl:for-each select="//dc-metadata/*">
					<meta>
						<xsl:attribute name="name">
							<xsl:value-of select="substring-after(name(), ':')"/>
						</xsl:attribute>
						<xsl:attribute name="content">
							<xsl:value-of select="."/>
						</xsl:attribute>
					</meta>
				</xsl:for-each>
				<xsl:apply-templates select="/package/guide/reference[@type='other.ms-titleimage-standard']"/>
			</head>
			<body>
				<!-- cover -->
				<table>
					<tr>
						<td colspan="2"></td>
					</tr>
					<tr>
						<td> </td>
						<td>
							<h1>
								<xsl:value-of select="/package/metadata/dc-metadata/dc:Title"/>
							</h1>
							<center>by</center>
							<h1>
								<xsl:value-of select="//dc:Creator"/>
							</h1>
							<br/>publ.
							<xsl:value-of select="//dc:Publisher"/>
							<br/>
							<xsl:value-of select="//dc:Identifier/@id"/>
							<xsl:value-of select="//dc:Identifier"/>
							<br/>Source: 
							<a>
								<xsl:attribute name="href">
									<xsl:value-of select="//dc:Source"/>
								</xsl:attribute>
								<xsl:value-of select="//dc:Source"/>
							</a>
						</td>
					</tr>
					<tr>
						<td>					</td>
						<td>
							<xsl:apply-templates select="/package/guide/reference[@type='other.ms-coverimage-standard']"/>
						</td>
					</tr>
				</table>
				<!-- guide -->
				<ul>
					<br/>
					<xsl:for-each select="//guide/*">
						<xsl:if test="not (string-length(substring-before(@type, 'image')) = 0)">
							<xsl:if test="(string-length(substring-before(@type, '-standard')) = 0)">
								<br/>
								<img>
									<xsl:attribute name="alt">
										<xsl:value-of select="./@title"/>
									</xsl:attribute>
									<xsl:attribute name="src">
										<xsl:value-of select="./@href"/>
									</xsl:attribute>
								</img>
							</xsl:if>
						</xsl:if>
						<xsl:if test="(string-length(substring-before(@type, 'image')) = 0)">
							<li/>
							<a>
								<xsl:attribute name="href">
									<xsl:value-of select="./@href"/>
								</xsl:attribute>
								Read 
								<xsl:value-of select="./@title"/>
							</a>
						</xsl:if>
					</xsl:for-each>
				</ul>
				<!-- spine -->
				<hr/>
				<h1>Contents</h1>
				<xsl:for-each select="//spine/itemref">
					<xsl:variable name="vidref">
						<xsl:value-of select="./@idref"/>
					</xsl:variable>
					<br/>
					<xsl:for-each select="//manifest/item">
						<xsl:if test="@id = $vidref">
							<a>
							<xsl:attribute name="href">
								<xsl:value-of select="@href"/>
							</xsl:attribute>
							</a>
						</xsl:if>
					</xsl:for-each>
					<xsl:value-of select="$vidref"/>
				</xsl:for-each>
				<!-- manifest -->
				<hr/>
				<h2>List of all files:</h2>
				<ul>
					<xsl:for-each select="//manifest/*">
						<li/>
						<a>
							<xsl:attribute name="href">
								<xsl:value-of select="./@href"/>
							</xsl:attribute>
							<xsl:value-of select="./@id"/>
						</a>
						<sup>
							<xsl:value-of select="./@media-type"/>
						</sup>
						<xsl:if test="not (string-length(substring-after(./@media-type, 'image')) = 0)">
							<!-- Image -->
							<a>
								<xsl:attribute name="href">
									<xsl:value-of select="./@href"/>
								</xsl:attribute>
								<xsl:attribute name="alt">
								View 
									<xsl:value-of select="./@id"/>
								</xsl:attribute>
								<img border="0" width="64" height="12">
									<xsl:attribute name="src">
										<xsl:value-of select="./@href"/>
									</xsl:attribute>
									<xsl:attribute name="alt">
										<xsl:value-of select="./@media-type"/>
									</xsl:attribute>
								</img>
							</a>
						</xsl:if>
						<xsl:if test="not (string-length(substring-after(./@media-type, 'text')) = 0)">
							<!-- Read text link -->
							<a>
								<xsl:attribute name="href">
									<xsl:value-of select="./@href"/>
								</xsl:attribute>
								Read 
								<xsl:value-of select="./@id"/>
							</a>
						</xsl:if>
					</xsl:for-each>
				</ul>
			</body>
		</html>
	</xsl:template>
</xsl:stylesheet>