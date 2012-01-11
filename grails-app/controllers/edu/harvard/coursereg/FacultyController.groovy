package edu.harvard.coursereg

import grails.converters.*

import java.text.SimpleDateFormat

import org.codehaus.groovy.grails.web.json.*

class FacultyController {
	
	RegistrationService registrationService
	
	def list = {
		Set<StudentCourse> studentCourses = new HashSet<StudentCourse>()
		studentCourses.addAll(this.registrationService.findAllStudentCoursesForFaculty(request.userId))
		studentCourses.addAll(this.registrationService.findAllStudentCoursesForProxy(request.userId))

		def model = new TreeMap(studentCourses.groupBy {
			def prefix = it.courseInstance.shortTitle ? it.courseInstance.shortTitle : it.courseInstance.course.registrarCode
			prefix + " / " + it.courseInstance.term.displayName
		})
		
		SimpleDateFormat sdf = new SimpleDateFormat("MMM d, yyyy h:mm a")
		model.each {
			it.value.sort {a,b ->
				def aDate = sdf.parse(a.getDateSubmitted())
				def bDate = sdf.parse(b.getDateSubmitted())
				return bDate.compareTo(aDate)
			}
		}
		
		def approvalText = [
			"standard": grailsApplication.config.standard.faculty.approval.text,
			"hds": grailsApplication.config.hds.faculty.approval.text,
			"gse": grailsApplication.config.gse.faculty.approval.text,
			"hsph": grailsApplication.config.hsph.faculty.approval.text
		]
		def denialText = [
			"standard": grailsApplication.config.standard.faculty.denial.text,
			"hds": grailsApplication.config.hds.faculty.denial.text,
			"gse": grailsApplication.config.gse.faculty.denial.text,
			"hsph": grailsApplication.config.hsph.faculty.denial.text
		]
		
		withFormat {
			html {[model:model, topicId:params.topicId, approvalText:approvalText, denialText:denialText]}
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
		
		if (!grailsApplication.config.faculty.actions.disabled || grailsApplication.config.faculty.actions.enabled.schools.contains(studentCourse.getCourseSchool().id)) {
			def ids = params.ids.trim().tokenize().collect {Long.parseLong(it)}
			def studentCourses = StudentCourse.findAllByIdInList(ids)
			
			studentCourses.each {
				def ctx = it.registrationContext
				this.registrationService.facultyApprove(ctx, request.userId)
				model << it
			}
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
		
		if (!grailsApplication.config.faculty.actions.disabled || grailsApplication.config.faculty.actions.enabled.schools.contains(studentCourse.getCourseSchool().id)) {
			def ids = params.ids.trim().tokenize().collect {Long.parseLong(it)}
			def studentCourses = StudentCourse.findAllByIdInList(ids)
			
			studentCourses.each {
				def ctx = it.registrationContext
				this.registrationService.facultyDeny(ctx, request.userId)
				model << it
			}
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
	
	def proxy = {
		def proxyUrl = RegistrationProxyUrl.get(params.proxy)
		if (request.userId != proxyUrl.facultyUserId) {
			def proxy = RegistrationProxy.findByRegistrationProxyUrlAndProxyUserId(proxyUrl, request.userId)
			if (!proxy) {
				proxy = new RegistrationProxy(
					proxyUserId: request.userId,
					registrationProxyUrl: proxyUrl
				)
				proxy.save(flush:true)
			}
		}
		forward(action: "list")
	}
	
}
