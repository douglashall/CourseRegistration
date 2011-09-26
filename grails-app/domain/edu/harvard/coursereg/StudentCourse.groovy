package edu.harvard.coursereg

import edu.harvard.icommons.coursedata.CourseInstance

class StudentCourse implements Serializable {

	String userId
	Date dateCreated
	int active = 1
	
	Map student
	
	static transients = ['student']
	
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
	
}
