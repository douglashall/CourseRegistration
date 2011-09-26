package edu.harvard.coursereg

import org.codehaus.groovy.grails.web.json.*

import edu.harvard.icommons.coursedata.CourseInstance
import grails.converters.*

class CourseController {
	
	RegistrationService registrationService
	
	def add = {
		def ci = CourseInstance.get(params.id)
		def studentCourse = this.registrationService.addCourseForStudent(request.userId, ci)
		withFormat {
			form {render(contentType: "application/json"){studentCourse} as JSON}
			html {render(contentType: "application/json"){studentCourse} as JSON}
			json {render(contentType: "application/json"){studentCourse} as JSON}
			xml {render(contentType: "application/xml"){studentCourse} as XML}
		}
	}
	
	def remove = {
		def ci = CourseInstance.get(params.id)
		this.registrationService.removeCourseForStudent(request.userId, ci)
		withFormat {
			form {render(contentType: "application/json"){[success:true]} as JSON}
			html {render(contentType: "application/json"){[success:true]} as JSON}
			json {render(contentType: "application/json"){[success:true]} as JSON}
			xml {render(contentType: "application/xml"){[success:true]} as XML}
		}
	}
	
}
