<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:t="http://www.tei-c.org/ns/1.0"
    xmlns:skos="http://www.w3.org/2004/02/skos/core#"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="2.0">
    <xsl:output indent="yes"/>
    <xsl:variable name="Glossar" select="document('rdfGlossar.xml')"/>
    <xsl:template match="/">
        <html>
            <head><meta charset="utf-8"/><title>Glossar-Test</title></head>
            <body>
                <xsl:apply-templates select="//t:row[position() gt 1]"/>
            </body>
        </html>
    </xsl:template>
    <xsl:template match="t:row">
        <div>
            <h2><xsl:value-of select="t:cell[1]"/><xsl:text>_</xsl:text><xsl:value-of select=".//t:hi[@rend='Archivort']/substring-before(.,' ')"/></h2>
            <ul>
                <xsl:apply-templates select=".//t:hi[@rend='bold']"/>
            </ul>
        </div>
    </xsl:template>
    <xsl:template match="t:hi[@rend='bold']">
        <li><xsl:choose>
            <xsl:when test="$Glossar//*[skos:prefLabel/normalize-space()=current()/normalize-space()]"/>
            <xsl:otherwise><xsl:attribute name="style">background-color:red;</xsl:attribute></xsl:otherwise>
        </xsl:choose><xsl:value-of select="current()"/></li>
    </xsl:template>
</xsl:stylesheet>