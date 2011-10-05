package edu.harvard.coursereg

import edu.harvard.icommons.coursedata.CourseInstance
import edu.harvard.icommons.coursedata.School

import static groovyx.net.http.ContentType.JSON
import groovyx.net.http.HTTPBuilder
import groovyx.net.http.Method

class StudentCourse implements Serializable {

	String userId
	Long homeSchoolId
	String levelOption
	String gradingOption
	Date dateCreated
	Date lastUpdated
	int active = 1
	
	Map student
	String termDisplay
	Map instructor
	String state
	List<Map> levelOptions
	List<Map> gradingOptions
	List<Map> schoolOptions
	
	static transients = [
		'student',
		'termDisplay',
		'instructor',
		'state',
		'levelOptions',
		'gradingOptions',
		'schoolOptions'
	]
	
	static belongsTo = [
		courseInstance : CourseInstance,
		registrationContext : RegistrationContext
	]
	
	static hasMany = [
		registrationStates : RegistrationState
	]
	
	static mapping = {
		version false
		id generator:'sequence', params:[sequence:'student_course_id_seq']
		courseInstance fetch: 'join'
		registrationStates lazy: false
	}
	
    static constraints = {
		userId(blank: false)
		homeSchoolId(nullable: true)
		levelOption(nullable: true)
		gradingOption(nullable: true)
		registrationContext(nullable: true)
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
			def http = new HTTPBuilder(grailsApplication.config.icommonsapi.url + "/people/by_id/" + userId)
			http.request(Method.GET, JSON) {
				response.success = {resp, json ->
					json.people.each {person ->
						this.student = [
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
		return student
	}
	
	public Map getInstructor() {
		if (!instructor) {
			def courseStaff = this.courseInstance.staff.find {it.roleId == 1}
			if (courseStaff) {
				instructor = [
					'userId': courseStaff.userId,
					'name': courseStaff.displayName ? courseStaff.displayName : this.courseInstance.instructorsDisplay
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
	
	public String getState() {
		def states = this.registrationStates.sort {a,b -> b.dateCreated.compareTo(a.dateCreated)}
		if (states.size() > 0) {
			state = states[0].state
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
