package edu.harvard.coursereg

import edu.harvard.icommons.coursedata.CourseInstance
import edu.harvard.icommons.coursedata.School

import static groovyx.net.http.ContentType.JSON
import groovyx.net.http.HTTPBuilder
import groovyx.net.http.Method

class StudentCourse implements Serializable {

	String userId
	Long homeSchoolId
	Date dateCreated
	int active = 1
	
	Map student
	String termDisplay
	Map instructor
	List<Map> levelOptions
	List<Map> gradingOptions
	List<Map> schoolOptions
	
	static transients = [
		'student',
		'termDisplay',
		'instructor',
		'levelOptions',
		'gradingOptions',
		'schoolOptions'
	]
	
	static belongsTo = [
		courseInstance : CourseInstance
	]
	
	static hasMany = [
		registrationStates : RegistrationState,
		studentCourseAttributes : StudentCourseAttribute
	]
	
	static mapping = {
		version false
		id generator:'sequence', params:[sequence:'student_course_id_seq']
		courseInstance fetch: 'join'
		registrationStates lazy: false
		studentCourseAttributes lazy: false
	}
	
    static constraints = {
		userId(blank: false)
		homeSchoolId(nullable: true)
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
			instructor = [
				'userId': courseStaff.userId,
				'name': courseStaff.displayName ? courseStaff.displayName : this.courseInstance.instructorsDisplay
			]
		}
		return instructor
	}
	
	public List<Map> getLevelOptions() {
		if (!levelOptions) {
			levelOptions = [
				["id": 1, "name": "Undergraduate"],
				["id": 2, "name": "Graduate"]
			]
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
		def config = grailsApplication.config.courseregistration.pilot.schools;
		if (!config) {
			return false;
		}
		
		def schools = Arrays.asList(config.split(','));
		def school = School.get(this.courseInstance.course.id)
		return schools.contains(school)
	}
	
}
