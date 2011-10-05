package edu.harvard.coursereg

class RegistrationContext implements Serializable {
	
	static hasMany = [
		studentCourses : StudentCourse,
		registrationApprovals : RegistrationApproval
	]
	
	static mapping = {
		version false
	}
	
    static constraints = {
    }
	
}
