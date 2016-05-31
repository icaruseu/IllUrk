<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs"
    version="2.0">
    <xsl:template match="/">
        <html>
            <head><meta charset="utf-8"/><title>Glossarbegriffe nachbessern</title></head>
            <body>
                <h1>Layout</h1>
                <ul><xsl:apply-templates select="//hi[@rend='bold'][.='Layout']"/></ul>
                <h1>Vera Ikon</h1>
                <ul><xsl:apply-templates select="//hi[@rend='bold'][.='Vera Ikon']"/></ul>
                <h1>Vera-Ikon-Typ</h1>
                <ul><xsl:apply-templates select="//hi[@rend='bold'][.='Vera-Ikon-Typ']"/></ul>
                <h1>ikonographische Diversifizierung</h1>
                <ul><xsl:apply-templates select="//hi[@rend='bold'][.='ikonographische Diversifizierung']"/></ul>
                <h1>Vera Ikon</h1>
                <ul><xsl:apply-templates select="//hi[@rend='bold'][ends-with(.,'s')]"/></ul>
            </body>
        </html>
    </xsl:template>
    <xsl:template match="hi[@rend='bold']">
        <li><xsl:apply-templates select="ancestor::row/cell[1]"/><xsl:text>_</xsl:text><xsl:apply-templates select="ancestor::row/cell[6]/descendant-or-self::*[@rend='Archivort']"/> - <xsl:text>http://monasterium.net/mom/IlluminierteUrkunden/</xsl:text><xsl:apply-templates select="ancestor::row/cell[1]"/><xsl:text>_</xsl:text><xsl:apply-templates select="ancestor::row/cell[6]/descendant-or-self::*[@rend='Archivort']"/><xsl:text>/charter</xsl:text></li>
    </xsl:template>
</xsl:stylesheet>