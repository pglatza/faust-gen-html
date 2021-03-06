<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" version="2.0" xmlns="http://www.tei-c.org/ns/1.0"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0" xmlns:f="http://faustedition.net/ns"
    xmlns:xi="http://www.w3.org/2001/XInclude" xmlns:svg="http://www.w3.org/2000/svg"
    xmlns:math="http://www.w3.org/1998/Math/MathML" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl">

    <xsl:output method="xml" indent="yes"/>
    <!-- in einer Transformation für / das TEI-Gerüst erzeugen -->
    <xsl:template match="/">
        <xsl:processing-instruction name="oxygen">oxygen RNGSchema="https://faustedition.uni-wuerzburg.de/xml/schema/faust-tei_neu.rng" type="xml"</xsl:processing-instruction>
        <TEI>
            <teiHeader>
                <fileDesc>
                    <titleStmt>
                        <title>WA ###</title>
                    </titleStmt>
                    <publicationStmt>
                        <p>Publication Information</p>
                    </publicationStmt>
                    <sourceDesc>
                        <p>Information about the source</p>
                    </sourceDesc>
                </fileDesc>
                <revisionDesc>
                    <change/>
                </revisionDesc>
            </teiHeader>
            <text>
                <body>
                    <!-- darin mittels select die Zeugnis-Briefe oder -Tagebucheinträge auswählen -->
                    <xsl:for-each select="descendant::div[@type = 'letter' or @type = 'diaryentry'][descendant::milestone[@unit = 'testimony']]">
                        <xsl:call-template name="testimony"/>
                    </xsl:for-each>

                </body>
            </text>
        </TEI>
    </xsl:template>
    
    <!-- unmittelbar vorhergehenden <pb> herbeikopieren -->
    <xsl:template name="testimony">
        <xsl:comment select="concat('Testimony ', string-join(descendant::milestone[@unit = 'testimony']/@xml:id, ', '))"/>
        <xsl:copy-of select="preceding::pb[1]"/>
        <xsl:apply-templates select="."/>
    </xsl:template>
    
    <xsl:template match="date[@when='']"/>
    
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*, node()"/>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>
