<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:t="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs" version="2.0">
    <xsl:output method="html" indent="yes"/>
    <xsl:variable name="ids">
        <xsl:for-each select="//t:row[position() gt 1]">
            <xsl:variable name="archivort" select=".//t:hi[@rend='Archivort'][1]/replace(replace(replace(replace(replace(text(),'ä','ae','i'),'Ö','Oe'),'ö','oe'),'ü','ue','i'),'ß','ss')/text()"/>
            <!-- FixMe: erzeugt leere Knoten statt Strings, deshalb wird die Variable vorläufig nicht verwendet -->
            <row n="{position()}">
                <id>
                    <xsl:value-of
                        select="replace(t:cell[1],'^([0123456789-]*?)[^0123456789-].*?$','$1')"/>
                    <xsl:text>_</xsl:text>
                    <xsl:value-of
                        select=".//t:hi[@rend='Archivort']/translate(normalize-space(.),'äöüßÄÖÜňřáàéèóòúù ,.;:()[]+*#{}/–','aousAOUnraaeeoouu-')"
                    />
                    <!-- FixMe: Apostroph, §$%&"!?
                    Alternativer Weg, Unicode-Codepoints als Kriterium zu verwenden, braucht auch eine Normalisierungstabelle und fällt deshalb wohl aus
                    Wunsch: äöü durch ae, oe, ue ersetzen (sie die Variable oben, die nicht funktioniert -->
                </id>
                <date>
                    <xsl:value-of select="t:cell[1]"/>
                </date>
                <archiv>
                    <xsl:value-of select="t:cell[6]"/>
                </archiv>
            </row>
        </xsl:for-each>
    </xsl:variable>
    <xsl:template match="/">
        <html>
            <head>
                <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
                <title>IDs</title>
            </head>
            <body>
                <table>
                    <thead>
                        <tr><th>ID</th>
                        <th>Anzahl Vorkommen der ID</th>
                        <th>Datumsspalte</th>
                        <th>Archivspalte</th></tr>
                    </thead>
                    <tbody><xsl:apply-templates select="$ids/row"/></tbody>
                </table>
            </body>
        </html>
    </xsl:template>
    <xsl:template match="row">
        <tr>
            <td>
                <xsl:value-of select="id"/>
            </td>
            <td>
                <xsl:value-of select="count($ids/row/id[.=current()/id])"/>
            </td>
            <td>
                <xsl:value-of select="date"/>
            </td>
            <td>
                <xsl:value-of select="archiv"/>
            </td>
        </tr>
    </xsl:template>
</xsl:stylesheet>
