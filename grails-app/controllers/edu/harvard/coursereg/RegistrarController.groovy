package edu.harvard.coursereg

import grails.converters.*
import org.codehaus.groovy.grails.web.json.*

class RegistrarController {
	
	RegistrationService registrationService
	
	def list = {
		def studentCourses = this.registrationService.searchStudentCourses(params.query, params.status, params.school)
		def model = [root: studentCourses]
		withFormat {
			html {[studentCourses: studentCourses, topicId:params.topicId]}
			json {
				JSON.use("deep") {
					render model as JSON
				}
			}
			xml {
				XML.use("deep") {
					render studentCourses as XML
				}
			}
		}
	}
	
	def export = {
		def studentCourses = this.registrationService.searchStudentCourses(null, null, null)
		def buffer = new StringBuffer()
		buffer.append("Status\tStudent HUID\tStudent First Name\tStudent Last Name\tStudent Email\tHome School\tSchool\tCourse\tTerm\tFaculty Name\tFaculty Email\n")
		studentCourses.each {
			buffer.append("${it.state}\t${it.studentHuid}\t${it.studentFirstName}\t${it.studentLastName}\t${it.studentEmail}\t${it.homeSchool}\t${it.courseSchool}\t${it.courseShortTitle}\t${it.term}\t${it.instructorName}\t${it.instructorEmail}\n")
		}
		
		def now = new Date()
		response.setHeader("Content-Disposition", "attachment; filename=crossreg_${now.getTime()}.xls")
		render(contentType: "application/vnd.ms-excel", text: buffer.toString())
	}
	
}
