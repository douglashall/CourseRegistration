package edu.harvard.coursereg

import grails.converters.*
import org.codehaus.groovy.grails.web.json.*

class AdminController {
	
	def list = {
		def controller = request.isRegistrarStaff ? "registrar" : "faculty"
		forward(controller: controller, action: "list")
	}
	
}
