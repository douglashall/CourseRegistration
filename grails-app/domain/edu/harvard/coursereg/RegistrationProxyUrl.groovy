package edu.harvard.coursereg

import edu.harvard.icommons.coursedata.School

class RegistrationProxyUrl implements Serializable {

	String id
	String facultyUserId
	String shortUrl
	
	static mapping = {
		version false
		id generator:'uuid'
	}
	
    static constraints = {
		facultyUserId(blank:false)
		shortUrl(nullable:true)
    }
	
}
