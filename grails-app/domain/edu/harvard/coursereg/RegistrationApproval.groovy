package edu.harvard.coursereg

class RegistrationApproval implements Serializable {
	
	String userId
	String type
	Integer approved
	Integer denied
	
	static belongsTo = [
		registrationContext : RegistrationContext
	]
	
	static mapping = {
		version false
	}
	
    static constraints = {
    }
	
}
