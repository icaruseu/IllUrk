<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:t="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs" version="2.0">
    <!-- 1. Herunterladen von http://images.monasterium.net/illum/IllUrk/ 
         2. XMLisierung der Datei und ablegen unter http://images.monasterium.net/illum/Bilder_illum_IllUrk.xml
         3. Dieses Skript ausführen
    -->
    <xsl:variable name="bilderurl"><xsl:text>file:/C:/Users/GV/Documents/Uni/HistInf/Urkunden/Monasterium/IlluminierteUrkunden/Import/Bilder_illum_IllUrk.xml<!--http://images.monasterium.net/illum/Bilder_illum_IllUrk.xml--></xsl:text></xsl:variable>
    <xsl:variable name="urkundenurl"><xsl:text>file:/Z:/eigene%20Dateien/Uni/HistInf/Urkunden/Monasterium/IlluminierteUrkunden/Import/Illuminierte-Urkunden-Liste-44_2015-01-27_%20Letztfassung-vor-Teilung.xml</xsl:text></xsl:variable>
    <xsl:variable name="bilder">
        <xsl:for-each
            select="document($bilderurl)//a[(ends-with(@href, '.jpg') or ends-with(@href, '.jpeg') or ends-with(@href,'.gif') or ends-with(@href, '.png'))]">
            <bild>
                <url>
                    <xsl:value-of select="@href"/>
                </url>
                <datum>
                    <xsl:value-of
                        select="substring-after(substring-before(@href,'_'),'http://images.monasterium.net/illum/Illurk/')"
                    />
                </datum>
            </bild>
        </xsl:for-each>
    </xsl:variable>
    <xsl:variable name="urkunden">
        <xsl:for-each select="//t:row[position() gt 1]">
            <urkunde n="position()">
                <datum>
                    <xsl:value-of select="t:cell[1]/(text()[1]|*[1]/text())[1]/translate(.,'–,;.?! ()','-')"/>
                </datum>
                <zelle1>
                    <xsl:copy-of select="t:cell[1]"/>
                </zelle1>
                <regest>
                    <xsl:copy-of select="t:cell[4]"></xsl:copy-of>
                </regest>
            </urkunde>
        </xsl:for-each>
    </xsl:variable>
    <xsl:template match="/">
        <html>
            <head>
                <title>Bildverknüpfung IllUrk</title>
            </head>
            <body>
                <h2>Bei Urkunden</h2>
                <p>Fett steht der Inhalt der Datumsspalte; In Klammern das vom Programm errechnete Datum; Wenn es Bilder gibt, dann stehen sie darunter</p>
                    <p><span style="color:red; font-weight:bold; cursor:help"
                        title="Achtung, Dublettengefahr">!! </span> = Achtung, Dublettengefahr</p>
                <p>Maus über dem Datum zeigt das Regest an.</p>
