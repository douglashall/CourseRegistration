<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fo="http://www.w3.org/1999/XSL/Format"
	exclude-result-prefixes="xs fo" version="2.0">
	<xsl:attribute-set name="normal">
		<xsl:attribute name="font-family">Calibri,Tahoma,Arial,Helvetica,sans-serif</xsl:attribute>
		<xsl:attribute name="font-size">11pt</xsl:attribute>
		<xsl:attribute name="line-height">1.6</xsl:attribute>
	</xsl:attribute-set>
	<xsl:attribute-set name="agreement">
		<xsl:attribute name="font-family">Calibri,Tahoma,Arial,Helvetica,sans-serif</xsl:attribute>
		<xsl:attribute name="font-size">10pt</xsl:attribute>
		<xsl:attribute name="line-height">1.2</xsl:attribute>
	</xsl:attribute-set>
	<xsl:attribute-set name="signaturetext">
		<xsl:attribute name="font-family">Calibri,Tahoma,Arial,Helvetica,sans-serif</xsl:attribute>
		<xsl:attribute name="font-size">10pt</xsl:attribute>
		<xsl:attribute name="line-height">1.2</xsl:attribute>
	</xsl:attribute-set>
	<xsl:attribute-set name="instructor">
		<xsl:attribute name="font-style">italic</xsl:attribute>
		<xsl:attribute name="font-size">8pt</xsl:attribute>		
	</xsl:attribute-set>	
	<xsl:attribute-set name="meeting_time">
		<xsl:attribute name="font-size">8pt</xsl:attribute>
	</xsl:attribute-set>	
	<xsl:attribute-set name="tableheader">
		<xsl:attribute name="background-color">#eeeeee</xsl:attribute>
		<xsl:attribute name="color">#000000</xsl:attribute>
		<xsl:attribute name="font-weight">bold</xsl:attribute>
		<xsl:attribute name="line-height">1.1</xsl:attribute>
	</xsl:attribute-set>
	<xsl:attribute-set name="tableheadercell">
		<xsl:attribute name="padding">4pt</xsl:attribute>
		<xsl:attribute name="background-color">#eeeeee</xsl:attribute>
		<xsl:attribute name="color">#000000</xsl:attribute>
		<xsl:attribute name="border">2pt solid black</xsl:attribute>
	</xsl:attribute-set>
	<xsl:attribute-set name="coursetablecell">
		<xsl:attribute name="background-color">#ffffff</xsl:attribute>
		<xsl:attribute name="padding-before">4pt</xsl:attribute>
		<xsl:attribute name="padding-top">3pt</xsl:attribute>
		<xsl:attribute name="padding-bottom">3pt</xsl:attribute>
		<xsl:attribute name="border">1pt solid black</xsl:attribute>
	</xsl:attribute-set>
	<xsl:attribute-set name="tablecontent">
		<xsl:attribute name="margin">3pt</xsl:attribute>
		<xsl:attribute name="font-family">Calibri,Tahoma,Arial,Helvetica,sans-serif</xsl:attribute>
		<xsl:attribute name="font-size">11pt</xsl:attribute>
		<xsl:attribute name="line-height">1.2</xsl:attribute>
	</xsl:attribute-set>	
	<xsl:attribute-set name="infotablecell">
		<xsl:attribute name="background-color">#ffffff</xsl:attribute>
		<xsl:attribute name="padding-before">4pt</xsl:attribute>
		<xsl:attribute name="padding-top">3pt</xsl:attribute>
		<xsl:attribute name="padding-bottom">3pt</xsl:attribute>
	</xsl:attribute-set>
	<xsl:attribute-set name="infotablecellfill">
		<xsl:attribute name="background-color">#ffffff</xsl:attribute>
		<xsl:attribute name="padding-before">4pt</xsl:attribute>
		<xsl:attribute name="padding-top">3pt</xsl:attribute>
		<xsl:attribute name="padding-bottom">3pt</xsl:attribute>
		<xsl:attribute name="border-bottom">1pt solid black</xsl:attribute>
		<xsl:attribute name="border-top">1pt solid black</xsl:attribute>
	</xsl:attribute-set>	
	<xsl:attribute-set name="heading1">
		<xsl:attribute name="font-family">Calibri,Tahoma,Arial,Helvetica,sans-serif</xsl:attribute>
		<xsl:attribute name="break-before">page</xsl:attribute>
		<xsl:attribute name="font-size">18pt</xsl:attribute>
		<xsl:attribute name="line-height">24pt</xsl:attribute>
		<xsl:attribute name="space-after.optimum">6pt</xsl:attribute>
		<xsl:attribute name="color">black</xsl:attribute>
		<xsl:attribute name="text-align">center</xsl:attribute>
		<xsl:attribute name="font-weight">bold</xsl:attribute>
	</xsl:attribute-set>
	<xsl:attribute-set name="heading2">
		<xsl:attribute name="font-family">Calibri,Tahoma,Arial,Helvetica,sans-serif</xsl:attribute>
		<xsl:attribute name="font-size">16pt</xsl:attribute>
		<xsl:attribute name="line-height">20pt</xsl:attribute>
		<xsl:attribute name="space-after.optimum">6pt</xsl:attribute>
		<xsl:attribute name="color">black</xsl:attribute>
		<xsl:attribute name="text-align">center</xsl:attribute>
		<xsl:attribute name="font-weight">bold</xsl:attribute>
	</xsl:attribute-set>
	<xsl:variable name="homeschool">
	<xsl:choose>
	<xsl:when test="string-length(/data/person/home_school) > 0">
		<xsl:variable name="hs" select="/data/person/home_school"/>
		<xsl:choose>
                  <xsl:when test="/data/person/huid eq '40653783'">Graduate School of Arts and Sciences</xsl:when>
			<xsl:when test="string-length(/data/schools/school[count(ldap[. eq $hs]) > 0]/name) > 0">
				<xsl:value-of select="/data/schools/school[count(ldap[. eq $hs]) > 0]/name"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$hs"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:when>
	<xsl:otherwise>  </xsl:otherwise>
	</xsl:choose>
	</xsl:variable>
	<xsl:variable name="homeschool_code">
	<xsl:choose>
	<xsl:when test="string-length(/data/person/home_school) > 0">
		<xsl:variable name="hs" select="/data/person/home_school"/>
		<xsl:choose>
                  <xsl:when test="/data/person/huid eq '40653783'">GSAS</xsl:when>
			<xsl:when test="string-length(/data/schools/school[count(ldap[. eq $hs]) > 0]/@code) > 0">
				<xsl:value-of select="/data/schools/school[count(ldap[. eq $hs]) > 0]/@code"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$hs"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:when>
	<xsl:otherwise>  </xsl:otherwise>
	</xsl:choose>
	</xsl:variable>
	<xsl:template match="/">
		<fo:root>
			<fo:layout-master-set>
				<fo:simple-page-master master-name="simple"
					page-height="8.5in" page-width="11in" margin-top="0.5in"
					margin-bottom="0.75in" margin-left="0.5in" margin-right="0.5in">
					<fo:region-body margin-top="0.25in" />
				</fo:simple-page-master>
			</fo:layout-master-set>
			<fo:page-sequence master-reference="simple">
				<fo:flow flow-name="xsl-region-body">
					<xsl:apply-templates />
				</fo:flow>
			</fo:page-sequence>
		</fo:root>
	</xsl:template>

	<xsl:template match="data">
		<xsl:for-each-group select="courses/course"
			group-by="concat(@school,'|',@term)">
          <xsl:if test="current-group()[1]/@school ne 'Harvard Kennedy School'">	          
			<fo:block xsl:use-attribute-sets="heading1">
				<xsl:text>Harvard University Cross Registration Petition</xsl:text>
			</fo:block>
			<xsl:if test="string-length(current-group()[1]/@school) > 0">
			<fo:block xsl:use-attribute-sets="heading2">
				<xsl:value-of select="current-group()[1]/@school" />
				<xsl:text>, </xsl:text>
				<xsl:value-of select="current-group()[1]/@term" />
			</fo:block>
			</xsl:if>
			<xsl:call-template name="person_info" />
			<fo:table space-before="0.25in" margin-top="0.125in" border-style="solid" border-width="2pt"
				border-color="#000000">
				<fo:table-column column-width="1.5in" />
				<fo:table-column column-width="2.4in" />
				<fo:table-column column-width="1.35in" />
				<fo:table-column column-width="1.25in" />
				<fo:table-column column-width="1.25in" />
				<fo:table-column column-width="2.25in" />
				<fo:table-header>
					<fo:table-row>
						<fo:table-cell xsl:use-attribute-sets="tableheadercell">
							<fo:block xsl:use-attribute-sets="normal tableheader">Course Number
							</fo:block>
						</fo:table-cell>
						<fo:table-cell xsl:use-attribute-sets="tableheadercell">
							<fo:block xsl:use-attribute-sets="normal tableheader">Course Title</fo:block>
						</fo:table-cell>
						<fo:table-cell xsl:use-attribute-sets="tableheadercell">
							<fo:block xsl:use-attribute-sets="normal tableheader">Graduate or Undergraduate</fo:block>
						</fo:table-cell>
						<fo:table-cell xsl:use-attribute-sets="tableheadercell">
							<fo:block xsl:use-attribute-sets="normal tableheader">Grading Option
							</fo:block>
						</fo:table-cell>
						<fo:table-cell xsl:use-attribute-sets="tableheadercell">
							<fo:block xsl:use-attribute-sets="normal tableheader">Number of Credits /
								Units</fo:block>
						</fo:table-cell>
						<fo:table-cell xsl:use-attribute-sets="tableheadercell">
							<fo:block xsl:use-attribute-sets="normal tableheader">Instructor's Signature
								</fo:block>
							<fo:block xsl:use-attribute-sets="normal tableheader">(required)
								</fo:block>
						</fo:table-cell>
					</fo:table-row>
				</fo:table-header>
				<fo:table-body>
					<xsl:for-each select="current-group()">
						<fo:table-row>
							<fo:table-cell xsl:use-attribute-sets="coursetablecell">
								<fo:block xsl:use-attribute-sets="normal tablecontent"
									>
									<xsl:value-of select="course_number" />
									<xsl:if test="@school_abbr eq 'FAS'">
									<fo:inline> (<xsl:value-of select="fas_catalog_number"/>)</fo:inline>
									</xsl:if>
								</fo:block>
							</fo:table-cell>
							<fo:table-cell xsl:use-attribute-sets="coursetablecell">
								<fo:block xsl:use-attribute-sets="normal tablecontent"
									>
									<xsl:value-of select="title" />
								</fo:block>
								<fo:block xsl:use-attribute-sets="normal tablecontent instructor"
									>
									<xsl:value-of select="instructor" />
								</fo:block>
								<fo:block xsl:use-attribute-sets="normal tablecontent meeting_time"
									>
									<xsl:value-of select="meeting_time" />
								</fo:block>
							</fo:table-cell>
							<fo:table-cell xsl:use-attribute-sets="coursetablecell">
								<fo:block xsl:use-attribute-sets="normal tablecontent"
									>
									<xsl:choose>
										<xsl:when
											test="string-length(/data/course_list/course[@course_id = current()/@id]/@level_option) > 0">
											<xsl:value-of
												select="/data/course_list/course[@course_id = current()/@id]/@level_option" />
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="level" />
										</xsl:otherwise>
									</xsl:choose>
								</fo:block>
							</fo:table-cell>
							<fo:table-cell xsl:use-attribute-sets="coursetablecell">
								<fo:block xsl:use-attribute-sets="normal tablecontent"
                                                                  >
                                                                  <xsl:choose>
                                                                    <xsl:when test="string-length(/data/course_list/course[@course_id = current()/@id]/@grading_option) > 0">
                                                                      <xsl:value-of
                                                                        select="/data/course_list/course[@course_id = current()/@id]/@grading_option" />
                                                                    </xsl:when>
                                                                  </xsl:choose>

								</fo:block>
							</fo:table-cell>
							<fo:table-cell xsl:use-attribute-sets="coursetablecell">
								<fo:block xsl:use-attribute-sets="normal tablecontent"
									>
									<xsl:value-of select="credit" />
								</fo:block>
							</fo:table-cell>
							<fo:table-cell xsl:use-attribute-sets="coursetablecell">
								<fo:block xsl:use-attribute-sets="normal tablecontent" color="#000000">
									&#160;
								</fo:block>
							</fo:table-cell>
						</fo:table-row>
					</xsl:for-each>
				</fo:table-body>
			</fo:table>
			<xsl:call-template name="signatures" >
				<xsl:with-param name="hostschool"  select="current-group()[1]/@school" />
			</xsl:call-template>
	      </xsl:if>
		</xsl:for-each-group>
	</xsl:template>

	<xsl:template name="person_info">
		<fo:table space-before="12pt">
			<fo:table-column column-width="5in" />
			<fo:table-column column-width="5in" />
			<fo:table-body>
				<fo:table-row>
					<fo:table-cell>
						<fo:table>
							<fo:table-column column-width="1in" />
							<fo:table-column column-width="3.5in" />
							<fo:table-body>
