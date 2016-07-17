<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:t="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs t" version="2.0">
    <xsl:output method="xml" indent="yes"/>
    <xsl:variable name="zotero-keys"
        select="tokenize(unparsed-text(/zotero-download/url), '\r?\n')"/>
    <xsl:template match="/">
        <xsl:result-document href="zotero-tei-download.xml">
            <t:TEI>
                <t:teiHeader>
                    <t:fileDesc>
                        <t:titleStmt>
                            <t:title>Download Zotero</t:title>
                        </t:titleStmt>
                        <t:publicationStmt>
                            <t:p>for internal use only</t:p>
                        </t:publicationStmt>
                        <t:sourceDesc>
                            <t:p>extracted via
                                https://api.zotero.org/groups/257864/items?format=keys from
                                https://api.zotero.org/groups/257864/items/',@id,'?format=tei'</t:p>
                        </t:sourceDesc>
                    </t:fileDesc>
                    <t:revisionDesc>
                        <t:change>Version <xsl:value-of select="current-date()"/></t:change>
                    </t:revisionDesc>
                </t:teiHeader>
                <t:text>
                    <t:body>
                        <t:listBibl>
                            <xsl:call-template name="bibl"/>
                        </t:listBibl>
                    </t:body>
                </t:text>
            </t:TEI>
        </xsl:result-document>
    </xsl:template>
    <xsl:template name="bibl">
        <xsl:for-each select="$zotero-keys">
            <xsl:copy-of
                select="document(concat('https://api.zotero.org/groups/257864/items/', ., '?format=tei'))//t:biblStruct"
            />
        </xsl:for-each>
    </xsl:template>
    <xsl:template match="bibl">
        <xsl:copy-of
            select="document(concat('https://api.zotero.org/groups/257864/items/', @id, '?format=tei'))//t:biblStruct"
        />
    </xsl:template>
</xsl:stylesheet>
