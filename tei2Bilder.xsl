<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:t="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs"
    version="2.0">
    <!-- 1. Herunterladen von http://images.monasterium.net/illum/IllUrk/ 
         2. XMLisierung der Datei und ablegen unter http://images.monasterium.net/illum/Bilder_illum_IllUrk.xml
         3. Dieses Skript ausführen
    -->
    <xsl:variable name="bilder" select="document('http://images.monasterium.net/illum/Bilder_illum_IllUrk.xml')"/>
    <xsl:template match="/">
        <html>
            <head>
                <title>Bildverknüpfung IllUrk</title>
            </head>
            <body>
                <ul>
        <xsl:for-each select="//t:row[position() gt 1]">
               <li>
                 <xsl:variable name="urk" select="concat('http://images.monasterium.net/illum/IllUrk/',t:cell[1]/(text()|*[1]/text())[1])"/>
                   <xsl:choose>
                     <xsl:when test="t:cell[1]/(text()|*[1]/text())[1]/normalize-space() != ''">
                       <xsl:value-of select="t:cell[1]"/> (=> <xsl:value-of select="$urk"/>):
                        <xsl:for-each
                            select="$bilder//a[starts-with(@href, $urk) and (ends-with(@href, '.jpg') or ends-with(@href, '.png'))]">
                            <br/><a>
                                <xsl:attribute name="href">
                                    <xsl:value-of select="@href"/>
                                </xsl:attribute>
                                <xsl:value-of select="@href"/>
                            </a>
                        </xsl:for-each>
                   </xsl:when>
                   <xsl:otherwise>KEIN DATUM</xsl:otherwise>
               </xsl:choose>
            </li>
        </xsl:for-each></ul></body></html>
    </xsl:template>
</xsl:stylesheet>