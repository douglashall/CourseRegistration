package edu.harvard.coursereg

import static groovyx.net.http.ContentType.JSON
import static groovyx.net.http.ContentType.TEXT

import java.text.SimpleDateFormat
import java.util.List
import java.util.Map;

import org.apache.commons.lang.builder.*
import org.codehaus.groovy.grails.commons.ConfigurationHolder

import edu.harvard.icommons.coursedata.CourseInstance
import grails.util.Environment
import groovy.text.SimpleTemplateEngine
import groovyx.net.http.*

class RegistrationService {

    static transactional = true
	
	SimpleDateFormat solrIndexDateFormat = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'")
	
	def config = ConfigurationHolder.config
	
	def emailSubjects = [
		"standard": config.standard.email.subject,
		"hds": config.hds.email.subject,
		"gse": config.gse.email.subject,
		"hsph": config.hsph.email.subject
	]
	
	def emailReplyToAddresses = [
		"hds": config.hds.email.replyto,
		"gse": config.gse.email.replyto,
		"hsph": config.hsph.email.replyto
	]
	
	def findAllActiveStudentCoursesForStudent(String userId) {
		return StudentCourse.executeQuery("\
			select sc from StudentCourse as sc \
			join sc.courseInstance as ci \
				with ci.excludeFromCatalog = 0 \
			where \
				sc.userId = :userId and \
				sc.active = 1",
			[
				userId: userId
			]
		)
	}
	
	def findAllActiveStudentCourses() {
		return StudentCourse.executeQuery("\
			select sc from StudentCourse as sc \
			join sc.courseInstance as ci \
				with ci.excludeFromCatalog = 0 \
			where \
				sc.active = 1"
		)
	}
	
