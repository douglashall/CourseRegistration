package edu.harvard.coursereg

class RegistrationContext implements Serializable {
	
	RegistrationContextState initialState
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
	
	public RegistrationContextState getInitialState() {
		if (this.registrationContextStates && this.registrationContextStates.size() > 0) {
			def states = this.registrationContextStates.sort {a,b -> a.dateCreated.compareTo(b.dateCreated)}
			this.initialState = states[0]
		}
		return this.initialState
	}
	
}
