package edu.harvard.coursereg

import edu.harvard.icommons.coursedata.CourseStaff
import grails.converters.*

import org.codehaus.groovy.grails.web.json.*

class FacultyController {
	
	RegistrationService registrationService
	
	def list = {
		def studentCourses = StudentCourse.executeQuery("\
			select sc from StudentCourse as sc \
			join sc.courseInstance as ci \
			join ci.staff as staff \
				with staff.userId = ? \
			where sc.active = 1", [request.userId]
		).findAll {
			it.state
		}
		def model = new TreeMap(studentCourses.groupBy {
			def prefix = it.courseInstance.shortTitle ? it.courseInstance.shortTitle : it.courseInstance.course.registrarCode
			prefix + " / " + it.courseInstance.term.displayName
		})
		withFormat {
			html {[model:model, topicId:params.topicId]}
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
	
	def approve = {
		def studentCourse = StudentCourse.get(params.id)
		
		if (studentCourse) {
			def ctx = studentCourse.registrationContext
			this.registrationService.updateRegistrationContextState("faculty_approve", ctx, request.userId)
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
	
	def deny = {
		def studentCourse = StudentCourse.get(params.id)
		
		if (studentCourse) {
			def ctx = studentCourse.registrationContext
			this.registrationService.updateRegistrationContextState("faculty_deny", ctx, request.userId)
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
