<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:t="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs" version="2.0">
    <!-- Beispiel für Generierung von eindeutigen IDs aus der Wordliste:
    * $ids: Variable über alle Zeilen mit ID-Wert aus Datumsangabe und Archivort incl. Sonderzeichennormalisierung 
      für's Debugging werden auch die Datumss- und Archivspalte mit in die Variable aufgenommen
    * Dublettenkontrolle: Vor der Ausgabe eine Kontrolle, ob die ID mehrfach vorkommt, ggf. Erweiterung um "-Zahl"
    -->
    <xsl:output method="html" indent="yes"/>
    <xsl:variable name="ids">
        <xsl:for-each select="//t:row[position() gt 1]">
            <xsl:variable name="archivort">
                <xsl:choose>
                    <xsl:when test="not(.//t:hi[@rend='Archivort'] and t:cell[6]/normalize-space()='')">
                        <xsl:value-of select="t:cell[6]/replace(., '^([^\s].*?),.*?$', '$1')"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select=".//t:hi[@rend='Archivort'][1]"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <row n="{position()}">
                <id>
                    <xsl:value-of
                        select="t:cell[1]/(text()[1]|t:p[1])/replace(.,'^([0123456789\-––]*)[^0123456789\-––][\s\S]*?$','$1')"/>
                    <xsl:variable name="totransform"><xsl:text>äöüßÄÖÜňřáàéèóòôúùâšíł ,.;:()[]+*#{}/–§$%&amp;"!?' ’</xsl:text></xsl:variable>
                    <xsl:choose>
<!--                        <xsl:when test="not(t:cell[6]//@rend = 'Archivort') and t:cell[6]/normalize-space()!=''">
                            <xsl:text>_</xsl:text><xsl:value-of select="t:cell[6]/replace(., '^([^\s].*?),.*?$', '$1')"/>
                        </xsl:when>-->
                        <xsl:when test="t:cell[6]/normalize-space()=''"/>
                        <xsl:otherwise>
                            <xsl:text>_</xsl:text><xsl:value-of select="$archivort/translate(normalize-space(replace(replace(replace(replace(replace(.,'ä','ae','i'),'Ö','Oe'),'ö','oe'),'ü','ue','i'),'ß','ss')),$totransform,'aousAOUnraaeeooouuasil-')"/>
                        </xsl:otherwise>
                    </xsl:choose>
                    <!-- 
                        1162_Klosterneuburg Klosterneuburg
                        1359-01-01_ aber Archivangabe Warwickshire Record Office (erworben 1984) vorhanden
                        1363-03-27 	Brüssel (Bruxelles),  => 1363-03-27_Brussel Bruxelles : Warum?
                    Alternativer Weg, Unicode-Codepoints als Kriterium zu verwenden, braucht auch eine Normalisierungstabelle und fällt deshalb wohl aus
                    Wunsch: äöü durch ae, oe, ue ersetzen (siehe die Variable archivort oben, die nicht funktioniert -->
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
                        <tr><th>Zeilenr.</th>
                            <th>ID</th>
                        <th>Anzahl Vorkommen der Kombination Datum-Ort</th>
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
            <td><xsl:value-of select="position()"/></td>
            <td>
                <xsl:value-of select="id"/>
                <!-- Dublettenkontrolle -->
                <xsl:if test="count($ids/row/id[.=current()/id]) gt 1">
                    <xsl:text>_</xsl:text><xsl:value-of select="(count(preceding::id[.=current()/id]) + 1)"></xsl:value-of>
                </xsl:if>
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
