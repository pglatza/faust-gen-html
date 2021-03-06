<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns="http://www.w3.org/1999/xhtml"
	xmlns:h="http://www.w3.org/1999/xhtml"
	xmlns:f="http://www.faustedition.net/ns" exclude-result-prefixes="xs f h"
	version="2.0">

	<xsl:param name="title">Faustedition [alpha]</xsl:param>
	<xsl:param name="edition"></xsl:param>
	<xsl:param name="assets" select="$edition"/>
	<xsl:param name="debug" select="false()"/>
	<xsl:param name="documentURI"/>
	<xsl:param name="headerAdditions"/>
	<xsl:param name="scriptAdditions"/>
	<xsl:param name="query" select="/f:results/@query"/>

	<xsl:output method="xhtml" indent="yes" include-content-type="no"
		omit-xml-declaration="yes"/>
	
	<xsl:function name="f:breadcrumb-json">
		<xsl:param name="breadcrumb-html"/>
		<xsl:choose>
			<xsl:when test="$breadcrumb-html//h:a">
				<xsl:text>[</xsl:text>
				<xsl:for-each select="$breadcrumb-html//h:a">
					<xsl:text>{caption:"</xsl:text><xsl:value-of select="replace(normalize-space(.), '&quot;', '')"/><xsl:text>"</xsl:text>
					<xsl:if test="@href">
						<xsl:text>,link:"</xsl:text><xsl:value-of select="@href"/><xsl:text>"</xsl:text>
					</xsl:if>
					<xsl:text>}</xsl:text>
					<xsl:if test="position() != last()">,</xsl:if>
				</xsl:for-each>
				<xsl:text>]</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="normalize-space($breadcrumb-html)"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>

	<xsl:template name="html-head">
		<xsl:param name="title" select="$title" tunnel="yes"/>
		<xsl:param name="headerAdditions" select="$headerAdditions"/>
		<xsl:param name="scriptAdditions"/>
		<xsl:comment select="concat('Generated: ', current-dateTime())"/>
		<head>
			<meta charset="utf-8"/>

			<script type="text/javascript" src="{$assets}/js/require.js"/>
			<script type="text/javascript" src="{$assets}/js/faust_config.js"/>

			<link rel="stylesheet" href="{$assets}/css/webfonts.css"/>
			<link rel="stylesheet" href="{$assets}/css/fontawesome-min.css"/>
			<link rel="stylesheet" href="{$assets}/css/pure-min.css"/>
			<link rel="stylesheet" href="{$assets}/css/pure-custom.css"/>
			<link rel="stylesheet" href="{$assets}/css/basic_layout.css"/>
			<link rel="stylesheet" href="{$assets}/css/overlay.css"/>
			<link rel="stylesheet" href="{$assets}/css/textual-transcript.css"/>
			<link rel="stylesheet" href="{$assets}/css/prints-viewer.css"/>
			<xsl:if test="$scriptAdditions">
				<script>
					requirejs(["faust_common"], function(Faust) {
	    				<xsl:copy-of select="$scriptAdditions"/>				  
					});
				</script>				
			</xsl:if>

			<link rel="icon" type="image/png" href="/favicon-16x16.png"
				sizes="16x16"/>
			<link rel="icon" type="image/png" href="/favicon-32x32.png"
				sizes="32x32"/>

			<xsl:copy-of select="$headerAdditions"/>
		</head>

	</xsl:template>

	<xsl:template name="header">
		<xsl:param name="breadcrumbs" tunnel="yes">***</xsl:param>
		<xsl:if test="$breadcrumbs != '***'"><xsl:message>ERROR: breadcrumbs param is not supported any longer</xsl:message></xsl:if>
		<header>
			<div class="logo">
				<a href="{$edition}/" title="Faustedition">
					<img src="{$assets}/img/faustlogo.svg" alt="Faustedition"/>
				</a>
				<sup class="pure-fade-50">
					<mark>alpha</mark>
				</sup>
			</div>
			
			<div class="breadcrumbs pure-right pure-nowrap pure-fade-50">
				<small id="breadcrumbs"/>
			</div>
			<div id="current" class="pure-nowrap"/>

			<nav id="nav_all" class="pure-menu pure-menu-open pure-menu-horizontal pure-right pure-nowrap pure-noprint">
				<ul>
					<li><a href="/help" title="Hilfe"><i class="fa fa-help-circled fa-lg"></i></a></li>
					<li><a href="#quotation" title="Zitieremfehlung"><i class="fa fa-bookmark fa-lg"></i></a></li>
					<li><form class="pure-form" action="/search" method="GET"><input id="quick-search" name="q" type="text" onblur="this.value=''" /><button type="submit" class="pure-fade-30"><i class="fa fa-search fa-lg"></i></button></form></li>
					<li><a href="#navigation" title="Seitennavgation"><i class="fa fa-menu fa-lg"></i> Menü</a></li>
				</ul>
			</nav>
		</header>
	</xsl:template>

	<xsl:template name="footer">
		<xsl:param name="breadcrumb-def" tunnel="yes" select="false()"/>
		<xsl:param name="scriptAdditions" select="$scriptAdditions"/>
		<footer>
			<div class="center pure-g-r">
				<div class="pure-u-1-2 pure-fade-50">
					<a class="undecorated" rel="license" href="http://creativecommons.org/licenses/by-nc-sa/4.0/"><img alt="Creative Commons Lizenzvertrag" src="https://i.creativecommons.org/l/by-nc-sa/4.0/80x15.png" align="middle"/></a>
				</div>
				<div class="pure-u-1-2 pure-right pure-fade-50 pure-noprint">
					<a href="/project">Projekt</a>
					·
					<a href="/intro">Ausgabe</a>
					·
					<a href="/contact">Kontakt</a>
					·
					<a href="/imprint">Impressum</a>
					·
					<a href="/intro#sitemap">Sitemap</a>
				</div>
			</div>
		</footer>
		
		<script type="text/template" id="navigation">
			<div class="center pure-g-r navigation">
				<div class="pure-u-1-4 pure-gap">
					<a href="/archive"><big>Archiv</big></a>
					<a href="/archive_locations">Aufbewahrungsorte</a>
					<a href="/archive_manuscripts">Handschriften</a>
					<a href="/archive_prints">Drucke</a>
					<a href="/archive_testimonies">Dokumente zur Entstehungsgeschichte</a>
				</div>
				<div class="pure-u-1-4 pure-gap">
					<a><big>Genese</big></a>
					<a href="/genesis">Werkgenese</a>
					<a href="/genesis_faust_i">Genese Faust I</a>
					<a href="/genesis_faust_ii">Genese Faust II</a>
				</div>
				<div class="pure-u-1-4 pure-gap">
					<a href="/text"><big>Text</big></a>
					<a href="/print/faust1">Faust I</a>
					<a href="/print/faust2">Faust II</a>
					<a href="/paralipomena">Paralipomena</a>
				</div>
				<div class="pure-u-1-4 pure-gap pure-fade-50">
					<a><big>Informationen</big></a>
					<a href="/intro">Über die Ausgabe</a>
					<a href="/project">Über das Projekt</a>
					<a href="/contact">Kontakt</a>
					<a href="/imprint">Impressum</a>
					<a href="/intro#sitemap">Sitemap</a>
					<a class="undecorated" rel="license" href="http://creativecommons.org/licenses/by-nc-sa/4.0/"><img alt="Creative Commons Lizenzvertrag" src="https://i.creativecommons.org/l/by-nc-sa/4.0/80x15.png" align="middle"/></a>
				</div>
			</div>
		</script>
		
		
		<script type="text/template" id="quotation">
			<div class="center pure-g-r quotation">
				<div class="pure-u-1">
					<h3>Zitierempfehlung</h3>
					<p class="quotation-content">
						Historisch-kritische Faustedition.
						Herausgegeben von Anne Bohnenkamp, Silke Henke und Fotis Jannidis.
						Unter Mitarbeit von Gerrit Brüning, Katrin Henzel, Christoph Leijser, Gregor Middell, Dietmar Pravida, Thorsten Vitt und Moritz Wissenbach.
						Version 1. Frankfurt am Main / Weimar / Würzburg 2016,
						<span>Startseite</span>,
						<span>URL: <?php echo $_SERVER['HTTP_HOST']; ?></span>,
						abgerufen am <?php echo date('d.m.Y'); ?>.
					</p>
					<p><i class="fa fa-paste pure-fade-50"></i> <a href="#" data-target=".quotation-content">kopieren</a></p>
				</div>
			</div>
		</script>
		
		<script>
			requirejs(['faust_common', 'jquery', 'jquery.chocolat', 'jquery.overlays', 'jquery.clipboard', 'faust_print_interaction'], 
				 function (Faust, $, $chocolat, $overlays, $clipboard, addPrintInteraction) {
						$('main').Chocolat({className:'faustedition', loop:true});
						$('header nav').menuOverlays({highlightClass:'pure-menu-selected', onAfterShow: function() {
							$('[data-target]').copyToClipboard();
						}});
						$(function(){addPrintInteraction('/', undefined, '<xsl:value-of select="if ($documentURI) then $documentURI else 'undefined'"/>');})
					<xsl:if test="$breadcrumb-def">
						var breadcrumbs = document.getElementById("breadcrumbs");
						breadcrumbs.appendChild(Faust.createBreadcrumbs(<xsl:value-of select="f:breadcrumb-json($breadcrumb-def)"/>));
					</xsl:if>
					<xsl:value-of select="$scriptAdditions"/>
				});
		</script>
		
		<!-- Piwik -->
		<script type="text/javascript">
  var _paq = _paq || [];
  _paq.push(['trackPageView']);
  _paq.push(['enableLinkTracking']);
  (function() {
    var u="//analytics.faustedition.net/";
    _paq.push(['setTrackerUrl', u+'piwik.php']);
    _paq.push(['setSiteId', 1]);
    var d=document, g=d.createElement('script'), s=d.getElementsByTagName('script')[0];
    g.type='text/javascript'; g.async=true; g.defer=true; g.src=u+'piwik.js'; s.parentNode.insertBefore(g,s);
  })();
</script>
		<noscript>
			<p>
				<img src="//analytics.faustedition.net/piwik.php?idsite=1"
					style="border:0;" alt=""/>
			</p>
		</noscript>
		<!-- End Piwik Code -->
	</xsl:template>


	<xsl:template name="html-frame">
		<xsl:param name="content">
			<xsl:apply-templates/>
		</xsl:param>
		<xsl:param name="headerAdditions" select="$headerAdditions"/>
		<xsl:param name="scriptAdditions" select="$scriptAdditions"/>
		<html>
			<xsl:call-template name="html-head">
				<xsl:with-param name="headerAdditions" select="$headerAdditions"/>				
			</xsl:call-template>
			<body>
				<xsl:call-template name="header"/>
				<main class="nofooter">
					<section>
						<article>
							<xsl:sequence select="$content"/>
						</article>
					</section>
				</main>
				<xsl:call-template name="footer">
					<xsl:with-param name="scriptAdditions" select="$scriptAdditions"/>
				</xsl:call-template>
			</body>
		</html>
	</xsl:template>

</xsl:stylesheet>
