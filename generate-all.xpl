<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step"
	xmlns:cx="http://xmlcalabash.com/ns/extensions" xmlns:pxp="http://exproc.org/proposed/steps"
	xmlns:pxf="http://exproc.org/proposed/steps/file"
	xmlns:f="http://www.faustedition.net/ns"
	xmlns:tei="http://www.tei-c.org/ns/1.0"
	xmlns:l="http://xproc.org/library" name="main" version="1.0">
	
	<p:input port="source"><p:empty/></p:input>
	<p:input port="parameters" kind="parameter"/>
	
	<p:output port="result" sequence="true">
		<p:empty/>
	</p:output>
	
	<p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>
	<p:import href="http://xproc.org/library/store.xpl"/>
	
	<p:import href="collect-metadata.xpl"/>
	<p:import href="generate-search.xpl"/>
	<p:import href="apply-edits.xpl"/>
	<p:import href="collate-variants.xpl"/>
	<p:import href="print2html.xpl"/>
	
	<p:import href="generate-app.xpl"/>
	<p:import href="generate-print.xpl"/>
	<p:import href="generate-metadata-js.xpl"/>
	<p:import href="metadata-html.xpl"/>
	<p:import href="bibliography.xpl"/>
	<p:import href="create-para-table.xpl"/>	
	<p:import href="testimony.xpl"/>
	
	<p:import href="generate-reading-text.xpl"/>

<!--	
	<p:import href="generate-indexes.xpl"/>
