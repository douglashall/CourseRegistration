package edu.harvard.coursereg

import edu.harvard.icommons.coursedata.School

class RegistrationProxy implements Serializable {

	String facultyUserId
	String proxyUserId
	
	static belongsTo = [
		registrationProxyUrl : RegistrationProxyUrl
	]
	
	static mapping = {
		version false
		id generator:'sequence', params:[sequence:'registration_proxy_seq']
	}
	
    static constraints = {
		facultyUserId(blank:false)
		proxyUserId(blank:false)
		registrationFacultyProxyUrl(blank:false)
    }
	
}
