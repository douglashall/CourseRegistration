package edu.harvard.coursereg

import edu.harvard.grails.plugins.baseline.BaselineUtils

class RegistrationContext implements Serializable {
	
	RegistrationContextState initialState
	RegistrationContextState currentRegistrationContextState
	RegistrationState currentState
	Map currentStateCreator
	int processed = 0
	Date dateProcessed
	String processedBy
	
	static transients = [
		'initialState',
		'currentRegistrationContextState',
		'currentState',
		'currentStateCreator'
	]
	
	static hasMany = [
		studentCourses : StudentCourse,
		registrationContextStates : RegistrationContextState
	]
	
	static mapping = {
		version false
		id generator:'sequence', params:[sequence:'registration_ctx_id_seq']
		studentCourses fetch: 'join'
		registrationContextStates fetch: 'join'
	}
	
    static constraints = {
		dateProcessed(nullable: true)
		processedBy(nullable: true)
    }
	
	public void resetCurrentState() {
		this.currentState = null
		this.currentRegistrationContextState = null
		this.currentStateCreator = null
	}
	
	public RegistrationState getCurrentState() {
		if (!this.currentState) {
			def currentRegistrationContextState = this.getCurrentRegistrationContextState()
			if (currentRegistrationContextState) {
				this.currentState = currentRegistrationContextState.registrationState
			}
		}
		return this.currentState
	}
	
	public RegistrationContextState getCurrentRegistrationContextState() {
		if (!this.currentRegistrationContextState) {
			if (this.registrationContextStates && this.registrationContextStates.size() > 0) {
				def states = this.registrationContextStates.sort {a,b -> b.dateCreated.compareTo(a.dateCreated)}
				this.currentRegistrationContextState = states[0]
			}
		}
		return this.currentRegistrationContextState
	}
	
	public RegistrationContextState getInitialState() {
		if (this.registrationContextStates && this.registrationContextStates.size() > 0) {
			def states = this.registrationContextStates.sort {a,b -> a.dateCreated.compareTo(b.dateCreated)}
			this.initialState = states[0]
		}
		return this.initialState
	}
	
	public Map getCurrentStateCreator() {
		if (!this.currentStateCreator) {
			def currentState = this.getCurrentRegistrationContextState()
			if (currentState) {
				this.currentStateCreator = BaselineUtils.findPerson(currentState.createdBy)
			}
		}
		return this.currentStateCreator
	}
	
}