<p><a
    href="{$bilderurl}" target="_top">Aktuell verwendete Bilderliste</a></p>
                <hr/>
                <div id="UrkundenMitBild">
                    <nav><a href="#Urkundenohnebild">Urkunden ohne Bild</a> | <a
                        href="#bilderohnezuordnung">Bilder ohne Zuordnung</a> | <a
                            href="#UrkundenMitBild">Urkunden mit Bild</a></nav>                <h1><xsl:value-of select="count($urkunden/urkunde[datum/text()=$bilder/bild/datum/text()])"/> Urkunden mit Bildzuordnung</h1>
                <ol>
                    <xsl:for-each select="$urkunden/urkunde[datum/text()=$bilder/bild/datum/text()]">
                        <li>
                            <xsl:if test="count($urkunden/urkunde[datum/text()=current()/datum/text()]) gt 1"><span style="color:red; font-weight:bold; cursor:help" title="Achtung, Dublettengefahr">!! </span></xsl:if>
                            <span title="{regest}" style="cursor:help; font-weight:bold;"><xsl:apply-templates select="zelle1"/></span> (=> <xsl:value-of select="datum"/>) 
                            <xsl:if test="count($urkunden/urkunde[datum/text()=current()/datum/text()]) gt 1"><span style="font-size:10pt" class="regest">
                                <br/><xsl:value-of select="regest//text()"/></span></xsl:if>
                            <xsl:for-each select="$bilder/bild[datum=current()/datum]">
                                <br/><a href="{url}"><xsl:value-of select="url"/></a>
                            </xsl:for-each>
                        </li>
                    </xsl:for-each>
                </ol></div>

                <hr/>
                <div id="Urkundenohnebild">
                    <nav><a href="#Urkundenohnebild">Urkunden ohne Bild</a> | <a
                        href="#bilderohnezuordnung">Bilder ohne Zuordnung</a> | <a
                            href="#UrkundenMitBild">Urkunden mit Bild</a></nav> 
                    <h1><xsl:value-of select="count($urkunden/urkunde[not(datum/text()=$bilder/bild/datum/text())])"/> Urkunden ohne Bilder</h1>
                <ol>
                    <xsl:for-each
                        select="$urkunden/urkunde[not(datum/text()=$bilder/bild/datum/text())]">
                        <li><b><xsl:value-of select="zelle1"/></b> (=> <xsl:value-of select="datum"
                            />)
                            <span style="font-size:10pt" class="regest">
                                <br/><xsl:value-of select="regest//text()"/></span></li>
                    </xsl:for-each>
                </ol></div>
                <hr/>

                <div id="bilderohnezuordnung">
                    <nav><a href="#Urkundenohnebild">Urkunden ohne Bild</a> | <a
                        href="#bilderohnezuordnung">Bilder ohne Zuordnung</a> | <a
                            href="#UrkundenMitBild">Urkunden mit Bild</a></nav> 
                    <h1><xsl:value-of select="count($bilder/bild[not(datum/text() =$urkunden/urkunde/datum/text())])"/> Bilder ohne Urkunde</h1>
                    <ol>
                        <xsl:for-each
                            select="$bilder/bild[not(datum/text() =$urkunden/urkunde/datum/text())]">
                            <li>
                                <a href="{url}">
                                    <xsl:value-of select="url"/>
                                </a>
                            </li>
                        </xsl:for-each>
                    </ol>
                </div>
            </body>
        </html>
    </xsl:template>
    <xsl:template name="orig">
        <xsl:variable name="urk"
            select="concat('http://images.monasterium.net/illum/IllUrk/',t:cell[1]/(text()[1]|*[1]/text())[1])"/>
        <xsl:variable name="bild" select="$bilder/bild[datum/text()=current()/datum/text()]"/>
        <!--               <xsl:variable name="bild" select="$bilder//a[substring-before(@href, '_') = $urk and (ends-with(@href, '.jpg') or ends-with(@href, '.jpeg') or ends-with(@href,'.gif') or ends-with(@href, '.png'))]"/>-->
        <xsl:choose>
            <xsl:when test="t:cell[1]/(text()[1]|*[1]/text())[1]/normalize-space() != ''">
                <xsl:if
                    test="count(//t:cell[1][(text()[1]|*[1]/text())[1]=current()/(text()[1]|*[1]/text())[1]]) gt 1 and $bild//text()">
                    <span style="color:red; font-weight:bold; cursor:help"
                        title="Achtung, Dublettengefahr">!! </span>
                </xsl:if>
                <span title="{t:cell[4]}" style="cursor:help; font-weight:bold;"><xsl:value-of
                        select="t:cell[1]"/></span> (=> <xsl:value-of select="$urk"/>):<xsl:if
                    test="$bild//text()"><br/><span style="font-size:10pt" class="regest"
                            ><xsl:value-of select="t:cell[4]//text()"/></span></xsl:if>
                <xsl:for-each select="$bild">
                    <br/><a>
                        <xsl:attribute name="href">
                            <xsl:value-of select="@href"/>
                        </xsl:attribute>
                        <xsl:value-of select="@href"/>
                    </a>
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise><span style="color:red; font-weight:bold; cursor:help"
                    title="Achtung, Gefahr">!! </span> KEIN DATUM</xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="t:p">
        <xsl:apply-templates/><br/>
    </xsl:template>
</xsl:stylesheet>
