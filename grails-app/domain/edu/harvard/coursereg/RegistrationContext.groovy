package edu.harvard.coursereg

class RegistrationContext implements Serializable {
	
	RegistrationContextState initialState
	RegistrationState currentState
	int processed = 0
	Date dateProcessed
	String processedBy
	
	static transients = [
		'initialState',
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
		dateProcessed(nullable: true)
		processedBy(nullable: true)
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
