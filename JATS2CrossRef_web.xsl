<?xml version="1.0"?>
<!-- ========================================================================== -->
<!-- XSL Name         : NLM2CrossRef.xsl (version 1.0)                          -->
<!-- Created By       : Aptara, Technology Group                                -->
<!-- Purpose          : To extract metadata for CrossRef from NLM's coded XML   -->
<!-- Creation Date    : May 16, 2007                                            -->
<!-- Command Line     : java -jar saxon8.jar input.xml NLM2CrossRef.xsl         -->
<!--                     meta=input_meta.xml >output.xml                      	-->
<!--                                                      						-->
<!-- ========================================================================== -->
<!-- Revision log
  -  10/1/2018   added abstracts, license-ref and funding sections from PeeJ XSL
  -  5/6/16 added ORCID (PDF)	
  -  10/8/15 updated pub-date types, added elocation, udpated to 4.3.6 (PDF)
  -  4/26/13 updated pub-date support (PDF)
  -  updated to work with NISO JATS 1 (PDF)
  -  updated schema version to 4.3.0 2/18/11 (PDF) -->

<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
                xmlns:xs="http://www.w3.org/2001/XMLSchema" 
				xmlns="http://www.crossref.org/schema/4.3.6"
				xmlns:xsldoc="http://www.bacman.net/XSLdoc" 
				xmlns:xlink="http://www.w3.org/1999/xlink" 
				xmlns:fr="http://www.crossref.org/fundref.xsd"
				xmlns:ai="http://www.crossref.org/AccessIndicators.xsd"
        xmlns:jatsFn="http://www.crossref.org/functions/jats"
				exclude-result-prefixes="xsldoc">

<xsl:output method="xml" 
            indent="yes" 
            encoding="UTF-8"/>

	<!-- One of these two fields must be populated -->
	<xsl:param name="metaContents" as="node()*" />
	<xsl:param name="meta" as="xs:string" select="''"/>
	<xsl:variable name="metafile">
		<xsl:if test="empty($metaContents) and $meta=''">
			<xsl:message terminate="yes">Must specify meta information - either as a nodeset in 'metaContents' or as a filename via 'meta'</xsl:message>
		</xsl:if>
		<xsl:sequence select="if (not(empty($metaContents))) then $metaContents else document($meta)"/>
	</xsl:variable>

<xsl:variable name="date" select="adjust-date-to-timezone(current-date(), ())"/>
<xsl:variable name="time" select="format-time(current-time(),'[H01][m01][s01]')"/>
<xsl:variable name="tempdatetime" select="concat($date,'',$time)"/>
<xsl:variable name="datetime" select="translate($tempdatetime,':-.','')"/>

<xsl:variable name="article-meta" select="/article/front/article-meta"/>
<xsl:variable name="article-id" select="$article-meta/article-id[@pub-id-type = 'publisher-id']"/>
<xsl:variable name="doi" select="$article-meta/article-id[@pub-id-type = 'doi']"/>
<xsl:variable name="url" select="$article-meta/self-uri/@xlink:href"/>

<!-- ========================================================================== -->
<!-- Root Element                                                               -->
<!-- ========================================================================== -->
<xsl:template match="/">
	<xsl:choose>
		<xsl:when test="article">
			<doi_batch version="4.3.6">
					<xsl:attribute name="xsi:schemaLocation">http://www.crossref.org/schema/4.3.6
						http://www.crossref.org/schema/deposit/crossref4.3.6.xsd</xsl:attribute>
				<head>
					<xsl:apply-templates select="//front"/>

				</head>
				<body>
					<journal>
						<xsl:apply-templates select="//journal-meta"/>
						<xsl:if test="//pub-date|//article-meta/volume|//article-meta/issue">
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

