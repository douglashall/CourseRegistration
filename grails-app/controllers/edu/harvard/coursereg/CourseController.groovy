package edu.harvard.coursereg

import org.codehaus.groovy.grails.web.json.*

import edu.harvard.icommons.coursedata.CourseInstance
import grails.converters.*

class CourseController {
	
	RegistrationService registrationService
	
	def add = {
		def ci = CourseInstance.get(params.id)
		this.registrationService.addCourseForStudent(request.userId, ci)
		def studentCourses = StudentCourse.findAllByUserIdAndActive(request.userId, 1)
		withFormat {
			form {render(contentType: "application/json"){studentCourses} as JSON}
			html {render(contentType: "application/json"){studentCourses} as JSON}
			json {render(contentType: "application/json"){studentCourses} as JSON}
			xml {render(contentType: "application/xml"){studentCourses} as XML}
		}
	}
	
	def remove = {
		def ci = CourseInstance.get(params.id)
		this.registrationService.removeCourseForStudent(request.userId, ci)
		def studentCourses = StudentCourse.findAllByUserIdAndActive(request.userId, 1)
		withFormat {
			form {render(contentType: "application/json"){studentCourses} as JSON}
			html {render(contentType: "application/json"){studentCourses} as JSON}
			json {render(contentType: "application/json"){studentCourses} as JSON}
			xml {render(contentType: "application/xml"){studentCourses} as XML}
		}
	}
	
	def client = {
		
	}
	
}
