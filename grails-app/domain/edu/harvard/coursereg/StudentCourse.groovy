package edu.harvard.coursereg

import edu.harvard.icommons.coursedata.CourseInstance
import edu.harvard.icommons.coursedata.School

import static groovyx.net.http.ContentType.JSON
import groovyx.net.http.HTTPBuilder
import groovyx.net.http.Method

class StudentCourse implements Serializable {

	String userId
	Date dateCreated
	int active = 1
	
	Map student
	String termDisplay
	List<Map> levelOptions
	List<Map> gradingOptions
	
	static transients = ['student','termDisplay', 'levelOptions', 'gradingOptions']
	
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
	
	public List<Map> getLevelOptions() {
		return [
			["id": 1, "name": "Undergraduate"],
			["id": 2, "name": "Graduate"]
		]
	}
	
	public List<Map> getGradingOptions() {
		return [
			["id": 1, "name": "Letter"],
			["id": 2, "name": "Sat-Unsat"],
			["id": 3, "name": "Audit"]
		]
	}
	
}
