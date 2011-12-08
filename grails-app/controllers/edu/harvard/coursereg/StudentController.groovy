package edu.harvard.coursereg

import static groovyx.net.http.ContentType.XML
import edu.harvard.grails.plugins.baseline.BaselineUtils
import grails.converters.*
import groovy.text.GStringTemplateEngine
import groovy.xml.XmlUtil
import groovyx.net.http.HTTPBuilder
import groovyx.net.http.Method

import javax.xml.transform.Result
import javax.xml.transform.Source
import javax.xml.transform.Transformer
import javax.xml.transform.TransformerFactory
import javax.xml.transform.sax.SAXResult
import javax.xml.transform.stream.StreamResult
import javax.xml.transform.stream.StreamSource

import org.apache.fop.apps.Fop
import org.apache.fop.apps.FopFactory
import org.apache.fop.apps.MimeConstants
import org.codehaus.groovy.grails.web.json.*

class StudentController {
	
	RegistrationService registrationService
	
	def list = {
		def studentCourses = StudentCourse.findAllByUserIdAndActive(request.userId, 1)
		
		if (studentCourses.size() > 1) {
			def student = studentCourses[0].student
			studentCourses.each {
				it.student = student
			}
		}
		
		studentCourses.each {
			if (it.schoolOptions.size() == 0) {
				it.schoolOptions = BaselineUtils.schools
			}
		}
		
		def regStudent = RegistrationStudent.findByUserId(request.userId)
		
		def model = new TreeMap(studentCourses.groupBy {it.termDisplay})
		withFormat {
			html {[model: model, topicId:params.topicId, regStudent: regStudent]}
			json {
				JSON.use("deep") {
					render model as JSON
				}
			}
			xml {
				XML.use("deep") {
					render model as XML
				}
			}
		}
	}
	
	def register = {
		def studentCourse = StudentCourse.findAllByUserIdAndActive(request.userId, 1).find {
			!it.state &&
			it.courseInstance.id.equals(Long.parseLong(params.id))
		}
		
		if (studentCourse) {
			studentCourse.programDepartment = params.programDepartment
			studentCourse.degreeYear = params.degreeYear ? Long.parseLong(params.degreeYear) : null
			if (!studentCourse.levelOption && params.levelOption) {
				studentCourse.levelOption = studentCourse.getLevelOptions().find {it.id == Integer.parseInt(params.levelOption)}.name
			}
			if (!studentCourse.gradingOption && params.gradingOption) {
				studentCourse.gradingOption = studentCourse.getGradingOptions().find {it.id == params.gradingOption}.name
			}
			if (!studentCourse.homeSchoolId && params.homeSchoolId) {
				studentCourse.homeSchoolId = params.homeSchoolId
			}
			
			def regStudent = RegistrationStudent.findByUserId(request.userId)
			if (!regStudent) {
				regStudent = new RegistrationStudent(userId: request.userId)
			}
			regStudent.homeSchoolId = studentCourse.homeSchoolId
			regStudent.programDepartment = studentCourse.programDepartment
			regStudent.degreeYear = studentCourse.degreeYear
			regStudent.save()
			
			def ctx = new RegistrationContext()
			ctx.addToStudentCourses(studentCourse)
			ctx.save(flush:true)
			
			this.registrationService.submit(ctx, request.userId)
		}
		
		withFormat {
			form {redirect(action:list)}
			html {redirect(action:list)}
			json {
				JSON.use("deep") {
					render(contentType: "application/json"){studentCourse} as JSON
				}
			}
			xml {
				XML.use("deep") {
					render(contentType: "application/xml"){studentCourse} as XML
				}
			}
		}
	}
	
	def showPetitionForm = {
		def solrXml
		def studentCourse = StudentCourse.get(params.id)
		def person = studentCourse.getStudent()
		def http = new HTTPBuilder(grailsApplication.config.catalog.url + "/select?q=course_instance_id:" + studentCourse.courseInstance.id + "&sort=course_title+asc")
		http.request(Method.GET, groovyx.net.http.ContentType.XML) {
			response.success = {resp, xml ->
				solrXml = xml
			}
		}
		
		StringWriter courses = new StringWriter()
		def input = new XmlSlurper().parseText("<petition></petition>")
		def personInfoFile = grailsAttributes.getApplicationContext().getResource("xml/person_information.xml").getFile()
		def engine = new GStringTemplateEngine()
		def binding = [
			"huid": person.id,
			"firstName": person.firstName,
			"lastName": person.lastName,
			"formattedName": person.firstName + " " + person.lastName,
			"homeSchool": person.school,
			"phone": person.phone,
			"email": person.email,
			"courseId": solrXml.result.doc.str.find {it.@name.text() == "id"}.text(),
			"levelOption": params.levelOption ? studentCourse.getLevelOptions().find {it.id == Integer.valueOf(params.levelOption)}.name : "",
			"gradingOption": params.gradingOption ? studentCourse.getGradingOptions().find {it.id == Integer.valueOf(params.gradingOption)}.name : ""
		]
		def template = engine.createTemplate(personInfoFile).make(binding)
		input.appendNode(new XmlSlurper().parseText(template.toString()))
		input.appendNode(solrXml)
		
		def factory = TransformerFactory.newInstance()
		def solr2courses = grailsAttributes.getApplicationContext().getResource("xsl/solr2courses.xsl").getFile()
		def transformer = factory.newTransformer(new StreamSource(solr2courses))
		transformer.transform(new StreamSource(new StringReader(XmlUtil.serialize(input))), new StreamResult(courses))
		
		FopFactory fopFactory = FopFactory.newInstance()
		response.contentType = "application/pdf"
		OutputStream out = new BufferedOutputStream(response.outputStream)
		def xregFormFo = grailsAttributes.getApplicationContext().getResource("xsl/xreg_form_fo.xsl").getFile()
		try {
			Fop fop = fopFactory.newFop(MimeConstants.MIME_PDF, out)
			TransformerFactory foFactory = TransformerFactory.newInstance()
			Transformer foTransformer = foFactory.newTransformer(new StreamSource(xregFormFo))
			Source src = new StreamSource(new StringReader(courses.toString()))
			Result res = new SAXResult(fop.getDefaultHandler())
			foTransformer.transform(src, res)
		} finally {
			out.close()
		}
	}
	
}
