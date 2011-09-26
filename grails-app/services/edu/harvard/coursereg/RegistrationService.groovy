package edu.harvard.coursereg

import static groovyx.net.http.ContentType.JSON

import org.codehaus.groovy.grails.commons.ConfigurationHolder

import edu.harvard.icommons.coursedata.CourseInstance
import groovyx.net.http.*

class RegistrationService {

    static transactional = true
	
	def config = ConfigurationHolder.config
	
	def addCourseForStudent(String userId, CourseInstance ci) {
		StudentCourse studentCourse = StudentCourse.createCriteria().get {
			eq("userId", userId)
			eq("courseInstance", ci)
			eq("active", 1)
		}
		if (!studentCourse) {
			studentCourse = new StudentCourse(userId:userId, courseInstance:ci)
			studentCourse.save(flush:true)
		}
		return studentCourse
	}
	
	def removeCourseForStudent(String userId, CourseInstance ci) {
		def studentCourses = StudentCourse.createCriteria().list {
			eq("userId", userId)
			eq("courseInstance", ci)
			eq("active", 1)
		}
		studentCourses.each {
			it.active = 0
			it.save()
		}
	}
	
	def findPeopleForStudentCourses(List<StudentCourse> studentCourses) {
		
	}
	
}
