package edu.harvard.coursereg

import org.codehaus.groovy.grails.web.json.*

import edu.harvard.icommons.coursedata.CourseInstance
import grails.converters.*
import groovyx.net.http.HTTPBuilder
import groovyx.net.http.Method

class CourseController {
	
	RegistrationService registrationService
	
	def add = {
		def ci = CourseInstance.get(params.id)
		this.registrationService.addCourseForStudent(request.userId, ci)
		forward(action: "catalogList")
	}
	
	def remove = {
		def ci = CourseInstance.get(params.id)
		this.registrationService.removeCourseForStudent(request.userId, ci)
		forward(action: "catalogList")
	}
	
	def catalogList = {
		def result = []
		def terminalMap = [:]
		def studentCourses = this.registrationService.findAllActiveStudentCoursesForStudent(request.userId)
		
		if (studentCourses.size() > 0) {
			def queryString = []
			studentCourses.each {
				queryString << ('course_instance_id:' + it.courseInstance.id)
				terminalMap[String.valueOf(it.courseInstance.id)] = it.state ? it.state.terminal == 1 : false
			}
			def http = new HTTPBuilder(grailsApplication.config.catalog.url + "/select?q=" + URLEncoder.encode(queryString.join(" OR "), 'UTF-8'))
			http.request(Method.GET, groovyx.net.http.ContentType.XML) {
				response.success = {resp, xml ->
					xml.result.doc.each {
						result.add([
							courseInstanceId: it.str.find {it.@name.text() == "course_instance_id"}.text(),
							catalogId: it.str.find {it.@name.text() == "id"}.text()
						])
					}
				}
			}
		}
		
		withFormat {
			json {
				render result as JSON
			}
			xml {
				render(contentType:"application/xml"){
					courselist(size: result.size()){
						for(c in result) {
							course(course_id: c.catalogId, terminal: terminalMap[c.courseInstanceId])
						}
					}
				}
			}
		}
	}
	
}
