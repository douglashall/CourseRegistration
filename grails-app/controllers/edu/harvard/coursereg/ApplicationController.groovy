package edu.harvard.coursereg

import org.codehaus.groovy.grails.web.json.*

import edu.harvard.grails.plugins.baseline.BaselineUtils
import edu.harvard.icommons.coursedata.CourseInstance
import grails.converters.*
import groovyx.net.http.HTTPBuilder
import groovyx.net.http.Method

import courseregistration.SendFacultyNotificationsJob

class ApplicationController {
	
	RegistrationService registrationService
	
	def ldapCodes = [
		BUS: 11,
		COL: 7,
		DES: 8,
		DIV: 13,
		DMD: 18,
		ECS: 5,
		EDU: 9,
		FAS: 7,
		FGS: 7,
		HMS: 17,
		KSG: 15,
		LAW: 16,
		RAD: 22,
		SPH: 19
	]
	
	def reloadConfig = {
		def locations = grailsApplication.config.grails.config.locations
		locations.each {
			String configFileName
			if (it.startsWith("classpath:")) {
				configFileName = it.split("classpath:")[1]
			} else {
				configFileName = it.split("file:")[1]
			}
			File configFile = new File(configFileName)
			if (configFile.exists()) {
				grailsApplication.config.merge(new ConfigSlurper().parse(configFile.text))
			}
		}
		
		render(contentType: "application/json") {["success": true]} as JSON
	}
	
	def updateSolrIndex = {
		def studentCourses = []
		def contexts = RegistrationContext.findAll("\
			from RegistrationContext as ctx\
			where ctx.registrationContextStates.size > 0\
		")
		contexts.each {
			it.studentCourses.findAll {it.active == 1}.each {studentCourses << it}
		}
		this.registrationService.updateStudentCourseIndex(studentCourses)
		render "success"
	}
	
	def triggerFacultyEmailJob = {
		SendFacultyNotificationsJob.triggerNow()
		render "job started"
	}
	
