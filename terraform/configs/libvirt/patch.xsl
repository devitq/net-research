<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output omit-xml-declaration="yes" indent="yes" />
  <xsl:template match="node()|@*">
    <xsl:copy><xsl:apply-templates select="node()|@*" /></xsl:copy>
  </xsl:template>

  <xsl:template match="target[@bus='ide']">
    <xsl:copy>
      <xsl:apply-templates select="@*[name()!='bus']" />
      <xsl:attribute name="bus">sata</xsl:attribute>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="/domain">
    <xsl:copy>
      <xsl:apply-templates select="node()[not(self::os)] | @*" />
      <os firmware="efi">
        <type arch="{./os/type/@arch}" machine="{./os/type/@machine}">hvm</type>
      </os>
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>