-->	
	
	
	
	<!-- Parameter laden -->
	<p:parameters name="config">
		<p:input port="parameters">
			<p:document href="config.xml"/>
			<p:pipe port="parameters" step="main"></p:pipe>
		</p:input>
	</p:parameters>
	
	<p:group>
		<p:variable name="source" select="//c:param[@name='source']/@value"><p:pipe port="result" step="config"/></p:variable>
		<p:variable name="html" select="//c:param[@name='html']/@value"><p:pipe port="result" step="config"/></p:variable>
		<p:variable name="builddir" select="resolve-uri(//c:param[@name='builddir']/@value)"><p:pipe port="result" step="config"/></p:variable>		
		
		<!--Step 1a Archivmetadaten -->
		<p:load><p:with-option name="href" select="resolve-uri('archives.xml', resolve-uri($source))"/></p:load>
		<cx:message log="info">
			<p:with-option name="message" select="'Converting archive metadata to js...'"/>
		</cx:message>
		<p:xslt>
			<p:input port="parameters"><p:pipe port="result" step="config"/></p:input>
			<p:input port="stylesheet"><p:document href="xslt/create-archives-metadata.xsl"/></p:input>
		</p:xslt>
		<p:store method="text">
			<p:with-option name="href" select="resolve-uri('www/data/archives.js', $builddir)"/>
		</p:store>
		
		
		
		<!-- ############ STEP 1: Create list of all transcripts -->			

		<!-- Collect all transcript's metadata in an XML document. This also copies the artificial reading texts. -->
		<f:list-transcripts name="transcripts">
			<p:input port="parameters"><p:pipe port="result" step="config"/></p:input>
		</f:list-transcripts>
		
		<!-- We need to save it now, its referenced later. -->
		<l:store name="save-transcripts">
			<p:with-option name="href" select="resolve-uri('faust-transcripts.xml', $builddir)"/>
		</l:store>
		
		<!-- ## Step 1.5: Lesetext -->
		<f:generate-reading-text/>				

		
		<!-- ############ STEP 2: Enhance all transcripts with metadata -->
		<f:generate-search name="generate-search">
			<p:input port="source"><p:pipe port="result" step="save-transcripts"/></p:input>
		</f:generate-search>
		<!-- TODO this by side-effect also collects the bargraph information  -->
				
		<cx:message message="Creating emended versions ..."/>
		
		<!-- ############ STEP 3: Create the emended version -->
		<p:for-each name="apply-edits">
			<p:iteration-source select="//f:textTranscript"/>
			<p:variable name="transcriptFile" select="/f:textTranscript/@href"/>
			<p:variable name="transcriptURI" select="/f:textTranscript/@uri"/>
			<p:variable name="documentURI" select="/f:textTranscript/@document"/>
			<p:variable name="type" select="/f:textTranscript/@type"/>
			<p:variable name="sigil" select="/f:textTranscript/f:idno[1]/text()"/>
			
			<p:load>
				<p:with-option name="href" select="resolve-uri(concat('prepared/textTranscript/', $documentURI), $builddir)"></p:with-option>
			</p:load>
			
		
			<p:choose>
				<p:when test="$type = 'lesetext'">
					<p:identity/>
				</p:when>
				<p:otherwise>
					<!--<cx:message><p:with-option name="message" select="concat('Emending ', $sigil, ' (', $documentURI, ') ...')"/></cx:message>-->
					<f:apply-edits/>					
				</p:otherwise>
			</p:choose>
			
			<p:store>
				<p:with-option name="href" select="resolve-uri(concat('emended/', $documentURI), $builddir)"/>
			</p:store>
		</p:for-each>
		<!-- Pipe through list of inputs -->
		<p:identity name="emended-version"><p:input port="source"><p:pipe port="result" step="generate-search"/></p:input></p:identity>
		
		<!-- ############## STEP 4: Creating the variant apparatus -->
		<f:collate-variants name="collate-variants"/>
		
		
		<!-- ############## STEP 5a: Creating the print versions -->
		<f:generate-print name="generate-print"/>
		
		
		<!-- ############################################################################## -->
		<!-- The following steps don't depend on the full workflow, but rather only on parts. -->
		
		<!-- ### Step 1a: scene line mapping -->
		<p:xslt>
			<p:input port="source"><p:document href="xslt/scenes.xml"></p:document></p:input>
			<p:input port="stylesheet"><p:document href="xslt/scene-line-mapping.xsl"></p:document></p:input>		
		</p:xslt>
		<p:store method="text" encoding="utf-8">
			<p:with-option name="href" select="resolve-uri('www/data/scene_line_mapping.js', resolve-uri($builddir))"/>
		</p:store>
		
		<!-- ### Step 3a: Apparatus -->
		<f:generate-app>
			<p:input port="source"><p:pipe port="result" step="generate-search"></p:pipe></p:input>
		</f:generate-app>
		
		<!-- ### Step 3b: pages.json -->
		<p:identity><p:input port="source"><p:pipe port="result" step="save-transcripts"></p:pipe></p:input></p:identity>
		<p:for-each>
			<p:iteration-source select="//f:textTranscript"/>
			<p:variable name="documentURI" select="/f:textTranscript/@document"/>			
			<p:load>
				<p:with-option name="href" select="resolve-uri(concat('prepared/textTranscript/', $documentURI), $builddir)"/>				
			</p:load>
		</p:for-each>
		<p:xslt template-name="collection">
			<p:input port="parameters"><p:pipe port="result" step="config"></p:pipe></p:input>
			<p:input port="stylesheet"><p:document href="xslt/pagelist.xsl"/></p:input>
		</p:xslt>
		<p:store method="text" media-type="application/json">
			<p:with-option name="href" select="resolve-uri('pages.json', resolve-uri($html))"/>			
		</p:store>
		
		<!-- ### Step 2a: Metadata HTML -->
		<f:metadata-html name="metadata-html">
			<p:input port="source"><p:pipe port="result" step="save-transcripts"></p:pipe></p:input>
		</f:metadata-html>
		
		<!-- ### Step 2b: Metadaten nach JSON -->
		<f:metadata-js>
			<p:input port="source"><p:pipe port="result" step="save-transcripts"></p:pipe></p:input>			
		</f:metadata-js>
		
		<!-- ## Step 2c: prints index -->
		<p:xslt>
			<p:input port="source"><p:pipe port="result" step="save-transcripts"/></p:input>
			<p:input port="parameters"><p:pipe port="result" step="config"/></p:input>
			<p:input port="stylesheet"><p:document href="xslt/prints-index.xsl"/></p:input>
		</p:xslt>
		<p:store method="xhtml" indent="true">
			<p:with-option name="href" select="resolve-uri('www/archive_prints.html', $builddir)"/>
		</p:store>
		
		<!-- ## Step 2d: testimony -->
		
		<f:testimony name="testimony">
			<p:input port="source"><p:pipe port="result" step="save-transcripts"></p:pipe></p:input>
		</f:testimony>
		
		
		
		<!-- ## Step 3a: bibliography -->		
		<f:bibliography>
			<p:input port="source">
				<p:pipe port="result" step="metadata-html"/>
				<p:pipe port="result" step="testimony"/>
			</p:input>
		</f:bibliography>
		
		<!-- ### Step 4a: Paralipomena-Tabelle -->
		<f:generate-para-table>
			<p:input port="source">
				<p:pipe port="result" step="emended-version"/>
			</p:input>		
		</f:generate-para-table>
		
		
		<!-- ### Step XXX: Wortindex -->
		<p:for-each>
			<p:iteration-source select="//f:textTranscript">
				<p:pipe port="result" step="emended-version"/>
			</p:iteration-source>
			<p:variable name="documentURI" select="/f:textTranscript/@document"/>	
			<p:load>
				<p:with-option name="href" select="resolve-uri(concat('emended/', $documentURI), $builddir)"/>
			</p:load>
		</p:for-each>		
		<p:wrap-sequence wrapper="doc" name="wrap-emended"/>
		<p:xslt>
			<p:input port="stylesheet"><p:document href="xslt/word-index.xsl"/></p:input>
		</p:xslt>		
		<p:store method="xhtml" indent="true">
			<p:with-option name="href" select="resolve-uri('www/word-index.html', $builddir)"/>
		</p:store>
		<p:store method="xhtml" indent="true">
			<p:with-option name="href" select="resolve-uri('emended-texts.xml', $builddir)"/>
			<p:input port="source"><p:pipe port="result" step="wrap-emended"></p:pipe></p:input>
		</p:store>
		
		
	</p:group>
	
	<!--<p:sink/>-->
</p:declare-step>
