package edu.harvard.coursereg

import static groovyx.net.http.ContentType.JSON

import java.text.SimpleDateFormat

import edu.harvard.grails.plugins.baseline.BaselineUtils
import edu.harvard.icommons.coursedata.CourseInstance
import edu.harvard.icommons.coursedata.School

class StudentCourse implements Serializable {

	String userId
	String homeSchoolId
	String programDepartment
	Long degreeYear
	String levelOption
	String gradingOption
	Date dateCreated
	Date lastUpdated
	int active = 1
	
	Map student
	School courseSchool
	String termDisplay
	Map instructor
	List<Map> levelOptions
	List<Map> gradingOptions
	List<Map> schoolOptions
	RegistrationState state
	String dateSubmitted
	
	static transients = [
		'student',
		'courseSchool',
		'termDisplay',
		'instructor',
		'levelOptions',
		'gradingOptions',
		'schoolOptions',
		'state',
		'dateSubmitted'
	]
	
	static belongsTo = [
		courseInstance : CourseInstance,
		registrationContext : RegistrationContext
	]
	
	static mapping = {
		version false
		id generator:'sequence', params:[sequence:'student_course_id_seq']
		courseInstance fetch: 'join'
		registrationContext fetch: 'join'
	}
	
    static constraints = {
		userId(blank: false)
		homeSchoolId(nullable: true)
		programDepartment(nullable: true)
		degreeYear(nullable: true)
		levelOption(nullable: true)
		gradingOption(nullable: true)
		registrationContext(nullable: true)
    }
	
	public static gradingOptionMap = [
		"letter/ordinal": 	["id": "letter/ordinal", "name": "Letter/Ordinal"],
		"pass/fail": 		["id": "pass/fail", "name": "Pass/Fail"],
		"sat/unsat": 		["id": "sat/unsat", "name": "Satisfactory/Unsatisfactory"],
		"sat/ncr": 			["id": "sat/ncr", "name": "Satisfactory/No Credit"],
		"ungraded": 		["id": "ungraded", "name": "Ungraded"],
		"audit": 			["id": "audit", "name": "Audit"]
	]
	
	public School getCourseSchool() {
		if (!courseSchool) {
			courseSchool = School.get(this.courseInstance.course.schoolId)
		}
		return courseSchool
	}
	
	public String getTermDisplay() {
		if (!termDisplay) {
			def school = School.get(this.courseInstance.course.schoolId)
			return this.courseInstance.term.displayName + ", " + school.titleLong
		}
		return termDisplay
	}
	
	public Map getStudent() {
		if (!student) {
			def person = BaselineUtils.findPerson(this.userId)
			this.student = [
				'id': person.id,
				'firstName': person.firstName,
				'lastName': person.lastName,
				'email': person.email,
				'phone': person.phone,
				'schoolAffiliations': person.schoolAffiliations,
				'school': this.homeSchoolId ? School.get(this.homeSchoolId).id : '',
				'schoolDisplay': this.homeSchoolId ? School.get(this.homeSchoolId).titleLong : ''
			]
		}
		return student
	}
	
	public void setStudent(Map student) {
		this.student = student
	}
	
	public Map getInstructor() {
		if (!instructor) {
			def courseStaff = this.courseInstance.staff.find {it.roleId == 1}
			if (courseStaff) {
				def person = BaselineUtils.findPerson(courseStaff.userId)
				def name = courseStaff.displayName ? courseStaff.displayName : this.courseInstance.instructorsDisplay
				if (!name || name == '') {
					name = person.firstName + ' ' + person.lastName
				}
				instructor = [
					'userId': courseStaff.userId,
					'name': name,
					'email': person.email,
					'phone': person.phone
				]
			} else {
				instructor = [
					'userId': '',
					'name': this.courseInstance.instructorsDisplay
				]
			}
		}
		return instructor
	}
	
	public RegistrationState getState() {
		if (this.registrationContext && this.registrationContext.currentState) {
			state = this.registrationContext.currentState
		}
		return state
	}
	
	public List<Map> getLevelOptions() {
		if (!levelOptions) {
			levelOptions = [
				["id": 1, "name": "Graduate"]
			]
			if (this.courseInstance.undergraduateCreditFlag == 1) {
				levelOptions << ["id": 2, "name": "Undergraduate"]
			}
		}
		return levelOptions
	}
	
	public List<Map> getGradingOptions() {
		if (!gradingOptions) {
			def xregGradingOptions = this.courseInstance.xregGradingOptions
			if (xregGradingOptions) {
				def optionKeys = this.courseInstance.xregGradingOptions.tokenize("|")
				gradingOptions = optionKeys.collect {
					gradingOptionMap[it]
				}
			} else {
				gradingOptions = gradingOptionMap.values().toList()
			}
		}
		return gradingOptions
	}
	
	public List<Map> getSchoolOptions() {
		if (!this.schoolOptions) {
			def student = this.getStudent()
			def options = []
			student.schoolAffiliations.each {
				def schoolId = BaselineUtils.ldapCodes[it]
				if (schoolId) {
					def school = School.get(schoolId)
					options << [school.id, school.titleShort]
				}
			}
			options.sort {it[1]}
			this.schoolOptions = options
		}
		return schoolOptions
	}
	
	public String getDateSubmitted() {
		if (!this.dateSubmitted) {
			if (this.registrationContext) {
				SimpleDateFormat sdf = new SimpleDateFormat("MMM d, yyyy h:mm a")
				def initialState = this.registrationContext.getInitialState()
				if (initialState) {
					this.dateSubmitted = sdf.format(initialState.dateCreated)
				}
			}
		}
		return this.dateSubmitted
	}
	
	public boolean checkPilot() {
		def config= grailsApplication.config.pilot.schools
		if (!config) {
			log.warn("missing pilot.schools config")
			return false
		}

		def schools = Arrays.asList(config.split(','));
		def school = School.get(this.courseInstance.course.schoolId)
		return schools.contains(school.id)
	}
	
}
