<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns="http://www.w3.org/1999/xhtml" xmlns:xh="http://www.w3.org/1999/xhtml"
	xmlns:f="http://www.faustedition.net/ns"
	xmlns:ge="http://www.tei-c.org/ns/geneticEditions"
	xpath-default-namespace="http://www.tei-c.org/ns/1.0"
	exclude-result-prefixes="xs f xh ge" 	
	version="2.0">
	
	<!-- common code for print2html and variant generation. not to be used standalone -->
	<xsl:import href="utils.xsl"/>
	
	<xsl:param name="edition">../</xsl:param>
	
	<xsl:variable name="scenes" select="doc('scenes.xml')"/>
	
	<xsl:function name="f:scene-for" as="element()?">
		<xsl:param name="element"/>
		<xsl:variable name="n" select="$element/@n"/>
		<xsl:sequence select="$scenes//f:scene[f:id = $n] | $scenes//f:scene[number(f:rangeStart) le number($n) and  number(f:rangeEnd) ge number($n)][1]"/>
	</xsl:function>
	
	<xsl:function name="f:is-schroer" as="xs:boolean">
		<xsl:param name="element"/>
		<xsl:value-of select="f:hasvars($element) and matches($element/@n, '^\d+')"/>
	</xsl:function>
	
	<xsl:template name="scene-data" as="element()?">
		<xsl:choose>
			<xsl:when test="f:hasvars(.) and matches(@n, '\d+')">
				<xsl:sequence select="f:scene-for(.)"/>
			</xsl:when>
<!--		FIXME I still don't get scene numbers. 1.1.23 !?	
			<xsl:when test="ancestor-or-self::div[@n]">
				<xsl:sequence select="f:scene-for(ancestor-or-self::div[@n][1])"/>
			</xsl:when>
