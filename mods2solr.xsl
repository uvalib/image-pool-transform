<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
  xmlns="http://www.loc.gov/mods/v3" xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:xlink="http://www.w3.org/1999/xlink" exclude-result-prefixes="mods xlink">

  <xsl:output method="xml" indent="yes" omit-xml-declaration="yes" />
  <xsl:strip-space elements="*"/>

  <!-- ======================================================================= -->
  <!-- PARAMETERS                                                              -->
  <!-- ======================================================================= -->

  <xsl:param name="diagnostics" select="'false'"/>
  
  <xsl:param name="id" required="yes" />
  
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
    <xsl:apply-templates select="//*:mods"/>
  </xsl:template>

  <!-- ======================================================================= -->
  <!-- MATCH TEMPLATES FOR ELEMENTS                                            -->
  <!-- ======================================================================= -->

  <xsl:template match="*:mods">
    <doc>
        <!-- It's not clear if/how the group will show up in the solr search so the ID may need to be more real.. currently V4 doesn't expose IDs for groups (if they even exist) -->
      <field name="id"><xsl:value-of select="$id" />-group</field>  
      <xsl:apply-templates mode="group" />
      <field name="pool_f_stored">images</field>
      <field name="doc_type_tsearch_stored">image_group</field>
      <!--<field name="originalMetadataType">MODS</field>-->
      <field name="items">
          <doc>
            <field name="id"><xsl:value-of select="$id" /></field>
            <field name="url_iiif_manifest_stored">https://iiifman.lib.virginia.edu/pid/<xsl:value-of select="$id"/></field> 
            <field name="url_iiif_image_stored">https://iiif.lib.virginia.edu/iiif/<xsl:value-of select="$id"/>/info.json</field>
            <field name="doc_type_tsearch_stored">image_item</field>
            <xsl:apply-templates mode="item" />
          </doc>
      </field>
    </doc>
  </xsl:template>

  <xsl:template match="*:mods/*:abstract" mode="item">
    <field name="summary_tsearch_stored">
      <xsl:value-of select="normalize-space(.)"/>
    </field>
  </xsl:template>

  <xsl:template match="*:mods/*:accessCondition[@type = 'restrictionOnAccess']" mode="item">
    <field name="accessRestrict_tsearch">
      <xsl:value-of select="normalize-space(.)"/>
    </field>
  </xsl:template>

  <xsl:template match="*:mods/*:genre" mode="item">
    <field name="workType_tsearch_stored">
      <xsl:value-of select="normalize-space(.)"/>
    </field>
  </xsl:template>

  <xsl:template match="*:mods/*:identifier" mode="item">
    <field name="otherIdentifier_tsearch_stored">
      <xsl:value-of select="normalize-space(.)"/>
    </field>
  </xsl:template>

  <xsl:template match="*:mods/*:location" mode="item">
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

  <xsl:template match="*:mods/*:note" mode="item">
    <field name="note_tsearch_stored">
      <xsl:value-of select="normalize-space(.)"/>
    </field>
  </xsl:template>

  <!--<xsl:template
    match="*:mods/*:note[matches(@type, '(handwritten|exhibitions|local|numbering|reproduction|system details|thesis|version identification|language)')]">
    <field name="note">
      <xsl:value-of select="normalize-space(.)"/>
    </field>
  </xsl:template>-->

  <xsl:template match="*:mods/*:originInfo" mode="item">
    <xsl:choose>
      <xsl:when test="*:dateCreated">
        <field name="published_daterange">
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

  <xsl:template match="*:mods/*:physicalDescription/*:digitalOrigin" mode="item">
    <field name="digitalOrigin">
      <xsl:value-of select="normalize-space(.)"/>
    </field>
  </xsl:template>

  <xsl:template match="*:mods/*:physicalDescription/*:internetMediaType" mode="item">
    <field name="internetMediaType">
      <xsl:value-of select="normalize-space(.)"/>
    </field>
  </xsl:template>

  <xsl:template match="*:mods/*:relatedItem[@type = 'host']" mode="item">
    <field name="collection_f_stored">
      <xsl:value-of
        select="normalize-space(concat(*:titleInfo/*:nonSort, ' ', *:titleInfo/*:title))"/>
    </field>
    <xsl:for-each select="*:location/*:physicalLocation">
      <field name="workLocation_tsearch_stored">
        <xsl:value-of select="normalize-space(.)"/>
      </field>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="*:mods/*:relatedItem[@type = 'original']" mode="item">
    <xsl:for-each select="*:typeOfResource">
      <field name="workType_tsearch_stored">
        <xsl:value-of select="normalize-space(.)"/>
      </field>
    </xsl:for-each>
    <xsl:for-each select="*:identifier">
      <field name="workIdentifier_tsearch_stored">
        <xsl:value-of select="normalize-space(.)"/>
      </field>
    </xsl:for-each>
    <xsl:for-each select="*:originInfo/*:dateCreated">
      <field name="published_daterange">
        <xsl:value-of select="normalize-space(.)"/>
      </field>
    </xsl:for-each>
    <xsl:for-each select="*:originInfo/*:place">
      <field name="coverageGeographic_tsearch_stored">
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
        <field name="workPhysicalDetails_tsearch_stored">
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

  <xsl:template match="*:mods/*:subject" mode="item">
    <field name="subject_tsearchf_stored">
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

  <xsl:template match="*:mods/*:titleInfo" mode="item">
    <field name="title_tsearch_stored">
      <xsl:value-of select="normalize-space(concat(*:nonSort, ' ', *:title))"/>
    </field>
  </xsl:template>

  <xsl:template match="*:mods/*:typeOfResource" mode="item">
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
  
  <xsl:template match="@* | node()" mode="group item skip">
    <xsl:apply-templates select="@* | node()"/>
  </xsl:template>

</xsl:stylesheet>
