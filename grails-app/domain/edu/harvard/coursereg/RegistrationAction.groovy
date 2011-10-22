package edu.harvard.coursereg

import edu.harvard.icommons.coursedata.School

class RegistrationAction implements Serializable {

	String action
	
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
		school(nullable:true)
		stateBefore(nullable:true)
    }
	
}
