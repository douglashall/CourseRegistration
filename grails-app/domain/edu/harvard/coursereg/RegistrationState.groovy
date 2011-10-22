package edu.harvard.coursereg

import org.apache.commons.lang.builder.EqualsBuilder
import org.apache.commons.lang.builder.HashCodeBuilder

class RegistrationState implements Serializable {

	String state
	Integer terminal
	String type
	
	static mapping = {
		version false
		id generator:'sequence', params:[sequence:'registration_state_id_seq']
	}
	
    static constraints = {
		state(blank: false)
		terminal(blank: false)
		type(blank: false)
    }
	
	@Override
	boolean equals(final Object that) {
		EqualsBuilder.reflectionEquals(this, that, ["id"])
	}

	@Override
	int hashCode() {
		HashCodeBuilder.reflectionHashCode(this, ["id"])
	}
	
}
