package edu.harvard.coursereg

class RegistrationStudent {

	String userId
	String programDepartment
	Long degreeYear
	
    static mapping = {
		version false
	}
	
    static constraints = {
		userId(blank: false)
		programDepartment(blank: false)
		degreeYear(blank: false)
    }
	
}
