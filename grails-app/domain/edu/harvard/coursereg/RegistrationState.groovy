package edu.harvard.coursereg

class RegistrationState implements Serializable {

	String state
	Date dateCreated
	String createdBy
	
	static belongsTo = [
		studentCourse : StudentCourse
	]
	
	static mapping = {
		version false
	}
	
    static constraints = {
		state(blank: false)
		createdBy(blank: false)
    }
	
}
