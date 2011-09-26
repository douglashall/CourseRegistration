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
			where sc.active = 1", [request.userId])
		CourseRegistrationUtils.findPeopleForStudentCourses(studentCourses)
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
	
}
