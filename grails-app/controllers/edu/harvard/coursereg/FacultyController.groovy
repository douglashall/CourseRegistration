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
		def model = []
		def ids = params.ids.trim().tokenize().collect {Long.parseLong(it)}
		def studentCourses = StudentCourse.findAllByIdInList(ids)
		
		studentCourses.each {
			def ctx = it.registrationContext
			this.registrationService.facultyApprove(ctx, request.userId)
			model << it
		}
		
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
	
	def deny = {
		def model = []
		def ids = params.ids.trim().tokenize().collect {Long.parseLong(it)}
		def studentCourses = StudentCourse.findAllByIdInList(ids)
		
		studentCourses.each {
			def ctx = it.registrationContext
			this.registrationService.facultyDeny(ctx, request.userId)
			model << it
		}
		
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
