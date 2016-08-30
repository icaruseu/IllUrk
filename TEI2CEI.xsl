<?xml version="1.0" encoding="UTF-8"?>
<!-- Authors: GVogeler, maburg -->
<!-- 
    
    Stand 9.08.2016
    Hinzugefügte Funktionen für Zotero-Referenzen
    Hinzugefügte Funktion für Glossarkonkordanzausgleich
    Für Bildreferenz/-abgleich ".JPG" und <xsl:variable name="bild" select="$bilder/bild[datum=$cell1InterestingPart]/url"/>
    @rend="interne Notizen" aufgenommen: kommt in bibl und regest vor, 
    //text() wird mit normalize-space() verarbeitet
    Stand 10.05. geändert Variable zur Erstellung der atom:links
    Kursivsetzung wird übernommen: t:seg[@rend='italic'] hinzugefügt
    Datum in Atom ID  ohne Unterstriche ($id-core geändert)
    19.05. t:ref angepasst für Zotero, $zotlink umgebaut
    Untergruppen:
            Wenn $untergruppen benannt, dann 
                1. wird dafür eine Sammlungsbeschreibung angelegen
                2. für jede Urkunde in der Untergruppe eine Urkunde mit <atom:link rel="versionOf" ref="tag:www.monasterium.net,2011:/charter/{$collection-id}/{$charter-id}"/> und <atom:content src=""tag:www.monasterium.net,2011:/charter/{$collection-id}/{$charter-id}"> erzeugt
            Achtung, die Verweise werden immer nur auf öffentliche Urkunden aufgelöst, d.h. die Untergruppe zeigt mit .../my-collection erst etwas sinnvolles an, wenn die einschlägigen Urkunden der Hauptsammlung veröffentlicht sind.               
    
    ToDo:
        IDs gegen Gesamtliste testen!: 


   FixMe:
        IDs von Nachgeschobenen Dateien müssen gegen die schon in der DB vorhandenen IDs getestet werden: <xsl:if test="unparsed-text-available(concat('http://..../my-collection/',$id)"> ...</xsl:if> => Test gegen IDs, die um *_n erweitert sind gibt es noch nicht. Sicherheitshalber mit TEI2ID-test.xsl ausprobieren und bei Überschreibungswarnungen vorsichtig sein!
            
        MOM-Links konsequent mit http:// davor vereinheitlichen?

        1417-04-21 => wie lautet der Bildname? Mit "April .??" ?
        
        Validierung:
        invalid tag: `class`. possible tags are: `Abstract (abstract)`, `issued (issued)`, `witnessOrig (witnessOrig)`, `Other textual witnesses (witListPar)`, `Diplomatic Analysis (diplomaticAnalysis)`, `language (lang_MOM)`
        
        Wie kann die Datumsangabe besser ausgelesen werden?
            Es sollte in der Short-List eigentlich keine undatierte Urkunde (mit 99999999) vorkommen
            
        hi[@rend='UrkArt-W'] => cei:index @indexName="IllUrk-Urkundenarten" (oder doch nach cei:class?)
        
        Das mapping von <hi rend="Archivort"> zu <cei:settlement> ergibt schlechte Ergebnisse, weil oft nur "," oder " " in Element.
        Alle <hi rend="Archivort" xml:space="preserve">, </hi> im XML entfernt!
        Alle Klammern aus Autorensigle entfernt und Autorensiglen zusammengefasst im XML.

 === Vor dem Import: === 
        atom:id auf den gewünschen Bestandsnamen anpassen
        Vorbereitung der Bildverknüpfung:
            (Zuletzt 7.9., wenn seither kein neuer Bildupload auf http://images.monasterium.net/illum/IllUrk/ stattgefunden hat, dann kann das so bleiben) 
            1. Herunterladen von http://images.monasterium.net/illum/IllUrk/ 
            2. XMLisierung der Datei (//a/@href sollte den Bildnamen auf dem Server enthalten: http://images.monasterium.net/illum/IllUrk ... 
            3. Ablageort in variable $bildurl eintragn
            4. aktuelles Illurk-Vocabulary local ablegen (für skos Normalisierung)
            5. aktuelles Illurk-Glossar local ablegen (für skos Normalisierung)
            6. aktuelle Bischofsliste_Ablässe_valide.xml lokal ablegen
            7. TEI-Version von Zotero erzeugen (z.B. mit zotero-tei-download.xsl) und lokal unter zotero-tei-download.xml ablegen
            
            Untergruppen:
               Achtung, die Verweise werden immer nur auf öffentliche Urkunden aufgelöst, d.h. die Untergruppe zeigt mit .../my-collection erst etwas sinnvolles an, wenn die einschlägigen Urkunden der Hauptsammlung veröffentlicht sind.
    -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:t="http://www.tei-c.org/ns/1.0" xmlns:cei="http://www.monasterium.net/NS/cei"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs cei t" version="2.0">
    <xsl:output method="xml" indent="no" encoding="UTF-8" omit-xml-declaration="yes"/>
    <xsl:variable name="bildurl">
        <xsl:text>Bilderliste.html</xsl:text>
<!--        <xsl:text>http://images.monasterium.net/illum/Bilder_illum_IllUrk.xml</xsl:text>-->
    </xsl:variable>
    <xsl:variable name="collection-name">Illuminierte Urkunden</xsl:variable>
    <xsl:variable name="collectionkürzel" select="translate($collection-name,' -_/|&amp;.:,;#+*?!§$%()[]{}=@','')"/>
    <xsl:variable name="glossarkonkordanz" select="document('GlossarKonkordanz.xml')"/><!-- Achtung, ggf. Speicherort anpassen! -->
    <xsl:variable name="personen" select="document('Bischofsliste_Ablässe_valide.xml')"/><!-- Achtung, ggf. Speicherort anpassen! -->
    <xsl:variable name="zoteroexport" select="document('zotero-tei-download.xml')"/><!-- Achtung, ggf. Speicherort anpassen! -->
    <xsl:variable name="untergruppe">Illuminierte Urkunden - Frankreich<!-- Enthält einen Namen für Untergruppen, die als MOM-Verknüpfungen erzeugt werden sollen. Solange leer passiert nichts  --></xsl:variable>
    <xsl:variable name="subcollectionkürzel" select="translate($untergruppe,' -_/|&amp;.:,;#+*?!§$%()[]{}=@','')"/>

    <xsl:variable name="names">
        <xsl:for-each select="$personen//t:person">
            <xsl:copy>
                <xsl:copy-of select="@*|*"/>
                <name><xsl:value-of select="t:persName/translate(normalize-space(text()[1]),' ,;','')"/><xsl:text> von </xsl:text><xsl:value-of select="t:occupation[1]/t:placeName[1]/normalize-space(translate(text()[1],'()[]^$\|',''))"/></name><!-- Achtung, es gibt Personen mit mehrer Bischofsämtern, die alle abgearbeitet werden sollten -->
            </xsl:copy>
        </xsl:for-each>
    </xsl:variable>
    <xsl:variable name="ids">
        <!-- Um auf dublette IDs zu testen, brauche ich eine skriptinterne Repräsentation der Prä-IDs, die aus Datum und Archivort bestehen: -->
        <xsl:for-each select="//t:row[position() gt 1]">
            <!-- Der Archivort kann automatische generiert werden oder explizit benannt sein -->
            <xsl:variable name="archivort">
             <!-- <xsl:choose>
                    <xsl:when test="not(.//t:hi[@rend='Archivort'] and t:cell[6]/normalize-space()='')">
                        <xsl:value-of select="t:cell[6]/replace(., '^([^\s].*?),.*?$', '$1')"/>
                    </xsl:when>
                    <xsl:otherwise>-->
                        <xsl:value-of select=".//t:hi[@rend='Archivort'][1]"/>
                 <!--</xsl:otherwise>
                </xsl:choose>-->
            </xsl:variable>
            <row n="{position()}">               
                <id>
                    <!-- Die ID sollte keine Sonderzeichen enthalten -->
                    <xsl:variable name="totransform">
                        <from><xsl:text>äöüßÄÖÜňřáàéèóòôúùâšíł ,.;:()[]+*#{}/–§$%&amp;"!?'’</xsl:text></from>
                        <to>aousAOUnraaeeooouuasil-</to>
                    </xsl:variable>
                    <!-- Aufräumen des Datums für die ID -->
                    <xsl:value-of
                        select="t:cell[1]/(text()|t:*[1]//text())/replace(translate(replace(
                            replace(.,'^([0123456789\-––_]+)([^0123456789\-––_][\s\S]*?$|$)','$1')
                        ,'[-––]', '-'),$totransform/from,$totransform/to), '-__', '')"/>
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
            select="document($bildurl)//a[(ends-with(@href, '.jpg') or ends-with(@href, '.JPG') or ends-with(@href, '.jpeg') or ends-with(@href,'.gif') or ends-with(@href, '.png'))]">
            <bild>
                <url>
                    <xsl:value-of select="@href"/>
                </url>
                <datum>
                    <xsl:value-of
                        select="substring-after(substring-before(@href,'_'),'http://images.monasterium.net/illum/IllUrk/')"
                    />
                </datum>
            </bild>
        </xsl:for-each>
    </xsl:variable>
    <xsl:template match="/">
        <xsl:choose>
            <xsl:when test="not(//t:row[t:cell[1]/text()/normalize-space()!=''])">
                <Achtung><xsl:comment>Die Datei enthält eine erste Spalte ohne Inhalte. Bitte erst überprüfen, ob das so gewollt ist!</xsl:comment></Achtung>
            </xsl:when>
            <xsl:otherwise>
             <xsl:result-document href="{$collectionkürzel}.mycollection.xml">
                 <atom:entry xmlns:atom="http://www.w3.org/2005/Atom">
                     <atom:id>tag:www.monasterium.net,2011:/mycollection/<xsl:value-of select="$collectionkürzel"/>/</atom:id>
                     <atom:title>Illuminierte Urkunden</atom:title><!-- zum Testen von Illuminierte Urkunden geändert -->
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
                                         <cei:title><xsl:value-of select="$collection-name"/></cei:title>
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
                <!-- Ebenso für Untergruppe die Sammlungsbeschreibung: -->
                <xsl:if test="$untergruppe!=''">
                    <xsl:result-document href="{$subcollectionkürzel}.mycollection.xml">
                        <atom:entry xmlns:atom="http://www.w3.org/2005/Atom">
                            <atom:id>tag:www.monasterium.net,2011:/mycollection/<xsl:value-of select="$subcollectionkürzel"/>/</atom:id>
                            <atom:title><xsl:value-of select="$untergruppe"/></atom:title>                            <atom:published>2016-01-16T10:09:17.748+02:00</atom:published>
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
                            <xrx:keywords xmlns:xrx="http://www.monasterium.net/NS/xrx"><xrx:keyword>Illuminierte Urkunden</xrx:keyword></xrx:keywords>
                            <atom:content type="application/xml">
                                <cei:cei xmlns:cei="http://www.monasterium.net/NS/cei">
                                    <cei:teiHeader>
                                        <cei:fileDesc>
                                            <cei:titleStmt>
                                                <cei:title><xsl:value-of select="$untergruppe"/></cei:title>
                                            </cei:titleStmt>
                                            <cei:publicationStmt/>
                                        </cei:fileDesc>
                                    </cei:teiHeader>
                                    <cei:text type="collection">
                                        <cei:front>
                                            <cei:div type="preface">Diese Sammlung ist eine Teilmenge der Sammlung <xsl:value-of select="$collection-name"/></cei:div>
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
                </xsl:if>
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
                            <xsl:value-of select="replace(replace($ids/row[$pos]/id, '-__-__' , ''), '-___' ,'')"/>
                            <!-- Dublettenkontrolle -->
                            <!-- 1. Testen, ob die ID chon in der Hauptsammlung verwendet wird --><xsl:variable name="online" select="concat('http://www.monasterium.net/mom/',$collectionkürzel,'/',$ids/row[$pos]/id,'/charter')"/>
                            <xsl:variable name="Onlinevorhanden" select="unparsed-text-available($online)"/>
                            <xsl:variable name="Onlinevorhanden-Anzahl"><xsl:choose><xsl:when test="$Onlinevorhanden">1</xsl:when><xsl:otherwise>0</xsl:otherwise></xsl:choose></xsl:variable>
                            <!-- FixMe: Achtung, das testet nur, ob die Basis-URL schon vorhanden ist, nicht auf Dubletten schon im Ausgangsdatensatz -->
                            <xsl:if test="count($ids/row/id[. = $ids/row[$pos]/id]) gt 1 or $Onlinevorhanden">
                                <xsl:text>_</xsl:text>
                                <xsl:value-of
                                    select="(count($ids/row[$pos]/id/preceding::id[. = $ids/row[$pos]/id]) + 1 + $Onlinevorhanden-Anzahl)"
                                />
                            </xsl:if>
                        </xsl:variable>
                        <!-- id anpassen an collection name bei jedem Import aufpassen -->
                        <xsl:variable name="id">                          
                            <atom:id xmlns:atom="http://www.w3.org/2005/Atom">tag:www.monasterium.net,2011:/charter/IlluminierteUrkunden/<xsl:value-of
                                    select="$id-core"/></atom:id>                                                    <subcollectionID>
                               <atom:id xmlns:atom="http://www.w3.org/2005/Atom">tag:www.monasterium.net,2011:/charter/<xsl:value-of select="$subcollectionkürzel"/><xsl:text>/</xsl:text><xsl:value-of select="$id-core"/></atom:id>                                                                 </subcollectionID>
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
                                        <xsl:when test="matches(normalize-space(.),'^[\S]*?mom-ca.uni-koeln.de/mom/.*?monasterium.*?/charter.*?$')">
                                           
                                            <xsl:value-of
                                                select="replace(normalize-space(.), '^.*.mom-ca.uni-koeln.de/mom/(.*?/charter.*?$)', 'tag:www.monasterium.net,2011:/charter/$1')"
                                            />
                                        </xsl:when>
                                        <xsl:when test="matches(normalize-space(.),'^[\S]*?mom-ca.uni-koeln.de/mom/.*[^monasterium]?/charter.*?$')">
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
                      
                       
                     
                          
                      <xsl:result-document href="{$collectionkürzel}/{$id-core}.charter.xml">
                        <!--<xsl:result-document href="illurk/{$id/text()}.charter.xml">-->
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
                                                        <xsl:value-of select="t:cell[1]/normalize-space(.)"/>
                                                        <!-- FixMe: Achtung, das muß angepaßt werden für die erweiterten Dateumsangaben ("ca.", "§BG§", "kopial" ...): Versucht wäre, daß im ersten Absatz nur Datumsangaben stehen? Aber "ca" ist ein Problem ... -->
                                                    </cei:dateRange>
                                                </cei:issued>
                                                <cei:witnessOrig>
                                                    <cei:traditioForm>Original</cei:traditioForm>
                                                    <!-- FixMe: es gibt auch kopiale Überlieferungen, die vermutlich am Einleitungswort "kopial" in der Archiv-Spalte erkennbar sind. -->
                                                    <xsl:for-each
                                                        select="t:cell[7]/t:p[@rend = 'LINK-ZU-BILD']">
                                                        <xsl:sort select="concat(.//t:ref[1],.)"/>
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
                                                    <xsl:variable name="bild" select="$bilder/bild[datum=$cell1InterestingPart]/url"/>
                                                  <!--  <xsl:variable name="bild" select="$bilder/bild[datum=$datum]/url"/> hier Variable ersetzt, weil $datum noch text enthält-->
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
                                                    <cei:p><xsl:apply-templates select="t:cell[4]//t:p[@rend='Beschreibung']/following-sibling::t:*[@rend='Autorensigle'][1]"/></cei:p>
                                                    <!-- Bum: warum kommt was aus archiv info in dipomatic analysis? -->
                                                    <!--<xsl:for-each select="t:cell[6]//t:p[not(@rend or t:hi[matches(.,'Archiv')])]">
                                                        <cei:p><xsl:apply-templates/></cei:p>
                                                    </xsl:for-each>-->          
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
                                            <xsl:apply-templates select="t:cell[5]/t:p[@rend = 'NIVEAU']"/>
                                            <cei:divNotes>
                                                <cei:note/>
                                            </cei:divNotes>
                                        </cei:back>
                                    </cei:text>
                                </atom:content>
                            </atom:entry>
                    </xsl:result-document>
                      <!-- Ebenso für Untergruppe -->
                      <xsl:if test="$untergruppe != ''">
                          <xsl:result-document href="{$subcollectionkürzel}/{$id-core}.charter.xml">
                              <atom:entry xmlns:atom="http://www.w3.org/2005/Atom">
                                  <xsl:copy-of select="$id/subcollectionID/atom:id"/>
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
                                  <atom:link rel="versionOf" ref="{$id/atom:id/text()}"/>
                                  <atom:content type="application/xml" src="{$id/atom:id/text()}">
                                    <cei:text xmlns:cei="http://www.monasterium.net/NS/cei" type="charter">
                                        <xsl:attribute name="id">
                                            <xsl:value-of select="$id/text()"/>
                                        </xsl:attribute>
                                        <cei:front>
                                            <cei:sourceDesc><cei:sourceDescVolltext><cei:bibl/></cei:sourceDescVolltext><cei:sourceDescRegest><cei:bibl>FWF Projekt P 26706-G21 "Illuminierte Urkunden"</cei:bibl></cei:sourceDescRegest></cei:sourceDesc>
                                        </cei:front>
                                        <cei:body>
                                            <xsl:copy-of select="$id/cei:idno"/>
                                            <cei:chDesc><cei:class/><cei:abstract/><cei:issued><cei:placeName/><cei:dateRange>
                                                <xsl:attribute name="from" select="$date/from"/>
                                                <xsl:attribute name="to" select="$date/to"/>
                                                <xsl:value-of select="t:cell[1]/normalize-space(.)"/></cei:dateRange></cei:issued><cei:witnessOrig><cei:traditioForm/><cei:figure/><cei:archIdentifier/><cei:physicalDesc><cei:decoDesc><cei:p/></cei:decoDesc><cei:material/><cei:dimensions/><cei:condition/></cei:physicalDesc><cei:auth><cei:notariusDesc/><cei:sealDesc/></cei:auth><cei:nota/></cei:witnessOrig><cei:witListPar><cei:witness><cei:traditioForm/><cei:figure/><cei:archIdentifier/><cei:physicalDesc><cei:material/><cei:dimensions/><cei:condition/></cei:physicalDesc><cei:auth><cei:sealDesc/><cei:notariusDesc/></cei:auth><cei:nota/></cei:witness></cei:witListPar><cei:diplomaticAnalysis><cei:listBibl><cei:bibl/></cei:listBibl><cei:listBiblEdition><cei:bibl/></cei:listBiblEdition><cei:listBiblRegest><cei:bibl/></cei:listBiblRegest><cei:listBiblFaksimile><cei:bibl/></cei:listBiblFaksimile><cei:listBiblErw><cei:bibl/></cei:listBiblErw><cei:p/><cei:quoteOriginaldatierung/><cei:nota/></cei:diplomaticAnalysis><cei:lang_MOM/></cei:chDesc><cei:tenor/>
                                        </cei:body>
                                        <cei:back><cei:persName/><cei:placeName/><cei:index/><cei:divNotes><cei:note/></cei:divNotes></cei:back>
                                    </cei:text>
                            
                                  </atom:content>
                              </atom:entry>
                          </xsl:result-document>
                      </xsl:if>
                    </xsl:for-each>
                </cei:group>
            </cei:text>
        </cei:cei>
            </xsl:otherwise>
        </xsl:choose>
        <!-- Schreibe eine Liste der exportierten Dateien -->
            <xsl:result-document href="{$collectionkürzel}/index.html">
                <html><head><title><xsl:value-of select="$collectionkürzel"/></title></head>
                    <body>
                        <ul>
                            <xsl:for-each select="collection(concat($collectionkürzel,'/?select=*.charter.xml'))" >
                                <xsl:variable name="link">http://wwww.monasterium.net/mom/<xsl:value-of select="$collectionkürzel"/>/<xsl:value-of select="substring-before(tokenize(document-uri(.), '/')[last()], '.charter.xml')"/>/edit</xsl:variable>
                                <li>
                                    <a href="{$link}"><xsl:value-of select="$link"/></a>
                                </li>
                            </xsl:for-each>
                        </ul>
                    </body>
                </html>
            </xsl:result-document>
        
    </xsl:template>
   <!-- In gesamten Dokument normalize-space() -->
    <xsl:template match="text()" priority="-2">
        <xsl:choose><xsl:when test="ancestor-or-self::t:p[@rend='Regest']"><xsl:copy-of select="cei:findperson(replace(.,'\s+',' '))"/></xsl:when><xsl:otherwise><xsl:value-of select="replace(.,'\s+',' ')"/></xsl:otherwise></xsl:choose>
        <!-- ToDo: Das könnte durch eine Funktion geschickt werden, die aus einer Namen aus einer Personenliste extrahiert, diese im Text findet, und ihnen dann ein cei:persName mit entsprechendem @key zuweist. Relevant ist es nur für die Regesten .. -->
    </xsl:template>
    
    <xsl:function name="cei:findperson">
        <xsl:param name="text"/>
        <!-- Teste die Liste der Personennamensformen, die passen könnten -->
        <xsl:variable name="regex" select="cei:testperson($text)"/>
        <xsl:choose>
            <xsl:when test="$regex!=''">
