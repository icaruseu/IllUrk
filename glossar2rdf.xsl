<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:t="http://www.tei-c.org/ns/1.0"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    exclude-result-prefixes="xs"
    version="2.0">
    <xsl:template match="/">
        <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
            xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:t="http://www.tei-c.org/ns/1.0">
       <xsl:for-each select="//t:div">
           <xsl:apply-templates select="t:div"/>            
       </xsl:for-each>           
        </rdf:RDF>
    </xsl:template>
    <xsl:template match="t:div">
        <skos:Concept>
            <xsl:attribute name="rdf:about">
                <xsl:text>#</xsl:text>
                <xsl:value-of select="replace(replace(replace(replace(replace(replace(replace(t:head, 'ä', 'ae'), 'ß', 'ss'), 'ö', 'oe'), 'ü', 'ue'), 'é', 'e'), ' ', ''), '&#xA;', '')"/>               
            </xsl:attribute>
            <skos:prefLabel xml:lang="de"><xsl:value-of select="t:head"/></skos:prefLabel>
            <skos:definition><xsl:apply-templates select="t:p" /></skos:definition>
        </skos:Concept>
    </xsl:template>
    <xsl:template match="t:p">
        <t:p>
            <xsl:apply-templates />
        </t:p>
    </xsl:template>
    <xsl:template match="t:hi[@rend='bold']">
        <t:ref>
            <xsl:attribute name="target">
                <xsl:text>#</xsl:text>
                <xsl:value-of select="replace(replace(replace(replace(replace(replace(replace(., 'ä', 'ae'), 'ß', 'ss'), 'ö', 'oe'), 'ü', 'ue'), 'é', 'e'), ' ', ''), '&#xA;', '')"/>               
            </xsl:attribute>
            <xsl:value-of select="."/>
        </t:ref>
    </xsl:template>    
</xsl:stylesheet>