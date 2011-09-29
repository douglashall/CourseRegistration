package edu.harvard.coursereg

import grails.converters.*

import org.codehaus.groovy.grails.web.json.*

class ApplicationController {
	
	def reloadConfig = {
		def locations = grailsApplication.config.grails.config.locations
		locations.each {
			String configFileName
			if (it.startsWith("classpath:")) {
				configFileName = it.split("classpath:")[1]
			} else {
				configFileName = it.split("file:")[1]
			}
			File configFile = new File(configFileName)
			if (configFile.exists()) {
				grailsApplication.config.merge(new ConfigSlurper().parse(configFile.text))
			}
		}
		
		render(contentType: "application/json") {["success": true]} as JSON
	}
	
}
