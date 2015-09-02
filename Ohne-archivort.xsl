<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="xs" version="2.0">
    <xsl:output method="html" indent="yes"/>
    <xsl:template match="/">
        <html>
            <head>
                <title>Einträge ohne Archivort</title>
                <style type="text/css">
                    td {vertical-align:top;
                        border-bottom:solid 1px; border-right:dotted 1px}
                </style>
            </head>
            <body style="margin:20px">
                <ul><li><a href="#mitArchivangaben">Mit Archivangaben aber ohne Archivortmarkierung</a></li>
                    <li><a href="#ohneArchivangaben">Ohne Archivangaben</a></li></ul>
                <h1 id="mitArchivangaben">Mit Archivangaben aber ohne Archivortmarkierung</h1>
                <p><xsl:value-of select="count(//row[not(cell[6]//@rend = 'Archivort') and cell[6]/normalize-space()!=''])"/> Einträge</p>
                <table>
                    <tr style="font-weight:bold">
                        <td>DAT</td>
                        <td>LOK</td>
                        <td>Ausstellungsort</td>
                        <td>REGEST</td>
                        <td>KUNSTHIST. BESCHREIBUNG</td>
                        <td>ARCHIV</td>
                        <td>LIT</td>
                        <td>Theoretischer Archivort</td>
                    </tr>
                    <xsl:for-each select="//row[not(cell[6]//@rend = 'Archivort') and cell[6]/normalize-space()!='']">
                        <tr>
                            <xsl:apply-templates/>
                            <td title="theoretischer Archivort"><xsl:value-of select="cell[6]/replace(., '^([^\s].*?),.*?$', '$1')"/></td>
                        </tr>
                    </xsl:for-each>
                </table>
                <h1 id="ohneArchivangaben">Ganz ohne Archivangaben</h1>
                <p><xsl:value-of select="count(//row[cell[6]/normalize-space()=''])"/> Einträge</p>
                <table>
                    <tr style="font-weight:bold">
                        <td>DAT</td>
                        <td>LOK</td>
                        <td>Ausstellungsort</td>
                        <td>REGEST</td>
                        <td>KUNSTHIST. BESCHREIBUNG</td>
                        <td>ARCHIV</td>
                        <td>LIT</td>
                        <td>Theoretischer Archivort</td>
                    </tr>
                    <xsl:for-each select="//row[cell[6]/normalize-space()='']">
                        <tr>
                            <xsl:apply-templates/>
                            <td title="theoretischer Archivort"><xsl:value-of select="cell[6]/replace(., '^([\S][\S]*?)( |,).*?$', '$1')"/></td>
                        </tr>
                    </xsl:for-each>
                </table>
            </body>
        </html>
    </xsl:template>
    <xsl:template match="cell">
        <td>
            <xsl:apply-templates/>
        </td>
    </xsl:template>
    <xsl:template match="p">
        <p class="{@rend}" title="{@rend}">
            <xsl:apply-templates/>
        </p>
    </xsl:template>
    <xsl:template match="hi">
        <span title="{@rend}" class="{@rend}" style="cursor:help">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="ref">
        <a href="{@target}">
            <xsl:apply-templates/>
        </a>
    </xsl:template>
</xsl:stylesheet>
