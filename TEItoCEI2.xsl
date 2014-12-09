<?xml version="1.0" encoding="UTF-8"?>
<!-- 2014-12-04 Author: GVogeler, maburg -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:t="http://www.tei-c.org/ns/1.0" xmlns:cei="http://www.monasterium.net/NS/cei"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs cei t" version="2.0">
    <xsl:output method="xml" indent="no" encoding="UTF-8" omit-xml-declaration="yes"/>
    <xsl:template match="/">

        <cei:cei xmlns:cei="http://www.monasterium.net/NS/cei">
            <!--            <cei:teiHeader>
                <cei:fileDesc>
                    <cei:titleStmt/>
                </cei:fileDesc>
            </cei:teiHeader>
-->
            <xsl:for-each select="/t:TEI/t:text[1]/t:body[1]/t:table[1]/t:row[position()>1]">
                <!-- FixMe: In die Attribute d¸rfen nur die Zahlen, nicht noch angeh‰ngte Texte.
                            Einleitende 0 sind auch noch zu entfernen.
                -->
                <xsl:variable name="from">
                    <xsl:if test="contains(t:cell[1], '-')">
                        <xsl:choose>
                            <xsl:when test="string-length(substring-before(t:cell[1], '-'))= 3">
                                <xsl:text>0</xsl:text>
                                <xsl:value-of select="substring-before(t:cell[1], '-')"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="substring-before(t:cell[1], '-')"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:if>
                    <xsl:if test="not(contains(t:cell[1], '-'))">
                        <xsl:value-of select="t:cell[1]"/>
                    </xsl:if>
                </xsl:variable>
                <xsl:variable name="monthandday">
                    <xsl:choose>
                        <xsl:when test="string-length(substring-after(t:cell[1], '-')) >= 5">
                            <xsl:choose>
                                <xsl:when test="contains(substring-after(t:cell[1], '-'), '_')">
                                    <xsl:value-of
                                        select="replace(replace(substring-after(t:cell[1], '-'), '-', ''), '_', '9')"
                                    />
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of
                                        select="replace(substring-after(t:cell[1], '-'), '-', '')"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:text>9999</xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>

                <xsl:variable name="date">
                    <xsl:value-of select="$from"/>
                    <xsl:value-of select="$monthandday"/>
                </xsl:variable>

                <!--
                    Es braucht ein paar Identifikatoren f¸r die Urkunde, die ich hier zusammenbaue und speichere
                -->
                <xsl:variable name="id">
                    <xsl:text>Illurk_</xsl:text>
                    <xsl:value-of select="position()"/>
                    <atom:id xmlns:atom="http://www.w3.org/2005/Atom"
                            >tag:www.monasterium.net,2011:/charter/illurk/Illurk_<xsl:value-of
                            select="position()"/></atom:id>
                    <cei:idno>
                        <xsl:value-of select="position()"/>
                    </cei:idno>
                    <xsl:for-each select="t:cell[7]/t:p[@rend='Monasterium-link']">
                        <mom>
                            <xsl:choose>
                                <xsl:when
                                    test="starts-with(normalize-space(.),'http://monasterium.net/')">
                                    <xsl:value-of
                                        select="replace(normalize-space(.),'http://www.monasterium.net/mom/(.*?)/charter','tag:www.monasterium.net,2011:/charter/$1')"
                                    />
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of
                                        select="replace(normalize-space(.),'http://www.mom-ca.uni-koeln.de/mom/(.*?)/charter','tag:www.monasterium.net,2011:/charter/$1')"
                                    />
                                </xsl:otherwise>
                            </xsl:choose>
                        </mom>
                    </xsl:for-each>
                </xsl:variable>

                <!-- *********************
    Und hier geht die eigentliche Konversion los: 
     *********************
