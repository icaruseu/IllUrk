<?xml version="1.0" encoding="UTF-8"?>
<!-- Authors: GVogeler, maburg -->
<!-- ToDo:
        MOM-Links konsquent mit http:// davor vereinheitlichen?

        1417-04-21 => wie lautet der Bildname? Mit "April .??" ?
        Validierung:
        invalid tag: `class`. possible tags are: `Abstract (abstract)`, `issued (issued)`, `witnessOrig (witnessOrig)`, `Other textual witnesses (witListPar)`, `Diplomatic Analysis (diplomaticAnalysis)`, `language (lang_MOM)`
        
        Wie kann die Datumsangabe besser ausgelesen werden?
            Es sollte in der Short-List eigentlich keine undatierte Urkunde (mit 99999999) vorkommen

        Vor dem Import: 
        
        atom:id auf den gewünschen Bestandsnamen anpassen
        Vorbereitung der Bildverknüpfung:
            (Zuletzt 7.9., wenn seither kein neuer Bildupload auf http://images.monasterium.net/illum/IllUrk/ stattgefunden hat, dann kann das so bleiben) 
            1. Herunterladen von http://images.monasterium.net/illum/IllUrk/ 
            2. XMLisierung der Datei (//a/@href sollte den Bildnamen auf dem Server enthalten: http://images.monasterium.net/illum/IllUrk ... 
            3. Ablageort in variable $bildurl eintragn
    -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:t="http://www.tei-c.org/ns/1.0" xmlns:cei="http://www.monasterium.net/NS/cei"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs cei t" version="2.0">
    <xsl:output method="xml" indent="no" encoding="UTF-8" omit-xml-declaration="yes"/>
    <xsl:variable name="bildurl"><xsl:text>http://images.monasterium.net/illum/Bilder_illum_IllUrk.xml</xsl:text></xsl:variable>
    <xsl:variable name="collectionkürzel">IlluminierteUrkunde</xsl:variable>
    <xsl:variable name="ids">
        <!-- Um auf dublette IDs zu testen, brauche ich eine skriptinterne Repräsentation der Prä-IDs, die aus Datum und Archivort bestehen: -->
        <xsl:for-each select="//t:row[position() gt 1]">
            <!-- Der Archivort kann automatische generiert werden oder explizit benannt sein -->
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
                    <!-- Die ID sollte keine Sonderzeichen enthalten -->
                    <xsl:variable name="totransform">
                        <from><xsl:text>äöüßÄÖÜňřáàéèóòôúùâšíł ,.;:()[]+*#{}/–§$%&amp;"!?'’</xsl:text></from>
                        <to>aousAOUnraaeeooouuasil-</to>
                    </xsl:variable>
                    <xsl:value-of
                        select="t:cell[1]/(text()|t:*[1]//text())/translate(replace(
                            replace(.,'^([0123456789\-––_]+)([^0123456789\-––_][\s\S]*?$|$)','$1')
                        ,'[-––]', '-'),$totransform/from,$totransform/to)"/>
                    <xsl:choose>
                        <!--                        <xsl:when test="not(t:cell[6]//@rend = 'Archivort') and t:cell[6]/normalize-space()!=''">
                            <xsl:text>_</xsl:text><xsl:value-of select="t:cell[6]/replace(., '^([^\s].*?),.*?$', '$1')"/>
                        </xsl:when>-->
                        <xsl:when test="t:cell[6]/normalize-space()=''"/>
                        <xsl:otherwise>
                            <xsl:text>_</xsl:text><xsl:value-of select="$archivort/translate(normalize-space(replace(replace(replace(replace(replace(.,'ä','ae','i'),'Ö','Oe'),'ö','oe'),'ü','ue','i'),'ß','ss')),$totransform/from,$totransform/to)"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </id>
                <!-- Schon mal ein paar Zellen strukturieren. Brauchen wir das noch? -->
                <!-- ToDo: Erwischt das wirklich den Inhalt der ersten Spalte? -->
                <date>
                    <xsl:value-of select="t:cell[1]"/>
                </date>
                <datum>
                    <xsl:value-of select="t:cell[1]/(text()[1]|*[1]/text())[1]/translate(.,'–,;.?! ()','-')"/>
                </datum>
                <archiv>
                    <xsl:value-of select="t:cell[6]"/>
                </archiv>
            </row>
        </xsl:for-each>
    </xsl:variable>
    <xsl:variable name="bilder">
        <xsl:for-each
            select="document($bildurl)//a[(ends-with(@href, '.jpg') or ends-with(@href, '.jpeg') or ends-with(@href,'.gif') or ends-with(@href, '.png'))]">
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
    <xsl:template match="/">
        <xsl:result-document href="illurk/{$collectionkürzel}.mycollection.xml">
            <atom:entry xmlns:atom="http://www.w3.org/2005/Atom">
                <atom:id>tag:www.monasterium.net,2011:/mycollection/<xsl:value-of select="$collectionkürzel"/>/</atom:id>
                <atom:title>Illuminierte Urkunden</atom:title>
                <atom:published>2016-01-16T10:09:17.748+02:00</atom:published>
                <atom:updated>2016-01-16T16:09:17.748+02:00</atom:updated>
                <atom:author>
                    <atom:email>illuminierteurkunden@gmail.com</atom:email>
                </atom:author>
                <app:control xmlns:app="http://www.w3.org/2007/app">
                    <app:draft>no</app:draft>
                </app:control>
                <xrx:sharing xmlns:xrx="http://www.monasterium.net/NS/xrx">
                    <xrx:visibility>private</xrx:visibility>
                    <xrx:user/>
                </xrx:sharing>
                <atom:content type="application/xml">
                    <cei:cei xmlns:cei="http://www.monasterium.net/NS/cei">
                        <cei:teiHeader>
                            <cei:fileDesc>
                                <cei:titleStmt>
                                    <cei:title>Illuminierte Urkunden</cei:title>
                                </cei:titleStmt>
                                <cei:publicationStmt/>
                            </cei:fileDesc>
                        </cei:teiHeader>
                        <cei:text type="collection">
                            <cei:front>
                                <cei:div type="preface"/>
                            </cei:front>
                            <cei:group>
                                <cei:text type="collection" sameAs=""/>
                                <cei:text type="charter" sameAs=""/>
                            </cei:group>
                            <cei:back/>
                        </cei:text>
                    </cei:cei>
                </atom:content>
            </atom:entry>
        </xsl:result-document>
        <!--        <cei:cei xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
            xsi:schemaLocation="http://www.monasterium.net/NS/cei cei.xsd"
            xmlns:cei="http://www.monasterium.net/NS/cei">-->
        <cei:cei>
            <cei:teiHeader>
                <cei:fileDesc>
                    <cei:titleStmt/>
                </cei:fileDesc>
            </cei:teiHeader>
            <cei:text>
                <cei:group>
                    <xsl:for-each
                        select="/t:TEI/t:text[1]/t:body[1]/t:table[1]/t:row[position() > 1]">
                        <xsl:variable name="cell1Content">
                            <!-- Erster Schritt:
                                Das Datum kann in cell[1] direkt oder t:cell[1]/t:p[1] stehen 
                            Vereinfachen: t:cell[1]/(text()[1]|t:*[1]//text())/normalize-space()? -->
                            <xsl:choose>
                                <xsl:when test="t:cell[1]/t:p">
                                    <xsl:value-of select="t:cell[1]/t:*[1]/normalize-space(.)"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="t:cell[1]/normalize-space(.)"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>
                        <!-- Zweiter Schritt: Datum kann stehen vor:
                            einem Komma
                            einem Leerzeichen
                            einem geschützten Leerzeichen
                            einem §-Zeichen
                            einer Klammer
                            oder nach einer 0
                        -->
                        <xsl:variable name="cell1InterestingPart">
                            <xsl:choose>
                                <xsl:when test="contains($cell1Content/text(), 'asgdg')"/>
                                <xsl:when test="contains($cell1Content, ',')">
                                    <xsl:value-of select="substring-before($cell1Content, ',')"/>
                                </xsl:when>
                                <xsl:when test="contains($cell1Content, ' ')">
                                    <xsl:value-of select="substring-before($cell1Content, ' ')"/>
                                </xsl:when>
                                <xsl:when test="contains($cell1Content, '&#xA;')">
                                    <xsl:value-of select="substring-before($cell1Content, '&#xA;')"
                                    />
                                </xsl:when>
                                <xsl:when test="contains($cell1Content, '§')">
                                    <xsl:value-of select="substring-before($cell1Content, '§')"/>
                                </xsl:when>
                                <xsl:when test="contains($cell1Content, '(')">
                                    <xsl:value-of select="substring-before($cell1Content, '(')"/>
                                </xsl:when>
                                <xsl:when test="starts-with($cell1Content, '0')">
                                    <xsl:value-of select="substring-after($cell1Content, '0')"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="$cell1Content"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>
                        <!-- Dritter Schritt: Das Datum folgt einem Pattern -->
                        <xsl:variable name="cell1-als-zahl">
                            <xsl:value-of
                                select="replace(replace(replace(replace(normalize-space($cell1InterestingPart), ' ', ''), '_', '9'), '–', '-'), '([0-9_]{3,4})-([0-9_][0-9_])-([0-9_][0-9_])', '$1$2$3')"/>
                            <!-- Jetzt gibt es keine _ mehr und alle sieben/achtstelligen Angaben haben keine Bindestriche mehr  -->
                        </xsl:variable>
                        <xsl:variable name="date">
                            <xsl:choose>
                                <xsl:when test="matches($cell1-als-zahl, '^[0-9]{7,8}$')">
                                    <!-- Das erledigt schon mal alles, was einfach nur eine korrekte Datumsangabe enthält -->
                                    <from>
                                        <xsl:value-of select="$cell1-als-zahl"/>
                                    </from>
                                    <to>
                                        <xsl:value-of select="$cell1-als-zahl"/>
                                    </to>
                                </xsl:when>
                                <xsl:when test="matches($cell1-als-zahl, '^[0-9]{3,4}-[0-9]{3,4}$')">
                                    <from>
                                        <xsl:value-of
                                            select="substring-before($cell1-als-zahl, '-')"/>
                                        <xsl:text>9999</xsl:text>
                                    </from>
                                    <to>
                                        <xsl:value-of select="substring-after($cell1-als-zahl, '-')"/>
                                        <xsl:text>9999</xsl:text>
                                    </to>
                                </xsl:when>
                                <!-- Fälle mit 3-stelliger Jahreszahl -->
                                <xsl:when
                                    test="matches($cell1-als-zahl, '^[0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]$')">
                                    <from>
                                        <xsl:value-of select="replace($cell1-als-zahl, '-', '')"/>
                                    </from>
                                    <to>
                                        <xsl:value-of select="replace($cell1-als-zahl, '-', '')"/>
                                    </to>
                                </xsl:when>
                                <xsl:when test="matches($cell1-als-zahl, '^[0-9][0-9][0-9]-__-__$')">
                                    <from>
                                        <xsl:value-of
                                            select="replace(replace($cell1-als-zahl, '_', '9'), '-', '')"
                                        />
                                    </from>
                                    <to>
                                        <xsl:value-of
                                            select="replace(replace($cell1-als-zahl, '_', '9'), '-', '')"
                                        />
                                    </to>
                                </xsl:when>
                                <xsl:when test="matches($cell1-als-zahl, '^[0-9][0-9][0-9]-__$')">
                                    <from>
                                        <xsl:value-of
                                            select="replace(replace($cell1-als-zahl, '_', '9'), '-', '')"/>
                                        <xsl:text>99</xsl:text>
                                    </from>
                                    <to>
                                        <xsl:value-of
                                            select="replace(replace($cell1-als-zahl, '_', '9'), '-', '')"/>
                                        <xsl:text>99</xsl:text>
                                    </to>
                                </xsl:when>

                                <!-- Fälle mit 4-stelliger Jahreszahl -->
                                <xsl:when
                                    test="matches($cell1-als-zahl, '^[0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]$')">
                                    <from>
                                        <xsl:value-of
                                            select="substring-before($cell1-als-zahl, '-')"/>
                                    </from>
                                    <to>
                                        <xsl:value-of select="substring-after($cell1-als-zahl, '-')"
                                        />
                                    </to>
                                </xsl:when>
                                <xsl:when
                                    test="matches($cell1-als-zahl, '^[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]$')">
                                    <from>
                                        <xsl:value-of
                                            select="substring-before($cell1-als-zahl, '-')"/>
                                    </from>
                                    <to>
                                        <xsl:value-of select="substring-after($cell1-als-zahl, '-')"
                                        />
                                    </to>
                                </xsl:when>
                                <xsl:when test="not(contains($cell1-als-zahl, '-'))">
                                    <from>
                                        <xsl:value-of select="substring($cell1-als-zahl, 1, 4)"/>
                                        <xsl:text>9999</xsl:text>
                                    </from>
                                    <to>
                                        <xsl:value-of select="substring($cell1-als-zahl, 1, 4)"/>
                                        <xsl:text>9999</xsl:text>
                                    </to>
                                </xsl:when>
                                <!-- Das ist der Normalfall, falls noch was übrig ist von oben ... -->
                                <xsl:when
                                    test="matches($cell1-als-zahl, '^[0-9]{3,4}-[0-9][0-9]-[0-9][0-9]$')">
                                    <from>
                                        <xsl:value-of select="replace($cell1-als-zahl, '-', '')"/>
                                    </from>
                                    <to>
                                        <xsl:value-of select="replace($cell1-als-zahl, '-', '')"/>
                                    </to>
                                </xsl:when>
                                <xsl:when test="matches($cell1-als-zahl, '^[0-9]{3,4}-__-__$')">
                                    <from>
                                        <xsl:value-of
                                            select="replace(replace($cell1-als-zahl, '_', '9'), '-', '')"
                                        />
                                    </from>
                                    <to>
                                        <xsl:value-of
                                            select="replace(replace($cell1-als-zahl, '_', '9'), '-', '')"
                                        />
                                    </to>
                                </xsl:when>
                                <xsl:when test="matches($cell1-als-zahl, '^[0-9]{3,4}-__$')">
                                    <from>
                                        <xsl:value-of
                                            select="replace(replace($cell1-als-zahl, '_', '9'), '-', '')"/>
                                        <xsl:text>99</xsl:text>
                                    </from>
                                    <to>
                                        <xsl:value-of
                                            select="replace(replace($cell1-als-zahl, '_', '9'), '-', '')"/>
                                        <xsl:text>99</xsl:text>
                                    </to>
                                </xsl:when>
                                <xsl:otherwise>
                                    <from>99999999</from>
                                    <to>99999999</to>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>

                        <!--
                    Es braucht ein paar Identifikatoren für die Urkunde, die ich hier zusammenbaue und speichere
                -->
                        <xsl:variable name="pos" select="position()"/>
                        <xsl:variable name="id-core">
                            <xsl:value-of select="$ids/row[$pos]/id"/>
                            <!-- Dublettenkontrolle -->
                            <xsl:if test="count($ids/row/id[. = $ids/row[$pos]/id]) gt 1">
                                <xsl:text>_</xsl:text>
                                <xsl:value-of
                                    select="(count($ids/row[$pos]/id/preceding::id[. = $ids/row[$pos]/id]) + 1)"
                                />
                            </xsl:if>
                        </xsl:variable>
                        <xsl:variable name="id">
                            <xsl:value-of select="$id-core"/>
                            <atom:id xmlns:atom="http://www.w3.org/2005/Atom">tag:www.monasterium.net,2011:/charter/IlluminatedCharters/<xsl:value-of
                                    select="$id-core"/></atom:id>
                            <cei:idno>
                                <xsl:attribute name="id">
                                    <xsl:value-of select="$id-core"/>
                                </xsl:attribute>
                                <xsl:value-of select="$id-core"/>
                            </cei:idno>
                            <xsl:for-each select="t:cell[7]/t:p[@rend = 'Monasterium-link']">
                                <!-- FixMe: kann es wirklich mehrere monasterium-links geben? 
                                
                                Sonderfälle: MOM-Link ohne http:// behandeln? -->
                                <xsl:variable name="mona">
                                    <xsl:choose>
                                        <xsl:when
                                            test="matches(normalize-space(.), '^[\S]*?monasterium.net/mom/(.*?)/charter.*?$')">
                                            <xsl:value-of
                                                select="replace(normalize-space(.), '^.*monasterium.net/mom/(.*?)/charter.*?$', 'tag:www.monasterium.net,2011:/charter/$1')"
                                            />
                                        </xsl:when>
                                        <xsl:when test="matches(normalize-space(.),'^[\S]*?mom-ca.uni-koeln.de/mom/(.*?)/charter.*?$')">
                                            <xsl:value-of
                                                select="replace(normalize-space(.), '^.*.mom-ca.uni-koeln.de/mom/(.*?)/charter.*?$', 'tag:www.monasterium.net,2011:/charter/$1')"
                                            />
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:comment>"<xsl:value-of select="normalize-space(.)"/>" ist kein richtiger Monasterium-Link.</xsl:comment>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:variable>
                                <mom>
                                    <!-- maskieren von |, ( , ) für Atomlink-->
                                    <xsl:choose>
                                        <xsl:when
                                            test="contains($mona, '(') or contains($mona, ')') or contains($mona, '|')">
                                            <xsl:value-of
                                                select="replace(replace(replace($mona, '\(', '%28'), '\)', '%29'), '\|', '%7C')"
                                            />
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:value-of select="$mona"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </mom>
                                <archivort><xsl:value-of select="$ids/id[$pos]/archivort"/></archivort>
                            </xsl:for-each>
                        </xsl:variable>
                        <!-- 
                        ****************
                        Vorab die Sammlungsbeschreibung erzeugen
                        
                        Ggf. anpassen: Titel, Beschreibung (Beschreibung in escpatem HTML: &lt;p&gt; ...) etc.
                        ****************
                        -->
                        <!-- 
     *********************
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
                                <app:control xmlns:app="http://www.w3.org/2007/app">
                                    <app:draft>no</app:draft>
                                </app:control>

                                <!-- prüfen, ob atom:link monasterium-link ist -->
                                <xsl:if
                                    test="$id/mom[1]/contains(., 'monasterium.net') or $id/mom[1]/contains(., 'mom-ca')">
                                    <atom:link rel="versionOf" ref="{$id/mom[1]/text()}"/>
                                </xsl:if>

                                <atom:content type="application/xml">
                                    <!-- 
                            Ab hier dann das CEI:
                            -->
                                    <cei:text xmlns:cei="http://www.monasterium.net/NS/cei"
                                        type="charter">
                                        <xsl:attribute name="id">
                                            <xsl:value-of select="$id/text()"/>
                                        </xsl:attribute>
                                        <cei:front>
                                            <cei:sourceDesc>
                                                <cei:sourceDescVolltext>
                                                  <cei:bibl/>
                                                </cei:sourceDescVolltext>
                                                <cei:sourceDescRegest>
                                                    <cei:bibl>FWF Projekt P 26706-G21 "Illuminierte Urkunden"</cei:bibl>
                                                </cei:sourceDescRegest>
                                            </cei:sourceDesc>
                                        </cei:front>
                                        <cei:body>
                                            <xsl:copy-of select="$id/cei:idno"/>
                                            <cei:chDesc>
                                                <!-- <cei:class/>
                                                Hier käme auf eigentlich die Urkundenart hinein:
                                                FixMe: Schame anpassen -->
                                                <cei:abstract>
                                                  <xsl:apply-templates select="t:cell[4]"/><xsl:text xml:space="preserve"> </xsl:text>
                                                    <!-- Hier einen Defaultwert für die Verantwortlichkeit einfügen? -->
                                                </cei:abstract>
                                                <cei:issued>
                                                  <cei:placeName>
                                                      <xsl:value-of select="t:cell[3]"/>
                                                  </cei:placeName>
                                                  <cei:dateRange>
                                                      <xsl:attribute name="from" select="$date/from"/>
                                                      <xsl:attribute name="to" select="$date/to"/>
                                                      <xsl:value-of select="t:cell[1]"/>
                                                      <!-- FixMe: Achtung, das muß angepaßt werden für die erweiterten Dateumsangaben ("ca.", "§BG§", "kopial" ...): Versucht wäre, daß im ersten Absatz nur Datumsangaben stehen? Aber "ca" ist ein Problem ... -->
                                                  </cei:dateRange>
                                                </cei:issued>
                                                <cei:witnessOrig>
                                                  <cei:traditioForm>orig.</cei:traditioForm>
                                                  <!-- FixMe: es gibt auch kopiale Überlieferungen, die vermutlich am Einleitungswort "kopial" in der Archiv-Spalte erkennbar sind. -->
                                                  <xsl:for-each
                                                  select="t:cell[7]/t:p[@rend = 'LINK-ZU-BILD']">
                                                    <xsl:choose>
                                                       <xsl:when
                                                       test="($id/mom and .//text()[contains(., 'monasterium.net')])">
                                                            <cei:figure/>
                                                       </xsl:when>
                                                       <xsl:otherwise>
                                                            <cei:figure>
                                                                <cei:graphic>
                                                                    <xsl:attribute name="url">
                                                                    <!-- Hier wird zuerst das &amp; in der URL durch einen Beistrich übersetzt und dann wird ',' durch das richtige Zeichen ersetzt.
                                                                        Achtung, die Formatvorlage ist zum Kotzen, denn darin steht auch "(Bild)"
                                                                                    Nachdenken über dauerhafte Lösung...
                                                                                    Warum ist das überhaupt nötig?
                                                                               -->
                                                                    <!--                                                                      <xsl:value-of select="replace(translate(., '[&amp;]', '[,]'), '[,]', '%26')"/>                             -->
                                                                        <xsl:choose>
                                                                            <xsl:when test=".//t:ref[starts-with(.,'http')]"><xsl:value-of select=".//t:ref[starts-with(.,'http')]/normalize-space()"/></xsl:when>
                                                                            <xsl:when test=".//t:ref[starts-with(@target,'http')]"><xsl:value-of select=".//t:ref[starts-with(@target,'http')]/@target/normalize-space()"/></xsl:when>
                                                                            <xsl:otherwise><xsl:value-of select="normalize-space(.)"/></xsl:otherwise>
                                                                        </xsl:choose>
                                                                </xsl:attribute>
                                                                </cei:graphic>
                                                            </cei:figure>
                                                       </xsl:otherwise>
                                                    </xsl:choose>
                                                  </xsl:for-each>
                                                  <!-- Hier wird noch zusätzlich die Martinsche Bildersammlung auf 
                                                    images.monasterium.net/illum ausgewertet, also z.B.:
                                                  Nimm Dir das Verzeichnis der Illuminierten Urkunden auf dem monasterium-Server, vergleiche a@href mit dem Datum (=t:cell[1]) und schreiber die @href in ein graphic@url-Element 
                                                  -->
                                                    <xsl:variable name="datum" select="t:cell[1]/(text()[1]|*[1]/text())[1]/translate(normalize-space(.),'–,;.?! ()','-')"/>
                                                    <xsl:variable name="bild" select="$bilder/bild[datum=$datum]/url"/>
                                                    <xsl:for-each
                                                        select="$bild">
                                                        <cei:figure>
                                                            <cei:graphic>
                                                            <xsl:attribute name="url">
                                                                <xsl:value-of select="."/>
                                                            </xsl:attribute>
<!--                                                                    <xsl:value-of select="@href"/>-->
                                                            </cei:graphic>
                                                        </cei:figure>
                                                    </xsl:for-each>
                                                    <!-- FixMe: Die leere figure braucht es nur, wenn es auch kein element in der Martinschen Sammlung gibt: ist das so abgefangen? -->
                                                    <xsl:if test="not(t:cell[7]/t:p[@rend = 'LINK-ZU-BILD'] or $id/mom or $bild)">
                                                    <cei:figure/>
                                                  </xsl:if>

                                                  <cei:archIdentifier>
                                                      <xsl:apply-templates select="t:cell[6]"/>
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
                                                  <xsl:apply-templates select="t:cell[4]//t:p[@rend='Beschreibung']"/>
                                                  <xsl:for-each select="t:cell[6]//t:p[not(@rend or t:hi[matches(.,'Archiv')])]">
                                                      <cei:p><xsl:apply-templates/></cei:p>
                                                  </xsl:for-each>          
                                                  <xsl:apply-templates select="t:cell[7]"/>
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
                                            <xsl:for-each select=".//t:*[@rend = 'UrkArt-W' or @rend='Suchbegriff']">
                                                <cei:index type="Urkundenart">
                                                  <xsl:value-of select="."/>
                                                </cei:index>
                                            </xsl:for-each>
                                            <xsl:if test="not(.//t:*[@rend = 'UrkArt-W'])">
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
                </cei:group>
            </cei:text>
        </cei:cei>
    </xsl:template>
    <xsl:template match="t:*[@rend = 'Archivort']">
        <cei:settlement><xsl:value-of select="."/></cei:settlement>
    </xsl:template>
    <xsl:template match="t:*[@rend = 'Archivname']">
        <cei:arch><xsl:value-of select="."/></cei:arch>
    </xsl:template>
    <xsl:template match="t:*[@rend = 'Archivfonds']">
        <cei:archFond><xsl:value-of select="."/></cei:archFond>
    </xsl:template>
    <xsl:template match="t:*[@rend = 'Archivsignatur']">
        <cei:idno><xsl:value-of select="."/></cei:idno>
    </xsl:template>
    
    <xsl:template match="t:*[@rend = 'Beschreibung']">
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
                <xsl:apply-templates select="t:*[@rend = 'Regest']"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="text()" priority="-2">
        <xsl:value-of select="normalize-space(.)"/>
    </xsl:template>
    <xsl:template match="t:*[@rend = 'Regest']">
        <xsl:if test="preceding-sibling::t:*[@rend = 'Regest']">
            <cei:lb/>
        </xsl:if>
        <xsl:apply-templates/>
    </xsl:template>
    <!-- 
        Die fünfte Spalte enthält die kunsthistorische Beschreibung
    -->
    <xsl:template match="t:cell[5]" priority="2">
        <xsl:if test="text() and text()/normalize-space(.) != ''">
            <cei:p>
                <xsl:value-of select="text()/normalize-space(.)"/>
            </cei:p>
        </xsl:if>
        <xsl:for-each select="t:p[not(@rend = 'NIVEAU') and not(@rend = 'Autorensigle')]">
            <cei:p>
                <xsl:apply-templates select="*|@*"/>
            </cei:p>
            <!-- Soll man hier schon probieren die Niveau-Schlagwörter im Text zu matchen?
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
        <xsl:if test="t:p[@rend = 'NIVEAU']">
            <cei:p>
                <xsl:apply-templates select="t:p[@rend = 'NIVEAU']"/>
            </cei:p>
        </xsl:if>
    </xsl:template>
    <xsl:template match="@rend[.='Ekphrasis' or .='Stil und Einordnung']">
        <xsl:attribute name="n"><xsl:value-of select="."/></xsl:attribute>
    </xsl:template>
    <xsl:template match="t:*[@rend = 'NIVEAU']" priority="1">
        <xsl:variable name="stringlist" select="tokenize(., ':')"/>
        <xsl:if test="preceding-sibling::t:*[@rend = 'NIVEAU']">
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
    <!-- FixMe: Die sechste Spalte enthält die Archivanagaben und irgendwelchen Klump, den ich hier ausschließen muß
        Wie geht MOM prinzipiell mit nicht markiertem Text um?
    -->
    <xsl:template match="t:cell[6]//t:p">
        <xsl:if test="(@rend or t:hi[matches(.,'Archiv')])"><xsl:apply-templates/></xsl:if>
    </xsl:template>
    <!-- 
        In der letzten Spalte stehen Literaturangaben und Links auf Bilder, die ich übergehe
    -->
    <xsl:template match="t:cell[7]" priority="1">
        <cei:listBibl>
            <xsl:for-each select="node()[not(@rend='LINK-ZU-BILD')]|text()">
                <cei:bibl><xsl:apply-templates select="."/></cei:bibl>
            </xsl:for-each>
        </cei:listBibl>
    </xsl:template>

    <!-- 
        Es folgen generische templates
    -->
    <xsl:template match="t:ref">
        <cei:ref>
            <xsl:attribute name="target">
                <!--  Nachdenken über dauerhafte Lösung, vgl. cei:graphic... -->
                <xsl:value-of
                    select="normalize-space(replace(translate(., '[&amp;]', '[,]'), '[,]', '%26'))"
                />
            </xsl:attribute>
            <xsl:apply-templates/>
        </cei:ref>
    </xsl:template>
    <xsl:template match="t:p[@rend = 'Autorensigle']">
        <!-- Autorensigle ist ein Problem: Auf was bezieht sich die Angabe? Wenn sie als Zeichenformatvorlage in einem Absatz verwendet wird, dann könnte man das handeln, als eigener Absatz könnte man sie immer nur auf den vorherigen Absatz beziehen. -->
        <cei:p><xsl:text xml:space="preserve"> (</xsl:text><xsl:value-of select="replace(.,'§','')"/><xsl:text>)</xsl:text></cei:p>
    </xsl:template>
    
    <xsl:template match="t:hi[@rend = 'bold']">
        <cei:index type="bold">
            <xsl:value-of select="."/>
        </cei:index>
    </xsl:template>
    <xsl:template match="t:hi[@rend = 'italic']">
        <cei:quote type="italic">
            <xsl:value-of select="."/>
        </cei:quote>
    </xsl:template>
    <xsl:template match="t:hi" priority="-2">
        <xsl:apply-templates/><xsl:text xml:space="preserve"> </xsl:text>
    </xsl:template>
    
    <xsl:template match="t:p" priority="-2">
        <xsl:apply-templates/>
    </xsl:template>


    <!-- 
        Hier sammeln sich Templates, die bestimmte Elemente aus einer Default-Verarbeitung ausnehmen, weil sie explizit in for-each-Schleifen abgearbeitet werden.
        -->
    <xsl:template match="t:*[@rend = 'LINK-ZU-BILD']"/>
    

</xsl:stylesheet>