<!-- ========================================================================== -->
<!-- Front Matter Element                                                       -->
<!-- ========================================================================== -->
	<xsl:template match="front">
		<xsl:variable name="noIdComment"><xsl:comment>No article-id has been entered by user</xsl:comment></xsl:variable>
		<xsl:variable name="noPublisherNameComment"><xsl:comment>Publisher's Name not found in the input file</xsl:comment></xsl:variable>
		<xsl:variable name="noEmailAddressComment"><xsl:comment>NO e-mail address has been entered by the user</xsl:comment></xsl:variable>

		<doi_batch_id>
			<xsl:sequence select="($metafile/meta/article_id, jatsFn:findDoiBatchId(article-meta/article-id), $noIdComment)[1]" />
		</doi_batch_id>
		<timestamp>
			<xsl:value-of select="$datetime"/>
		</timestamp>
		<depositor>
			<depositor_name>
				<xsl:sequence select="(//journal-meta/publisher/publisher-name/string(), $noPublisherNameComment)[1]"/>
			</depositor_name>
			<email_address>
				<xsl:sequence select="($metafile/meta/email_address/string(), $noEmailAddressComment)[1]"/>
			</email_address>
		</depositor>
		<registrant>
			<xsl:sequence select="($metafile/meta/depositor/string(), //journal-meta/publisher/publisher-name/string(), $noPublisherNameComment)[1]"/>
		</registrant>
	</xsl:template>

	<xsl:function name="jatsFn:findDoiBatchId" as="xs:string?">
		<xsl:param name="candidateIdElements" as="element()*"/>
		<xsl:variable name="candidateIds" select="($candidateIdElements[@pub-id-type='art-access-id']
												  ,$candidateIdElements[@pub-id-type='publisher-id']
												  ,$candidateIdElements[@pub-id-type='doi']
												  ,$candidateIdElements[@pub-id-type='medline']
												  ,$candidateIdElements[@pub-id-type='pii']
												  ,$candidateIdElements[@pub-id-type='sici']
												  ,$candidateIdElements[@pub-id-type='pmid']
												  ,$candidateIdElements[@pub-id-type='other'])"/>
		<xsl:sequence select="$candidateIds[1]"/>
	</xsl:function>

<!-- ========================================================================== -->
<!-- Journal Metadata Element                                                   -->
<!-- ========================================================================== -->
	<xsl:template match="journal-meta">
		<journal_metadata language="en">
			<xsl:variable name="fullTitle" as="xs:string?" select="(journal-title-group/journal-title, journal-title, journal-id)[1]" />
			<xsl:if test="not($fullTitle)"><xsl:message terminate="yes">Journal full title is not available in the Input file</xsl:message></xsl:if>
			<full_title><xsl:value-of select="$fullTitle"/></full_title>

			<xsl:apply-templates select="(journal-title-group/abbrev-journal-title | abbrev-journal-title)[1]"/>

			<xsl:if test="not(issn)"><xsl:message terminate="yes">ISSN is not available in the Input file</xsl:message></xsl:if>
			<xsl:apply-templates select="issn"/>

			<xsl:if test="../article-meta/article-id[@pub-id-type='coden']">
				<coden>
					<xsl:value-of select="../article-meta/article-id[@pub-id-type='coden']"/>
				</coden>
			</xsl:if>
		</journal_metadata>
	</xsl:template>

	<xsl:template match="abbrev-journal-title">
		<abbrev_title><xsl:value-of select="."/></abbrev_title>
	</xsl:template>

	<xsl:template match="issn">
		<xsl:variable name="media_type" select="if (@pub-type=('epub', 'epub-ppub')) then 'electronic' else 'print'"/>
		<issn media_type="{$media_type}"><xsl:value-of select="."/></issn>
	</xsl:template>

<!-- ========================================================================== -->
<!-- Publication Date                                                           -->
<!-- ========================================================================== -->

	<xsl:template match="pub-date">
		<xsl:variable name="mediaType" select="if (@pub-type=('epub', 'epub-ppub')) then 'online' else 'print'"/>
		<publication_date media_type="{ $mediaType }">
			<xsl:apply-templates select="month"/>
			<xsl:apply-templates select="day"/>
			<xsl:apply-templates select="year"/>
		</publication_date>
	</xsl:template>

	<xsl:template match="month"><month><xsl:value-of select="."/></month></xsl:template>
	<xsl:template match="day"><day><xsl:value-of select="."/></day></xsl:template>
	<xsl:template match="year"><year><xsl:value-of select="."/></year></xsl:template>

<!-- ========================================================================== -->
<!-- Volume/Issue                                                               -->
<!-- ========================================================================== -->
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

