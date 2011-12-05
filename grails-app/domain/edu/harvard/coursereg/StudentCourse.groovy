package edu.harvard.coursereg

import static groovyx.net.http.ContentType.JSON
import edu.harvard.grails.plugins.baseline.BaselineUtils
import edu.harvard.icommons.coursedata.CourseInstance
import edu.harvard.icommons.coursedata.School

class StudentCourse implements Serializable {

	String userId
	Long homeSchoolId
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
	
	static transients = [
		'student',
		'courseSchool',
		'termDisplay',
		'instructor',
		'levelOptions',
		'gradingOptions',
		'schoolOptions',
		'state'
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
		levelOption(nullable: true)
		gradingOption(nullable: true)
		registrationContext(nullable: true)
    }
	
	public School getCourseSchool() {
		if (!courseSchool) {
			courseSchool = School.findBySchoolId(this.courseInstance.course.schoolId)
		}
		return courseSchool
	}
	
	public String getTermDisplay() {
		if (!termDisplay) {
			def school = School.findBySchoolId(this.courseInstance.course.schoolId)
			return this.courseInstance.term.displayName + ", " + school.titleLong
		}
		return termDisplay
	}
	
	public Map getStudent() {
		if (!student) {
			def person = BaselineUtils.findPerson(this.userId)
			if (this.userId == '10564158') {
				this.homeSchoolId = 7
			}
			this.student = [
				'id': person.id,
				'firstName': person.firstName,
				'lastName': person.lastName,
				'email': person.email,
				'phone': person.phone,
				'school': this.homeSchoolId ? School.get(this.homeSchoolId).schoolId : '',
				'schoolDisplay': this.homeSchoolId ? School.get(this.homeSchoolId).titleLong : ''
			]
		}
		return student
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
			if (this.courseInstance.undergraduateCreditFlag == 0 &&
					this.courseInstance.graduateCreditFlag == 0) {
				levelOptions = [
					["id": 1, "name": "Undergraduate"],
					["id": 2, "name": "Graduate"]
				]
			} else {
				levelOptions = []
				if (this.courseInstance.undergraduateCreditFlag == 1) {
					levelOptions << ["id": 1, "name": "Undergraduate"]
				}
				if (this.courseInstance.graduateCreditFlag == 1) {
					levelOptions << ["id": 2, "name": "Graduate"]
				}
			}
		}
		return levelOptions
	}
	
	public List<Map> getGradingOptions() {
		if (!gradingOptions) {
			gradingOptions = [
				["id": 1, "name": "Letter"],
				["id": 2, "name": "Sat-Unsat"],
				["id": 3, "name": "Audit"]
			]
		}
		return gradingOptions
	}
	
	public List<Map> getSchoolOptions() {
		if (!schoolOptions) {
			schoolOptions = []
		}
		return schoolOptions
	}
	
	public boolean checkPilot() {
		def config= grailsApplication.config.courseregistration.pilot.schools
		if (!config) {
			log.warn("missing courseregistration.pilot.schools config")
			return false
		}

		def schools = Arrays.asList(config.split(','));
		def school = School.findBySchoolId(this.courseInstance.course.schoolId)
		return schools.contains(school.schoolId)
	}
	
}