-->			<xsl:otherwise>
				<xsl:sequence select="f:scene-for((descendant::*[f:is-schroer(.)][1], preceding-sibling::*[f:is-schroer(.)][1], following-sibling::*[f:is-schroer(.)])[1])"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
		
	<xsl:template name="breadcrumbs">
		<xsl:param name="scene-data" as="element()?">
			<xsl:call-template name="scene-data"/>
		</xsl:param>
		<xsl:param name="separator">
			<i class="fa fa-angle-right"/>			
		</xsl:param>
		<div class="breadcrumbs pure-right pure-nowrap pure-fade-50">
			<small id="breadcrumbs">
				<xsl:choose>
					<xsl:when test="$type='lesetext'">
						<span>
							<a href="../print/text.html">Text</a>
							<xsl:copy-of select="$separator"/>
							<xsl:choose>								
								<xsl:when test="starts-with($scene-data/f:id, '1')">
									<a href="faust1.1.html">Faust I</a>
								</xsl:when>
								<xsl:otherwise>
									<a href="faust2.1.html">Faust II</a>
								</xsl:otherwise>
							</xsl:choose>
							<xsl:copy-of select="$separator"/>
							<a>
								<xsl:value-of select="$scene-data/f:title"/>
							</a>
						</span>
					</xsl:when>
					<xsl:otherwise>
						<span>
							<xsl:call-template name="breadcrumbs-archive">
								<xsl:with-param name="separator" select="$separator"/>						
							</xsl:call-template>
						</span>
						<br/>
						<span>
							<xsl:call-template name="breadcrumbs-genesis">
								<xsl:with-param name="separator" select="$separator"/>
								<xsl:with-param name="scene-data" select="$scene-data"/>
							</xsl:call-template>
						</span>						
					</xsl:otherwise>
				</xsl:choose>
			</small>
		</div>
		<div id="current" class="pure-nowrap">
			<span title="{//idno[@type='faustedition'][1]}">
				<xsl:value-of select="//idno[@type='faustedition'][1]"/>
			</span>
		</div>
	</xsl:template>
	<xsl:template name="breadcrumbs-genesis">
		<xsl:param name="scene-data" as="element()?">
			<xsl:call-template name="scene-data"/>
		</xsl:param>
		<xsl:param name="separator">
			<i class="fa fa-angle-right"/>			
		</xsl:param>
		<a href="genesis.php">Genese</a>
		<xsl:copy-of select="$separator"/>
		<xsl:choose>
			<xsl:when test="not($scene-data)"> [keine Zuordnung gefunden] </xsl:when>
			<xsl:when test="starts-with($scene-data/f:id, '1')">
				<a href="../genesis_faust_i.php">Faust I</a>
			</xsl:when>
			<xsl:otherwise>
				<a href="../genesis_faust_ii.php">Faust II</a>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:copy-of select="$separator"/>
		<a
			href="../genesis_bargraph.php?rangeStart={$scene-data/f:rangeStart}&amp;rangeEnd={$scene-data/f:rangeEnd}">
			<xsl:value-of select="$scene-data/f:title"/>
		</a>
	</xsl:template>
	
	<xsl:template name="breadcrumbs-archive">
		<xsl:param name="separator"/>		
		<a href="../archive.php">Archiv</a>
		<xsl:copy-of select="$separator"/>
		<xsl:choose>
			<xsl:when test="$type = 'print'">
				<a href="../archive_prints.php">Drucke</a>
			</xsl:when>
			<xsl:otherwise>
				<a href="../archive_locations_detail.php?id={/TEI/@f:repository}">
					<xsl:value-of select="/TEI/@f:repository-label"/>
				</a>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template mode="debugxml" match="*">
		<xsl:value-of select="concat('&lt;', name(), ' ', string-join((for $attr in @* return concat(name($attr), '=&quot;', $attr, '&quot;')), ' '), '>')"/>
			<xsl:apply-templates select="node()" mode="#current"/>
		<xsl:value-of select="concat('&lt;/', name(), '>')"/>
	</xsl:template>
	
	
	<xsl:template match="figure">
		<br class="figure {@type}"/>
	</xsl:template>
		
	<xsl:template match="gap[@unit='chars']">
		<span class="{string-join(f:generic-classes(.), ' ')} gap-unit-chars generated-text appnote" 
			data-gap-length="{@quantity}" 
			title="{if (@cert='medium') then 'ungefähr ' else ''}{@quantity} unlesbare Zeichen">
			<xsl:value-of select="string-join(for $n in 1 to @quantity return '×', '')"/>
		</span>
	</xsl:template>
	
	<xsl:template match="gap[@unit='words']">
		<span class="{string-join(f:generic-classes(.), ' ')} gap-unit-words generated-text appnote" data-gap-length="{@quantity}" title="{@quantity} unlesbare Wörter">
			<xsl:value-of select="string-join(for $n in 1 to @quantity return '×···×', ' ')"/>
		</span>
	</xsl:template>  
	
	<xsl:template match="space" priority="2">
	  <xsl:choose>
	    <xsl:when test="$type = 'archivalDocument'">
    	  <span class="{string-join(f:generic-classes(.), ' ')} generated-text appnote" title="Lücke">[***]</span>	      
	    </xsl:when>
	    <xsl:otherwise>
	      <xsl:next-match/>
	    </xsl:otherwise>
	  </xsl:choose>
	</xsl:template>
	
	
	<!-- 
		Sometimes we need to highlight not only the currently hovered element but also some others which are, in a way,
		connected. E.g., <addSpan/> and corresponding target, or all elements of a transposition group.
		
		For JS efficiency, it is probably best to give every HTML element that could be in a highlight group an id, and
		to add an attribute listing _all_ relevant other IDs to the element.
		
		This should be called immediately inside an .appnote element
	-->
	<xsl:key name="samestage" match="*[@ge:stage]" use="string(@ge:stage)"/>
	<xsl:template name="highlight-group">
		<xsl:param name="others" as="element()*"/>
		<xsl:variable name="samestage" select="if (@ge:stage) then key('samestage', @ge:stage) else ()"/>
		<xsl:variable name="others" select="for $el in ($others, $samestage) except . return f:generate-id($el)"/>
		<xsl:if test="count($others) > 0">
			<xsl:attribute name="id" select="f:generate-id(.)"/>
			<xsl:attribute name="data-also-highlight" select="string-join($others, ' ')"/>
		</xsl:if>	
	</xsl:template>
	
	<!-- Reuse IDs from the XML source (since they are manually crafted) -->
	<xsl:function name="f:generate-id" as="xs:string">
		<xsl:param name="element"/>
		<xsl:value-of select="if ($element/@xml:id) then $element/@xml:id else generate-id($element)"/>
	</xsl:function>
	
	
	<!-- 
		Render sth as enclosed with generated text.
		
		The template will render an all-enclosing span, the supplied prefix, the normal content at that position and the supplied suffix.
		Prefix and suffix will be styled with the class 'generated-text'. 
		
		Parameters:
		
		pre	    - Prefix   (may be nodes)
		post    - Postfix  (may be nodes)
		with    - alternative way to specify $pre and $post as a 2-tuple
		classes - sequence of strings to be used as classes for the enclosing element, f:generic-classes(.) by default
		title   - optional title (tooltip) for the enclosing element
	-->
	<xsl:template name="enclose">
		<xsl:param name="with" select="('', '')"/>
		<xsl:param name="pre" select="$with[1]"/>
		<xsl:param name="post" select="if ($with[2]) then $with[2] else $with"/>
		<xsl:param name="classes" select="f:generic-classes(.)"/>
		<xsl:param name="title"/>
		<span class="{string-join($classes, ' ')}">
			<xsl:call-template name="highlight-group"/>
			<xsl:if test="$title">
				<xsl:attribute name="title" select="$title"/>
			</xsl:if>
			<span class="generated-text">
				<xsl:copy-of select="$pre"/>
			</span>
			<xsl:apply-templates select="node()" mode="#current"/>
			<span class="generated-text">
				<xsl:copy-of select="$post"/>
			</span>
		</span>
	</xsl:template>
	
	<xsl:template match="supplied">
		<xsl:call-template name="enclose">
			<xsl:with-param name="with" select="'[',']'"/>
			<xsl:with-param name="title">editorisch ergänzt</xsl:with-param>
			<xsl:with-param name="classes" select="f:generic-classes(.), 'appnote'"></xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	
	<xsl:template match="supplied[@evidence='conjecture']"/>
	
	<xsl:template match="unclear[@cert='high']">
		<xsl:call-template name="enclose">
			<xsl:with-param name="with" select="'{','}'"/>
			<xsl:with-param name="title">unsichere Lesung – wahrscheinlich</xsl:with-param>
			<xsl:with-param name="classes" select="f:generic-classes(.), 'appnote'"></xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	
	<xsl:template match="unclear[@cert='low']">
		<xsl:call-template name="enclose">
			<xsl:with-param name="with" select="'{{','}}'"/>
			<xsl:with-param name="classes" select="f:generic-classes(.), 'appnote'"/>
			<xsl:with-param name="title">unsichere Lesung – möglich</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	
	
	<!-- choice: richtige Alternative wählen -->
	
	<xsl:template match="choice[sic and corr]">
			<xsl:apply-templates select="sic/node()"/>	<!-- komplett ignorieren -->
	</xsl:template>
	
	<xsl:template match="choice[abbr and expan]">
		<abbr class="{string-join((f:generic-classes(abbr), 'appnote'), ' ')}"			
			title="{expan}">
			<xsl:apply-templates select="abbr/node()"/>
		</abbr>
	</xsl:template>
	
	<xsl:template match="choice[orig and reg]">
		<span class="{string-join((f:generic-classes(orig), 'appnote'), ' ')}"
			title="{reg}">
			<xsl:apply-templates select="orig/node()"/>
		</span>		
	</xsl:template>
	
	<xsl:template match="app[lem and rdg]">
		<span class="{string-join((f:generic-classes(lem), 'appnote'), ' ')}">
			<xsl:attribute name="title">
				<xsl:for-each select="rdg">
					<xsl:value-of select="@resp"/>	<!-- FIXME can we resolve this? -->
					<xsl:text> liest »</xsl:text>
					<xsl:value-of select="."/>
					<xsl:text>«</xsl:text>
					<xsl:if test="following-sibling::rdg">; </xsl:if>
				</xsl:for-each>
			</xsl:attribute>
			<span class="{string-join((f:generic-classes(lem), 'appnote'), ' ')}">
				<xsl:apply-templates select="lem/node()"/>
			</span>
		</span>
	</xsl:template>
	
	<xsl:template match="choice[unclear[@cert='high'] and unclear[@cert='low']]">
		<xsl:for-each select="unclear[@cert='high']">
			<xsl:call-template name="enclose">
				<xsl:with-param name="pre">{</xsl:with-param>
				<xsl:with-param name="post">}</xsl:with-param>
				<xsl:with-param name="classes" select="f:generic-classes(.), 'appnote'"/>
				<xsl:with-param name="title" select="concat('wahrscheinliche Lesung; Alternative: ', ../unclear[cert='low'])"/>
			</xsl:call-template>
		</xsl:for-each>
	</xsl:template>
	
	<xsl:template match="choice|app">
		<xsl:message>WARNING: Unrecognized <xsl:value-of select="local-name(.)"/>, using COMPLETE content:
