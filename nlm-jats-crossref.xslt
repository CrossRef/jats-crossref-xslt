<?xml version="1.0"?>
<!--
Originally created by Aptara, Technology Group
Revised by CrossRef to accomodate NISO JATS 1.0
Improved by Christopher Brown to be compatible with XSLT 1.0 and latest schema
Change log:
* 2017-07-19 implement support for structured citations (CHB)
* 2017-07-19 update to crossref4.4.0.xsd (CHB)
* 2016-12-17 merged with updated NLM.JATS2Crossref.v3.1.xsl from Crossref (CHB)
* 2016-12-04 simplified to support XSLT 1.0 (CHB)
* 2016-05-06 added ORCID (PDF)
* 2015-10-08 updated pub-date types, added elocation, udpated to 4.3.6 (PDF)
* 2013-04-26 updated pub-date support (PDF)
* updated to work with NISO JATS 1 (PDF)
* 2014-08-05 shortened timestamp value to match web deposit value (PDF)
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.crossref.org/schema/4.4.0"
                xmlns:xsldoc="http://www.bacman.net/XSLdoc"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                version="1.0" exclude-result-prefixes="xsldoc">
  <xsl:output method="xml" indent="yes" encoding="UTF-8"/>
  <xsl:param name="timestamp">19700101000000</xsl:param>
  <xsl:param name="email">labs-notifications@crossref.org</xsl:param>
  <xsl:variable name="alphabet">abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ</xsl:variable>

  <xsl:template match="/">
    <xsl:apply-templates select="article"/>
  </xsl:template>

  <xsl:template match="article">
    <doi_batch xmlns="http://www.crossref.org/schema/4.4.0"
               xmlns:xlink="http://www.w3.org/1999/xlink"
               xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
               xmlns:fr="http://www.crossref.org/fundref.xsd"
               version="4.4.0"
               xsi:schemaLocation="http://www.crossref.org/schema/4.4.0
                                   https://www.crossref.org/schema/crossref4.4.0.xsd">
      <head>
        <xsl:apply-templates select="front"/>
      </head>
      <body>
        <journal>
          <xsl:apply-templates select="front/journal-meta"/>
          <xsl:if test="//pub-date | //article-meta/volume | //article-meta/issue">
            <journal_issue>
              <xsl:apply-templates select="//pub-date"/>
              <xsl:apply-templates select="//article-meta/volume"/>
              <xsl:apply-templates select="//article-meta/issue"/>
            </journal_issue>
          </xsl:if>
          <xsl:apply-templates select="//article-meta/title-group"/>
        </journal>
      </body>
    </doi_batch>
  </xsl:template>

  <xsl:template match="front">
    <doi_batch_id>
      <xsl:apply-templates select="article-meta/article-id"/>
    </doi_batch_id>
    <timestamp>
      <xsl:value-of select="$timestamp"/>
    </timestamp>
    <depositor>
      <depositor_name>
        <xsl:apply-templates select="//journal-meta/publisher/publisher-name"/>
      </depositor_name>
      <email_address>
        <xsl:value-of select="$email"/>
      </email_address>
    </depositor>
    <registrant>
      <xsl:apply-templates select="//journal-meta/publisher/publisher-name"/>
    </registrant>
  </xsl:template>

  <xsl:template match="journal-meta">
    <journal_metadata language="en">
      <full_title>
        <!-- pick the most specific title available -->
        <xsl:choose>
          <xsl:when test="journal-title-group/journal-title">
            <xsl:value-of select="journal-title-group/journal-title"/>
          </xsl:when>
          <xsl:when test="journal-id">
            <xsl:value-of select="journal-id"/>
          </xsl:when>
        </xsl:choose>
      </full_title>
      <xsl:apply-templates select="journal-title-group/abbrev-journal-title"/>
      <xsl:apply-templates select="issn"/>
      <xsl:apply-templates select="./article-meta/article-id[@pub-id-type='coden']"/>
    </journal_metadata>
  </xsl:template>

  <xsl:template match="abbrev-journal-title">
    <abbrev_title>
      <xsl:apply-templates/>
    </abbrev_title>
  </xsl:template>

  <xsl:template match="issn">
    <issn>
      <xsl:if test="@publication-format">
        <xsl:attribute name="media_type">
          <xsl:value-of select="@publication-format"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:apply-templates/>
    </issn>
  </xsl:template>

  <xsl:template match="article-id[@pub-id-type='coden']">
    <coden>
      <xsl:apply-templates/>
    </coden>
  </xsl:template>

  <xsl:template match="month"><month><xsl:apply-templates/></month></xsl:template>
  <xsl:template match="day"><day><xsl:apply-templates/></day></xsl:template>
  <xsl:template match="year"><year><xsl:apply-templates/></year></xsl:template>

  <xsl:template match="pub-date">
    <publication_date media_type="{@publication-format}">
      <!-- reorder into m/d/y instead of JATS's more standard d/m/y -->
      <xsl:apply-templates select="month"/>
      <xsl:apply-templates select="day"/>
      <xsl:apply-templates select="year"/>
    </publication_date>
  </xsl:template>

  <xsl:template match="article-meta/volume">
    <journal_volume>
      <volume>
        <xsl:apply-templates/>
      </volume>
    </journal_volume>
  </xsl:template>
  <xsl:template match="article-meta/issue">
    <issue>
      <xsl:apply-templates/>
    </issue>
  </xsl:template>

  <xsl:template match="//article-meta/title-group">
    <journal_article publication_type="full_text">
      <titles>
        <title>
          <xsl:apply-templates select="article-title"/>
        </title>
      </titles>
      <xsl:if test="//article-meta/contrib-group">
        <xsl:apply-templates select="../contrib-group"/>
      </xsl:if>
      <xsl:apply-templates select="//pub-date"/>
      <xsl:if test="//article-meta/fpage | //article-meta/lpage">
        <xsl:apply-templates select="//article-meta/fpage | //article-meta/lpage"/>
      </xsl:if>
      <xsl:if test="//article-meta/elocation-id">
        <xsl:apply-templates select="//article-meta/elocation-id"/>
      </xsl:if>
      <xsl:if test="//article-id[@pub-id-type='doi'] |
                    //article-id[@pub-id-type='pii'] |
                    //article-id[@pub-id-type='sici']">
        <xsl:call-template name="publisher-item"/>
      </xsl:if>
      <doi_data>
        <doi>
          <xsl:choose>
            <xsl:when test="//article-meta/article-id[@pub-id-type='doi']">
              <xsl:apply-templates select="//article-meta/article-id[@pub-id-type='doi']"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:message terminate="yes">DOI entry is not available in the Input/Meta file(s)</xsl:message>
            </xsl:otherwise>
          </xsl:choose>
        </doi>
        <resource>
          <xsl:choose>
            <xsl:when test="//article-meta/self-uri/@xlink:href">
              <xsl:apply-templates select="//article-meta/self-uri/@xlink:href"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:comment>No Resource entry has been entered by the user</xsl:comment>
            </xsl:otherwise>
          </xsl:choose>
        </resource>
      </doi_data>
      <xsl:apply-templates select="//back/ref-list"/>
    </journal_article>
  </xsl:template>

  <xsl:template match="contrib-id[@contrib-id-type='orcid']">
    <ORCID>
      <xsl:apply-templates/>
    </ORCID>
  </xsl:template>

  <xsl:template match="//article-meta/contrib-group">
    <xsl:if test="contrib">
      <contributors>
        <xsl:apply-templates select="contrib"/>
      </contributors>
    </xsl:if>
  </xsl:template>
  <xsl:template match="contrib">
    <xsl:if test="name">
      <xsl:if test="position()=1">
        <person_name sequence="first" contributor_role="author">
          <xsl:apply-templates select="name"/>
          <!--
            <xsl:if test="xref[@ref-type='aff' and @rid]">
              <xsl:call-template name="multi-ref">
                <xsl:with-param name="tokens" select="xref[@ref-type='aff']/@rid"/>
              </xsl:call-template>
            </xsl:if>
          -->
          <xsl:apply-templates select="contrib-id"/>
        </person_name>
      </xsl:if>
      <xsl:if test="position()&gt;1">
        <person_name sequence="additional" contributor_role="author">
          <xsl:apply-templates select="name"/>
          <!--
            <xsl:if test="xref[@ref-type='aff' and @rid]">
              <xsl:call-template name="multi-ref">
                <xsl:with-param name="tokens" select="xref[@ref-type='aff']/@rid"/>
              </xsl:call-template>
            </xsl:if>
          -->
          <xsl:if test="contrib-id[@contrib-id-type='orcid']">
            <ORCID>
              <xsl:apply-templates select="contrib-id"/>
            </ORCID>
          </xsl:if>
        </person_name>
      </xsl:if>
      <xsl:if test="collab">
        <xsl:if test="position()=1">
          <organization sequence="first" contributor_role="author">
            <xsl:apply-templates select="collab"/>
          </organization>
        </xsl:if>
        <xsl:if test="position()&gt;1">
          <organization sequence="additional" contributor_role="author">
            <xsl:apply-templates select="name"/>
          </organization>
        </xsl:if>
      </xsl:if>
    </xsl:if>
  </xsl:template>
  <xsl:template match="contrib-group/contrib/name">
    <xsl:if test="given-names">
      <given_name>
        <xsl:apply-templates select="given-names"/>
      </given_name>
    </xsl:if>
    <surname>
      <xsl:apply-templates select="surname"/>
    </surname>
    <xsl:if test="suffix">
      <suffix>
        <xsl:apply-templates select="suffix"/>
      </suffix>
    </xsl:if>
  </xsl:template>
  <xsl:template match="contrib-group/contrib/collab">
    <xsl:if test="collab">
      <organization>
        <xsl:apply-templates select="collab"/>
      </organization>
    </xsl:if>
  </xsl:template>
  <xsl:template name="multi-ref">
    <xsl:param name="tokens"/>
    <xsl:if test="$tokens">
      <xsl:choose>
        <xsl:when test="contains($tokens,' ')">
          <xsl:call-template name="one-ref">
            <xsl:with-param name="token" select="substring-before($tokens,' ')"/>
          </xsl:call-template>
          <xsl:call-template name="multi-ref">
            <xsl:with-param name="tokens" select="substring-after($tokens,' ')"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="one-ref">
            <xsl:with-param name="token" select="$tokens"/>
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
  </xsl:template>
  <xsl:template name="one-ref">
    <xsl:param name="token"/>
    <affiliation>
      <xsl:value-of select="//aff[@id=$token]"/>
    </affiliation>
  </xsl:template>
  <xsl:template match="aff"> </xsl:template>
  <xsl:template match="aff/label"> </xsl:template>

  <xsl:template match="article-meta/fpage">
    <pages>
      <first_page>
        <xsl:apply-templates/>
      </first_page>
      <xsl:if test="../lpage">
        <last_page>
          <xsl:value-of select="../lpage"/>
        </last_page>
      </xsl:if>
    </pages>
  </xsl:template>
  <xsl:template match="lpage"> </xsl:template>

  <xsl:template name="publisher-item">
    <publisher_item>
      <xsl:if test="//article-meta/elocation-id">
        <item_number item_number_type="article_number">
          <xsl:value-of select="//article-meta/elocation-id"/>
        </item_number>
      </xsl:if>
      <xsl:if test="//article-id[@pub-id-type='doi']">
        <identifier id_type="doi">
          <xsl:value-of select="//article-id[@pub-id-type='doi']"/>
        </identifier>
      </xsl:if>
      <xsl:if test="//article-id[@pub-id-type='pii']">
        <identifier id_type="pii">
          <xsl:value-of select="//article-id[@pub-id-type='pii']"/>
        </identifier>
      </xsl:if>
      <xsl:if test="//article-id[@pub-id-type='sici']">
        <identifier id_type="sici">
          <xsl:value-of select="//article-id[@pub-id-type='sici']"/>
        </identifier>
      </xsl:if>
    </publisher_item>
  </xsl:template>

  <xsl:template name="fundref">
    <!--
      <fr:program name="fundref">
      </fr:program>
    -->
  </xsl:template>

  <!-- ref-list + citation_list -->

  <xsl:template match="ref-list">
    <citation_list>
      <xsl:apply-templates select="ref"/>
    </citation_list>
  </xsl:template>
  <xsl:template match="ref">
    <citation key="{@id}">
      <xsl:apply-templates select="element-citation"/>
      <xsl:apply-templates select="citation"/>
      <xsl:apply-templates select="nlm-citation"/>
      <xsl:apply-templates select="mixed-citation"/>
    </citation>
  </xsl:template>
  <xsl:template match="element-citation | citation | nlm-citation | mixed-citation">
    <xsl:apply-templates select="issn"/>
    <xsl:apply-templates select="source"/>
    <xsl:apply-templates select="collab"/>
    <!-- editors are ignored -->
    <xsl:apply-templates select="person-group[@person-group-type!='editor']" mode="citation"/>
    <xsl:apply-templates select="issue"/>
    <xsl:apply-templates select="volume"/>
    <xsl:apply-templates select="fpage"/>
    <xsl:apply-templates select="year" mode="citation"/>
    <xsl:apply-templates select="pub-id"/>
    <xsl:apply-templates select="isbn"/>
    <xsl:apply-templates select="series"/>
    <xsl:apply-templates select="article-title"/>
  </xsl:template>

  <!-- citation children -->

  <xsl:template match="source[../@publication-type='journal' or ../@citation-type='journal']">
    <journal_title>
      <xsl:apply-templates/>
    </journal_title>
  </xsl:template>
  <xsl:template match="source">
    <volume_title>
      <xsl:apply-templates/>
    </volume_title>
  </xsl:template>
  <xsl:template match="person-group | contrib" mode="citation">
    <author>
      <xsl:apply-templates select="name | collab" mode="citation"/>
    </author>
  </xsl:template>
  <xsl:template match="volume">
    <volume>
      <xsl:apply-templates/>
    </volume>
  </xsl:template>
  <xsl:template match="issue">
    <issue>
      <xsl:apply-templates/>
    </issue>
  </xsl:template>
  <xsl:template match="fpage">
    <first_page>
      <xsl:apply-templates/>
    </first_page>
  </xsl:template>
  <xsl:template match="year" mode="citation">
    <cYear>
      <xsl:value-of select="translate(., $alphabet, '')"/>
    </cYear>
  </xsl:template>
  <xsl:template match="pub-id[@pub-id-type='doi']">
    <doi>
      <xsl:apply-templates />
    </doi>
  </xsl:template>
  <xsl:template match="isbn">
    <isbn>
      <xsl:apply-templates/>
    </isbn>
  </xsl:template>
  <xsl:template match="series">
    <series_title>
      <xsl:apply-templates/>
    </series_title>
  </xsl:template>
  <xsl:template match="edition">
    <edition_number>
      <xsl:apply-templates />
    </edition_number>
  </xsl:template>
  <xsl:template match="back//article-title">
    <article_title>
      <xsl:apply-templates/>
    </article_title>
  </xsl:template>

  <!-- name formatting -->

  <xsl:template match="name" mode="citation">
    <xsl:value-of select="given-names" />
    <xsl:for-each select="surname">
      <xsl:text> </xsl:text>
      <xsl:value-of select="text()" />
    </xsl:for-each>
    <xsl:if test="position() != last()">
      <xsl:text>, </xsl:text>
    </xsl:if>
  </xsl:template>
  <xsl:template match="collab" mode="citation">
    <xsl:apply-templates/>
    <xsl:if test="position() != last()">
      <xsl:text>, </xsl:text>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
