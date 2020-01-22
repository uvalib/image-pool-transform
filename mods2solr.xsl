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
      <field name="doc_type_f_stored">image_group</field>
      <!--<field name="originalMetadataType">MODS</field>-->
      <field name="items">
          <doc>
            <field name="id"><xsl:value-of select="$id" /></field>
            <field name="url_iiif_manifest_stored">https://iiifman.lib.virginia.edu/pid/<xsl:value-of select="$id"/></field> 
            <field name="url_iiif_image_stored">https://iiif.lib.virginia.edu/iiif/<xsl:value-of select="$id"/>/info.json</field>
            <field name="doc_type_f_stored">image_item</field>
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
        <xsl:variable name="extractedDate">
          <xsl:for-each select="*:dateCreated">
            <xsl:if test="position() != 1">
              <xsl:text>-</xsl:text>
            </xsl:if>
            <xsl:value-of select="normalize-space(.)"/>
          </xsl:for-each>
        </xsl:variable>
        <xsl:call-template name="fixDate">
          <xsl:with-param name="field">published_daterange</xsl:with-param>
          <xsl:with-param name="datestring"><xsl:value-of select="$extractedDate" /></xsl:with-param>
          <xsl:with-param name="range">true</xsl:with-param>
        </xsl:call-template>
        <xsl:call-template name="fixDate">
          <xsl:with-param name="field">published_date</xsl:with-param>
          <xsl:with-param name="datestring"><xsl:value-of select="$extractedDate"  /></xsl:with-param>
          <xsl:with-param name="monthDefault">-01</xsl:with-param>
          <xsl:with-param name="dayDefault">-01</xsl:with-param>
          <xsl:with-param name="timeDefault">T00:00:00Z</xsl:with-param>
        </xsl:call-template>       
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
  
  <!-- handles fixing all of the dates. Can create a date or a daterange -->
  <xsl:template name="fixDate">
    <xsl:param name="field"/>
    <xsl:param name="datestring"/>
    <xsl:param name="monthDefault" />
    <xsl:param name="dayDefault" />
    <xsl:param name="timeDefault"/>
    <xsl:param name="range"/>
    <xsl:variable name="fmtdate">
      <xsl:choose>
        <xsl:when test="matches($datestring, '([0-9][0-9][0-9][0-9])[~?]?[/]([0-9][0-9][0-9][0-9])[~?]?(.*)')">
          <xsl:analyze-string select="$datestring" regex="([0-9][0-9][0-9][0-9])[~?]?[/]([0-9][0-9][0-9][0-9])[~?]?(.*)">
            <xsl:matching-substring>
              <xsl:variable name="year1" select="number(regex-group(1))"/>
              <xsl:variable name="year2" select="number(regex-group(2))"/>
              <xsl:choose>
                <xsl:when test="$range = 'true'">
                  <xsl:value-of select="concat('[',$year1, ' TO ', $year2, ']')"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="concat($year1,  $monthDefault, $dayDefault, $timeDefault)"/>                            
                </xsl:otherwise>
              </xsl:choose>
            </xsl:matching-substring>
          </xsl:analyze-string>
        </xsl:when>
        <xsl:when test="matches($datestring, '([0-9][0-9][0-9][0-9])[-/]([0-9][0-9]?)[-/]([0-9][0-9]?)(.*)')">
          <xsl:analyze-string select="$datestring" regex="([0-9][0-9][0-9][0-9])[-/]([0-9][0-9]?)[-/]([0-9][0-9]?)(.*)">
            <xsl:matching-substring>
              <xsl:variable name="month" select="number(regex-group(2))"/>
              <xsl:variable name="day" select="number(regex-group(3))"/>
              <xsl:variable name="year" select="number(regex-group(1))"/>
              <xsl:value-of select="concat($year, '-', format-number($month, '00'), '-', format-number($day, '00'), $timeDefault)" />
            </xsl:matching-substring>
          </xsl:analyze-string>
        </xsl:when>
        <xsl:when test="matches($datestring, '[^0-9]*([0-9][0-9][0-9][0-9])(.*)')">
          <xsl:analyze-string select="$datestring" regex="[^0-9]*([0-9][0-9][0-9][0-9])(.*)">
            <xsl:matching-substring>
              <xsl:variable name="year" select="number(regex-group(1))"/>
              <xsl:value-of select="concat($year, $monthDefault, $dayDefault, $timeDefault)" />
            </xsl:matching-substring>
          </xsl:analyze-string>
        </xsl:when>
        <xsl:when test="matches($datestring, '[^0-9]*([0-9][0-9][0-9])X(.*)')">
          <xsl:analyze-string select="$datestring" regex="[^0-9]*([0-9][0-9][0-9])X(.*)">
            <xsl:matching-substring>
              <xsl:variable name="yearstart" select="number(regex-group(1))"/>
              <xsl:variable name="yearunits" select="number(regex-group(1))"/>
              <xsl:choose>
                <xsl:when test="$range = 'true'">
                  <xsl:value-of select="concat('[',$yearstart, '0', ' TO ', $yearstart, '9', ']')"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="concat($yearstart,'5', $monthDefault, $dayDefault, $timeDefault)"/>                            
                </xsl:otherwise>
              </xsl:choose>
            </xsl:matching-substring>
          </xsl:analyze-string>
        </xsl:when>
        <xsl:otherwise>
          <!--   <xsl:value-of select="concat('%%%%%', $datestring, '%%%%%')"/> -->
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:if test="$fmtdate != ''">
      <xsl:element name="field">
        <xsl:attribute name="name"><xsl:value-of select="$field"/></xsl:attribute>
        <xsl:value-of select="$fmtdate" />
      </xsl:element>
    </xsl:if>
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
