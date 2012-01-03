package edu.harvard.coursereg

import edu.harvard.icommons.coursedata.School

class RegistrationProxy implements Serializable {

	String proxyUserId
	
	static belongsTo = [
		registrationProxyUrl : RegistrationProxyUrl
	]
	
	static mapping = {
		version false
		id generator:'sequence', params:[sequence:'registration_proxy_seq']
	}
	
    static constraints = {
		proxyUserId(blank:false)
		registrationProxyUrl(blank:false)
    }
	
}
