<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:atom="http://www.w3.org/2005/Atom"
    xmlns:cei="http://www.monasterium.net/NS/cei"
    exclude-result-prefixes="xs"
    version="2.0">
    <!-- Diese Skript erzeugt aus einer Liste von atom:id Kopien der Urkunden, die Nebensammlungen mit Verweisen auf in MOM schon publizierte illuminierte Urkunden eingefügt werden-->
    <xsl:param name="subcollectionkürzel"/><!-- insert subcollection name -->
    <xsl:param name="untergruppe"/>
    <xsl:variable name="collection-name">Illuminierte Urkunden</xsl:variable>
    <xsl:template match="/">
        <xsl:result-document href="{$subcollectionkürzel}.mycollection.xml">
            <atom:entry xmlns:atom="http://www.w3.org/2005/Atom">
                <atom:id>tag:www.monasterium.net,2011:/mycollection/<xsl:value-of select="$subcollectionkürzel"/>/</atom:id>
                <atom:title><xsl:value-of select="$untergruppe"/></atom:title>
                <atom:published><xsl:value-of select="current-dateTime()"/></atom:published>
                <atom:updated><xsl:value-of select="current-dateTime()"/></atom:updated>
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
        <xsl:apply-templates select="//charter"/>
    </xsl:template>
    <xsl:template match="charter">
        <xsl:variable name="id-core" select="substring-after(./atom:id,'tag:www.monasterium.net,2011:/charter/IlluminierteUrkunden/')"/>
        <xsl:variable name="date">
            <from>99999999</from>
            <to>99999999</to>
        </xsl:variable>
        <xsl:result-document href="{$subcollectionkürzel}/{$id-core}.charter.xml">
            <atom:entry xmlns:atom="http://www.w3.org/2005/Atom">
                <atom:id>tag:www.monasterium.net,2011:/charter/<xsl:value-of select="$subcollectionkürzel"/>/<xsl:value-of select="$id-core"/></atom:id>
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
                <atom:link rel="versionOf" ref="{atom:id/text()}"/>
                <atom:content type="application/xml" src="{atom:id/text()}">
                    <cei:text xmlns:cei="http://www.monasterium.net/NS/cei" type="charter">
                        <xsl:attribute name="id">
                            <!--                            <xsl:value-of select="$id/text()"/>-->
                        </xsl:attribute>
                        <cei:front>
                            <cei:sourceDesc><cei:sourceDescVolltext><cei:bibl/></cei:sourceDescVolltext><cei:sourceDescRegest><cei:bibl>FWF Projekt P 26706-G21 "Illuminierte Urkunden"</cei:bibl></cei:sourceDescRegest></cei:sourceDesc>
                        </cei:front>
                        <cei:body>
                            <xsl:copy-of select="$id-core"/>
                            <cei:chDesc><cei:class/><cei:abstract/><cei:issued><cei:placeName/><xsl:copy-of select="./cei:dateRange"></xsl:copy-of></cei:issued><cei:witnessOrig><cei:traditioForm/><cei:figure/><cei:archIdentifier/><cei:physicalDesc><cei:decoDesc><cei:p/></cei:decoDesc><cei:material/><cei:dimensions/><cei:condition/></cei:physicalDesc><cei:auth><cei:notariusDesc/><cei:sealDesc/></cei:auth><cei:nota/></cei:witnessOrig><cei:witListPar><cei:witness><cei:traditioForm/><cei:figure/><cei:archIdentifier/><cei:physicalDesc><cei:material/><cei:dimensions/><cei:condition/></cei:physicalDesc><cei:auth><cei:sealDesc/><cei:notariusDesc/></cei:auth><cei:nota/></cei:witness></cei:witListPar><cei:diplomaticAnalysis><cei:listBibl><cei:bibl/></cei:listBibl><cei:listBiblEdition><cei:bibl/></cei:listBiblEdition><cei:listBiblRegest><cei:bibl/></cei:listBiblRegest><cei:listBiblFaksimile><cei:bibl/></cei:listBiblFaksimile><cei:listBiblErw><cei:bibl/></cei:listBiblErw><cei:p/><cei:quoteOriginaldatierung/><cei:nota/></cei:diplomaticAnalysis><cei:lang_MOM/></cei:chDesc><cei:tenor/>
                        </cei:body>
                        <cei:back><cei:persName/><cei:placeName/><cei:index/><cei:divNotes><cei:note/></cei:divNotes></cei:back>
                    </cei:text>
                    
                </atom:content>
            </atom:entry>
        </xsl:result-document>
    </xsl:template>
</xsl:stylesheet>