<!-- ========================================================================== -->
<!-- Title Group                                                                -->
<!-- ========================================================================== -->
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
			<xsl:apply-templates select="//article-meta/abstract" mode="abstract"/>
		<xsl:apply-templates select="//pub-date"/>
		<xsl:if test="//article-meta/fpage|//article-meta/lpage">
			<xsl:apply-templates select="//article-meta/fpage|//article-meta/lpage"/>
		</xsl:if>
			<xsl:if test="//article-id[@pub-id-type = 'doi'] | //article-id[@pub-id-type = 'pii'] | //article-id[@pub-id-type = 'sici'] | //article-meta/elocation-id">
                            <xsl:call-template name="publisher-item"/>
                        </xsl:if>
			
			<!-- fundref -->
			<xsl:apply-templates select="//article-meta/funding-group[@specific-use = 'Crossref']" mode="fundref"/>

			<!-- license-ref AccessIndicators -->
			<xsl:sequence select="jatsFn:accessIndicator((//permissions)[1])"/>

			<!-- archive locations -->
			<!-- <xsl:call-template name="archive-locations"/> -->
			
		<doi_data>
			<doi>
				<xsl:choose>
					<xsl:when test="$metafile/meta/doi">
						<xsl:apply-templates select="$metafile/meta/doi"/>
					</xsl:when>
					<xsl:when test="//article-meta/article-id[@pub-id-type='doi']">
						<xsl:apply-templates select="//article-meta/article-id[@pub-id-type = 'doi']"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:message terminate="yes">DOI not provided</xsl:message>
					</xsl:otherwise>
				</xsl:choose>
			</doi>

			<resource>
				<xsl:choose>
					<xsl:when test="$metafile/meta/resource">
						<xsl:apply-templates select="$metafile/meta/resource"/>
					</xsl:when>
					<xsl:when test="//article-meta/self-uri/@xlink:href">
						<xsl:apply-templates select="//article-meta/self-uri/@xlink:href"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:comment>No Resource entry has been entered by the user</xsl:comment>
					</xsl:otherwise>
				</xsl:choose>
			</resource>
           		<xsl:call-template name="tdm"/>
           		<xsl:call-template name="crawler"/>
		</doi_data>
		<xsl:apply-templates select="//back/ref-list"/>
	</journal_article>
</xsl:template>

	<!-- ========================================================================== -->
	<!-- Article Contributors                                                       -->
	<!-- ========================================================================== -->
	<xsl:template match="//article-meta/contrib-group[contrib]">
		<contributors><xsl:apply-templates select="contrib"/></contributors>
	</xsl:template>

	<xsl:template match="contrib[name or name-alternatives or string-name]">
		<person_name sequence="{ if (position() eq 1) then 'first' else 'additional' }" contributor_role="{ @contrib-type }">
			<xsl:apply-templates select="(name, string-name, name-alternatives/name, name-alternatives/string-name)[1]"/>

			<xsl:if test="contrib-id[@contrib-id-type='orcid']">
				<ORCID>
					<xsl:apply-templates select="contrib-id"/>
				</ORCID>
			</xsl:if>
		</person_name>

		<xsl:if test="collab">
			<organization sequence="{ if (position() eq 1) then 'first' else 'additional' }" contributor_role="author">
				<xsl:apply-templates select="collab"/>
			</organization>
		</xsl:if>
	</xsl:template>

	<xsl:template match="contrib-group//name">
		<xsl:apply-templates select="given-names"/>
		<xsl:apply-templates select="surname"/>
		<xsl:apply-templates select="suffix"/>
	</xsl:template>

	<xsl:template match="contrib-group//given-names"><given_name><xsl:apply-templates/></given_name></xsl:template>
	<xsl:template match="contrib-group//surname"><surname><xsl:apply-templates/></surname></xsl:template>
	<xsl:template match="contrib-group//suffix"><suffix><xsl:apply-templates/></suffix></xsl:template>

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
	
<!-- ========================================================================== -->
<!-- Article Page Information                                                   -->
<!-- ========================================================================== -->
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

<!-- ========================================================================== -->
<!-- Publication Identifier                                                     -->
<!-- ========================================================================== -->
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

<!-- ========================================================================== -->
<!-- Citations                                                                  -->
<!-- ========================================================================== -->
<xsl:template match="ref-list">
	<citation_list>
		<xsl:apply-templates select="ref"/>
	</citation_list>
</xsl:template>