<fo:table-row>
  <fo:table-cell xsl:use-attribute-sets="infotablecell">
    <fo:block xsl:use-attribute-sets="normal">Name:</fo:block>
  </fo:table-cell>
  <fo:table-cell xsl:use-attribute-sets="infotablecellfill" border-top-style="none">
    <fo:block xsl:use-attribute-sets="normal">
      <xsl:value-of select="/data/person/formatted_name" />
    </fo:block>
  </fo:table-cell>
</fo:table-row>
<fo:table-row>
  <fo:table-cell xsl:use-attribute-sets="infotablecell">
										<fo:block xsl:use-attribute-sets="normal">HUID:</fo:block>
									</fo:table-cell>
									<fo:table-cell xsl:use-attribute-sets="infotablecellfill">
										<fo:block xsl:use-attribute-sets="normal">
											<xsl:value-of select="/data/person/huid" />
										</fo:block>
									</fo:table-cell>
								</fo:table-row>
								<fo:table-row>
									<fo:table-cell xsl:use-attribute-sets="infotablecell">
										<fo:block xsl:use-attribute-sets="normal">Email:</fo:block>
									</fo:table-cell>
									<fo:table-cell xsl:use-attribute-sets="infotablecellfill">
										<fo:block xsl:use-attribute-sets="normal">
											<xsl:value-of select="/data/person/email" />
										</fo:block>
									</fo:table-cell>
								</fo:table-row>
								<fo:table-row>
									<fo:table-cell xsl:use-attribute-sets="infotablecell">
										<fo:block xsl:use-attribute-sets="normal">Phone:</fo:block>
									</fo:table-cell>
									<fo:table-cell xsl:use-attribute-sets="infotablecellfill">
										<fo:block xsl:use-attribute-sets="normal">
											<xsl:value-of select="/data/person/phone" />
										</fo:block>
									</fo:table-cell>
								</fo:table-row>
							</fo:table-body>
						</fo:table>
					</fo:table-cell>
					<fo:table-cell>
						<fo:table>
							<fo:table-column column-width="1.25in" />
							<fo:table-column column-width="3.5in" />
							<fo:table-body>
								<fo:table-row>
									<fo:table-cell xsl:use-attribute-sets="infotablecell">
										<fo:block xsl:use-attribute-sets="normal">Home School:
										</fo:block>
									</fo:table-cell>
									<fo:table-cell xsl:use-attribute-sets="infotablecellfill" border-top-style="none">
										<fo:block xsl:use-attribute-sets="normal">
											<xsl:value-of select="$homeschool" />
										</fo:block>
									</fo:table-cell>
								</fo:table-row>
								<fo:table-row>
									<fo:table-cell xsl:use-attribute-sets="infotablecell">
										<fo:block xsl:use-attribute-sets="normal">Host School:
										</fo:block>
									</fo:table-cell>
									<fo:table-cell xsl:use-attribute-sets="infotablecellfill">
										<fo:block xsl:use-attribute-sets="normal">
											<xsl:value-of select="current-group()[1]/@school" />
										</fo:block>
									</fo:table-cell>
								</fo:table-row>
								<fo:table-row>
									<fo:table-cell xsl:use-attribute-sets="infotablecell">
										<fo:block xsl:use-attribute-sets="normal">Semester/Year:
										</fo:block>
									</fo:table-cell>
									<fo:table-cell xsl:use-attribute-sets="infotablecellfill">
										<fo:block xsl:use-attribute-sets="normal">
											<xsl:value-of select="current-group()[1]/@term" />
										</fo:block>
									</fo:table-cell>
								</fo:table-row>
								<xsl:if test="string-length(/data/person/degree_program) > 0">
									<fo:table-row>
										<fo:table-cell xsl:use-attribute-sets="infotablecell">
											<fo:block xsl:use-attribute-sets="normal">Program:</fo:block>
										</fo:table-cell>
										<fo:table-cell xsl:use-attribute-sets="infotablecellfill">
											<fo:block xsl:use-attribute-sets="normal">
												<xsl:value-of select="/data/person/degree_program" />
											</fo:block>
										</fo:table-cell>
									</fo:table-row>
									<fo:table-row>
										<fo:table-cell xsl:use-attribute-sets="infotablecell">
											<fo:block xsl:use-attribute-sets="normal">Advisor Name:
											</fo:block>
										</fo:table-cell>
										<fo:table-cell xsl:use-attribute-sets="infotablecellfill">
											<fo:block xsl:use-attribute-sets="normal">
												<xsl:value-of select="/data/person/advisor_name" />
											</fo:block>
										</fo:table-cell>
									</fo:table-row>
								</xsl:if>
							</fo:table-body>
						</fo:table>
					</fo:table-cell>
				</fo:table-row>
			</fo:table-body>
		</fo:table>


	</xsl:template>
	<xsl:template name="signatures">
	    <xsl:param name="hostschool" select="HOST"/>
		<fo:block padding-before="0.125in" xsl:use-attribute-sets="agreement"><fo:inline font-weight="bold">Student signature required:</fo:inline>  I am a current full-time or part-time student. I have read the relevant rules on cross registration and wish to enroll in the course(s) listed
