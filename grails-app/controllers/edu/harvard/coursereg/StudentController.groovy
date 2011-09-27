package edu.harvard.coursereg

import grails.converters.*

import org.codehaus.groovy.grails.web.json.*

class StudentController {
	
	RegistrationService registrationService
	
	def list = {
		def studentCourses = StudentCourse.findAllByUserIdAndActive(request.userId, 1)
		def model = new TreeMap(studentCourses.groupBy {it.termDisplay})
		withFormat {
			html {[model: model, topicId:params.topicId]}
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