<!--                <xsl:variable name="test">
                    <hit><xsl:value-of select="substring-before($text,$regex/treffer/text())"/><cei:persName key="#{$regex//@xml:id}"><xsl:value-of select="$regex/treffer/text()"/></cei:persName><xsl:value-of select="substring-after($text,$regex/treffer/text())"/></hit>
                </xsl:variable>-->
                <xsl:value-of select="substring-before($text,$regex/treffer[1]/text())"/><cei:persName key="#{string($regex/*[1]/@xml:id[1])}"><xsl:value-of select="$regex/treffer[1]/text()"/></cei:persName><xsl:value-of select="substring-after($text,$regex/treffer[1]/text())"/>
</xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="$text"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    <xsl:function name="cei:testperson">
        <xsl:param name="text"/>
        <xsl:for-each select="$names/t:person">
            <xsl:choose>
                <xsl:when test="matches($text,./name/text())">
                    <treffer><xsl:copy-of select="@xml:id"/>
                    <xsl:value-of select="./name/text()"/></treffer>
                </xsl:when>
            </xsl:choose>
        </xsl:for-each>
    </xsl:function>
    
    <!-- interne Notizen werden als Kommentar bereitgestellt -->
    <xsl:template match="t:*[@rend = 'Interne Notizen']">
        <xsl:comment>
            <xsl:value-of select="."/>
        </xsl:comment>        
    </xsl:template>    
    <xsl:template match="t:*[@rend = 'Archivort']">
       <!-- <xsl:if test="./parent::t:p/parent::t:cell[6] | ./parent::t:cell[6]">-->
            <cei:settlement><xsl:apply-templates/></cei:settlement>
        <!--</xsl:if>-->    
    </xsl:template>
    <xsl:template match="t:*[@rend = 'Archivname']">       
        <cei:arch><xsl:apply-templates/></cei:arch>        
    </xsl:template>
    <xsl:template match="t:*[@rend = 'Archivfonds']">
        <cei:archFond><xsl:apply-templates/></cei:archFond>
    </xsl:template>
    <xsl:template match="t:*[@rend = 'Archivsignatur']">
        <cei:idno><xsl:apply-templates/></cei:idno>
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
                <cei:lb/><xsl:apply-templates select="t:*[@rend='Autorensigle'][1]"/>
                <xsl:if test="t:p[@rend='Interne Notizen']">
                    <xsl:apply-templates select="t:p[@rend='Interne Notizen']" />
                </xsl:if>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates/>
            </xsl:otherwise>
        </xsl:choose>
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
    <xsl:choose>
        <xsl:when test="text() and text()/normalize-space(.) != ''">
            <cei:p>
                <xsl:apply-templates/>
            </cei:p>
        </xsl:when>
            <xsl:otherwise>
               <!-- <xsl:apply-templates/>-->
        <xsl:for-each select="t:p[not(@rend = 'NIVEAU')]">
            <cei:p>
                <xsl:apply-templates select="@*"/>
                <xsl:apply-templates/>
            </cei:p>          
        </xsl:for-each>
          </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="@rend[.='Ekphrasis' or .='Stil und Einordnung' or .='Autorensigle']">
        <xsl:attribute name="n"><xsl:value-of select="."/></xsl:attribute>
    </xsl:template>
    <xsl:template match="@rend" priority="-2"/>
    
    <xsl:template match="t:*[@rend = 'NIVEAU']" priority="1">
        <xsl:variable name="stringlist" select="normalize-space(.)"/>
