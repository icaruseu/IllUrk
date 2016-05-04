<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:skos="http://www.w3.org/2004/02/skos/core#"
    xmlns:t="http://www.tei-c.org/ns/1.0" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    exclude-result-prefixes="xs" version="2.0">
    <xsl:variable name="glossarkonkordanz" select="document('GlossarKonkordanz.xml')"/>
    <!-- Achtung, ggf. Speicherort anpassen! -->
    <xsl:template match="/">
        <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
            xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:t="http://www.tei-c.org/ns/1.0"
            xmlns:xhtml="http://www.w3.org/1999/xhtml">
            <xsl:for-each select="//t:div">
                <xsl:apply-templates select="t:div"/>
            </xsl:for-each>
        </rdf:RDF>
    </xsl:template>
    <xsl:template match="t:div">
        <skos:Concept>
            <xsl:attribute name="rdf:about">
                <xsl:text>#</xsl:text>
                <xsl:value-of
                    select="replace(replace(replace(replace(replace(replace(replace(t:head, 'ä', 'ae'), 'ß', 'ss'), 'ö', 'oe'), 'ü', 'ue'), 'é', 'e'), ' ', ''), '&#xA;', '')"
                />
            </xsl:attribute>
            <skos:prefLabel xml:lang="de">
                <xsl:value-of select="t:head"/>
            </skos:prefLabel>
            <skos:definition>
                <xsl:apply-templates select="t:p"/>
            </skos:definition>
        </skos:Concept>
    </xsl:template>

    <xsl:template match="t:p[@rend]" xmlns:xhtml="http://www.w3.org/1999/xhtml">
        <xhtml:ul>
            <xsl:for-each select=".">
                <xhtml:li>
                    <xsl:value-of select="."/>
                </xhtml:li>
            </xsl:for-each>
        </xhtml:ul>
    </xsl:template>
    <xsl:template match="t:p[not(@rend)]" xmlns:xhtml="http://www.w3.org/1999/xhtml">
        <xhtml:p>
            <xsl:apply-templates/>
        </xhtml:p>
    </xsl:template>


    <xsl:template match="t:hi[@rend = 'bold']" >
       
            <xsl:copy-of select="t:lemmakontrolle(.)"/>
      
    </xsl:template>

    <xsl:function name="t:lemmakontrolle" xmlns:xhtml="http://www.w3.org/1999/xhtml">
        <xsl:param name="knoten"/>
        <!-- Teste, ob normalizedtext in $glossarkonkordanz/orig vorkommt -->
        <xsl:variable name="glossaryentry"
            select="$glossarkonkordanz//entry[orig = $knoten/text()[1]/normalize-space()]"/>
        <xhtml:a>       
        <xsl:attribute name="href">
            <xsl:text>#</xsl:text>            
            <xsl:value-of
                select="replace(replace(replace(replace(replace(replace(replace($glossaryentry/normalized, 'ä', 'ae'), 'ß', 'ss'), 'ö', 'oe'), 'ü', 'ue'), 'é', 'e'), ' ', ''), '&#xA;', '')"
            />
        </xsl:attribute>            
        <xsl:choose>
            <xsl:when test="$glossaryentry/@action = 'replace'">               
                <xsl:apply-templates select="$glossaryentry/normalized"/>
            </xsl:when>
            <xsl:otherwise>                               
               <xsl:apply-templates select="$knoten/(* | text())"/>
            </xsl:otherwise>
        </xsl:choose>
        </xhtml:a>
    </xsl:function>


</xsl:stylesheet>
