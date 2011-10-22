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
		def studentCourse = StudentCourse.findAllByUserIdAndActive(request.userId, 1).find {
			!it.state &&
			it.courseInstance.id.equals(Long.parseLong(params.id))
		}
		
		if (studentCourse) {
			if (!studentCourse.levelOption && params.levelOption) {
				studentCourse.levelOption = studentCourse.getLevelOptions().find {it.id == Integer.parseInt(params.levelOption)}.name
			}
			if (!studentCourse.gradingOption && params.gradingOption) {
				studentCourse.gradingOption = studentCourse.getGradingOptions().find {it.id == Integer.parseInt(params.gradingOption)}.name
			}
			if (!studentCourse.homeSchoolId && params.homeSchoolId) {
				studentCourse.homeSchoolId = Long.parseLong(params.homeSchoolId)
			}
			
			def ctx = new RegistrationContext()
			ctx.addToStudentCourses(studentCourse)
			ctx.save(flush:true)
			this.registrationService.updateRegistrationContextState("register", ctx, request.userId)
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
	
}
