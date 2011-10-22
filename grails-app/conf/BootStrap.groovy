import edu.harvard.coursereg.StudentCourse
import edu.harvard.icommons.coursedata.Course
import edu.harvard.icommons.coursedata.CourseInstance
import edu.harvard.icommons.coursedata.CourseMeeting
import grails.converters.JSON
import grails.converters.XML

class BootStrap {
	
	def grailsApplication
	
    def init = { servletContext ->
		for (dc in grailsApplication.domainClasses) {
			dc.clazz.metaClass.getGrailsApplication = { -> grailsApplication }
			dc.clazz.metaClass.static.getGrailsApplication = { -> grailsApplication }
		}
		
		JSON.use("deep") {
			JSON.registerObjectMarshaller(StudentCourse) {
				return [
					'id': it.id,
					'student': it.student,
					'courseInstance': it.courseInstance,
					'levelOption': it.levelOption,
					'gradingOption': it.gradingOption,
					'dateCreated': it.dateCreated,
					'active': it.active,
					'state': it.state
				]
			}
			JSON.registerObjectMarshaller(CourseInstance) {
				return [
					'id': it.id,
					'title': it.title,
					'shortTitle': it.shortTitle,
					'subTitle': it.subTitle,
					'course': it.course,
					'term': it.term,
					'courseMeetings': it.courseMeetings
				]
			}
			JSON.registerObjectMarshaller(Course) {
				return [
					'id': it.id,
					'schoolId': it.schoolId,
					'registrarCode': it.registrarCode,
					'registrarCodeDisplay': it.registrarCodeDisplay,
					'source': it.source
				]
			}
			JSON.registerObjectMarshaller(CourseMeeting) {
				return [
					'day': it.day,
					'startTime': it.startTime,
					'endTime': it.endTime,
					'location': it.location
				]
			}
		}
		XML.use("deep") {
			XML.registerObjectMarshaller(StudentCourse) {
				return [
					'id': it.id,
					'student': it.student,
					'courseInstance': it.courseInstance,
					'levelOption': it.levelOption,
					'gradingOption': it.gradingOption,
					'dateCreated': it.dateCreated,
					'active': it.active,
					'state': it.state
				]
			}
			XML.registerObjectMarshaller(CourseInstance) {
				return [
					'id': it.id,
					'title': it.title,
					'shortTitle': it.shortTitle,
					'subTitle': it.subTitle,
					'course': it.course,
					'term': it.term,
					'courseMeetings': it.courseMeetings
				]
			}
			XML.registerObjectMarshaller(Course) {
				return [
					'id': it.id,
					'schoolId': it.schoolId,
					'registrarCode': it.registrarCode,
					'registrarCodeDisplay': it.registrarCodeDisplay,
					'source': it.source
				]
			}
			XML.registerObjectMarshaller(CourseMeeting) {
				return [
					'day': it.day,
					'startTime': it.startTime,
					'endTime': it.endTime,
					'location': it.location
				]
			}
		}
    }
    def destroy = {
    }
}
