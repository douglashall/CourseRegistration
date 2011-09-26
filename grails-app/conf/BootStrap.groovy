import edu.harvard.coursereg.StudentCourse
import edu.harvard.icommons.coursedata.Course
import edu.harvard.icommons.coursedata.CourseInstance
import grails.converters.JSON
import grails.converters.XML

class BootStrap {

    def init = { servletContext ->
		JSON.use("deep") {
			JSON.registerObjectMarshaller(StudentCourse) {
				return [
					'id': it.id,
					'student': it.student,
					'courseInstance': it.courseInstance,
					'registrationStates': it.registrationStates,
					'studentCourseAttributes': it.studentCourseAttributes,
					'dateCreated': it.dateCreated,
					'active': it.active
				]
			}
			JSON.registerObjectMarshaller(CourseInstance) {
				return [
					'id': it.id,
					'title': it.title,
					'shortTitle': it.shortTitle,
					'course': it.course,
					'term': it.term
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
		}
		XML.use("deep") {
			XML.registerObjectMarshaller(StudentCourse) {
				return [
					'id': it.id,
					'student': it.student,
					'courseInstance': it.courseInstance,
					'registrationStates': it.registrationStates,
					'studentCourseAttributes': it.studentCourseAttributes,
					'dateCreated': it.dateCreated,
					'active': it.active
				]
			}
			XML.registerObjectMarshaller(CourseInstance) {
				return [
					'id': it.id,
					'title': it.title,
					'shortTitle': it.shortTitle,
					'course': it.course,
					'term': it.term
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
		}
    }
    def destroy = {
    }
}
