package edu.harvard.coursereg

import static groovyx.net.http.ContentType.JSON
import groovyx.net.http.HTTPBuilder
import groovyx.net.http.Method

import org.codehaus.groovy.grails.commons.ConfigurationHolder

class CourseRegistrationUtils {

	def static config = ConfigurationHolder.config
	
	def static findPeopleForStudentCourses(List<StudentCourse> studentCourses) {
		studentCourses.each {studentCourse ->
			def http = new HTTPBuilder(config.icommonsapi.url + "/people/by_id/" + studentCourse.userId)
			http.request(Method.GET, JSON) {
				response.success = {resp, json ->
					json.people.each {person ->
						studentCourse.student = [
							'id': person.id,
							'firstName': person.firstName,
							'lastName': person.lastName,
							'email': person.email,
							'school': 'EXT'
						]
					}
				}
			}
		}
	}
	
}
