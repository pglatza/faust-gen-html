<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	exclude-result-prefixes="xs"
	xmlns:tei="http://www.tei-c.org/ns/1.0"
	xmlns:f="http://www.faustedition.net/ns"
	xmlns:ge="http://www.tei-c.org/ns/geneticEditions"
	xpath-default-namespace="http://www.tei-c.org/ns/1.0"
	version="2.0">
	
	<!-- Additional cleanup steps for preparing the reading text. -->

	<xsl:strip-space elements="TEI teiHeader fileDesc titleStmt publicationStmt sourceDesc ge:transpose choice"/>

	
	<!-- These elements are replaced with their respective content: -->
	<xsl:template match="
		  group 
		| l/hi[@rend='big'] 
		| seg[@f:questionedBy or @f:markedBy] 
		| c
		| damage
		| s
		| seg[@xml:id]
		| orig
		| profileDesc
		| creation
		| ge:transposeGrp
		| surplus
		| unclear
		| supplied">
		<xsl:apply-templates/>
	</xsl:template>
	
	<!-- These nodes are dropped, together with their content: -->
	<xsl:template match="
		  sourceDesc/* 
		| encodingDesc 
		| revisionDesc 
		| titlePage[not(./titlePart[@n])] 
		| pb[not(@break='no')] 
		| fw 
		| hi/@status 
		| anchor 
		| join[@type='antilabe'] 
		| join[@result='sp'] 
		| join[@type='former_unit'] 
		| */@xml:space
		| div[@type='stueck' and not(.//l[@n])] 
		| lg/@type 
		| figure 
		| text[not(.//l[@n])] 
		| speaker/@rend 
		| stage[not(matches(@rend,'inline'))]/@rend
		| l/@rend 
		| l/@xml:id 
		| space[@type='typographical'] 
		| hi[not(matches(@rend,'antiqua')) and not(matches(@rend,'latin'))]/@rend
		| sp/@who 
		| note[@type='editorial'] 
		| ge:transpose[not(@ge:stage='#posthumous')] 
		| ge:stageNotes 
		| handNotes 
		| unclear/@cert 
		| lg/@xml:id 
		| addSpan[not(@ge:stage='#posthumous')]
		| milestone[@unit='group' or @unit='stage']
		| ge:rewrite
		| ge:transpose/add/text()
		| div[@type='stueck']"/>

	<!-- Drop comments as well; this needs to override node() from above -->
	<xsl:template match="comment()" priority="1"/>
	
	<!-- lb -> space -->
	<xsl:template match="lb">
		<xsl:if test="not(@break='no')">
			<xsl:text> </xsl:text>
		</xsl:if>
	</xsl:template>

	<xsl:template match="choice[sic]">
		<xsl:apply-templates select="sic/text()"/>
	</xsl:template>
	
	<xsl:template match="text/@type">
		<xsl:attribute name="type">lesetext</xsl:attribute>
	</xsl:template>
	
	<!-- The following post-processing steps need to be applied afterwards: -->
	<xsl:template match="/">
		<xsl:variable name="stage1">
			<xsl:apply-templates/>
		</xsl:variable>
		<xsl:apply-templates mode="stage2" select="$stage1"/>
	</xsl:template>
	
	<!-- Drop now-empty container elements -->
	<xsl:template mode="stage2"	match="
		  text[not(normalize-space(.))] 
		| front[not(normalize-space(.))]"/>
	
	<!-- Drop outer text containers -->
	<xsl:template mode="stage2" match="text[text]">
		<xsl:apply-templates mode="#current"/>
	</xsl:template>
	
	<!-- The following fixes are eventually to be implemented in all source files: -->
	<xsl:template match="stage/emph">
		<xsl:element name="hi">
			<xsl:apply-templates select="@*, node()"/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="name">
		<xsl:element name="hi">
			<xsl:apply-templates select="@*, node()"/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="sp[stage[not(following-sibling::*)]]">
		<xsl:next-match/>
		<xsl:for-each select="stage[not(following-sibling::*)]">
			<xsl:copy>
				<xsl:apply-templates select="@*, node()"/>
			</xsl:copy>
		</xsl:for-each>
	</xsl:template>
	<xsl:template match="sp/stage[not(following-sibling::*)]"/>

	<!--<!-\- sample data for MC; to be moved at the end of procedures when reading text is finished -\->
						<xsl:template match="div/@n"/>
						<xsl:template match="orig | unclear">
							<xsl:apply-templates/>
						</xsl:template>
						<xsl:template match="l[@n='4625']">
							<l n="4625">
								<xsl:text>Sein Innres reinigt von verlebtem</xsl:text>
								<note type="textcrit">
									<it>
										<xsl:text>4625</xsl:text>
									</it>
									<xsl:text> Lemma] Variante </xsl:text>
									<it><xsl:text>Sigle</xsl:text></it>
								</note>
								<xsl:text>Graus.</xsl:text>
							</l>
						</xsl:template>-->

	<xsl:template match="text()" priority="0.5">
		<xsl:value-of select="replace(replace(replace(., 'Ae', 'Ä'), 'Oe', 'Ö'), 'Ue', 'Ü')"/>
	</xsl:template>

	<xsl:template match="processing-instruction('oxygen')|processing-instruction('xml-model')">
		<xsl:processing-instruction name="xml-model">href="http://dev.digital-humanities.de/ci/job/faust-schema/lastSuccessfulBuild/artifact/target/schema/faust-tei.rng" type="application/xml" schematypens="http://relaxng.org/ns/structure/1.0"</xsl:processing-instruction>
		<xsl:processing-instruction name="xml-model">href="http://dev.digital-humanities.de/ci/job/faust-schema/lastSuccessfulBuild/artifact/target/schema/faust-tei.sch" type="application/xml" schematypens="http://purl.oclc.org/dsdl/schematron"</xsl:processing-instruction>		
	</xsl:template>

	<!-- Keep everything else as is -->
	<xsl:template match="node()|@*" mode="#all">
		<xsl:copy>
			<xsl:apply-templates select="@*, node()" mode="#current"/>
		</xsl:copy>
	</xsl:template>
	
	
</xsl:stylesheet>