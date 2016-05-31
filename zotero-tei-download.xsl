<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:t="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs t"
    version="2.0">
    <xsl:output method="xml" indent="yes"/>
    <xsl:template match="/">
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
                        <t:p>extracted via https://api.zotero.org/groups/257864/items?format=keys from https://api.zotero.org/groups/257864/items/',@id,'?format=tei'</t:p>
                    </t:sourceDesc>
                </t:fileDesc>
                <t:revisionDesc>
                    <t:change>Version <xsl:value-of select="current-date()"/></t:change>
                </t:revisionDesc>
            </t:teiHeader>
            <t:text>
                <t:body>
                    <t:listBibl>
                        <xsl:apply-templates select="liste/bibl"/>
                    </t:listBibl>
                </t:body>
            </t:text>
        </t:TEI>
    </xsl:template>
    <xsl:template match="bibl">
        <xsl:copy-of select="document(concat('https://api.zotero.org/groups/257864/items/',@id,'?format=tei'))//t:biblStruct"/>
    </xsl:template>
</xsl:stylesheet>