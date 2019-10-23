<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
  xmlns="http://www.loc.gov/mods/v3" xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:xlink="http://www.w3.org/1999/xlink" exclude-result-prefixes="mods xlink">

  <xsl:output media-type="text/xml" method="xml" indent="yes"/>
  <xsl:strip-space elements="*"/>

  <!-- ======================================================================= -->
  <!-- PARAMETERS                                                              -->
  <!-- ======================================================================= -->

  <xsl:param name="diagnostics" select="'false'"/>

  <!-- ======================================================================= -->
  <!-- GLOBAL VARIABLES                                                        -->
  <!-- ======================================================================= -->

  <!-- program name -->
  <xsl:variable name="progname">
    <xsl:text>mods2solr.xsl</xsl:text>
  </xsl:variable>

  <!-- program version -->
  <xsl:variable name="version">
    <xsl:text>0.1 beta</xsl:text>
  </xsl:variable>

  <!-- new line -->
  <xsl:variable name="nl">
    <xsl:text>&#xa;</xsl:text>
  </xsl:variable>

  <!-- ======================================================================= -->
  <!-- UTILITIES / NAMED TEMPLATES                                             -->
  <!-- ======================================================================= -->

  <!-- ======================================================================= -->
  <!-- MAIN OUTPUT TEMPLATE                                                    -->
  <!-- ======================================================================= -->

  <xsl:template match="/">
    <add>
      <xsl:apply-templates select="//*:mods"/>
    </add>
  </xsl:template>

  <!-- ======================================================================= -->
  <!-- MATCH TEMPLATES FOR ELEMENTS                                            -->
  <!-- ======================================================================= -->

  <xsl:template match="*:mods">
    <doc>
      <field name="originalMetadataType">MODS</field>
      <xsl:apply-templates/>
    </doc>
  </xsl:template>

  <xsl:template match="*:mods/*:abstract">
    <field name="summary">
      <xsl:value-of select="normalize-space(.)"/>
    </field>
  </xsl:template>

  <xsl:template match="*:mods/*:accessCondition[@type = 'restrictionOnAccess']">
    <field name="accessRestrict">
      <xsl:value-of select="normalize-space(.)"/>
    </field>
  </xsl:template>

  <xsl:template match="*:mods/*:genre">
    <field name="workType">
      <xsl:value-of select="normalize-space(.)"/>
    </field>
  </xsl:template>

  <xsl:template match="*:mods/*:identifier">
    <field name="otherIdentifier">
      <xsl:value-of select="normalize-space(.)"/>
    </field>
  </xsl:template>

  <xsl:template match="*:mods/*:location">
    <!--<field name="originals">
      <xsl:value-of select="normalize-space(string-join(*:physicalLocation, ', '))"/>
      <!-\-<xsl:if test="ancestor::*:mods/*:relatedItem[@type = 'series']">
        <xsl:for-each select="ancestor::*:mods/*:relatedItem[@type = 'series']">
          <xsl:value-of
            select="concat(', ', normalize-space(concat(*:titleInfo/*:nonSort, ' ', *:titleInfo/*:title)))"
          />
        </xsl:for-each>
      </xsl:if>-\->
      <xsl:if test="ancestor::*:mods/*:identifier[matches(@displayLabel, 'retrieval ID', 'i')]">
        <xsl:value-of
          select="concat(', ', ancestor::*:mods/*:identifier[matches(@displayLabel, 'retrieval ID', 'i')])"
        />
      </xsl:if>
      <xsl:for-each select="*:shelfLocator">
        <xsl:text>,&#32;</xsl:text>
        <xsl:value-of select="normalize-space(.)"/>
      </xsl:for-each>
    </field>--> </xsl:template>

  <xsl:template match="*:mods/*:note">
    <field name="note">
      <xsl:value-of select="normalize-space(.)"/>
    </field>
  </xsl:template>

  <!--<xsl:template
    match="*:mods/*:note[matches(@type, '(handwritten|exhibitions|local|numbering|reproduction|system details|thesis|version identification|language)')]">
    <field name="note">
      <xsl:value-of select="normalize-space(.)"/>
    </field>
  </xsl:template>-->

  <xsl:template match="*:mods/*:originInfo">
    <xsl:choose>
      <xsl:when test="*:dateCreated">
        <field name="creationDate">
          <xsl:for-each select="*:dateCreated">
            <xsl:if test="position() != 1">
              <xsl:text>-</xsl:text>
            </xsl:if>
            <xsl:value-of select="normalize-space(.)"/>
          </xsl:for-each>
        </field>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="*:mods/*:physicalDescription/*:digitalOrigin">
    <field name="digitalOrigin">
      <xsl:value-of select="normalize-space(.)"/>
    </field>
  </xsl:template>

  <xsl:template match="*:mods/*:physicalDescription/*:internetMediaType">
    <field name="internetMediaType">
      <xsl:value-of select="normalize-space(.)"/>
    </field>
  </xsl:template>

  <xsl:template match="*:mods/*:relatedItem[@type = 'host']">
    <field name="resourceGroupName">
      <xsl:value-of
        select="normalize-space(concat(*:titleInfo/*:nonSort, ' ', *:titleInfo/*:title))"/>
    </field>
    <xsl:for-each select="*:location/*:physicalLocation">
      <field name="workLocation">
        <xsl:value-of select="normalize-space(.)"/>
      </field>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="*:mods/*:relatedItem[@type = 'original']">
    <xsl:for-each select="*:typeOfResource">
      <field name="workType">
        <xsl:value-of select="normalize-space(.)"/>
      </field>
    </xsl:for-each>
    <xsl:for-each select="*:identifier">
      <field name="workIdentifier">
        <xsl:value-of select="normalize-space(.)"/>
      </field>
    </xsl:for-each>
    <xsl:for-each select="*:originInfo/*:dateCreated">
      <field name="workCreationDate">
        <xsl:value-of select="normalize-space(.)"/>
      </field>
    </xsl:for-each>
    <xsl:for-each select="*:originInfo/*:place">
      <field name="coverageGeographic">
        <xsl:for-each select="*:placeTerm">
          <xsl:if test="position() ne 1">
            <xsl:text> -- </xsl:text>
          </xsl:if>
          <xsl:value-of select="normalize-space(.)"/>
        </xsl:for-each>
      </field>
    </xsl:for-each>
    <xsl:for-each select="*:physicalDescription">
      <xsl:if test="*:form[matches(@type, '(material|technique)')] | *:extent">
        <field name="workPhysicalDetails">
          <xsl:for-each select="*:form[matches(@type, '(material|technique)')] | *:extent">
            <xsl:if test="position() ne 1">
              <xsl:text>; </xsl:text>
            </xsl:if>
            <xsl:value-of select="normalize-space(.)"/>
          </xsl:for-each>
        </field>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="*:mods/*:subject">
    <field name="subject">
      <xsl:for-each select="*">
        <xsl:choose>
          <xsl:when test="matches(local-name(), 'hierarchicalGeographic')">
            <xsl:for-each select="*">
              <xsl:if test="position() ne 1">
                <xsl:text>--</xsl:text>
              </xsl:if>
              <xsl:value-of select="normalize-space(.)"/>
            </xsl:for-each>
          </xsl:when>
          <xsl:otherwise>
            <xsl:if test="position() ne 1">
              <xsl:text>--</xsl:text>
            </xsl:if>
            <xsl:value-of select="normalize-space(.)"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
    </field>
  </xsl:template>

  <xsl:template match="*:mods/*:titleInfo">
    <field name="title">
      <xsl:value-of select="normalize-space(concat(*:nonSort, ' ', *:title))"/>
    </field>
  </xsl:template>

  <xsl:template match="*:mods/*:typeOfResource">
    <field name="contentType">
      <xsl:value-of select="normalize-space(.)"/>
    </field>
  </xsl:template>

  <!-- ======================================================================= -->
  <!-- DEFAULT TEMPLATE                                                        -->
  <!-- ======================================================================= -->

  <xsl:template match="@* | node()">
    <xsl:apply-templates select="@* | node()"/>
  </xsl:template>

</xsl:stylesheet>
