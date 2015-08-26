<?xml version="1.0" encoding="UTF-8"?>
<!-- 2014-12-15 Author: GVogeler, maburg -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:t="http://www.tei-c.org/ns/1.0" xmlns:cei="http://www.monasterium.net/NS/cei"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs cei t" version="2.0">
    <xsl:output method="xml" indent="no" encoding="UTF-8" omit-xml-declaration="yes"/>
    <xsl:variable name="ids">
        <xsl:for-each select="//t:row[position() gt 1]">
            <xsl:variable name="archivort" select=".//t:hi[@rend='Archivort'][1]/replace(replace(replace(replace(replace(text(),'ä','ae','i'),'Ö','Oe'),'ö','oe'),'ü','ue','i'),'ß','ss')/text()"/>
            <!-- FixMe: erzeugt leere Knoten statt Strings, deshalb wird die Variable vorläufig nicht verwendet -->
            <row n="{position()}">
                <id>
                    <xsl:value-of
                        select="t:cell[1]/(text()[1]|t:p[1])/replace(.,'^([0123456789\-––]*)[^0123456789\-––][\s\S]*?$','$1')"/>
                    <xsl:text>_</xsl:text>
                    <xsl:variable name="totransform"><xsl:text>äöüßÄÖÜňřáàéèóòôúùâší ,.;:()[]+*#{}/–§$%&amp;"!?' ’</xsl:text></xsl:variable>
                    <xsl:value-of
                        select=".//t:hi[@rend='Archivort'][1]/translate(normalize-space(.),$totransform,'aousAOUnraaeeooouuasi-')"
                    />
                    <!-- Apostroph, §$%&"!?
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
                    <xsl:for-each select="/t:TEI/t:text[1]/t:body[1]/t:table[1]/t:row[position()>1]">
                        <!-- FixMe: 1036–1073 (undatiert; Nachweis des Notars) wird nicht richtig in eine Datumsangabe umgewandelt -->
                        <xsl:variable name="cell1Content">
                            <!-- Erster Schritt:
                                Das Datum kann in cell[1] direkt oder t:cell[1]/t:p[1] stehen 
                            Vereinfachen: t:cell[1]//text()/normalize-space() -->
                            <xsl:choose>
                                <xsl:when test="t:cell[1]/t:p">
                                    <xsl:value-of select="t:cell[1]/t:p[1]/normalize-space(.)"/>
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
                                <xsl:when test="contains($cell1Content/text(),'asgdg')"></xsl:when>
                         <xsl:when test="contains($cell1Content, ',')">
                                    <xsl:value-of select="substring-before($cell1Content, ',')"/>
                                </xsl:when>
                                <xsl:when test="contains($cell1Content, ' ')">
                                    <xsl:value-of select="substring-before($cell1Content, ' ')"/>
                                </xsl:when>
                                <xsl:when test="contains($cell1Content,'&#xA;')">
                                    <xsl:value-of select="substring-before($cell1Content, '&#xA;')"/>
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
                                select="replace(replace(replace(replace(normalize-space($cell1InterestingPart), ' ', ''),'_','9'),'–','-'),'([0-9_]{3,4})-([0-9_][0-9_])-([0-9_][0-9_])','$1$2$3')"/>
                            <!-- Jetzt gibt es keine _ mehr und alle sieben/achtstelligen Angaben haben keine Bindestriche mehr  -->
                        </xsl:variable>
                        <xsl:variable name="date">
                            <xsl:choose>
                                <xsl:when test="matches($cell1-als-zahl,'^[0-9]{7,8}$')">
                                    <!-- Das erledigt schon mal alles, was einfach nur eine korrekte Datumsangabe enthält -->
                                    <from>
                                        <xsl:value-of select="$cell1-als-zahl"/>
                                    </from>
                                    <to>
                                        <xsl:value-of select="$cell1-als-zahl"/>
                                    </to>
                                </xsl:when>
                                <xsl:when test="matches($cell1-als-zahl,'^[0-9]{3,4}-[0-9]{3,4}$')">
                                    <from>
                                        <xsl:value-of select="substring-before($cell1-als-zahl,'-')"/>
                                        <xsl:text>9999</xsl:text>
                                    </from>
                                    <to>
                                        <xsl:value-of select="substring-after($cell1-als-zahl,'-')"/>
                                        <xsl:text>9999</xsl:text>
                                    </to>
                                </xsl:when>
                                <!-- Fälle mit 3-stelliger Jahreszahl -->
                                <xsl:when
                                    test="matches($cell1-als-zahl,'^[0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]$')">
                                    <from>
                                        <xsl:value-of select="replace($cell1-als-zahl, '-', '')"/>
                                    </from>
                                    <to>
                                        <xsl:value-of select="replace($cell1-als-zahl, '-', '')"/>
                                    </to>
                                </xsl:when>
                                <xsl:when test="matches($cell1-als-zahl,'^[0-9][0-9][0-9]-__-__$')">
                                    <from>
                                        <xsl:value-of
                                            select="replace(replace($cell1-als-zahl, '_','9'), '-', '')"
                                        />
                                    </from>
                                    <to>
                                        <xsl:value-of
                                            select="replace(replace($cell1-als-zahl, '_','9'), '-', '')"
                                        />
                                    </to>
                                </xsl:when>
                                <xsl:when test="matches($cell1-als-zahl,'^[0-9][0-9][0-9]-__$')">
                                    <from>
                                        <xsl:value-of
                                            select="replace(replace($cell1-als-zahl, '_','9'), '-', '')"/>
                                        <xsl:text>99</xsl:text>
                                    </from>
                                    <to>
                                        <xsl:value-of
                                            select="replace(replace($cell1-als-zahl, '_','9'), '-', '')"/>
                                        <xsl:text>99</xsl:text>
                                    </to>
                                </xsl:when>

                                <!-- Fälle mit 4-stelliger Jahreszahl -->
                                <xsl:when
                                    test="matches($cell1-als-zahl,'^[0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]$')">
                                    <from>
                                        <xsl:value-of select="substring-before($cell1-als-zahl,'-')"
                                        />
                                    </from>
                                    <to>
                                        <xsl:value-of select="substring-after($cell1-als-zahl,'-')"
                                        />
                                    </to>
                                </xsl:when>
                                <xsl:when
                                    test="matches($cell1-als-zahl,'^[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]$')">
                                    <from>
                                        <xsl:value-of select="substring-before($cell1-als-zahl,'-')"
                                        />
                                    </from>
                                    <to>
                                        <xsl:value-of select="substring-after($cell1-als-zahl,'-')"
                                        />
                                    </to>
                                </xsl:when>
                                <xsl:when test="not(contains($cell1-als-zahl, '-'))">
                                    <from>
                                        <xsl:value-of select="substring($cell1-als-zahl, 1,4)"/>
                                        <xsl:text>9999</xsl:text>
                                    </from>
                                    <to>
                                        <xsl:value-of select="substring($cell1-als-zahl, 1,4)"/>
                                        <xsl:text>9999</xsl:text>
                                    </to>
                                </xsl:when>
                                <!-- Das ist der Normalfall, falls noch was übrig ist von oben ... -->
                                <xsl:when
                                    test="matches($cell1-als-zahl,'^[0-9]{3,4}-[0-9][0-9]-[0-9][0-9]$')">
                                    <from>
                                        <xsl:value-of select="replace($cell1-als-zahl, '-', '')"/>
                                    </from>
                                    <to>
                                        <xsl:value-of select="replace($cell1-als-zahl, '-', '')"/>
                                    </to>
                                </xsl:when>
                                <xsl:when test="matches($cell1-als-zahl,'^[0-9]{3,4}-__-__$')">
                                    <from>
                                        <xsl:value-of
                                            select="replace(replace($cell1-als-zahl, '_','9'), '-', '')"
                                        />
                                    </from>
                                    <to>
                                        <xsl:value-of
                                            select="replace(replace($cell1-als-zahl, '_','9'), '-', '')"
                                        />
                                    </to>
                                </xsl:when>
                                <xsl:when test="matches($cell1-als-zahl,'^[0-9]{3,4}-__$')">
                                    <from>
                                        <xsl:value-of
                                            select="replace(replace($cell1-als-zahl, '_','9'), '-', '')"/>
                                        <xsl:text>99</xsl:text>
                                    </from>
                                    <to>
                                        <xsl:value-of
                                            select="replace(replace($cell1-als-zahl, '_','9'), '-', '')"/>
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
                            <!--<xsl:text>Illurk_</xsl:text>
                            <xsl:value-of select="position()"/>-->
                            <!-- Dublettenkontrolle -->
                            <xsl:if test="count($ids/row/id[.=$ids/row[$pos]/id]) gt 1">
                                <xsl:text>_</xsl:text><xsl:value-of select="(count($ids/row[$pos]/id/preceding::id[.=$ids/row[$pos]/id]) + 1)"></xsl:value-of>
                            </xsl:if>
                        </xsl:variable>
                        <xsl:variable name="id">
                            <xsl:value-of select="$id-core"/>
                            <atom:id xmlns:atom="http://www.w3.org/2005/Atom"
                                    >tag:www.monasterium.net,2011:/charter/illurk/Illurk_<xsl:value-of
                                    select="$id-core"/></atom:id>
                            <cei:idno>
                                <xsl:attribute name="id"><xsl:text>Illurk_</xsl:text><xsl:value-of select="position()"/></xsl:attribute>
                                <xsl:value-of select="position()"/>
                            </cei:idno>
                            <xsl:for-each select="t:cell[7]/t:p[@rend='Monasterium-link']">
                                <xsl:variable name="mona">
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
                                </xsl:variable>
                                <mom>
                                    <!-- maskieren von |, ( , ) für Atomlink-->
                                    <xsl:choose>
                                        <xsl:when test="contains($mona, '(') or contains($mona, ')') or contains($mona, '|')">
                                            <xsl:value-of select="replace(replace(replace($mona, '\(', '%28'), '\)', '%29'), '\|', '%7C')"/>
                                        </xsl:when>                                            
                                        <xsl:otherwise>
                                            <xsl:value-of select="$mona"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </mom>
                            </xsl:for-each>
                        </xsl:variable>

                        <!-- *********************
    Und hier geht die eigentliche Konversion los: 
     *********************-->

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
                               <xsl:if test="contains($id/mom, 'monasterium.net') or contains($id/mom, 'mom-ca')">
                                   <atom:link rel="versionOf" ref="{$id/mom/text()}"/>
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
                                                  <cei:bibl>Gabriele Bartz (Kunsthistorische Beschreibung), Markus Gneiß (diplomatische Beschreibung) im Rahmen des FWF Projekts "Illuminierte Urkunden"</cei:bibl>
                                                </cei:sourceDescRegest>
                                            </cei:sourceDesc>
                                        </cei:front>
                                        <cei:body>
                                            <xsl:copy-of select="$id/cei:idno"/>
                                            <cei:chDesc>
                                                <cei:class/>
                                                <!-- Hier käme auf eigentlich die Urkundenart hinein -->
                                                <cei:abstract>
                                                  <xsl:apply-templates select="t:cell[4]"/>
                                                </cei:abstract>
                                                <cei:issued>
                                                  <cei:placeName>
                                                  <xsl:value-of select="t:cell[3]"/>
                                                  </cei:placeName>

                                                  <cei:dateRange>
                                                  <xsl:attribute name="from" select="$date/from"/>

                                                  <xsl:attribute name="to" select="$date/to"/>


                                                  <xsl:value-of select="t:cell[1]"/>
                                                  </cei:dateRange>
                                                </cei:issued>
                                                <cei:witnessOrig>
                                                  <cei:traditioForm>orig.</cei:traditioForm>
                                                  <!-- FixMe: es gibt auch kopiale Überlieferungen, die vermutlich am Einleitungswort "kopial" in der Archiv-Spalte erkennbar sind. -->
                                                  <xsl:for-each
                                                  select="t:cell[7]/t:p[@rend='LINK-ZU-BILD']">
                                                  <xsl:choose>
                                                  <xsl:when
                                                  test="($id/mom and .//text()[contains(.,'monasterium.net')])">
                                                  <cei:figure/>
                                                  </xsl:when>
                                                  <xsl:otherwise>
                                                  <cei:figure>
                                           
                                                      <cei:graphic>
                                                          <xsl:attribute name="url">
                                                              <!-- Hier wird zuerst das &amp; in der URL durch einen Beistrich übersetzt und dann wird ',' durch das richtige Zeichen ersetzt.
                                                                  Nachdenken über dauerhafte Lösung...
                                                                  Warum ist das überhaupt nötig?
                                                             -->
