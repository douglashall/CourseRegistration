package edu.harvard.coursereg

import org.codehaus.groovy.grails.web.json.*

import edu.harvard.icommons.coursedata.CourseInstance
import grails.converters.*
import groovyx.net.http.HTTPBuilder
import groovyx.net.http.Method

class ApplicationController {
	
	RegistrationService registrationService
	
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
	
	def testSolrIndexUpdate = {
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
	
}
