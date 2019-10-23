<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.loc.gov/mods/v3"
  xmlns:mods="http://www.loc.gov/mods/v3" xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" exclude-result-prefixes="mods xs"
  version="2.0">

  <xsl:output method="xml" encoding="UTF-8" indent="yes" media-type="text/xml"
    omit-xml-declaration="no" standalone="no"/>
  <xsl:strip-space elements="*"/>

  <!-- ======================================================================= -->
  <!-- GLOBAL VARIABLES                                                        -->
  <!-- ======================================================================= -->

  <!-- program name -->
  <xsl:variable name="progname">
    <xsl:text>normalizeMODS.xsl</xsl:text>
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

  <xsl:template match="*:mods">
    <xsl:copy>
      <xsl:attribute name="xsi:schemaLocation">
        <xsl:text>http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-6.xsd</xsl:text>
      </xsl:attribute>
      <xsl:attribute name="version">3.6</xsl:attribute>
      <!--<xsl:apply-templates select="@*"/>-->
      <!--
        abstract accessCondition classification extension genre identifier language location name note originInfo part physicalDescription
        recordInfo relatedItem subject tableOfContents targetAudience titleInfo typeOfResource       
      -->
      <typeOfResource>
        <xsl:apply-templates select="*:typeOfResource/@*[not(matches(local-name(), 'collection'))]"/>
        <xsl:text>still image</xsl:text>
      </typeOfResource>
      <xsl:apply-templates
        select="
          *:abstract | *:accessCondition[not(matches(@displayLabel, 'access.*(collection|object)', 'i'))] | *:classification | *:extension | *:genre |
          *:identifier[not(matches(@displayLabel, '(retrieval id|slide call number|negative number|iris id|legacy tiff|prints number|ead id|fine arts id)', 'i') or matches(@type, '(accession|legacy|uri)', 'i'))] |
          *:language | *:name | *:note[not(matches(@type, 'provenance') or matches(@displayLabel, '(set code|size)', 'i'))] | *:part | *:physicalDescription | *:subject | *:tableOfContents |
          *:targetAudience | *:titleInfo"/>
      <xsl:apply-templates select="*:identifier[matches(@type, 'uri', 'i')]"/>
      <xsl:apply-templates select="*:location[*:url]" mode="image"/>
      <xsl:apply-templates select="*:originInfo" mode="image"/>
      <!-- Can the following test be simplied to *:identifier[matches(@type, 'legacy')]? -->
      <xsl:if
        test="*:identifier[matches(@displayLabel, '(retrieval id|slide call number|negative number|iris id|legacy tiff|prints number|fine arts id)', 'i') or matches(@type, 'legacy')]">
        <relatedItem type="original" displayLabel="Original">
          <xsl:apply-templates select="*:typeOfResource[not(matches(., 'still image'))]"/>
          <xsl:apply-templates
            select="*:identifier[matches(@displayLabel, '(retrieval id|slide call number|negative number|iris id|legacy tiff|prints number|fine arts id)', 'i') or matches(@type, 'legacy')]"/>
          <xsl:if
            test="*:physicalDescription[*:form[matches(@type, 'material|technique', 'i') or matches(., '(negative|nonprojected graphic)', 'i')] or *:extent]">
            <physicalDescription>
              <xsl:apply-templates
                select="*:physicalDescription/*:form[matches(@type, 'material|technique', 'i') or matches(., '(negative|nonprojected graphic)', 'i')] | *:physicalDescription/*:extent | *:physicalDescription/*:note[matches(@displayLabel, '(condition|size)', 'i')]"
              />
            </physicalDescription>
          </xsl:if>
          <!--<xsl:if test="*:location[*:physicalLocation]">
            <xsl:apply-templates select="*:location" mode="original"/>
          </xsl:if>-->
          <xsl:apply-templates
            select="//*:note[matches(., 'original negative', 'i') or matches(@displayLabel, 'copy negative', 'i')]"/>
          <xsl:apply-templates select="*:originInfo" mode="original"/>
          <xsl:apply-templates
            select="*:accessCondition[not(matches(@displayLabel, 'access.*collection', 'i'))]"/>
          <xsl:apply-templates select="*:note[matches(@type, 'provenance')]"/>
        </relatedItem>
      </xsl:if>
      <xsl:apply-templates select="*:relatedItem"/>
      <xsl:apply-templates select="*:note[matches(@displayLabel, 'set code', 'i')]"/>
      <xsl:apply-templates select="*:recordInfo"/>
    </xsl:copy>
  </xsl:template>

  <!-- ======================================================================= -->
  <!-- MATCH TEMPLATES FOR ELEMENTS                                            -->
  <!-- ======================================================================= -->

  <xsl:template match="*:mods/*:note[matches(@displayLabel, 'set code', 'i')]">
    <relatedItem displayLabel="Part of" type="host">
      <genre displayLabel="{@displayLabel}">
        <xsl:value-of select="."/>
      </genre>
    </relatedItem>
  </xsl:template>

  <xsl:template match="*:namePart">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:value-of
        select="normalize-space(replace(replace(normalize-space(.), '([A-Z]\.)([A-Z]\.)$', '$1 $2'), '^([A-Z]\.)([A-Z]\.)', '$1 $2 '))"
      />
    </xsl:copy>
  </xsl:template>

  <xsl:template match="*:note[matches(@displayLabel, 'size')]">
    <extent>
      <xsl:value-of select="normalize-space(.)"/>
    </extent>
  </xsl:template>

  <xsl:template match="*:note">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:value-of select="normalize-space(.)"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="*:identifier[matches(@type, 'uri', 'i')]">
    <location>
      <url>
        <xsl:apply-templates select="@displayLabel"/>
        <xsl:value-of select="normalize-space(.)"/>
      </url>
    </location>
  </xsl:template>

  <xsl:template match="*:mods/*:location" mode="image">
    <xsl:if test="normalize-space(.) ne ''">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="*[not(local-name() eq 'physicalLocation')]"/>
      </xsl:copy>
    </xsl:if>
  </xsl:template>

  <xsl:template match="*:mods/*:location/*:url">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:if test="not(@usage)">
        <xsl:attribute name="usage">primary</xsl:attribute>
      </xsl:if>
      <xsl:if test="not(@access)">
        <xsl:attribute name="access">object in context</xsl:attribute>
      </xsl:if>
      <xsl:value-of select="normalize-space(.)"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="*:mods/*:location" mode="original">
    <xsl:if test="normalize-space(.) ne '' and normalize-space(.) ne 'VA@'">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates
          select="*[not(local-name() eq 'url')][not(matches(normalize-space(.), '^VA@', 'i'))]"/>
      </xsl:copy>
    </xsl:if>
  </xsl:template>

  <xsl:template match="*:originInfo" mode="image">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <publisher>The Rector and Visitors of the University of Virginia</publisher>
      <place>
        <placeTerm type="text">Charlottesville, Va.</placeTerm>
      </place>
      <xsl:apply-templates select="*:dateCaptured"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="*:originInfo" mode="original">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates select="*[not(matches(local-name(), 'dateCaptured|publisher'))]"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="*:titleInfo">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:if test="*:title[matches(normalize-space(.), '^untitled$', 'i')]">
        <xsl:attribute name="supplied">yes</xsl:attribute>
      </xsl:if>
      <xsl:apply-templates select="*:nonSort"/>
      <xsl:apply-templates select="*[not(matches(local-name(), 'nonSort'))]"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="*:digitalOrigin">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:choose>
        <xsl:when test="matches(ancestor::*:mods/*:typeOfResource, 'object')">
          <xsl:text>born digital</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="."/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="*:placeTerm">
    <xsl:variable name="thisValue">
      <xsl:value-of select="normalize-space(.)"/>
    </xsl:variable>
    <xsl:if
      test="not(preceding-sibling::*:placeTerm[contains(., $thisValue)]) and not(following-sibling::*:placeTerm[contains(., $thisValue)])">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:value-of select="$thisValue"/>
      </xsl:copy>
    </xsl:if>
  </xsl:template>

  <xsl:template match="*:recordInfo">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:if test="not(*:recordOrigin)">
        <recordOrigin>
          <xsl:text>Normalized </xsl:text>
          <xsl:value-of select="format-dateTime(current-dateTime(), '[Y]-[M02]-[D02]T[H]:[m]:[s]')"/>
          <xsl:text> using </xsl:text>
          <xsl:value-of select="concat($progname, ', ', $version, '.')"/>
        </recordOrigin>
      </xsl:if>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="*:recordInfo/*:recordOrigin">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:variable name="recordContentSource">
        <xsl:value-of select="normalize-space(../*:recordContentSource)"/>
      </xsl:variable>
      <xsl:variable name="recordOrigin">
        <xsl:if
          test="not(normalize-space(.) eq '') and not(normalize-space(.) eq $recordContentSource)">
          <xsl:value-of select="normalize-space(.)"/>
          <xsl:if test="not(matches(normalize-space(normalize-space(.)), '\p{P}$'))">
            <xsl:text>.</xsl:text>
          </xsl:if>
        </xsl:if>
        <xsl:text>&#32;Normalized </xsl:text>
        <xsl:value-of select="format-dateTime(current-dateTime(), '[Y]-[M02]-[D02]T[H]:[m]:[s]')"/>
        <xsl:text> using </xsl:text>
        <xsl:value-of select="concat($progname, ', ', $version, '.')"/>
      </xsl:variable>
      <xsl:value-of select="normalize-space($recordOrigin)"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="*:mods/*:physicalDescription">
    <xsl:if
      test="
        *:digitalOrigin | *:form[not(matches(@type, 'material|technique', 'i') or matches(., '(negative|nonprojected graphic)', 'i'))] |
        *:internetMediaType | *:note[not(matches(@type, 'provenance')) and not(matches(@displayLabel, '(condition|copy negative)', 'i'))
        and not(matches(., 'original negative', 'i'))]">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates
          select="
            *:digitalOrigin | *:form[not(matches(@type, 'material|technique', 'i') or matches(., '(negative|nonprojected graphic)', 'i'))] |
            *:internetMediaType | *:note[not(matches(@type, 'provenance')) and not(matches(@displayLabel, '(condition|copy negative|size)', 'i'))
            and not(matches(., 'original negative', 'i'))]"
        />
      </xsl:copy>
    </xsl:if>
  </xsl:template>

  <xsl:template match="*:mods/*:relatedItem">
    <xsl:copy>
      <xsl:apply-templates select="@*[not(matches(local-name(), 'type'))]"/>
      <xsl:attribute name="type">
        <xsl:choose>
          <xsl:when
            test="matches(lower-case(.), 'carnegie survey|collection|johnston photographs|jackson davis|photograph file')">
            <!--
              carnegie survey of the architecture of the south
              eduardo montes-bradley photograph and film collection
              frances benjamin johnston photographs
              holsinger studio collection
              jackson davis collection of african american photographs
              papers and photographs of jackson davis
              medical artifacts collection
              printing services photograph file
              visual history collection
              -->
            <xsl:text>host</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="@type"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
      <xsl:if
        test="matches(lower-case(.), 'carnegie survey|collection|johnston photographs|jackson davis|photograph file') and not(*:typeOfResource)">
        <typeOfResource collection="yes">mixed material</typeOfResource>
      </xsl:if>
      <xsl:choose>
        <xsl:when
          test="not(*:titleInfo/*:title[matches(., '(visual history collection|jackson davis collection of african american photographs)', 'i')])">
          <xsl:apply-templates/>
          <xsl:if test="ancestor::*:mods/*:location[*:physicalLocation]">
            <xsl:apply-templates select="ancestor::*:mods/*:location" mode="original"/>
          </xsl:if>
          <xsl:if
            test="ancestor::*:mods/*:identifier[matches(@displayLabel, 'ead id', 'i') or matches(@type, 'accession', 'i') or matches(., '^(RG|MSS)')]">
            <xsl:apply-templates
              select="ancestor::*:mods/*:identifier[matches(@displayLabel, 'ead id', 'i') or matches(@type, 'accession', 'i') or matches(., '^(RG|MSS)')]"
            />
          </xsl:if>
          <xsl:apply-templates
            select="ancestor::*:mods/*:accessCondition[matches(@displayLabel, 'access.*collection', 'i')]"
          />
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="*:titleInfo | *:name"/>
          <xsl:if
            test="not(ancestor::*:mods/*:relatedItem/*:titleInfo[not(matches(*:title, '(visual history collection|jackson davis collection of african american photographs)', 'i'))])">
            <xsl:apply-templates select="ancestor::*:mods/*:location" mode="original"/>
            <xsl:apply-templates
              select="ancestor::*:mods/*:identifier[matches(@type, 'accession', 'i')]"/>
          </xsl:if>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:copy>
  </xsl:template>

  <xsl:template
    match="*:dateIssued | *:dateCreated | *:dateCaptured | *:dateValid | *:dateModified | *:copyrightDate | *:dateOther">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:choose>
        <xsl:when test="matches(., 'unknown date', 'i')">
          <xsl:text>undated</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="."/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="@authority[matches(., ';')]" priority="4">
    <xsl:variable name="nameValue">
      <xsl:value-of select="../*:namePart"/>
    </xsl:variable>
    <xsl:attribute name="authority">
      <xsl:analyze-string select="normalize-space(.)" regex=";">
        <xsl:non-matching-substring>
          <xsl:analyze-string select="." regex="^(.*)\(([^\)]+)\)">
            <xsl:matching-substring>
              <xsl:variable name="nameRef">
                <xsl:value-of select="regex-group(2)"/>
              </xsl:variable>
              <xsl:if test="matches($nameValue, $nameRef)">
                <xsl:value-of
                  select="replace(replace(replace(upper-case(normalize-space(regex-group(1))), 'ULAN', 'ulan'), 'LC', 'lcnaf'), 'NAF', 'lcnaf')"
                />
              </xsl:if>
            </xsl:matching-substring>
          </xsl:analyze-string>
        </xsl:non-matching-substring>
      </xsl:analyze-string>
    </xsl:attribute>
  </xsl:template>

  <xsl:template match="@authority" priority="2">
    <xsl:attribute name="authority">
      <xsl:value-of
        select="replace(replace(replace(replace(normalize-space(.), 'ULAN', 'ulan'), 'LC ', 'lcnaf '), '^naf$', 'lcnaf'), '^tgm', 'lctgm')"
      />
    </xsl:attribute>
  </xsl:template>

  <xsl:template match="@type" priority="2">
    <xsl:attribute name="type">
      <xsl:value-of
        select="replace(replace(replace(replace(normalize-space(.), 'useAndReproduction', 'use and reproduction'), 'restrictionOnAccess', 'restriction on access'), '^accessionNumber', 'accession number'), 'LegacyAccessionNumber', 'legacy accession number')"
      />
    </xsl:attribute>
  </xsl:template>

  <xsl:template match="@usage[matches(normalize-space(.), 'primary display')]" priority="2">
    <xsl:attribute name="usage">
      <xsl:text>primary</xsl:text>
    </xsl:attribute>
  </xsl:template>

  <!-- ======================================================================= -->
  <!-- DEFAULT TEMPLATE                                                        -->
  <!-- ======================================================================= -->

  <xsl:template match="@* | node()">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <!--<xsl:copy-of select="@*"/>-->
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
