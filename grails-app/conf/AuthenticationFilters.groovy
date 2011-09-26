class AuthenticationFilters {

    def filters = {
        checkUser(controller:'*', action:'*') {
            before = {
                def userId = request.getHeader("HU-PIN-USER-ID")
				if (!userId) {
					userId = params.userid
				}
				if (userId) {
					request.userId = userId
				} else {
					log.error "unauthenticated access attempt: " + request.getRequestURL() + " " + request.getRemoteAddr()
					return false
				}
            }
        }
    }
    
}