<!--        <xsl:if test="preceding-sibling::t:*[@rend = 'NIVEAU']">
            <xsl:text> - </xsl:text>
        </xsl:if>-->
        <xsl:variable name="skos" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:atom="http://www.w3.org/2005/Atom">           
            <xsl:variable name="lemmawert">
                <xsl:value-of select="$stringlist"/>
            </xsl:variable>          
            <xsl:value-of select="document('illurk-vocabulary.xml')//skos:prefLabel[text()= $lemmawert]/parent::rdf:Description/@rdf:about"/>          
        </xsl:variable>
        <cei:index>
            <xsl:variable name="zeilenumbruch" select="."/>
            <xsl:attribute name="indexName">illurk-vocabulary</xsl:attribute>        
            <!-- lemma wird mit SKOS normalisiert und die '#' entfernt -->
            <xsl:attribute name="lemma">
                <xsl:value-of select="replace($skos, '#', '')"/>             
           </xsl:attribute>
            <xsl:value-of select="normalize-space($stringlist)"/>
        </cei:index>

    </xsl:template>
    <!-- FixMe: Die sechste Spalte enthält die Archivanagaben und irgendwelchen Klump, den ich hier ausschließen muß
        Wie geht MOM prinzipiell mit nicht markiertem Text um?
    -->
    <xsl:template match="t:cell[6]">
        <!-- bum: habe hier //p rausgenommen -->
       <!-- <xsl:if test="(@rend or t:hi[matches(.,'Archiv')])">-->
            <xsl:apply-templates/>
        <!--</xsl:if>-->
    </xsl:template>
    <!-- 
        In der letzten Spalte stehen Literaturangaben und Links auf Bilder, die ich übergehe
    -->
    <xsl:template match="t:cell[7]" priority="1">
        <cei:listBibl>
           <!-- <xsl:for-each select="node()[not(@rend='LINK-ZU-BILD')]|text()">-->
            <xsl:choose>
                <xsl:when test="t:p">
                    <xsl:for-each select="t:p[not(@rend='LINK-ZU-BILD')][not(@rend='Interne Notizen')]">
                        <xsl:call-template name="bibl"/>
                    </xsl:for-each>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="bibl"/>
                </xsl:otherwise>
            </xsl:choose>
            <!--</xsl:for-each>-->
        </cei:listBibl>
        <xsl:if test="t:p[@rend='Interne Notizen']">
            <xsl:apply-templates select="t:p[@rend='Interne Notizen']" />
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="bibl">
        <xsl:variable name="zotero">
            <!-- Zotero-Link ermitteln -->            
            <xsl:choose>     
                
            <xsl:when test="matches(text()[1],'[A-z]') and not(.//t:ref[contains(@target,'zotero')])">
               
                <xsl:variable name="shortest" select="normalize-space(translate(substring-before(./text()[1],','),'()-&amp;:;-_?![]',''))"/>
                <short><xsl:value-of select="$shortest"/></short>
                <xsl:if test="$shortest!=''">
                    <xsl:variable name="test" select="$zoteroexport//t:biblStruct[.//t:title[@type='short']/starts-with(.,$shortest)]"/>
                    <xsl:variable name="me" select="current()"/>
                    <xsl:variable name="t2" select="$test[.//t:title[matches($me,.)]]"/>
                    <xsl:variable name="zotlink">
                        <xsl:choose>
                            <!-- FixMe: Ich bräuchte eigentlich mehr als nur $shortest http://zotero.org/groups/257864/items/7VDGF2FQ-->
                            <xsl:when test="$t2">
                                <xsl:value-of select="$t2/@corresp"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:variable name="zotjson" select="unparsed-text(concat('https://api.zotero.org/groups/257864/items?q=',$shortest))"/>
                                <xsl:if test="not($zotjson='' or $zotjson='[]')">                                   
                                    <xsl:value-of select="cei:zotero(.,1,document(concat('https://api.zotero.org/groups/257864/items?q=',$shortest,'&amp;format=tei')))"/>
                                </xsl:if>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <zotlink><xsl:value-of select="$zotlink"/></zotlink>
                    <key><xsl:value-of select="replace($zotlink,'^http://zotero.org/groups/257864/items/([A-Z0-9]+).*?$','zotero:$1')"/></key>
                    <referenz><xsl:text> (</xsl:text><cei:ref target="{$zotlink}">Volltitel auf Zotero</cei:ref><xsl:text>)</xsl:text></referenz> <!-- kann das cei element nicht in variablen rausspielen -->                   
                </xsl:if>
            </xsl:when>           
            </xsl:choose>
        </xsl:variable>
        <cei:bibl>           
            <xsl:if test="$zotero/key/text()">
                <xsl:attribute name="key" select="$zotero/key"/>                
            </xsl:if>           
            <xsl:apply-templates/>
            <xsl:if test="$zotero/zotlink/text()">
                <xsl:text> (</xsl:text><cei:ref><xsl:attribute name="target"><xsl:value-of select="$zotero/zotlink"/></xsl:attribute>Volltitel auf Zotero</cei:ref><xsl:text>)</xsl:text>
            </xsl:if>
        </cei:bibl>
    </xsl:template>

    <!-- Zotero-Funktion -->
    <xsl:function name="cei:zotero">
        <xsl:param name="suche"/>
        <xsl:param name="position"/>
        <xsl:param name="zotero"/>
        <!-- Zotero-Bibliographie:
                        ./text()[1] nehmen
                        in Wörter zerlegen
                        Durchtesten ab mindestens 3 Wörter, bis genau 1 Treffer aus Zotero zurückkommt.
                    -->
        <xsl:variable name="short">
            <xsl:for-each select="tokenize($suche,' ')">
                <xsl:if test="position() lt ($position + 1)">
                    <xsl:if test="position() gt 1"><xsl:text> </xsl:text></xsl:if><xsl:value-of select="."/>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="zottreffer" select="$zotero/t:listBibl/t:biblStruct[.//t:title[@type='short'][contains(.,$short)]]"/>
        <xsl:choose>
            <xsl:when test="count($zottreffer) gt 1">
                <xsl:value-of select="cei:zotero($suche,($position + 1), $zotero)"/>
            </xsl:when>
            <xsl:when test="count($zottreffer) = 1">
                <xsl:value-of select="$zottreffer/@corresp"/>
            </xsl:when>
        </xsl:choose>
    </xsl:function>

    <!-- 
        Es folgen generische templates
    -->
    <xsl:template match="t:ref">
        <cei:ref>
            <xsl:attribute name="target">
                <!--  Nachdenken über dauerhafte Lösung, vgl. cei:graphic... -->
                <xsl:value-of
                    select="normalize-space(replace(translate(./@target, '[&amp;]', '[,]'), '[,]', '%26'))"
                />
            </xsl:attribute>
            <xsl:apply-templates/>
        </cei:ref>
    </xsl:template>
   <!-- Autorensigle wird schon an anderer Stelle transformiert <xsl:template match="t:p[@rend = 'Autorensigle']">
        <cei:p><xsl:text xml:space="preserve"> (</xsl:text><xsl:value-of select="replace(.,'§\(\)','')"/><xsl:text>)</xsl:text></cei:p>
    </xsl:template>-->
    
    <xsl:template match="t:hi[@rend = 'bold']">
        <cei:index>
            <!--<xsl:if test="preceding-sibling::text()[1]/ends-with(.,'*') and following-sibling::text()[1]/starts-with(.,'*')">-->
                <xsl:attribute name="indexName">IllUrkGlossar</xsl:attribute>
            <!-- ToDo: Hier eine Funktion einbauen, die den aktuellen Glossarbegriff mit der Glossarkonkordanz in ein existierendes Lemma umwandelt -->
                <xsl:copy-of select="cei:lemmakontrolle(.)"/>
        </cei:index>
    </xsl:template>

    <xsl:function name="cei:lemmakontrolle">
        <xsl:param name="knoten"/>
        <!-- Teste, ob normalizedtext in $glossarkonkordanz/orig vorkommt -->
        <xsl:variable name="glossarentry" select="$glossarkonkordanz//entry[orig=$knoten/text()[1]/normalize-space()]"/>
        <xsl:attribute name="lemma"><xsl:text>#</xsl:text><xsl:value-of select="replace(replace(replace(replace(replace(replace(replace(replace($glossarentry/normalized, 'ä', 'ae'), 'ß', 'ss'), 'ö', 'oe'), 'ü', 'ue'), 'é', 'e'), ' ', ''), '&#xA;', ''), '-', '')"/></xsl:attribute>           
        <xsl:choose>
            <xsl:when test="$glossarentry/@action='replace'"><xsl:apply-templates select="$glossarentry/normalized"/></xsl:when>
            <xsl:otherwise><xsl:apply-templates select="$knoten/(*|text())"/></xsl:otherwise>
        </xsl:choose>
    </xsl:function>
        
    <xsl:template match="t:hi[@rend='UrkArt-W'][ancestor::t:cell[@rend='Regest']/child::t:p[1]/t:hi = current()]">       
            <cei:index>
                <xsl:attribute name="indexName">Illurk-Urkundenart</xsl:attribute>
                <xsl:apply-templates/>
            </cei:index><!--<xsl:text xml:space="preserve"> </xsl:text>-->
    </xsl:template>
    <xsl:template match="t:hi[@rend = 'italic'] | t:seg[@rend = 'italic']">
        <cei:quote type="italic">
            <xsl:apply-templates/>
        </cei:quote>
    </xsl:template>
    <xsl:template match="t:hi[@rend='Hyperlink'][normalize-space(.)!='']">
        <cei:ref target="{normalize-space(.)}"><xsl:apply-templates/></cei:ref>
    </xsl:template>
    <xsl:template match="t:hi" priority="-2">
        <xsl:apply-templates/><xsl:text xml:space="preserve"> </xsl:text>
    </xsl:template>
    
    <xsl:template match="t:p" priority="-2">
<!--        <xsl:apply-templates select="@*"/>-->
        <xsl:apply-templates/>
    </xsl:template>


    <!-- 
        Hier sammeln sich Templates, die bestimmte Elemente aus einer Default-Verarbeitung ausnehmen, weil sie explizit in for-each-Schleifen abgearbeitet werden.
        -->
    <xsl:template match="t:*[@rend = 'LINK-ZU-BILD']"/>
   

</xsl:stylesheet>