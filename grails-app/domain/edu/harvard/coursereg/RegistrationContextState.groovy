package edu.harvard.coursereg

class RegistrationContextState implements Serializable {

	Date dateCreated
	String createdBy
	
	static belongsTo = [
		registrationContext : RegistrationContext,
		registrationState : RegistrationState
	]
	
	static mapping = {
		version false
		id generator:'sequence', params:[sequence:'student_course_state_id_seq']
		registrationState fetch: 'join'
	}
	
    static constraints = {
		state(blank: false)
		createdBy(blank: false)
    }
	
}
