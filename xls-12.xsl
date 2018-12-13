<xsl:stylesheet
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
 xmlns:o="urn:schemas-microsoft-com:office:office"
 xmlns:x="urn:schemas-microsoft-com:office:excel"
 xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet"
 xmlns:html="http://www.w3.org/TR/REC-html40">
    <!-- Remove xmlns="urn:schemas-microsoft-com:office:spreadsheet"
      from saved input Excel xml file
    -->
	<!-- Excel xml file translate to taxon -->
	<xsl:output method="xml" indent="yes" encoding="utf-8" />
	<xsl:template match="/">
		<taxons>
			<xsl:apply-templates select="Workbook"/>
		</taxons>
	</xsl:template>
	<xsl:template match="Workbook" name="wb">
		<xsl:apply-templates select="Worksheet"/>
	</xsl:template>
	<xsl:template match="Worksheet">
		<xsl:comment>
			<xsl:value-of select="@ss:Name" />
		</xsl:comment>
		<xsl:value-of select="@ss:name" />
		<xsl:apply-templates select="Table"/>
	</xsl:template>
	<xsl:template match="Table">
		<xsl:apply-templates select="Row"/>
	</xsl:template>
	<xsl:template match="Row">
		<xsl:if test="((count(Cell) > 0)) ">
			<taxon>
				<xsl:for-each select="Cell">
					<xsl:variable name="n">
						<xsl:number/>
					</xsl:variable>
					<xsl:if test="(string-length(.) > 1)">
					<xsl:if test="$n = 1">
						<xsl:element name="sys">
							<xsl:attribute name="name">Семейство</xsl:attribute>
							<xsl:attribute name="rank"><xsl:value-of select="$n"/></xsl:attribute>
							<xsl:value-of select="."/>
						</xsl:element>
					</xsl:if>
					<xsl:if test="$n = 2">
						<xsl:element name="sys">
							<xsl:attribute name="name">Подсемейство</xsl:attribute>
							<xsl:attribute name="rank"><xsl:value-of select="$n"/></xsl:attribute>
							<xsl:value-of select="."/>
						</xsl:element>
					</xsl:if>
					<xsl:if test="$n = 3">
						<xsl:element name="sys">
							<xsl:attribute name="name">Триба</xsl:attribute>
							<xsl:attribute name="rank"><xsl:value-of select="$n"/></xsl:attribute>
							<xsl:value-of select="."/>
						</xsl:element>
					</xsl:if>
					<xsl:if test="$n = 4">
						<xsl:element name="sys">
							<xsl:attribute name="name">Род</xsl:attribute>
							<xsl:attribute name="rank"><xsl:value-of select="$n"/></xsl:attribute>
							<xsl:value-of select="."/>
						</xsl:element>
					</xsl:if>
					<xsl:if test="$n = 7">
						<xsl:element name="sys">
							<xsl:attribute name="name">Подрод</xsl:attribute>
							<xsl:attribute name="rank"><xsl:value-of select="$n"/></xsl:attribute>
							<xsl:value-of select="."/>
						</xsl:element>
					</xsl:if>
					<xsl:if test="$n = 10">
						<xsl:element name="sys">
							<xsl:attribute name="name">Вид</xsl:attribute>
							<xsl:attribute name="rank"><xsl:value-of select="$n"/></xsl:attribute>
							<xsl:value-of select="."/>
						</xsl:element>
					</xsl:if>
					<xsl:if test="$n = 5">
						<xsl:element name="authors">
							<xsl:element name="person">
								<xsl:attribute name="date">0</xsl:attribute>
								<xsl:attribute name="rel">dsc-genus</xsl:attribute>
								<xsl:element name="name">
									<xsl:value-of select="."/>
								</xsl:element>
								<xsl:element name="description">
									Описатель рода
								</xsl:element>
							</xsl:element>
						</xsl:element>
					</xsl:if>
					<xsl:if test="$n = 8">
						<xsl:element name="authors">
							<xsl:element name="person">
								<xsl:attribute name="date">0</xsl:attribute>
								<xsl:attribute name="rel">dsc-subgenus</xsl:attribute>
								<xsl:element name="name">
									<xsl:value-of select="."/>
								</xsl:element>
								<xsl:element name="description">
									Описатель подрода
								</xsl:element>
							</xsl:element>
						</xsl:element>
					</xsl:if>
					<xsl:if test="$n = 11">
						<xsl:element name="authors">
							<xsl:element name="person">
								<xsl:attribute name="date">-1</xsl:attribute>
								<xsl:attribute name="rel">dsc-species</xsl:attribute>
								<xsl:element name="name">
									<xsl:value-of select="."/>
								</xsl:element>
								<xsl:element name="description">
									Описатель вида
								</xsl:element>
							</xsl:element>
						</xsl:element>
					</xsl:if>
					<xsl:if test="$n = 6">
						<xsl:comment>Род: <xsl:value-of select="."/></xsl:comment>
					</xsl:if>
					<xsl:if test="$n = 9">
						<xsl:comment>Подрод: <xsl:value-of select="."/></xsl:comment>
					</xsl:if>
					<xsl:if test="$n = 12">
						<xsl:element name="date">
							<xsl:attribute name="value"><xsl:value-of select="."/>-01-01T00:00:00Z</xsl:attribute>
							<xsl:attribute name="ratio"><xsl:value-of select="1"/></xsl:attribute>
						</xsl:element>
					</xsl:if>
					<xsl:if test="$n = 13">
						<xsl:if test="not (string-length(.) = 0)">
							<xsl:element name="synonyms">
								<xsl:element name="name">
									<xsl:attribute name="option">Sakha</xsl:attribute>
									<xsl:attribute name="xml:lang">ru</xsl:attribute>							
									<xsl:value-of select="."/>
								</xsl:element>
							</xsl:element>
						</xsl:if>
					</xsl:if>
					<xsl:if test="($n = 9)"><xsl:element name="distributions"></xsl:element></xsl:if>
					<xsl:if test="($n = 14) or ($n = 15) or ($n = 16) or ($n = 17) or ($n = 18) or ($n = 14)or ($n = 19)">
						<xsl:if test="(string-length(.) > 1)">
							<xsl:element name="distribution">
								<xsl:element name="area">
									<xsl:if test="($n = 14)">
										<xsl:element name="description">
											<xsl:value-of select="."/>
										</xsl:element>
									</xsl:if>
									<xsl:if test="($n = 15)">
										<xsl:attribute name="name">Sakha</xsl:attribute>
									</xsl:if>
									<xsl:if test="($n = 16)">
										<xsl:attribute name="name">Russia</xsl:attribute>
									</xsl:if>
									<xsl:if test="($n = 17)">
										<xsl:attribute name="name">Earth</xsl:attribute>
									</xsl:if>
									<xsl:element name="location">
										<xsl:attribute name="xml:lang">ru</xsl:attribute>
										<xsl:value-of select="."/>
									</xsl:element>
								</xsl:element>
							</xsl:element>
						</xsl:if>
					</xsl:if>
				</xsl:if>
				</xsl:for-each>
			</taxon>
		</xsl:if>
	</xsl:template>
</xsl:stylesheet>