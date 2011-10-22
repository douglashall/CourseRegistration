package edu.harvard.coursereg

class RegistrationContext implements Serializable {
	
	RegistrationState currentState
	
	static transients = [
		'currentState'
	]
	
	static hasMany = [
		studentCourses : StudentCourse,
		registrationContextStates : RegistrationContextState
	]
	
	static mapping = {
		version false
		studentCourses fetch: 'join'
		registrationContextStates fetch: 'join'
	}
	
    static constraints = {
    }
	
	public RegistrationState getCurrentState() {
		if (this.registrationContextStates && this.registrationContextStates.size() > 0) {
			def states = this.registrationContextStates.sort {a,b -> b.dateCreated.compareTo(a.dateCreated)}
			this.currentState = states[0].registrationState
		}
		return this.currentState
	}
	
}
