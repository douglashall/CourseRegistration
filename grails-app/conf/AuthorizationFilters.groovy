import org.codehaus.groovy.grails.commons.ConfigurationHolder

import edu.harvard.grails.plugins.baseline.BaselineUtils

class AuthorizationFilters {

	def config = ConfigurationHolder.config
	
    def filters = {
        authorize(controller:'*', action:'*') {
            before = {
				println config.registrar.group.id
				request.isRegistrarStaff = BaselineUtils.isGroupMember(request.userId, "IcGroup", config.registrar.group.id)
				if (request.isRegistrarStaff) {
					def whitelist = config.registrar.whitelist[request.userId]
					println whitelist
					if (whitelist) {
						request.schoolAffiliation = whitelist.school
					} else {
						def person = BaselineUtils.findPerson(request.userId)
						request.schoolAffiliation = BaselineUtils.ldapCodes[person.departmentAffiliation]
					}
				}
				return true
            }
        }
    }
    
}