-->
                <xsl:result-document href="illurk/{$id/text()}.charter.xml">
                    <atom:entry xmlns:atom="http://www.w3.org/2005/Atom">
                        <xsl:copy-of select="$id/atom:id"/>
                        <atom:title/>
                        <atom:published>
                            <xsl:value-of select="current-dateTime()"/>
                        </atom:published>
                        <atom:updated>
                            <xsl:value-of select="current-dateTime()"/>
                        </atom:updated>
                        <atom:author>
                            <atom:email>illuminierteurkunden@gmail.com</atom:email>
                        </atom:author>
                        <app:control xmlns:app="http://www.w3.org72007/app">
                            <app:draft>no</app:draft>
                        </app:control>

                        <xsl:if test="$id/mom">
                            <atom:link rel="versionOf" ref="{$id/mom/text()}"/>
                        </xsl:if>
                        <atom:content type="application/xml">
                            <!-- 
                            Ab hier dann das CEI:
                            -->
                            <cei:text xmlns:cei="http://www.monasterium.net/NS/cei" type="charter">
                                <xsl:attribute name="xml:id">
                                    <xsl:value-of select="$id/text()"/>
                                </xsl:attribute>
                                <cei:front>
                                    <cei:sourceDesc>
                                        <cei:sourceDescVolltext>
                                            <cei:bibl/>
                                        </cei:sourceDescVolltext>
                                        <cei:sourceDescRegest>Gabriele Bartz (Kunsthistorische
                                            Beschreibung), Markus Gneiﬂ (diplomatische Beschreibung)
                                            im Rahmen des FWF Projekts "Illuminierte
                                            Urkunden"</cei:sourceDescRegest>
                                    </cei:sourceDesc>
                                </cei:front>
                                <cei:body>
                                    <xsl:copy-of select="$id/cei:idno"/>
                                    <cei:chDesc>
                                        <cei:class/>
                                        <!-- Hier k‰me auf eigentlich die Urkundenart hinein -->
                                        <cei:abstract>
                                            <xsl:apply-templates select="t:cell[4]"/>
                                        </cei:abstract>
                                        <cei:issued>
                                            <cei:placeName>
                                                <xsl:value-of select="t:cell[3]"/>
                                            </cei:placeName>

                                            <cei:dateRange from="{$date}">

                                                <xsl:attribute name="to">
                                                  <xsl:choose>
                                                  <xsl:when
                                                  test="string-length(substring-after(t:cell[1], '-')) = 4">
                                                  <xsl:value-of
                                                  select="substring-after(t:cell[1], '-')"/>
                                                  <xsl:text>9999</xsl:text>
                                                  </xsl:when>
                                                  <xsl:otherwise>
                                                  <xsl:value-of select="$date"/>
                                                  </xsl:otherwise>
                                                  </xsl:choose>
                                                </xsl:attribute>
                                                <xsl:value-of select="t:cell[1]"/>
                                            </cei:dateRange>
                                        </cei:issued>
                                        <cei:witnessOrig>
                                            <cei:traditioForm>orig.</cei:traditioForm>
                                            <!-- FixMe: es gibt auch kopiale ‹berlieferungen, die vermutlich am Einleitungswort "kopial" in der Archiv-Spalte erkennbar sind. -->
                                            <xsl:choose>
                                                <xsl:when test="$id/mom">
                                                  <xsl:for-each select="$id/mom">
                                                  <xsl:copy-of
                                                  select="document(concat('http://monasterium.net/mom/atom/GET/metadata.charter.public/',substring-after(.,'tag:www.monasterium.net,2011:/charter/'),'.cei.xml'))//cei:witnessOrig/cei:figure"
                                                  />
                                                  </xsl:for-each>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                  <xsl:for-each
                                                  select="t:cell/t:p[@rend='LINK-ZU-BILD']">
                                                  <cei:figure>
                                                  <cei:graphic>
                                                  <xsl:attribute name="url">
                                                  <xsl:value-of select="t:ref"/>
                                                  </xsl:attribute>
                                                  </cei:graphic>
                                                  </cei:figure>
                                                  </xsl:for-each>
                                                  <xsl:if
                                                  test="not(t:cell/t:p[@rend='LINK-ZU-BILD'])">
                                                  <cei:figure/>
                                                  </xsl:if>
                                                  <!-- Hier kˆnnte man noch zus‰tzlich die Martinsche Bildersammlung auf 
                                                    images.monasterium.net/illum auswerten, also
                                                    <xsl:for-each select="document('http://images.monasterium.net/illum ...')//a[starts-with(.,substring-before(t:cell[1],'_'))]">
                                                        <cei:figure>
                                                            <cei:graphic>
                                                                <xsl:attribute name="url">
                                                                    <xsl:value-of select="@href"/>
                                                                </xsl:attribute>
                                                            </cei:graphic>
                                                        </cei:figure>
                                                    </xsl:for-each>
                                                    -->
                                                </xsl:otherwise>
                                            </xsl:choose>
                                            <cei:archIdentifier>
                                                <cei:settlement>
                                                  <xsl:value-of
                                                  select="t:cell[6]/t:*[@rend='Archivort']"/>
                                                </cei:settlement>
                                                <cei:arch>
                                                  <xsl:value-of
                                                  select="t:cell[6]/t:*[@rend='Archivname']"/>
                                                </cei:arch>
                                            </cei:archIdentifier>
                                            <cei:physicalDesc>
                                                <cei:decoDesc>
                                                  <xsl:apply-templates select="t:cell[5]"/>
                                                </cei:decoDesc>
                                                <cei:material/>
                                                <cei:dimensions/>
                                                <cei:condition/>
                                            </cei:physicalDesc>
                                            <cei:auth>
                                                <cei:notariusDesc/>
                                                <cei:sealDesc/>
                                            </cei:auth>
                                            <cei:nota/>
                                        </cei:witnessOrig>
                                        <cei:witListPar>
                                            <cei:witness>
                                                <cei:traditioForm/>
                                                <cei:figure/>
                                                <cei:archIdentifier/>
                                                <cei:physicalDesc>
                                                  <cei:material/>
                                                  <cei:dimensions/>
                                                  <cei:condition/>
                                                </cei:physicalDesc>
                                                <cei:auth>
                                                  <cei:sealDesc/>
                                                  <cei:notariusDesc/>
                                                </cei:auth>
                                                <cei:nota/>
                                            </cei:witness>
                                        </cei:witListPar>
                                        <cei:diplomaticAnalysis>
                                            <xsl:apply-templates
                                                select="t:cell/t:*[@rend='Beschreibung']"/>
                                            <cei:listBiblEdition>
                                                <cei:bibl/>
                                            </cei:listBiblEdition>
                                            <cei:listBiblRegest>
                                                <cei:bibl/>
                                            </cei:listBiblRegest>
                                            <cei:listBiblFaksimile>
                                                <cei:bibl/>
                                            </cei:listBiblFaksimile>
                                            <cei:listBiblErw>
                                                <cei:bibl/>
                                            </cei:listBiblErw>
                                            <cei:p/>
                                            <cei:quoteOriginaldatierung/>
                                            <cei:nota/>
                                        </cei:diplomaticAnalysis>
                                        <cei:lang_MOM/>
                                    </cei:chDesc>
                                    <cei:tenor/>
                                </cei:body>
                                <cei:back>
                                    <cei:persName/>
                                    <cei:placeName type="Region">
                                        <xsl:value-of select="t:cell[2]"/>
                                    </cei:placeName>
                                    <xsl:for-each select=".//t:*[@rend='UrkArt']">
                                        <cei:index type="Urkundenart">
                                            <xsl:value-of select="."/>
                                        </cei:index>
                                    </xsl:for-each>
                                    <xsl:if test="not(.//t:*[@rend='UrkArt'])">
                                        <cei:index/>
                                    </xsl:if>
                                    <cei:divNotes>
                                        <cei:note/>
                                    </cei:divNotes>
                                </cei:back>
                            </cei:text>
                        </atom:content>
                    </atom:entry>
                </xsl:result-document>
            </xsl:for-each>
        </cei:cei>
    </xsl:template>
    <xsl:template match="t:*[@rend='Beschreibung']">
        <cei:p>
            <xsl:apply-templates/>
        </cei:p>
    </xsl:template>
    <!--
        In der vierten Spalte steht das Regest
    -->
    <xsl:template match="t:cell[4]" priority="1">
        <xsl:choose>
            <xsl:when test="t:p">
                <xsl:apply-templates select="t:*[@rend='Regest']"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="t:*[@rend='Regest']">
        <xsl:if test="preceding-sibling::t:*[@rend='Regest']">
            <lb/>
        </xsl:if>
        <xsl:apply-templates/>
    </xsl:template>
    <!-- 
        Die f¸nfte Spalte enth‰lt die kunsthistorische Beschreibung
    -->
    <xsl:template match="t:cell[5]" priority="2">
        <xsl:if test="text() and text()/normalize-space(.)!=''">
            <cei:p>
                <xsl:value-of select="text()"/>
            </cei:p>
        </xsl:if>
        <xsl:for-each select="t:p[not(@rend='NIVEAU') and not(@rend='Autorensigle')]">
            <cei:p>
                <xsl:apply-templates/>
            </cei:p>
            <!-- Soll man hier schon probieren die Niveau-Schlagwˆrter im Text zu matchen?
                <xsl:variable name='niveau'>
                    <xsl:for-each select="*[@rend='NIVEAU']">
                        <niveau><xsl:value-of></xsl:value-of></niveau></xsl:for-each>
                </xsl:variable>
                ... Das geht erst aus, wenn ich auch Unterlemente in der Zelle mitbedenke
            <for-each select="text()">
            <xsl:value-of select="substring-before(.,$niveau/term)"/>
            <xsl:copy-of select="$niveau"></xsl:copy-of>
            <xsl:value-of select="substring-after(.,$niveau/term)"/>
            </for-each>
            -->
        </xsl:for-each>
        <xsl:if test="t:p[@rend='NIVEAU']">
            <cei:p>
                <xsl:apply-templates select="t:p[@rend='NIVEAU']"/>
            </cei:p>
        </xsl:if>
    </xsl:template>
    <xsl:template match="t:*[@rend='NIVEAU']" priority="1">
        <xsl:variable name="stringlist" select="tokenize(.,':')"/>


        <xsl:if test="preceding-sibling::t:*[@rend='NIVEAU']">
            <xsl:text> - </xsl:text>
        </xsl:if>
        <cei:index>
            <xsl:variable name="zeilenumbruch" select="."/>
            <xsl:attribute name="indexName">
                <xsl:value-of select="$stringlist[1]"/>
            </xsl:attribute>
            <xsl:attribute name="lemma">
                <xsl:value-of select="normalize-space($stringlist[2])"/>
            </xsl:attribute>
            <xsl:value-of select="normalize-space($stringlist[2])"/>
        </cei:index>

    </xsl:template>
    <!-- 
        In der letzten Spalte stehen Literaturangaben und Links auf Bilder, die ich ¸bergehe
    -->
    <xsl:template match="t:cell[7]" priority="1">
        <xsl:choose>
            <xsl:when test="not(t:cell[7]/t:p)">
                <cei:bibl>
                    <xsl:apply-templates/>
                </cei:bibl>
            </xsl:when>
            <xsl:otherwise>
                <!-- FixMe: Hier werden in Urkunde 2 (769-03-22) ganz viele bibl erzeugt. Warum?  -->
                <xsl:apply-templates/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="t:p[parent::t:cell = ancestor::t:row/t:cell[7]]" priority="-1">
        <cei:bibl>
            <xsl:apply-templates/>
        </cei:bibl>
    </xsl:template>
    <xsl:template match="t:ref">
        <cei:ref>
            <xsl:attribute name="target">
                <xsl:value-of select="normalize-space(.)"/>
            </xsl:attribute>
            <xsl:apply-templates/>
        </cei:ref>
    </xsl:template>

    <xsl:template match="t:hi[@rend='bold']">
        <cei:index type="bold">
            <xsl:value-of select="."/>
        </cei:index>
    </xsl:template>
    <xsl:template match="t:hi[@rend='italic']">
        <cei:quote type="italic">
            <xsl:value-of select="."/>
        </cei:quote>
    </xsl:template>
    <xsl:template match="t:p" priority="-2">
        <!--            <xsl:choose>
                <xsl:when test="following-sibling::t:p[@rend='Autorensigle']">
                    <xsl:attribute name="resp">
                        <xsl:value-of select="replace(.,'ß','')"/>
                    </xsl:attribute>
                    <xsl:apply-templates/>
                </xsl:when>
                <xsl:otherwise>
-->
        <xsl:element name="cei:p">
            <xsl:apply-templates/>
        </xsl:element>
        <!--</xsl:otherwise>
            </xsl:choose>-->
    </xsl:template>

    <!-- 
        Hier sammeln sich Templates, die bestimmte Elemente aus einer Default-Verarbeitung ausnehmen, weil sie explizit in for-each-Schleifen abgearbeitet werden.
        -->
    <xsl:template match="t:*[@rend='Autorensigle']|t:*[@rend='LINK-ZU-BILD']">
        <!-- Autorensigle ist ein Problem: Auf was bezieht sich die Angabe? Wenn sie als Zeichenformatvorlage in einem Absatz verwendet wird, dann kˆnnte man das handeln, als eigener Absatz kˆnnte man sie immer nur auf den vorherigen Absatz beziehen. -->
        <!--        <cei:p>
            <xsl:attribute name="resp">
                <xsl:value-of select="replace(.,'ß','')"/>
            </xsl:attribute>
            <xsl:value-of select="."/>
        </cei:p>
-->
    </xsl:template>

</xsl:stylesheet>