<xsl:copy-of select="."/>
in <xsl:value-of select="document-uri(/)"/>
		</xsl:message>
		<xsl:next-match/>
	</xsl:template>
	
	<!-- Es gibt wohl die Elemente auch noch ohne <choice> -->
	<xsl:template match="corr"/>
	<!-- die anderen werden einfach durchgereicht -->
	
	<xsl:template match="lb">
		<xsl:text> </xsl:text>
	</xsl:template>
	
	<xsl:template match="lb[@break='no']"/>
	
	<xsl:template match="pb">
		<xsl:text> </xsl:text>
	</xsl:template>
	
	<xsl:template match="pb[$type = 'lesetext']" priority="5">
		<xsl:text> </xsl:text>
	</xsl:template>
  
  <xsl:template name="generate-pageno">
    <xsl:choose>
      <xsl:when test="@n">
        <xsl:value-of select="replace(@n, '^0+', '')"/>
      </xsl:when>
      <xsl:when test="@facs">
        <xsl:value-of select="replace(@facs, '^0*(.*)\.(tiff|jpg|jpeg|xml)$', '$1')"/>
      </xsl:when>
      <xsl:otherwise>
        <i class="icon-file-alt" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="pb[@f:docTranscriptNo]" priority="1">
    <xsl:text> </xsl:text>
    <a  
      class="{string-join((f:generic-classes(.), 'generated-text', 'pageno', 'doclink'), ' ')}"
      id="dt{@f:docTranscriptNo}"
      href="{f:doclink($documentURI, @f:docTranscriptNo, ())}"> 
      [<xsl:call-template name="generate-pageno"/>]
    </a>
  </xsl:template>
	
  <xsl:template match="pb[@n][following::*[1][self::pb]]" priority="2">
  	<span id="pb{@n}" class="pb-supressed">
  		<xsl:comment>Supressed page break <xsl:value-of select="@n"/></xsl:comment>
  	</span>
  </xsl:template>
  
  <xsl:template match="pb[@n]">
    <xsl:text> </xsl:text>
    <span
      class="{string-join((f:generic-classes(.), 'generated-text', 'pageno'), ' ')}"
      id="pb{@n}">
      [<xsl:call-template name="generate-pageno"/>]
    </span>
  </xsl:template>
	
  <xsl:template match="fw"/>
	
	<!-- Erzeugt die Zeilennummer vor der Zeile -->
	<xsl:template name="generate-lineno">
		<xsl:variable name="display-line" select="f:lineno-for-display(@n)"/>
		<xsl:choose>
			<xsl:when test="number($display-line) gt 0">
				<!-- Klick auf Zeilennummer führt zu einem Link, der wiederum auf die Zeilennummer verweist -->
				<xsl:attribute name="id" select="concat('l', @n)"/>
				<a href="#l{@n}">
					<xsl:attribute name="class">
						<xsl:text>lineno</xsl:text>
						<!-- Jede 5. ist immer sichtbar, alle anderen nur wenn über die Zeile gehovert wird -->
						<xsl:if test="$display-line mod 5 != 0">
							<xsl:text> invisible</xsl:text>
						</xsl:if>
					</xsl:attribute>
					<xsl:value-of select="$display-line"/>
				</a>
			</xsl:when>
			<xsl:otherwise>
				<a class="lineno invisible">&#160;</a>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	
	<!-- Tabellen -->
	<xsl:template match="table">
	  <table class="{string-join((f:generic-classes(.)), ' ')}">
	      <xsl:attribute name="xml:id" select="f:generate-id(.)"/>
			<xsl:apply-templates mode="#current"/>
		</table>
	</xsl:template>
	<xsl:template match="row">
		<tr class="{string-join(f:generic-classes(.), ' ')}">
			<xsl:apply-templates/>
		</tr>
	</xsl:template>
	<xsl:template match="cell">
		<td class="{string-join(f:generic-classes(.), ' ')}">
			<xsl:apply-templates/>
		</td>
	</xsl:template>
	
	
	<!-- Sonderzeichen -->
	<xsl:template match="g[@ref]">
		<xsl:variable name="map">
			<f:g ref="#g_break">[</f:g>
			<f:g ref="#g_transp_1">⊢</f:g>
			<f:g ref="#g_transp_2">⊨</f:g>
			<f:g ref="#g_transp_2a">⫢</f:g>
			<f:g ref="#g_transp_3">⫢</f:g>
			<f:g ref="#g_transp_3S">⎱</f:g>
			<f:g ref="#g_transp_4">+</f:g>
			<f:g ref="#g_transp_5">✓</f:g>
			<f:g ref="#g_transp_6">#</f:g>
			<f:g ref="#g_transp_7">◶</f:g>
			<f:g ref="#g_transp_8">⊣</f:g>
			<f:g ref="#parenthesis_left">(</f:g>
			<f:g ref="#parenthesis_right">)</f:g>
			<f:g ref="#truncation">.</f:g>			
		</xsl:variable>
		<span class="g g-{substring(@ref, 2)}">
			<xsl:choose>
				<xsl:when test="$map/f:g[@ref=current()/@ref]">
					<xsl:value-of select="$map/f:g[@ref=current()/@ref]"/>					
				</xsl:when>				
				<xsl:when test="document(@ref)//mapping">
					<xsl:value-of select="document(@ref)//mapping"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>�</xsl:text>
					<xsl:message select="concat(document-uri(.), ': Unresolved glyph: ', @ref)"/>
				</xsl:otherwise>
			</xsl:choose>			
		</span>
	</xsl:template>
	
</xsl:stylesheet>