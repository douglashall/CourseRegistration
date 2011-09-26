package edu.harvard.coursereg

import java.util.Date;

class StudentCourseAttribute implements Serializable {

	String key
	String value
	Date dateCreated
	Date lastModified
	
	static belongsTo = [
		studentCourse : StudentCourse
	]
	
	static mapping = {
		version false
	}
	
    static constraints = {
		key(blank: false)
		value(blank: false)
    }
	
}
