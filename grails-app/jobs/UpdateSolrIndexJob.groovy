import edu.harvard.coursereg.RegistrationContext
import edu.harvard.coursereg.RegistrationService


class UpdateSolrIndexJob {
	
	RegistrationService registrationService
	
    static triggers = {
		cron name: 'updateSolrIndexTrigger', cronExpression: "0 0 4 * * ?"
	}

    def execute() {
		log.info("Starting UpdateSolrIndexJob...")
		def studentCourses = []
		def contexts = RegistrationContext.findAll("\
			from RegistrationContext as ctx\
			where ctx.registrationContextStates.size > 0\
		")
		contexts.each {
			it.studentCourses.findAll {it.active == 1}.each {studentCourses << it}
		}
		this.registrationService.updateStudentCourseIndex(studentCourses)
		log.info("Completed UpdateSolrIndexJob.")
    }
	
}
