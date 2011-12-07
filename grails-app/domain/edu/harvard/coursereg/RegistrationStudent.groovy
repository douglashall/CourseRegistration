package edu.harvard.coursereg

class RegistrationStudent {

	String userId
	String programDepartment
	Long degreeYear
	
    static mapping = {
		version false
		id generator:'sequence', params:[sequence:'registration_student_id_seq']
	}
	
    static constraints = {
		userId(blank: false)
		programDepartment(blank: false)
		degreeYear(blank: false)
    }
	
}
