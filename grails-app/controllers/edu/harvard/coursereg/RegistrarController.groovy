package edu.harvard.coursereg

import grails.converters.*
import org.codehaus.groovy.grails.web.json.*

class RegistrarController {
	
	RegistrationService registrationService
	
	def list = {
		params.hostSchool = request.schoolAffiliation
		def result = this.registrationService.searchStudentCourses(params)
		def model = [total: result.total, root: result.records]
		withFormat {
			html {[studentCourses: result.records, topicId:params.topicId]}
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
	
	def export = {
		def studentCourses = this.registrationService.searchStudentCourses(params).records
		def buffer = new StringBuffer()
		buffer.append("Status\tStudent HUID\tStudent First Name\tStudent Last Name\tStudent Email\tHome School\tSubmitted On\tGrading Option\tCourse\tFaculty Name\tFaculty Email\tTerm\n")
		studentCourses.each {
			buffer.append("${it.state}\t${it.studentHuid}\t${it.studentFirstName}\t${it.studentLastName}\t${it.studentEmail}\t${it.homeSchool}\t${it.petitionCreated}\t${it.gradingOption}\t${it.courseShortTitle}\t${it.instructorName}\t${it.instructorEmail}\t${it.term}\n")
		}
		
		def now = new Date()
		response.setHeader("Content-Disposition", "attachment; filename=crossreg_${now.getTime()}.xls")
		render(contentType: "application/vnd.ms-excel", text: buffer.toString())
	}
	
	def process = {
		def model = []
		def ids = params.ids.trim().tokenize().collect {Long.parseLong(it)}
		def studentCourses = StudentCourse.findAllByIdInList(ids)
		
		studentCourses.each {
			def ctx = it.registrationContext
			ctx.processed = 1
			ctx.dateProcessed = new Date()
			ctx.processedBy = request.userId
			ctx.save()
			model << it
		}
		this.registrationService.updateStudentCourseIndex(studentCourses)
		
		withFormat {
			form {redirect(action:list)}
			html {redirect(action:list)}
			json {
				JSON.use("deep") {
					render(contentType: "application/json"){model} as JSON
				}
			}
			xml {
				XML.use("deep") {
					render(contentType: "application/xml"){model} as XML
				}
			}
		}
	}
	
}