above. I understand that I must meet the earliest cross registration or add/drop/change deadline and must abide by the policies of both my HOME school <xsl:if test="$homeschool">(<xsl:value-of select="$homeschool"/>)</xsl:if> and the
HOST school <xsl:if test="$hostschool">(<xsl:value-of select="$hostschool"/>)</xsl:if>. I certify that the course listed does not overlap in coursework that I am taking or have taken, and that the course
does not conflict with my HOME school <xsl:if test="$homeschool">(<xsl:value-of select="$homeschool"/>)</xsl:if> course or exam schedule.</fo:block>
<fo:block padding-before="0.125in" xsl:use-attribute-sets="agreement">Students are expected to attend classes they wish to cross-register into during the first week of classes; a failure to do so may result in the instructor refusing to sign
this form. Host schools may for any reason (including a student's failure to attend class during the first week) refuse to accept the cross-registration, even if it is
signed by the instructor.</fo:block>
		<fo:table>
			<fo:table-column column-width="5in" />
			<fo:table-column column-width="5in" />
			<fo:table-body>
				<fo:table-row>
					<fo:table-cell>
						<fo:table>
							<fo:table-column column-width="3.35in" />
							<fo:table-column column-width="1.35in" />
							<fo:table-body>
								<fo:table-row>
									<fo:table-cell padding-before="0.5in"
										padding-right="0.25in">
										<fo:block border-top="1pt solid black"
											xsl:use-attribute-sets="signaturetext">Student's Signature</fo:block>
									</fo:table-cell>
									<fo:table-cell padding-before="0.5in"
										padding-right="0.25in">
										<fo:block border-top="1pt solid black"
											xsl:use-attribute-sets="signaturetext">Date</fo:block>
									</fo:table-cell>
								</fo:table-row>

							</fo:table-body>
						</fo:table>
					</fo:table-cell>
					<xsl:if test="$homeschool_code eq 'HSDM' or $homeschool_code eq 'hsdm'">
					<fo:table-cell>
						<fo:table>
							<fo:table-column column-width="3.35in" />
							<fo:table-column column-width="1.35in" />
							<fo:table-body>
								<fo:table-row>
									<fo:table-cell padding-before="0.5in"
										padding-right="0.25in">
										<fo:block border-top="1pt solid black"
											xsl:use-attribute-sets="signaturetext">Advisor's Signature
										</fo:block>
										<fo:block xsl:use-attribute-sets="signaturetext">(Only required for HSDM students)</fo:block>
									</fo:table-cell>
									<fo:table-cell padding-before="0.5in"
										padding-right="0.25in">
										<fo:block border-top="1pt solid black"
											xsl:use-attribute-sets="signaturetext">Date</fo:block>
									</fo:table-cell>
								</fo:table-row>
							</fo:table-body>
						</fo:table>
					</fo:table-cell>
					</xsl:if>
				</fo:table-row>
			</fo:table-body>
		</fo:table>
	</xsl:template>
</xsl:stylesheet>