<xsl:template match="ref">
	<xsl:variable name="key" select="concat($datetime,'_',@id)"/>
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
					<xsl:value-of select="//element-citation/issn | //citation/issn | //nlm-citation/issn | //mixed-citation/issn"/>
				</issn>
			</xsl:if>
			<xsl:if test="source">
				<journal_title>
					<xsl:apply-templates select="source"/>
				</journal_title>
			</xsl:if>
                        <xsl:choose>
                            <xsl:when test="person-group">
				<xsl:apply-templates select="person-group/name|person-group/collab"/>
                            </xsl:when>
                            <xsl:when test="string-name">
				<xsl:apply-templates select="string-name"/>
                            </xsl:when>
                            <xsl:when test="collab">
				<xsl:apply-templates select="collab"/>
                            </xsl:when>
                        </xsl:choose>    
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
					<xsl:value-of select="replace(year, '[a-zA-Z]', '')" /> 
				</cYear>
			</xsl:if>
			<xsl:if test="article-title">
				<article_title>
					<xsl:apply-templates select="article-title"/>
				</article_title>
			</xsl:if>
		</xsl:when>
			<xsl:when test="@citation-type = 'book' or @citation-type = 'conf-proceedings' or @citation-type = 'confproc' or @citation-type = 'other' or @publication-type = 'book' or @publication-type = 'conf-proceedings' or @publication-type = 'confproc' or @publication-type = 'other'">
                        <xsl:choose>
                            <xsl:when test="person-group">
				<xsl:apply-templates select="person-group/name|person-group/collab"/>
                            </xsl:when>
                            <xsl:when test="string-name">
				<xsl:apply-templates select="string-name"/>
                            </xsl:when>
                            <xsl:when test="collab">
				<xsl:apply-templates select="collab"/>
                            </xsl:when>
                        </xsl:choose>    
			<xsl:if test="fpage">
				<first_page>
					<xsl:apply-templates select="fpage"/>
				</first_page>
			</xsl:if>
			<xsl:if test="year">
				<cYear>
					<xsl:value-of select="replace(year, '[a-zA-Z]', '')" /> 
				</cYear>
			</xsl:if>
			<xsl:if test="source">
				<volume_title>
					<xsl:apply-templates select="source"/>
				</volume_title>
			</xsl:if>
			<xsl:if test="edition">
				<edition_number>
					<xsl:apply-templates select="edition"/>
				</edition_number>
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

