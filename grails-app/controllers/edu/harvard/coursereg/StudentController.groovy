package edu.harvard.coursereg

import grails.converters.*

import org.codehaus.groovy.grails.web.json.*

class StudentController {
	
	RegistrationService registrationService
	
	def list = {
		def studentCourses = StudentCourse.findAllByUserIdAndActive(request.userId, 1)
		withFormat {
			html {[studentCourseList:studentCourses, topicId:params.topicId]}
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
	
	def register = {
		//def p = new Petition(new JSONObject(params.petition))
		p.userId = request.userId
		this.petitionService.create(p)
		
		def result = ['state': p.state().title]
		withFormat {
			form {redirect(action:list)}
			html {redirect(action:list)}
			json {render(contentType: "application/json"){result} as JSON}
			xml {render(contentType: "application/xml"){result} as XML}
		}
	}
	
}
