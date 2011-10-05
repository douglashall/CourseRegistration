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
			def levelOptions = studentCourse.levelOptions
			if (levelOptions.size() == 1) {
				studentCourse.levelOption = levelOptions[0].name
			}
			def gradingOptions = studentCourse.gradingOptions
			if (gradingOptions.size() == 1) {
				studentCourse.gradingOption = gradingOptions[0].name
			}
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
	
	def createRegistrationContext(List<Long> studentCourses) {
		if (!studentCourses || studentCourses.size() == 0) {
			return null;
		}
		
		def ctx = new RegistrationContext()
		studentCourses.each {
			it.addToRegistrationStates(new RegistrationState(state: 'pending', createdBy: it.userId))
			ctx.addToStudentCourses(it)
		}
		ctx.save(flush:true)
		return ctx
	}
	
}
