package edu.harvard.coursereg

import grails.converters.*
import org.codehaus.groovy.grails.web.json.*

class AdviserController {
	
	def registrationService
	
	def list = {
		def petitions = this.petitionService.findAllByUserIdForFaculty(request.userId)
		withFormat {
			html {[petitionList:petitions, topicId:params.topicId]}
			json {render petitions as JSON}
			xml {render petitions as XML}
		}
	}
	
}
