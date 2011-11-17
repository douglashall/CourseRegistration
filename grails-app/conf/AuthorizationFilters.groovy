import org.codehaus.groovy.grails.commons.ConfigurationHolder

import edu.harvard.grails.plugins.baseline.BaselineUtils

class AuthorizationFilters {

	def config = ConfigurationHolder.config
	
    def filters = {
        authorize(controller:'*', action:'*') {
            before = {
				request.isRegistrarStaff = BaselineUtils.isGroupMember(request.userId, "IcGroup", config.registrar.group.id)
				return true
            }
        }
    }
    
}
