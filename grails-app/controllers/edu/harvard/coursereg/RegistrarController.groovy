package edu.harvard.coursereg

import grails.converters.*
import org.codehaus.groovy.grails.web.json.*

class RegistrarController {
	
	RegistrationService registrationService
	
	def list = {
		def studentCourses = this.registrationService.searchStudentCourses()
		withFormat {
			html {[studentCourses: studentCourses, topicId:params.topicId]}
			json {
				JSON.use("deep") {
					render studentCourses as JSON
				}
			}
			xml {
				XML.use("deep") {
					render studentCourses as XML
				}
			}
		}
	}
	
}