<xsl:template match="back//string-name">
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

	<!-- =================================================== -->

	<!-- http://help.crossref.org/include-abstracts-in-deposits -->
	<xsl:template match="element()" mode="abstract">
		<xsl:element name="jats:{local-name()}" namespace="http://www.ncbi.nlm.nih.gov/JATS1">
			<!--<xsl:copy-of select="namespace::*"/>-->
			<xsl:apply-templates select="node() | @*" mode="abstract"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="text()" mode="abstract">
		<xsl:value-of select="."/>
	</xsl:template>

	<xsl:template match="@*" mode="abstract">
		<xsl:attribute name="{name()}">
			<xsl:value-of select="."/>
		</xsl:attribute>
	</xsl:template>

	<xsl:template match="xref" mode="abstract">
		<xsl:apply-templates select="node()"/>
	</xsl:template>

	<!-- license URL -->
	<xsl:function name="jatsFn:accessIndicator" as="element(ai:program)?">
		<xsl:param name="permissions" as="element()?"/>

		<xsl:variable name="indicators" as="element()*">
			<xsl:if test="$permissions/license[@license-type=('open-access', 'free')]"><free_to_read/></xsl:if>
			<xsl:apply-templates select="$permissions/license" mode="access-indicators"/>
			<xsl:apply-templates select="$metafile/meta/license" mode="fromMeta"/>
		</xsl:variable>

		<xsl:if test="not(empty($indicators))">
			<ai:program name="AccessIndicators"><xsl:sequence select="$indicators"/></ai:program>
		</xsl:if>
	</xsl:function>

	<xsl:template match="license" mode="fromMeta">
		<ai:license_ref>
			<xsl:if test="@applies_to"><xsl:attribute name="applies_to" select="@applies_to"/></xsl:if>
			<xsl:value-of select="."/>
		</ai:license_ref>
	</xsl:template>

	<!-- http://tdmsupport.crossref.org/license-uris-technical-details/ -->
	<xsl:template match="license[@xlink:href]" mode="access-indicators">
		<ai:license_ref><xsl:value-of select="@xlink:href"/></ai:license_ref>
	</xsl:template>
	<xsl:template match="*" mode="access-indicators" priority="-1"/>

	<!-- fundref -->
	<!-- http://help.crossref.org/fundref -->
	<xsl:template match="funding-group" mode="fundref">
		<fr:program>
			<xsl:apply-templates select="award-group/funding-source" mode="fundref"/>
		</fr:program>
	</xsl:template>

	<xsl:template match="funding-group/award-group/funding-source" mode="fundref">
		<xsl:if test="normalize-space(string(.)) != ''">
			<fr:assertion name="fundgroup">
			<!-- TODO: in JATS 1.1d1 the name and ID/DOI may be in a wrapper -->
			
		    <xsl:choose>
			    <xsl:when test="institution-wrap">
			    	 
			    	<xsl:variable name="institution-id" select="institution-wrap/institution-id"/>
			    	 
			    	<xsl:choose> 
					    <xsl:when test="institution-wrap/institution != ''">
						    <fr:assertion name="funder_name">
							    <xsl:value-of select="institution-wrap/institution"/>
								<xsl:if test="$institution-id != ''">
									<fr:assertion name="funder_identifier">
										<xsl:value-of select="$institution-id"/>
									</fr:assertion>
								</xsl:if>
						    </fr:assertion>
						</xsl:when>
						<xsl:otherwise>
						    <xsl:if test="$institution-id != ''">
							    <fr:assertion name="funder_identifier">
								    <xsl:value-of select="$institution-id"/>
							    </fr:assertion>
						    </xsl:if>
						</xsl:otherwise>
					</xsl:choose>
			    </xsl:when>
			    <xsl:when test="institution != ''">
				    <fr:assertion name="funder_name">
					    <xsl:value-of select="institution"/>
				    </fr:assertion>
			    </xsl:when>
			    <xsl:otherwise>
			    	<xsl:if test="normalize-space(string(.)) != ''">
					    <fr:assertion name="funder_name">
						    <xsl:value-of select="normalize-space(string(.))"/>
					    </fr:assertion>
					</xsl:if>
			    </xsl:otherwise>
		    </xsl:choose>
		    
			 
			<xsl:apply-templates select="../award-id" mode="fundref"/>
			</fr:assertion>
		</xsl:if>
	</xsl:template>

	<xsl:template match="award-id" mode="fundref">
		<xsl:if test=". != ''">
			<fr:assertion name="award_number">
				<xsl:value-of select="."/>
			</fr:assertion>
		</xsl:if>
	</xsl:template>

	<!-- full-text URLs -->
	<!-- http://tdmsupport.crossref.org/full-text-uris-technical-details/ -->
	<xsl:template name="tdm">
		<collection property="text-mining">
			<item>
				<resource content_version="vor" mime_type="application/pdf">
					<xsl:choose>
						<xsl:when test="ends-with($url,'/')">
							<xsl:value-of select="concat(substring($url,1,string-length($url)-1), '.pdf')"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="concat($url, '.pdf')"/>
						</xsl:otherwise>
					</xsl:choose>
				</resource>
			</item>
			<item>
				<resource content_version="vor" mime_type="application/xml">
					<xsl:choose>
						<xsl:when test="ends-with($url,'/')">
							<xsl:value-of select="concat(substring($url,1,string-length($url)-1), '.xml')"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="concat($url, '.xml')"/>
						</xsl:otherwise>
					</xsl:choose>
				</resource>
			</item>
			<item>
				<resource content_version="vor" mime_type="text/html">
					<xsl:choose>
						<xsl:when test="ends-with($url,'/')">
							<xsl:value-of select="concat(substring($url,1,string-length($url)-1), '.html')"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="concat($url, '.html')"/>
						</xsl:otherwise>
					</xsl:choose>
				</resource>
			</item>
		</collection>
	</xsl:template>

<!-- crawler full-text URLs for Similarity Check -->
	<!-- https://support.crossref.org/hc/en-us/articles/215774943-Depositing-as-crawled-URLs-for-Similarity-Check -->
	<xsl:template name="crawler">
		<collection property="crawler-based">
			<item crawler="iParadigms">
				<resource>
					<xsl:choose>
						<xsl:when test="ends-with($url,'/')">
							<xsl:value-of select="concat(substring($url,1,string-length($url)-1), '.pdf')"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="concat($url, '.pdf')"/>
						</xsl:otherwise>
					</xsl:choose>
				</resource>
			</item>
		</collection>
	</xsl:template>

	<!-- archive locations -->
<!--	<xsl:template name="archive-locations">
		<xsl:if test="$archiveLocations">
			<archive_locations>
				<xsl:for-each select="str:tokenize($archiveLocations, ',')">
					<archive name="{.}"/>
				</xsl:for-each>
			</archive_locations>
		</xsl:if>
</xsl:template> -->

</xsl:stylesheet>