	def addCourseForStudent(String userId, CourseInstance ci) {
		StudentCourse studentCourse = StudentCourse.createCriteria().get {
			eq("userId", userId)
			eq("courseInstance", ci)
			eq("active", 1)
		}
		if (!studentCourse) {
			studentCourse = new StudentCourse(userId:userId, courseInstance:ci)
			def schoolOptions = studentCourse.schoolOptions
			if (schoolOptions.size() == 1) {
				studentCourse.homeSchoolId = schoolOptions[0][0]
			}
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
		this.deleteFromStudentCourseIndex(studentCourses)
	}
	
	public void submit(RegistrationContext ctx, String userId) {
		def isApprovalRequired = false
		ctx.studentCourses.each {
			if (it.courseInstance.xregInstructorSigReqd == 1) {
				isApprovalRequired = true
				return false
			}
		}
		
		this.updateRegistrationContextState(isApprovalRequired ? "submit" : "register", ctx, userId)
	}
	
	public void facultyApprove(RegistrationContext ctx, String userId) {
		this.updateRegistrationContextState("faculty_approve", ctx, userId)
	}
	
	public void facultyDeny(RegistrationContext ctx, String userId) {
		this.updateRegistrationContextState("faculty_deny", ctx, userId)
	}
	
	public void registrarApprove(RegistrationContext ctx, String userId) {
		this.updateRegistrationContextState("registrar_approve", ctx, userId)
	}
	
	public void registrarDeny(RegistrationContext ctx, String userId) {
		this.updateRegistrationContextState("registrar_deny", ctx, userId)
	}
	
	private void updateRegistrationContextState(String action, RegistrationContext ctx, String userId) {
		def studentCourse = ctx.studentCourses.toArray()[0]
		def registrationAction = RegistrationAction.findAllByAction(action).find {
			if (it.stateBefore == ctx.currentState) {
				if (it.school) {
					return it.school.id == studentCourse.homeSchoolId
				} else {
					return true
				}
			}
			return false
		}
		
		if (registrationAction) {
			def registrationContextState = new RegistrationContextState(
				createdBy: userId,
				registrationState: registrationAction.stateAfter
			)
			
			ctx.addToRegistrationContextStates(registrationContextState)
			ctx.resetCurrentState()
			ctx.save(flush:true)
			
			def studentCourses = ctx.studentCourses.toList()
			this.updateStudentCourseIndex(studentCourses)
			this.sendNotificationEmailForAction(registrationAction, studentCourses, userId)
		}
	}
	
	def updateStudentCourseIndex(List<StudentCourse> studentCourses) {
		def docs = []
		studentCourses.each {
			def initialState = it.registrationContext.getInitialState()
			def currentState = it.registrationContext.getCurrentRegistrationContextState()
			def doc = [
				id: it.id,
				state: it.state.state,
				stateTerminal: it.state.terminal,
				stateType: it.state.type,
				stateCreator: it.stateCreator,
				stateCreated: currentState ? solrIndexDateFormat.format(currentState.dateCreated) : "",
				processed: it.registrationContext.processed > 0,
				petitionCreated: initialState ? solrIndexDateFormat.format(initialState.dateCreated) : "",
				gradingOption: it.gradingOption,
				studentHuid: it.userId,
				studentFirstName: it.student.firstName,
				studentLastName: it.student.lastName,
				studentEmail: it.student.email,
				studentPhone: it.student.phone,
				homeSchool: it.student.school,
				homeSchoolDisplay: it.student.schoolDisplay,
				hostSchool: it.courseSchool.id,
				hostSchoolDisplay: it.courseSchool.titleLong,
				courseInstanceId: it.courseInstance.id,
				courseShortTitle: it.courseInstance.shortTitle ? it.courseInstance.shortTitle : it.courseInstance.course.registrarCode,
				term: it.courseInstance.term.displayName,
				instructorHuid: it.instructor.userId,
				instructorName: it.instructor.name,
				instructorEmail: it.instructor.email,
				instructorPhone: it.instructor.phone
			]
			if (it.registrationContext.processed > 0) {
				doc.processedAt = solrIndexDateFormat.format(it.registrationContext.dateProcessed)
				doc.processedBy = it.registrationContext.getProcessor().firstName + " " + it.registrationContext.getProcessor().lastName
			}
			docs << doc
		}
		
		def http = new HTTPBuilder(config.solr.url + "/update/json?commit=true")
		http.request(Method.POST) {
			requestContentType = JSON
			body = docs
			response.success = {resp ->
				log.info("Indexed ${docs.size()} student courses with status code ${resp.statusLine.statusCode}")
			}
		}
	}
	
	def deleteFromStudentCourseIndex(List<StudentCourse> studentCourses) {
		def ids = new StringBuffer()
		studentCourses.each {
			ids << "<id>${it.id}</id>"
		}
		
		def http = new HTTPBuilder(config.solr.url + "/update?commit=true")
		http.request(Method.POST) {
			requestContentType = JSON
			body = "<delete>${ids}</delete>"
			response.success = {resp ->
				log.info("Removed ${studentCourses.size()} student courses from solr index with status code ${resp.statusLine.statusCode}")
			}
		}
	}
	
	def searchStudentCourses(Map searchParams) {
		def total
		def result = []
		def queryString = []
		if (searchParams.id) {queryString << ('id:' + searchParams.id)}
		if (searchParams.query) {queryString << ('"' + searchParams.query + '"')}
		if (searchParams.status) {queryString << ('state:"' + searchParams.status + '"')}
		if (searchParams.homeSchool) {queryString << ('homeSchool:"' + searchParams.homeSchool + '"')}
		if (searchParams.hostSchool) {queryString << ('hostSchool:"' + searchParams.hostSchool + '"')}
		
		def start = searchParams.start ? searchParams.start : 0
		def rows = searchParams.limit ? searchParams.limit : 5000
		def sort = URLEncoder.encode((searchParams.sort ? searchParams.sort : "petitionCreated desc"), 'UTF-8')
		
		def q = queryString.size() == 0 ? "*:*" : URLEncoder.encode(queryString.join(" AND "), 'UTF-8')
		def http = new HTTPBuilder(config.solr.url + "/select?wt=json&q=${q}&start=${start}&rows=${rows}&sort=${sort}")
		SimpleDateFormat sdf = new SimpleDateFormat("MMM d, yyyy HH:mm:ss")
		http.request(Method.GET, JSON) {
			response.success = {resp, json ->
				total = json.response.numFound
				json.response.docs.each {
					it.processed = it.processed ? "Processed" : "Not Processed"
					if (it.processedAt) {
						it.processedAt = sdf.format(solrIndexDateFormat.parse(it.processedAt))
					}
					it.stateCreated = sdf.format(solrIndexDateFormat.parse(it.stateCreated))
					it.petitionCreated = sdf.format(solrIndexDateFormat.parse(it.petitionCreated))
					result << it
				}
			}
		}
		return [
			"total": total,
			"records": result
		]
	}
	
	def sendNotificationEmailForAction(RegistrationAction action, List<StudentCourse> studentCourses, String userId) {
		studentCourses.each {this.sendNotificationEmailForAction(action, it, userId)}
	}
	
	def sendNotificationEmailForAction(RegistrationAction action, StudentCourse studentCourse, String userId) {
		if (!action.notifyStudent && !action.notifyFaculty) {
			return
		}
		
		def student = studentCourse.getStudent()
		def instructor = studentCourse.getInstructor()
		def courseSchool = studentCourse.getCourseSchool()
		def ci = studentCourse.getCourseInstance()
		
		def recipients = []
		if (Environment.current == Environment.PRODUCTION) {
			if (action.notifyStudent && !config.email.student.disabled) recipients << student.email
			if (action.notifyFaculty && !config.email.faculty.disabled) recipients << instructor.email
		}
		
		def model = [
			student: student,
			faculty: instructor,
			course: [
				code: ci.shortTitle ? ci.shortTitle : ci.course.registrarCode,
				title: ci.title
			],
			plural: ""
		]
		def engine = new SimpleTemplateEngine()
		def binding = ["courseCode": model.course.code.toString(), "plural": ""]
		def template = engine.createTemplate(this.emailSubjects[courseSchool.id]).make(binding)
		sendMail {
			to recipients.size() > 0 ? recipients.toArray() : config.email.from
			bcc config.test.email.recipients.toArray()
			from config.email.from
			subject template.toString()
			replyTo this.emailReplyToAddresses[courseSchool.id]
			body (view: "/email/" + courseSchool.id + "/" + action.emailType, model: model)
		}
		log.info("Sent email to " + recipients + " for action " + action.action + " student course id " + studentCourse.id)
	}
	
	def sendNotificationEmailToFaculty(Map faculty, List<StudentCourse> studentCourses) {
		def students = studentCourses.collect {it.student}.findAll {
			!it.unknown
		}.sort {a, b ->
			if (a.school != b.school) {
				return a.school.compareTo(b.school)
			} else {
				def aName = a.lastName + a.firstName
				def bName = b.lastName + b.firstName
				return aName.compareTo(bName)
			}
		}
		def courseSchool = studentCourses[0].getCourseSchool()
		def ci = studentCourses[0].getCourseInstance()
		
		def recipients = []
		if (Environment.current == Environment.PRODUCTION && !config.email.faculty.disabled) {
			recipients << faculty.email
		}
		
		def proxyUrl = RegistrationProxyUrl.findByFacultyUserId(faculty.userId)
		if (!proxyUrl) {
			proxyUrl = this.createRegistrationProxyUrl(faculty.userId)
		}
		
		def model = [
			students: students,
			faculty: faculty,
			course: [
				code: ci.shortTitle ? ci.shortTitle : ci.course.registrarCode,
				title: ci.title
			],
			plural: students.size() > 1 ? "s" : "",
			url: proxyUrl.shortUrl
		]
		
		def engine = new SimpleTemplateEngine()
		def binding = ["courseCode": model.course.code.toString(), "plural": model.plural.toString()]
		def template = engine.createTemplate(this.emailSubjects[courseSchool.id]).make(binding)
		sendMail {
			to recipients.size() > 0 ? recipients.toArray() : config.email.from
			bcc config.test.email.recipients.toArray()
			from config.email.from
			subject template.toString()
			replyTo this.emailReplyToAddresses[courseSchool.id]
			body (view: "/email/" + courseSchool.id + "/faculty", model: model)
		}
		log.info("Sent email to " + recipients + " for student course ids " + studentCourses.collect {it.id})
	}
	
	def createRegistrationProxyUrl(String facultyUserId) {
		def proxyUrl = new RegistrationProxyUrl(facultyUserId: facultyUserId)
		proxyUrl.save(flush:true)
		
		def engine = new SimpleTemplateEngine()
		def binding = ["username": config.bitly.username, "apikey": config.bitly.apikey, "url": (config.faculty.proxy.url + proxyUrl.id).encodeAsURL()]
		def template = engine.createTemplate(config.bitly.api.url).make(binding)
		
		def http = new HTTPBuilder(template.toString())
		http.request(Method.GET, JSON) {
			response.success = {resp, json ->
				proxyUrl.shortUrl = json.data.url
				proxyUrl.save()
			}
		}
		return proxyUrl
	}
	
	def findAllStudentCoursesForProxy(String userId) {
		def studentCourses = []
		def proxies = RegistrationProxy.findAllByProxyUserId(userId)
		proxies.each {
			studentCourses.addAll(this.findAllStudentCoursesForFaculty(it.registrationProxyUrl.facultyUserId))
		}
		return studentCourses
	}
	
	def findAllStudentCoursesForFaculty(String facultyId) {
		def studentCourses = StudentCourse.executeQuery("\
			select sc from StudentCourse as sc \
			join sc.courseInstance as ci \
			join ci.staff as staff \
				with staff.userId = ? \
			where sc.active = 1", [facultyId]
		).findAll {
			it.state
		}
		
		studentCourses.each {
			def result = this.searchStudentCourses([id: it.id])
			if (result.records.size() > 0) {
				it.stateCreator = result.records[0].stateCreator
			}
		}
		
		return studentCourses
	}
	
}
