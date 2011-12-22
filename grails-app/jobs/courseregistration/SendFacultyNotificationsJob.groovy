package courseregistration

import edu.harvard.coursereg.RegistrationService;
import edu.harvard.coursereg.RegistrationState
import edu.harvard.coursereg.StudentCourse
import grails.util.Environment
import groovy.text.SimpleTemplateEngine


class SendFacultyNotificationsJob {
	
	RegistrationService registrationService
	
    static triggers = {
		cron name: 'sendFacultyNotificationsTrigger', cronExpression: "0 0 6 * * ?"
	}

    def execute() {
        def studentCourses = StudentCourse.findAllByActive(1).findAll {
			if (it.registrationContext) {
				return it.registrationContext.currentState.id == RegistrationState.PENDING
			}
			return false
		}
		
		def facultyMap = [:]
		studentCourses.each {studentCourse ->
			def instructors = studentCourse.getInstructors()
			instructors.each {
				def facultyEntry = facultyMap[it.userId]
				if (!facultyEntry) {
					facultyEntry = [
						faculty: it,
						studentCourseMap: [:]
					]
					facultyMap[it.userId] = facultyEntry
				}
				
				def ci = studentCourse.courseInstance
				def code = ci.shortTitle ? ci.shortTitle : ci.course.registrarCode
				def studentCourseEntry = facultyEntry.studentCourseMap[code]
				if (!studentCourseEntry) {
					studentCourseEntry = []
					facultyEntry.studentCourseMap[code] = studentCourseEntry
				}
				studentCourseEntry << studentCourse
			}
		}
		
		facultyMap.each {facultyKey, facultyVal ->
			facultyVal.studentCourseMap.each {courseKey, courseVal ->
				registrationService.sendNotificationEmailToFaculty(facultyVal.faculty, courseVal)
			}
		}
    }
	
}