<!--                                                                      <xsl:value-of select="replace(translate(., '[&amp;]', '[,]'), '[,]', '%26')"/>                                                                                                   -->
                                                              <xsl:value-of select="."/>
                                                          </xsl:attribute>
                                                      </cei:graphic>
                                                  </cei:figure>
                                                  </xsl:otherwise>
                                                  </xsl:choose>
                                                  </xsl:for-each>
                                                  <!-- Hier könnte man noch zusätzlich die Martinsche Bildersammlung auf 
                                                    images.monasterium.net/illum auswerten, also z.B.:
                                                  Nimm Dir das Verzeichnis der Illuminierten Urkunden auf dem monasterium-Server, vergleiche a@href mit dem Datum (=t:cell[1]) und schreiber die @href in ein graphic@url-Element 
                                                  
                                                  -->
                                                    <xsl:for-each select="document('http://images.monasterium.net/illum/Bilder_illum_IllUrk.xml')//a[starts-with(@href,concat('http://images.monasterium.net/illum/IllUrk/',substring-before(t:cell[1],'_'))) and (ends-with(@href,'.jpg') or ends-with(@href,'.png'))]">
                                                        <cei:figure>
                                                            <cei:graphic>
                                                                <xsl:attribute name="url">
                                                                    <xsl:value-of select="@href"/>
                                                                </xsl:attribute>
                                                            </cei:graphic>
                                                        </cei:figure>
                                                    </xsl:for-each>
                                                    <!-- FixMe: Die leere figure braucht es nur, wenn es auch kein element in der Martinschen Sammlung gibt. -->
                                                    <xsl:if test="not(t:cell[7]/t:p[@rend='LINK-ZU-BILD'] or $id/mom)">
                                                        <cei:figure/>
                                                    </xsl:if>
                                                    
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
                                                    <cei:listBiblEdition>
                                                        <xsl:apply-templates select="t:cell[7]"/>
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
                </cei:group>
            </cei:text>
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
    <xsl:template match="text()" priority="-2">
        <xsl:value-of select="normalize-space(.)"/>
    </xsl:template>
    <xsl:template match="t:*[@rend='Regest']">
        <xsl:if test="preceding-sibling::t:*[@rend='Regest']">
            <cei:lb/>
        </xsl:if>
        <xsl:apply-templates/>
    </xsl:template>
    <!-- 
        Die fünfte Spalte enthält die kunsthistorische Beschreibung
    -->
    <xsl:template match="t:cell[5]" priority="2">
        <xsl:if test="text() and text()/normalize-space(.)!=''">
            <cei:p>
                <xsl:value-of select="text()/normalize-space(.)"/>
            </cei:p>
        </xsl:if>
        <xsl:for-each select="t:p[not(@rend='NIVEAU') and not(@rend='Autorensigle')]">
            <cei:p>
                <xsl:apply-templates/>
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
        In der letzten Spalte stehen Literaturangaben und Links auf Bilder, die ich übergehe
    -->
    <xsl:template match="t:cell[7]" priority="1">
         <cei:listBiblEdition>
             <xsl:apply-templates />   
        </cei:listBiblEdition>
    </xsl:template>
    
    <xsl:template match="child::t:cell[7]/t:p">
        <cei:bibl>
            <xsl:apply-templates/>        
        </cei:bibl>
    </xsl:template>

    <xsl:template match="t:ref">
        <cei:ref>
            <xsl:attribute name="target">
                <!--  Nachdenken über dauerhafte Lösung, vgl. cei:graphic... -->
                <xsl:value-of select="normalize-space(replace(translate(., '[&amp;]', '[,]'), '[,]', '%26'))"/>   
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




    <!-- 
        Hier sammeln sich Templates, die bestimmte Elemente aus einer Default-Verarbeitung ausnehmen, weil sie explizit in for-each-Schleifen abgearbeitet werden.
        -->
    <xsl:template match="t:*[@rend='Autorensigle']|t:*[@rend='LINK-ZU-BILD']">
        <!-- Autorensigle ist ein Problem: Auf was bezieht sich die Angabe? Wenn sie als Zeichenformatvorlage in einem Absatz verwendet wird, dann könnte man das handeln, als eigener Absatz könnte man sie immer nur auf den vorherigen Absatz beziehen. -->
        <!--        <cei:p>
            <xsl:attribute name="resp">
                <xsl:value-of select="replace(.,'§','')"/>
            </xsl:attribute>
            <xsl:value-of select="."/>
        </cei:p>
-->
    </xsl:template>

</xsl:stylesheet>



