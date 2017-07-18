<?xml version="1.0"?>
<!-- Originally created by Aptara, Technology Group -->
<!-- Revised by CrossRef to accomodate NISO JATS 1.0 -->
<!-- Revision log
  -  5/6/16 added ORCID (PDF)
  -  10/8/15 updated pub-date types, added elocation, udpated to 4.3.6 (PDF)
  -  4/26/13 updated pub-date support (PDF)
  -  updated to work with NISO JATS 1 (PDF)
  -  8/5/2014 (PDF) shortened timestamp value to match web deposit value
-->
<!-- Simplified by Christopher Brown to support XSL 1.0 -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.crossref.org/schema/4.3.6"
                xmlns:xsldoc="http://www.bacman.net/XSLdoc"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                version="1.0" exclude-result-prefixes="xsldoc">
  <xsl:output method="xml" indent="yes" encoding="UTF-8"/>
  <xsl:param name="timestamp">19700101000000</xsl:param>
  <xsl:param name="email">labs-notifications@crossref.org</xsl:param>
  <xsl:variable name="alphabet">abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ</xsl:variable>

  <xsl:template match="/">
    <xsl:choose>
      <xsl:when test="article">
        <doi_batch xmlns="http://www.crossref.org/schema/4.3.6"
                   xmlns:xlink="http://www.w3.org/1999/xlink"
                   xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                   xmlns:fr="http://www.crossref.org/fundref.xsd"
                   version="4.3.6"
                   xsi:schemaLocation="http://www.crossref.org/schema/4.3.6
                                       http://www.crossref.org/schema/deposit/crossref4.3.6.xsd">
          <head>
            <xsl:apply-templates select="//front"/>
          </head>
          <body>
            <journal>
              <xsl:apply-templates select="//journal-meta"/>
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
      </xsl:when>
      <xsl:otherwise>
        <xsl:message terminate="yes"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="front">
    <doi_batch_id>
      <xsl:choose>
        <xsl:when test="article-meta/article-id[@pub-id-type='art-access-id']">
          <xsl:apply-templates select="article-meta/article-id[@pub-id-type='art-access-id']"/>
        </xsl:when>
        <xsl:when test="article-meta/article-id[@pub-id-type='publisher-id']">
          <xsl:apply-templates select="article-meta/article-id[@pub-id-type='publisher-id']"/>
        </xsl:when>
        <xsl:when test="article-meta/article-id[@pub-id-type='doi']">
          <xsl:apply-templates select="article-meta/article-id[@pub-id-type='doi']"/>
        </xsl:when>
        <xsl:when test="article-meta/article-id[@pub-id-type='medline']">
          <xsl:apply-templates select="article-meta/article-id[@pub-id-type='medline']"/>
        </xsl:when>
        <xsl:when test="article-meta/article-id[@pub-id-type='pii']">
          <xsl:apply-templates select="article-meta/article-id[@pub-id-type='pii']"/>
        </xsl:when>
        <xsl:when test="article-meta/article-id[@pub-id-type='sici']">
          <xsl:apply-templates select="article-meta/article-id[@pub-id-type='sici']"/>
        </xsl:when>
        <xsl:when test="article-meta/article-id[@pub-id-type='pmid']">
          <xsl:apply-templates select="article-meta/article-id[@pub-id-type='pmid']"/>
        </xsl:when>
        <xsl:when test="article-meta/article-id[@pub-id-type='other']">
          <xsl:apply-templates select="article-meta/article-id[@pub-id-type='other']"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:comment>No article-id has been entered by user</xsl:comment>
        </xsl:otherwise>
      </xsl:choose>
    </doi_batch_id>
    <timestamp>
      <xsl:value-of select="$timestamp"/>
    </timestamp>
    <depositor>
      <depositor_name>
        <xsl:choose>
          <xsl:when test="//journal-meta/publisher">
            <xsl:apply-templates select="//journal-meta/publisher/publisher-name"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:comment>Publisher's Name not found in the input file</xsl:comment>
          </xsl:otherwise>
        </xsl:choose>
      </depositor_name>
      <email_address>
        <xsl:value-of select="$email"/>
      </email_address>
    </depositor>
    <registrant>
      <xsl:choose>
        <xsl:when test="//journal-meta/publisher">
          <xsl:apply-templates select="//journal-meta/publisher/publisher-name"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:comment>Publisher's name not found in the input file</xsl:comment>
        </xsl:otherwise>
      </xsl:choose>
    </registrant>
  </xsl:template>

  <xsl:template match="journal-meta">
    <journal_metadata language="en">
      <xsl:choose>
        <xsl:when test="journal-title-group/journal-title">
          <full_title>
            <xsl:value-of select="journal-title-group/journal-title"/>
          </full_title>
        </xsl:when>
        <xsl:when test="journal-title">
          <full_title>
            <xsl:value-of select="journal-title"/>
          </full_title>
        </xsl:when>
        <xsl:when test="journal-id">
          <full_title>
            <xsl:value-of select="journal-id"/>
          </full_title>
        </xsl:when>
        <xsl:otherwise>
          <full_title>
            <xsl:message terminate="yes">Journal full title is not available in the Input file</xsl:message>
          </full_title>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:choose>
        <xsl:when test="abbrev-journal-title">
          <abbrev_title>
            <xsl:value-of select="abbrev-journal-title"/>
          </abbrev_title>
        </xsl:when>
      </xsl:choose>
      <xsl:choose>
        <xsl:when test="issn">
          <xsl:apply-templates select="issn"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:message terminate="yes">ISSN is not available in the Input file</xsl:message>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:if test="../article-meta/article-id[@pub-id-type='coden']">
        <coden>
          <xsl:value-of select="../article-meta/article-id[@pub-id-type='coden']"/>
        </coden>
      </xsl:if>
    </journal_metadata>
  </xsl:template>

  <xsl:template match="issn">
    <issn media_type="{@publication-format}">
      <xsl:apply-templates/>
    </issn>
  </xsl:template>

  <xsl:template match="pub-date">
    <publication_date media_type="{@publication-format}">
      <xsl:if test="month">
        <month>
          <xsl:apply-templates select="month"/>
        </month>
      </xsl:if>
      <xsl:if test="day">
        <day>
          <xsl:apply-templates select="day"/>
        </day>
      </xsl:if>
      <year>
        <xsl:apply-templates select="year"/>
      </year>
    </publication_date>
  </xsl:template>

  <xsl:template match="//article-meta/volume">
    <journal_volume>
      <volume>
        <xsl:apply-templates/>
      </volume>
    </journal_volume>
  </xsl:template>
  <xsl:template match="//article-meta/issue">
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
          <xsl:if test="contrib-id[@contrib-id-type='orcid']">
            <ORCID>
              <xsl:apply-templates select="contrib-id"/>
            </ORCID>
          </xsl:if>
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

  <xsl:template match="ref-list">
    <citation_list>
      <xsl:apply-templates select="ref"/>
    </citation_list>
  </xsl:template>
  <xsl:template match="ref">
    <xsl:variable name="key" select="concat($timestamp,'_',@id)"/>
    <citation>
      <xsl:attribute name="key">key<xsl:value-of select="$key"/></xsl:attribute>
      <xsl:apply-templates select="element-citation"/>
      <xsl:apply-templates select="citation"/>
      <xsl:apply-templates select="nlm-citation"/>
      <xsl:apply-templates select="mixed-citation"/>
    </citation>
  </xsl:template>
  <xsl:template match="element-citation | citation | nlm-citation | mixed-citation">
    <xsl:choose>
      <xsl:when test="@publication-type='journal' or @citation-type='journal'">
        <xsl:if test="issn">
          <issn>
            <xsl:value-of select="//element-citation/issn |
                                  //citation/issn |
                                  //nlm-citation/issn |
                                  //mixed-citation/issn"/>
          </issn>
        </xsl:if>
        <xsl:if test="source">
          <journal_title>
            <xsl:apply-templates select="source"/>
          </journal_title>
        </xsl:if>
        <xsl:if test="collab">
          <xsl:apply-templates select="collab"/>
        </xsl:if>
        <xsl:if test="person-group">
          <xsl:apply-templates select="person-group/name | person-group/collab"/>
        </xsl:if>
        <xsl:if test="volume">
          <volume>
            <xsl:apply-templates select="volume"/>
          </volume>
        </xsl:if>
        <xsl:if test="issue">
          <issue>
            <xsl:apply-templates select="issue"/>
          </issue>
        </xsl:if>
        <xsl:if test="fpage">
          <first_page>
            <xsl:apply-templates select="fpage"/>
          </first_page>
        </xsl:if>
        <xsl:if test="year">
          <cYear>
            <xsl:value-of select="translate(year, $alphabet, '')"/>
          </cYear>
        </xsl:if>
        <xsl:if test="article-title">
          <article_title>
            <xsl:apply-templates select="article-title"/>
          </article_title>
        </xsl:if>
      </xsl:when>
      <xsl:when test="@citation-type='book' or @citation-type='conf-proceedings' or
                      @citation-type='confproc' or @citation-type='other' or
                      @publication-type='book' or @publication-type='conf-proceedings' or
                      @publication-type='confproc' or @publication-type='other'">
        <xsl:if test="source">
          <volume_title>
            <xsl:apply-templates select="source"/>
          </volume_title>
        </xsl:if>
        <xsl:if test="collab">
          <xsl:apply-templates select="collab"/>
        </xsl:if>
        <xsl:if test="person-group">
          <xsl:apply-templates select="person-group/name | person-group/collab"/>
        </xsl:if>
        <xsl:if test="edition">
          <edition_number>
            <xsl:apply-templates select="edition"/>
          </edition_number>
        </xsl:if>
        <xsl:if test="fpage">
          <first_page>
            <xsl:apply-templates select="fpage"/>
          </first_page>
        </xsl:if>
        <xsl:if test="year">
          <cYear>
            <xsl:value-of select="translate(year, $alphabet, '')"/>
          </cYear>
        </xsl:if>
        <xsl:if test="article-title">
          <article_title>
            <xsl:apply-templates select="article-title"/>
          </article_title>
        </xsl:if>
      </xsl:when>
      <xsl:otherwise>
        <unstructured_citation>
          <xsl:value-of select="."/>
        </unstructured_citation>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template match="back//name">
    <xsl:if test="position()=1">
      <author>
        <xsl:apply-templates select="surname"/>
      </author>
    </xsl:if>
  </xsl:template>
  <xsl:template match="back//collab">
    <xsl:if test="position()=1">
      <author>
        <xsl:apply-templates/>
      </author>
    </xsl:if>
  </xsl:template>
</xsl:stylesheet>
