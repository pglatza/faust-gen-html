<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xi="http://www.w3.org/2001/XInclude"
    xmlns:svg="http://www.w3.org/2000/svg"
    xmlns:math="http://www.w3.org/1998/Math/MathML"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
	xmlns="http://www.tei-c.org/ns/1.0"	
	xpath-default-namespace="http://www.tei-c.org/ns/1.0"
	xmlns:f="http://www.faustedition.net/ns"
	exclude-result-prefixes="xs xi svg math xd f"
	version="2.0">
	
	<xsl:import href="bibliography.xsl"/>	
	
	<xsl:variable name="basename" select="replace(document-uri(/), '^.*/([^/]+)\.xml', '$1')"/>
	<xsl:variable name="biburl" select="concat('faust://bibliography/', $basename)"/>
	
	<xsl:param name="builddir-resolved" select="resolve-uri('../../../../target/')"/>
	<xsl:param name="output" select="resolve-uri('testimony-split/', $builddir-resolved)"/>
	
	<!-- XML version of the testimony table, generated by get-testimonies.py from the excel table -->
	<xsl:param name="table" select="doc('testimony-table.xml')"/>

	<!-- Remove leading zeros from IDs -->
	<xsl:function name="f:real_id" as="xs:string">
		<xsl:param name="id"/>
		<xsl:value-of select="replace($id, '^(\w+)_0*(.*)$', '$1_$2')"/>
	</xsl:function>
	
	<xsl:function name="f:unfree-text" as="xs:boolean">
		<xsl:param name="el"/>
		<xsl:value-of select="matches(document-uri(root($el)), '/quz_.*(\.xml)?')"/>
	</xsl:function>
		
	<xsl:template match="/">
		<xsl:variable name="root-divs" select="//div[descendant::milestone[@unit='testimony'] and not(ancestor::div)]"/>		
		<xsl:message select="concat(if (count($root-divs) = 0) then 'WARNING: ' else '', count($root-divs), ' testimony divs in ', $basename)"/>
		
		<xsl:for-each select="$root-divs">
			<xsl:call-template name="process-testimony-div"/>
		</xsl:for-each>
	</xsl:template>
	
	<xsl:template name="process-testimony-div">
		<xsl:param name="div" select="."/>
		<!-- First find the testimony id(s). -->
		<xsl:variable name="milestones" select="descendant::milestone[@unit='testimony'][count(tokenize(@xml:id, '_')) = 2]"/>
		<xsl:if test="count($milestones) > 1">
			<xsl:message select="concat('WARNING: div[', position(), '] in ', $basename, ' contains ', count($milestones), ' testimonies: ', string-join($milestones/@xml:id, ', '))"/>
			<!--<xsl:message><xsl:copy-of select="$milestones"/></xsl:message>-->
		</xsl:if>
		<xsl:for-each select="$milestones">
			<xsl:variable name="id" select="f:real_id(@xml:id)"/>
			<xsl:variable name="xml-id" select="@xml:id"/>
			<xsl:variable name="milestone" select="."/>
			<xsl:result-document href="{resolve-uri(concat($id, '.xml'), $output)}" exclude-result-prefixes="xs xi svg math xd f">
				<xsl:for-each select="$div">					
					<xsl:variable name="metadata" select="$table//f:testimony[@id=$id]"/>
					<TEI>
						<xsl:for-each select="/TEI/teiHeader">
							<teiHeader>	
								<xsl:copy-of select="@*"/>
								<xsl:comment>Preliminary TEI header</xsl:comment>
								<xsl:copy-of select="* except revisionDesc"/>
								<xenoData>
									<xsl:for-each select="$metadata">
										<xsl:copy>
											<xsl:copy-of select="@*"/>
											<xsl:copy-of select="*"/>
											<f:biburl><xsl:value-of select="$biburl"/></f:biburl>										
										</xsl:copy>
									</xsl:for-each>								
								</xenoData>
								<xsl:copy-of select="revisionDesc"/>								
							</teiHeader>
						</xsl:for-each>
						<text>
							<group>
								<text>
									<body>
										<xsl:choose>
											<xsl:when test="f:unfree-text(.)">
												<desc type="editorial" subtype="info">
													Für die Veröffentlichung dieses Volltexts liegt noch keine Freigabe vor.
													<xsl:copy-of select="$milestone"/>
												</desc>
												
											</xsl:when>
											<xsl:otherwise>
												<xsl:copy-of select="$div"/>												
											</xsl:otherwise>
										</xsl:choose>
									</body>
								</text>
								<text n="{$id}" copyOf="#{$xml-id}" type="testimony">
									<body>
										<xsl:call-template name="milestone-content">
											<xsl:with-param name="milestone" select="id($xml-id)"/>
										</xsl:call-template>										
									</body>
								</text>
							</group>
						</text>
					</TEI>
				</xsl:for-each>
			</xsl:result-document>
		</xsl:for-each>		
	</xsl:template>
	
	<xsl:template name="milestone-content">
		<xsl:param name="milestone" select="self::milestone"/>
		<xsl:param name="allow-leading-gap" select="true()"/>
		<xsl:for-each select="$milestone">
			<xsl:variable name="target" select="id(substring(@spanTo, 2))"/>
			<xsl:variable name="content">
				<xsl:if test="$allow-leading-gap and (preceding-sibling::* or normalize-space(string-join(preceding-sibling::text(), '')) != '')">
					<gap reason="irrelevant"/>
				</xsl:if>
				<xsl:variable name="actual-content" select="following::node() except (., $target, $target/following::node(), following::*/node())"/>
				<xsl:choose>
					<xsl:when test="$target is $milestone">
						<xsl:message>ERROR: <xsl:value-of select="$milestone/@xml:id"/> spans to itself in <xsl:value-of select="$basename"/>!</xsl:message>
						<xsl:text>⚠↺ </xsl:text>					
					</xsl:when>
					<xsl:when test="not($actual-content)">
						<xsl:message>ERROR: <xsl:value-of select="$milestone/@xml:id"/> does not have any content in <xsl:value-of select="$basename"/>!</xsl:message>
						<xsl:text>⚠∅ </xsl:text>					
					</xsl:when>					
				</xsl:choose>
				<xsl:sequence select="$actual-content"/>
				<xsl:if test="@next or following-sibling::* or normalize-space(following-sibling::text()) != ''">
					<gap reason="irrelevant"/>
				</xsl:if>
			</xsl:variable>
			<xsl:choose>
				<xsl:when test="parent::div or parent::text">
					<xsl:sequence select="$content"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:for-each select="parent::*">
						<xsl:copy>
							<xsl:sequence select="$content"/>
						</xsl:copy>
					</xsl:for-each>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:call-template name="milestone-content">
				<xsl:with-param name="milestone" select="id(substring(@next, 2))"/>
				<xsl:with-param name="allow-leading-gap" select="false()"/>
			</xsl:call-template>						
		</xsl:for-each>
	</xsl:template>
	
</xsl:stylesheet>