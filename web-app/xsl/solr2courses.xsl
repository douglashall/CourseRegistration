<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:cracc="http://cracc.isites.harvard.edu">

	<xsl:function name="cracc:course_no_display">
		<xsl:param name="string1" />
		<xsl:choose>
			<xsl:when test="contains($string1,'|')">
				<xsl:value-of select="substring-before($string1,'|')" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$string1" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>

	<xsl:template match="/">
		<data>
			<xsl:copy-of select="/petition/data/*" />
			<xsl:apply-templates select="/petition/response" />
		</data>
	</xsl:template>


	<xsl:template match="result">
		<courses>
			<xsl:apply-templates select="doc"/>
		</courses>
	</xsl:template>
	<xsl:template match="doc">
		<!--
		<course school="FAS" term="Fall Term 2010"> 
		<course_number>English 101</course_number> 
		<fas_catalog_number>12345</fas_catalog_number>
		<title>Introduction to English Gramer and Speling</title>
		<level>U</level> 
		<grading></grading> 
		<credit>half course</credit>
		<signature>required</signature> 
		</course>
	-->
		<course>
			<xsl:attribute name="id"><xsl:value-of
				select="str[@name = 'id']/text()" /></xsl:attribute>
			<xsl:attribute name="school"><xsl:value-of
				select="str[@name = 'school_nm']/text()" /></xsl:attribute>
			<xsl:attribute name="school_abbr"><xsl:value-of
				select="str[@name = 'school_short_name']/text()" /></xsl:attribute>
			<xsl:attribute name="term"><xsl:value-of
				select="str[@name = 'term_desc']/text()" /></xsl:attribute>
			<course_number><xsl:value-of select="cracc:course_no_display(str[@name='course_no'])"/></course_number>
			<fas_catalog_number><xsl:value-of select="str[@name='fas_cat_no']"/></fas_catalog_number>
			<title><xsl:value-of select="str[@name='course_title']"/></title>
			<level>
			    <xsl:choose>
				<xsl:when test="str[@name='grad_undergrad_fl'] eq 'U'">Undergraduate</xsl:when>
				<xsl:when test="str[@name='grad_undergrad_fl'] eq 'G'">Graduate</xsl:when>
				<xsl:otherwise>  </xsl:otherwise>
				</xsl:choose>
			</level>
			<credit><xsl:value-of select="str[@name='credits']"/></credit>
			<school><xsl:value-of select="str[@name='school_nm']"/></school>
			<term><xsl:value-of select="str[@name='term_desc']"/></term>
			<instructor><xsl:value-of select="str[@name='instructor']"/></instructor>
            <meeting_time><xsl:value-of select="concat(str[@name='course_meeting_days'],' ',str[@name='course_time'])"/></meeting_time>
			<xsl:apply-templates />
		</course>
	</xsl:template>
	<xsl:template match="*[@name='responseHeader']" />
	<xsl:template match="text()" />
</xsl:stylesheet>
