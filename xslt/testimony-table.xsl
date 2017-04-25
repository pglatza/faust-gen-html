<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:f="http://www.faustedition.net/ns"
	xmlns="http://www.w3.org/1999/xhtml"
	xpath-default-namespace="http://www.faustedition.net/ns"
	exclude-result-prefixes="xs"
	version="2.0">
		
	<xsl:import href="utils.xsl"/>
	<xsl:include href="html-frame.xsl"/>
	
	<xsl:strip-space elements="*"/>	
	
	<xsl:param name="builddir-resolved" select="resolve-uri('../../../../target/')"/>
	
	<!-- XML version of the testimony table, generated by get-testimonies.py from the excel table -->
	<xsl:param name="table" select="doc('testimony-table.xml')"/>	
	
	<!-- input is the Mapping id -> file, generated by workflow from testimony xmls -->
	<xsl:param name="usage" select="/"/>
	
	<xsl:param name="transcript-list" select="resolve-uri('faust-transcripts.xml', resolve-uri($builddir-resolved))"/>
	
	<!-- Machine-readable bibliography, generated by python script from wiki page : -->
	<xsl:variable name="bibliography" select="doc('bibliography.xml')"/>

	<!-- 
		
		The following variable defines the available columns. To define a new column, you
		should copy the corresponding <fieldspec> element from testimony-table.xml to the
		right place in the variable below and adjust it accordingly.
		
		Attributes:
		
			- label: label as used in the <field> attributes
			- spreadsheet: original label from spreadsheet, for reference only
			- sortable-type: sort order for sortable
			
		Content:
		
			The element content is copied 1:1 to the corresponding <th> element
	
	-->
	<xsl:variable name="columns" xmlns="http://www.faustedition.net/ns">
		<fieldspec name="graef-nr" spreadsheet="Gräf-Nr." sortable-type="numericplus">Gräf</fieldspec>
		<fieldspec name="pniower-nr" spreadsheet="Pniower-Nr." sortable-type="numericplus">Pniower</fieldspec>
		<fieldspec name="quz" spreadsheet="QuZ">QuZ</fieldspec>
		<fieldspec name="biedermann-herwignr" spreadsheet=" Biedermann-HerwigNr.">Biedermann³</fieldspec>
		<fieldspec name="datum-von" spreadsheet="Datum.(von)" sortable-type="date-de">Datum</fieldspec>
		<fieldspec name="dokumenttyp" spreadsheet="Dokumenttyp">Quellengattung</fieldspec>		
		<fieldspec name="verfasser" spreadsheet="Verfasser">Verfasser</fieldspec>
		<fieldspec name="adressat" spreadsheet="Adressat">Adressat</fieldspec>
		<fieldspec name="druckort" spreadsheet="Druckort" sortable-type="bibliography">Druckort</fieldspec>
		<fieldspec name="excerpt" generated="true">Auszug</fieldspec>
	</xsl:variable>
	
	<!-- Used for the message column. Can be removed once there are no more warnings etc. -->
	<xsl:param name="extrastyle">
		<style type="text/css">
			.message { border: 1px solid transparent; border-radius: 1px; padding: 1px; margin: 1px;}
			.message.error { color: rgb(190,0,0); border-color: rgb(190,0,0); background-color: rgba(190,0,0,0.1); }
			.message.warning { color: black; background-color: rgba(220,160,0,0.2); border-color: rgb(220,160,0); }
			.message.info  { color: rgb(0,0,190); border-color: rgb(0,0,190); background-color: rgba(0,0,190,0.1); }
		</style>
	</xsl:param>
	
	<xsl:template match="/testimony-index">
		<xsl:for-each select="$table">
			<xsl:call-template name="start"/>
		</xsl:for-each>
	</xsl:template>
	
	<xsl:template name="start">
		<xsl:call-template name="html-frame">
			<xsl:with-param name="headerAdditions"><xsl:copy-of select="$extrastyle"/></xsl:with-param>
			<xsl:with-param name="content">
				
				<div id="testimony-table-container">
					<table data-sortable='true' class='pure-table'>
						<thead>
							<tr>
								<xsl:for-each select="$columns/fieldspec">
									<th data-sorted="false"
										data-sortable-type="{if (@sortable-type) then @sortable-type else 'alpha'}"
										id="th-{@name}"> 
										<xsl:copy-of select="node()"/>
									</th>
								</xsl:for-each>	
							</tr>
						</thead>
						<tbody>
							<xsl:apply-templates/>
						</tbody>
					</table>
				</div>
				
				<script type="text/javascript">
					// set breadcrumbs
					document.getElementById("breadcrumbs").appendChild(Faust.createBreadcrumbs([{caption: "Archiv", link: "archive"}, {caption: "Dokumente zur Entstehungsgeschichte"}]));
				</script>
								
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	
	<xsl:template match="citation|testimony">
		<xsl:variable name="entry" select="."/>
		<xsl:variable name="lbl" select="string-join(
			for $field in field return if ($field/text()) then concat(string-join($columns/fieldspec[@label=$field/@label], ''), ': ', $field) else (),
			', ')"/>
		<xsl:variable name="used" select="$usage//*[@testimony-id=current()/@id]"/>
		
		<!-- We're building an XML fragment that will finally serve as  info container for the current entry -->
		<xsl:variable name="rowinfo_raw">
			
			<!-- now a bunch of assertions -->
			<xsl:choose>
				<xsl:when test="not($used) and $entry//field[@name='h-sigle']">
					<f:excerpt/>	<!-- keine Warnung nötig -->
				</xsl:when>
				<xsl:when test="not($used) and (not(@id) or @id = '' or contains(@id, ' '))">
					<f:excerpt/>
					<f:message status="error">keine/komische ID: »<xsl:value-of select="@id"/>«</f:message>
				</xsl:when>
				<xsl:when test="not($used)">
					<f:excerpt/>
					<f:message status="info">kein XML für »<xsl:value-of select="@id"/>«</f:message>
				</xsl:when>
				<xsl:when test="count($used) > 1">
					<f:excerpt/>
					<f:message status="error"><xsl:value-of select="concat(count($used), ' XML-Quellen: ', string-join($used/@base, ', '))"/></f:message>
				</xsl:when>				
				<xsl:otherwise>
					<f:base><xsl:value-of select="$used/@base"/></f:base>
					<f:href><xsl:value-of select="concat('testimony/', $used/@base, '#', $used/@testimony-id)"/></f:href>
					<xsl:variable name="bibref" select="normalize-space($used/text())"/>
					<xsl:variable name="bib" select="$bibliography//bib[@uri=$bibref]"/> <!-- TODO refactor to bibliography.xsl -->
					<xsl:copy-of select="$bib"/>
					<xsl:variable name="excerpt" select="$used/@rs"/>
					
					<xsl:if test="not($excerpt)">
						<f:message status="info">kein Auszug</f:message>
					</xsl:if>
					<f:excerpt><xsl:value-of select="$excerpt"/></f:excerpt>
					<xsl:if test="not($bib)">
						<f:message status="warning">kein Literaturverzeichniseintrag für faust://bibliography/<xsl:value-of select="$used/@base"/></f:message>
					</xsl:if>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:variable name="rowinfo">
			<f:row id="{@testimony-id}" lbl="{$lbl}">
				<xsl:copy-of select="@*"/>
				<xsl:for-each select="$columns/fieldspec[@name != 'excerpt']">
					<xsl:variable name="fieldspec" select="." as="element()"/>
					<xsl:variable name="field" select="$entry//f:field[@name = $fieldspec/@name]" as="element()*"/>
					<xsl:choose>
						<xsl:when test="$field">
							<xsl:for-each select="$field">
								<xsl:copy>
									<xsl:copy-of select="@*"/>
									<xsl:attribute name="label" select="string-join($fieldspec, '')"/>
									<xsl:copy-of select="node()"/>
								</xsl:copy>
							</xsl:for-each>
						</xsl:when>
						<xsl:otherwise>
							<f:field name="{$fieldspec/@name}" label="{string-join($fieldspec, '')}"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:for-each>
				<xsl:copy-of select="$rowinfo_raw/*[local-name() != 'message']"/>				
				<f:messages>
					<xsl:copy-of select="$rowinfo_raw/message"/>
				</f:messages>
				<f:metadata>
					<xsl:copy-of select="$entry//f:field"/>					
				</f:metadata>
			</f:row>
		</xsl:variable>
		
		<xsl:apply-templates select="$rowinfo"/>
		
	</xsl:template>
	
	<xsl:template match="row">
		<tr id="{@id}">
			<xsl:apply-templates/>			
		</tr>
	</xsl:template>
	
	<xsl:template match="field">
		<td title="{if (text()) then concat(@label, ': ', .) else @label}">
			<xsl:apply-templates/>
		</td>
	</xsl:template>
	
	<xsl:template match="field[@name='druckort']">
		<xsl:choose>
			<xsl:when test="../bib">
				<td>	
					<cite class="bib-short bib-testimony" title="{../bib/reference}" data-bib-uri="faust://bibliography/{../base}">
						<a href="{../href}"><xsl:value-of select="."/></a>
					</cite>								
				</td>
			</xsl:when>
			<xsl:when test="../base">
				<td>
					<a href="{../href}"><xsl:value-of select="."/></a>
				</td>
			</xsl:when>
			<xsl:otherwise>
				<xsl:next-match/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="excerpt">
		<td>
			<xsl:if test="../metadata/field[@name='h-sigle']">				
				<xsl:variable name="sigils" select="normalize-space(../metadata/field[@name='h-sigle']/text())"/>
				<xsl:text>→ </xsl:text>
				<xsl:for-each select="tokenize($sigils, ';\s*')">
					<xsl:variable name="sigil" select="."/>
					<xsl:variable name="document" select="doc($transcript-list)//*[@f:sigil=$sigil]"/>
					<xsl:variable name="uri" select="$document/idno[@type='faust-doc-uri']/text()"/>
					<xsl:choose>
						<xsl:when test="not($document)">
							<a class="message error">H-Sigle nicht gefunden: <a title="zur Handschriftenliste" href="/archive_manuscripts">»<xsl:value-of select="$sigil"/>«</a></a>
						</xsl:when>
						<xsl:otherwise>
							<a href="{if ($document/@type='print')
									  then concat('/print/', replace(replace($document/@uri, '^.*/', ''), '\.xml$', ''))
								      else concat('/documentViewer?faustUri=', $uri)}"
							   title="{$document/headNote}">
								<xsl:value-of select="$sigil"/>
							</a>											
						</xsl:otherwise>
					</xsl:choose>
					<xsl:if test="not(position() = last())">; </xsl:if>
				</xsl:for-each>
			</xsl:if>
			<xsl:if test="normalize-space(.)">
				<a href="{../href}">… <xsl:apply-templates/> …</a>				
			</xsl:if>
			<xsl:for-each select="../messages/message">
				<div class="message {@status}"><xsl:value-of select="."/></div>
			</xsl:for-each>
		</td>
	</xsl:template>
	
	<xsl:template match="messages">
		<xsl:for-each select="message">
			<xsl:message select="concat(upper-case(@status), ':', ../../base, ':', ., ' (', ../../@lbl, ')')"/>			
		</xsl:for-each>
	</xsl:template>
	
	<xsl:template match="row/*" priority="-1"/>
	<!--		
		<xsl:comment>
			<xsl:value-of select="concat(name(), ' ', @name, ' ', .)"/>
		</xsl:comment>
	</xsl:template>
	
	<xsl:template match="metadata" priority="-0.9">
		<xsl:comment select="string-join(for $field in field return string-join(($field/@name, $field), ': '), '&#10;')"/>
	</xsl:template>
	-->		
	
</xsl:stylesheet>