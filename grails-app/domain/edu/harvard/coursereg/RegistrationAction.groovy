package edu.harvard.coursereg

import edu.harvard.icommons.coursedata.School

class RegistrationAction implements Serializable {

	String action
	String emailType
	int notifyStudent
	int notifyFaculty
	
	static belongsTo = [
		school : School,
		stateBefore : RegistrationState,
		stateAfter : RegistrationState
	]
	
	static mapping = {
		version false
		id generator:'sequence', params:[sequence:'registration_action_id_seq']
	}
	
    static constraints = {
		emailType(nullable:true)
		notifyStudent(nullable:true)
		notifyFaculty(nullable:true)
		school(nullable:true)
		stateBefore(nullable:true)
    }
	
}