	def loadDemoData = {
		def http = new HTTPBuilder("http://localhost")
		
		def fasStudents =[]
		http.request(Method.GET, groovyx.net.http.ContentType.JSON) {
			uri.path = '/fas_students.json'
			response.success = {resp, json ->
				json.students.each {item ->
					fasStudents << item
				}
			}
		}
		
		def gseStudents =[]
		http.request(Method.GET, groovyx.net.http.ContentType.JSON) {
			uri.path = '/gse_students.json'
			response.success = {resp, json ->
				json.students.each {item ->
					gseStudents << item
				}
			}
		}
		
		def hdsStudents =[]
		http.request(Method.GET, groovyx.net.http.ContentType.JSON) {
			uri.path = '/hds_students.json'
			response.success = {resp, json ->
				json.students.each {item ->
					hdsStudents << item
				}
			}
		}
		
		def hsphStudents =[]
		http.request(Method.GET, groovyx.net.http.ContentType.JSON) {
			uri.path = '/hsph_students.json'
			response.success = {resp, json ->
				json.students.each {item ->
					hsphStudents << item
				}
			}
		}
		
		def gseCourses =[]
		http.request(Method.GET, groovyx.net.http.ContentType.JSON) {
			uri.path = '/gse_courses.json'
			response.success = {resp, json ->
				json.each {item ->
					gseCourses << CourseInstance.get(item)
				}
			}
		}
		
		def hdsCourses =[]
		http.request(Method.GET, groovyx.net.http.ContentType.JSON) {
			uri.path = '/hds_courses.json'
			response.success = {resp, json ->
				json.each {item ->
					hdsCourses << CourseInstance.get(item)
				}
			}
		}
		
		def hsphCourses =[]
		http.request(Method.GET, groovyx.net.http.ContentType.JSON) {
			uri.path = '/hsph_courses.json'
			response.success = {resp, json ->
				json.each {item ->
					hsphCourses << CourseInstance.get(item)
				}
			}
		}
		
		def studentCourses = []
		def now = new Date()
		def random = new Random(now.getTime())
		
		def gseEnrollees = fasStudents + hdsStudents + hsphStudents
		def size = gseEnrollees.size()
		gseCourses.each {
			for (i in 0..1) {
				def student = gseEnrollees[random.nextInt(size)]
				def ci = CourseInstance.get(it.id)
				def studentCourse = this.registrationService.addCourseForStudent(student.id, ci)
				studentCourse.homeSchoolId = ldapCodes[student.schoolAffiliations[0]]
				studentCourse.save()
				studentCourses << studentCourse
			}
		}
		
		def hdsEnrollees = fasStudents + gseStudents + hsphStudents
		size = hdsEnrollees.size()
		hdsCourses.each {
			for (i in 0..1) {
				def student = hdsEnrollees[random.nextInt(size)]
				def ci = CourseInstance.get(it.id)
				def studentCourse = this.registrationService.addCourseForStudent(student.id, ci)
				studentCourse.homeSchoolId = ldapCodes[student.schoolAffiliations[0]]
				studentCourse.save()
				studentCourses << studentCourse
			}
		}
		
		def hsphEnrollees = fasStudents + gseStudents + hdsStudents
		size = hsphEnrollees.size()
		hsphCourses.each {
			for (i in 0..1) {
				def student = hsphEnrollees[random.nextInt(size)]
				def ci = CourseInstance.get(it.id)
				def studentCourse = this.registrationService.addCourseForStudent(student.id, ci)
				studentCourse.homeSchoolId = ldapCodes[student.schoolAffiliations[0]]
				studentCourse.save()
				studentCourses << studentCourse
			}
		}
		
		def model = [
			"count": studentCourses.size(),
			"studentCourses": studentCourses
		]
		withFormat {
			html {
				JSON.use("deep") {
					render model as JSON
				}
			}
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
	
	def findFasStudents = {
		def enrollees = new HashSet<String>()
		def students =[]
		def http = new HTTPBuilder("http://localhost")
		http.request(Method.GET, groovyx.net.http.ContentType.JSON) {
			uri.path = '/fas_enrollees.json'
			response.success = {resp, json ->
				json.each {item ->
					enrollees << item
				}
			}
		}
		
		enrollees.each {
			def person = BaselineUtils.findPerson(it)
			if (!person.unknown && ['FAS','FGS','COL'].contains(person.schoolAffiliations[0])) {
				students << person
			}
		}
		
		def model = [
			"count": students.size(),
			"students": students
		]
		withFormat {
			html {
				JSON.use("deep") {
					render model as JSON
				}
			}
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
	
	def findGseStudents = {
		def enrollees = new HashSet<String>()
		def students =[]
		def http = new HTTPBuilder("http://localhost")
		http.request(Method.GET, groovyx.net.http.ContentType.JSON) {
			uri.path = '/gse_enrollees.json'
			response.success = {resp, json ->
				json.each {item ->
					enrollees << item
				}
			}
		}
		
		enrollees.each {
			def person = BaselineUtils.findPerson(it)
			if (!person.unknown && ['EDU'].contains(person.schoolAffiliations[0])) {
				students << person
			}
		}
		
		def model = [
			"count": students.size(),
			"students": students
		]
		withFormat {
			html {
				JSON.use("deep") {
					render model as JSON
				}
			}
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
	
	def findHdsStudents = {
		def enrollees = new HashSet<String>()
		def students =[]
		def http = new HTTPBuilder("http://localhost")
		http.request(Method.GET, groovyx.net.http.ContentType.JSON) {
			uri.path = '/hds_enrollees.json'
			response.success = {resp, json ->
				json.each {item ->
					enrollees << item
				}
			}
		}
		
		enrollees.each {
			def person = BaselineUtils.findPerson(it)
			if (!person.unknown && ['DIV'].contains(person.schoolAffiliations[0])) {
				students << person
			}
		}
		
		def model = [
			"count": students.size(),
			"students": students
		]
		withFormat {
			html {
				JSON.use("deep") {
					render model as JSON
				}
			}
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
	
	def findHsphStudents = {
		def enrollees = new HashSet<String>()
		def students =[]
		def http = new HTTPBuilder("http://localhost")
		http.request(Method.GET, groovyx.net.http.ContentType.JSON) {
			uri.path = '/hsph_enrollees.json'
			response.success = {resp, json ->
				json.each {item ->
					enrollees << item
				}
			}
		}
		
		enrollees.each {
			def person = BaselineUtils.findPerson(it)
			if (!person.unknown && ['SPH'].contains(person.schoolAffiliations[0])) {
				students << person
			}
		}
		
		def model = [
			"count": students.size(),
			"students": students
		]
		withFormat {
			html {
				JSON.use("deep") {
					render model as JSON
				}
			}
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
	
	def testData = {
		def ldapCodes = [
			gse: 'GSE',
			hsph: 'SPH',
			hds: 'DIV'
		]
		def model = []
		CourseInstance.executeQuery("\
			select ci from CourseInstance as ci \
			join ci.term as t \
				with t.termCode in (2,8,9) and \
					 t.academicYear = 2010 and \
					 t.schoolId in ('gse','hsph','hds')"
		).each {courseInstance ->
			courseInstance.enrollees.each {
				if (it.source != "xreg_map") {
					def homeSchool
					def http = new HTTPBuilder(grailsApplication.config.icommonsapi.url + "/people/by_id/" + it.userId)
					println "Finding person ${it.userId}"
					http.request(Method.GET, groovyx.net.http.ContentType.JSON) {
						response.success = {resp, json ->
							json.people.each {person ->
								if (!person.unknown) {
									println "Found person ${person.id}"
									homeSchool = person.departmentAffiliation
									println "home school is ${homeSchool}"
								}
							}
						}
					}
					println "Checking home school for ${it.userId}"
					if (homeSchool && homeSchool != "null") {
						if (ldapCodes[courseInstance.course.schoolId] != homeSchool) {
							println "${it.userId} is cross registered for course instance ${courseInstance.id}"
							model << [
								userId: it.userId,
								homeSchool: homeSchool,
								courseInstance: courseInstance
							]
						}
					}
				}
			}
		}
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
	
	def testLoadStudentCourses = {
		def count = 0
		def http = new HTTPBuilder("http://localhost/crossreg.json")
		http.request(Method.GET, groovyx.net.http.ContentType.JSON) {
			response.success = {resp, json ->
				json.findAll {
					['BUS','COL','DES','DIV','DMD','ECS','EDU','FAS','FGS','HMS','KSG','LAW','RAD','SPH'].contains(it.homeSchool)
				}.each {item ->
					count++
					println "${item.userId}|${item.homeSchool}|${item.courseInstance.course.schoolId}|${item.courseInstance.id}"
					def ci = CourseInstance.get(item.courseInstance.id)
					def studentCourse = this.registrationService.addCourseForStudent(item.userId, ci)
					studentCourse.homeSchoolId = ldapCodes[item.homeSchool]
					studentCourse.save()
				}
			}
		}
		render count
	}
	
	def testRegister = {
		def studentCourses = StudentCourse.findAllByActive(1).findAll {
			!it.state
		}
		
		studentCourses.each {
			it.levelOption = "Graduate"
			it.gradingOption = "Letter"
			def ctx = new RegistrationContext()
			ctx.addToStudentCourses(it)
			ctx.save(flush:true)
			this.registrationService.updateRegistrationContextState("register", ctx, request.userId)
		}
		
		render "success"
	}
	
}
