// locations to search for config files that get merged into the main config
// config files can either be Java properties files or ConfigSlurper scripts

grails.config.locations = [ "classpath:${appName}-config.properties",
							"classpath:${appName}-config.groovy",
							"file:${userHome}/.grails/${appName}-config.properties",
							"file:${userHome}/.grails/${appName}-config.groovy",
							"file:${userHome}/.grails/config.groovy"]

// if(System.properties["${appName}.config.location"]) {
//    grails.config.locations << "file:" + System.properties["${appName}.config.location"]
// }

grails.project.groupId = appName // change this to alter the default package name and Maven publishing destination
grails.mime.file.extensions = true // enables the parsing of file extensions from URLs into the request format
grails.mime.use.accept.header = true
grails.mime.types = [ xml: ['text/xml', 'application/xml'],
					  html: ['text/html','application/xhtml+xml'],
					  text: 'text/plain',
					  js: 'text/javascript',
					  rss: 'application/rss+xml',
					  atom: 'application/atom+xml',
					  css: 'text/css',
					  csv: 'text/csv',
					  all: '*/*',
					  json: ['application/json','text/json'],
					  form: 'application/x-www-form-urlencoded',
					  multipartForm: 'multipart/form-data'
					]

// URL Mapping Cache Max Size, defaults to 5000
//grails.urlmapping.cache.maxsize = 1000

// The default codec used to encode data with ${}
grails.views.default.codec = "none" // none, html, base64
grails.views.gsp.encoding = "UTF-8"
grails.converters.encoding = "UTF-8"
grails.converters.default.pretty.print = true
// enable Sitemesh preprocessing of GSP pages
grails.views.gsp.sitemesh.preprocess = true
// scaffolding templates configuration
grails.scaffolding.templates.domainSuffix = 'Instance'

// Set to false to use the new Grails 1.2 JSONBuilder in the render method
grails.json.legacy.builder = false
// enabled native2ascii conversion of i18n properties files
grails.enable.native2ascii = true
// whether to install the java.util.logging bridge for sl4j. Disable for AppEngine!
grails.logging.jul.usebridge = true
// packages to include in Spring bean scanning
grails.spring.bean.packages = []

// request parameters to mask when logging exceptions
grails.exceptionresolver.params.exclude = ['password']

// set per-environment serverURL stem for creating absolute links
environments {
	production {
		grails.serverURL = "http://www.changeme.com"
		icommonsapi.url = "http://tool2.isites.harvard.edu:8971/icommonsapi"
	}
	development {
		grails.serverURL = "http://localhost:8080/${appName}"
		icommonsapi.url = "http://qa.isites.harvard.edu:8861/icommonsapi"
		solr.url = "http://localhost:8983/solr"
		catalog.url = "http://qa.isites.harvard.edu:8986/solr"
		registrar.group.id = "18470"
	}
	test {
		grails.serverURL = "http://localhost:8080/${appName}"
		icommonsapi.url = "http://qa.isites.harvard.edu:8861/icommonsapi"
		solr.url = "http://qa.isites.harvard.edu:8955/solr"
		catalog.url = "http://qa.isites.harvard.edu:8986/solr"
		registrar.group.id = "18470"
	}

}

// log4j configuration
def catalinaBase = System.properties.getProperty('catalina.base')
if (!catalinaBase) {catalinaBase = "target"}
log4j = {
	// Example of changing the log pattern for the default console
	// appender:
	//
	//appenders {
	//    console name:'stdout', layout:pattern(conversionPattern: '%c{2} %m%n')
	//}
	appenders {
		rollingFile name: "requestLog",
					maxFileSize: 1024,
					layout: pattern(conversionPattern: "%d %m%n"),
					file: "${catalinaBase}/logs/request.log"
	}

	error  'org.codehaus.groovy.grails.web.servlet',  //  controllers
		   'org.codehaus.groovy.grails.web.pages', //  GSP
		   'org.codehaus.groovy.grails.web.sitemesh', //  layouts
		   'org.codehaus.groovy.grails.web.mapping.filter', // URL mapping
		   'org.codehaus.groovy.grails.web.mapping', // URL mapping
		   'org.codehaus.groovy.grails.commons', // core / classloading
		   'org.codehaus.groovy.grails.plugins', // plugins
		   'org.codehaus.groovy.grails.orm.hibernate', // hibernate integration
		   'org.springframework',
		   'org.hibernate',
		   'net.sf.ehcache.hibernate'

	warn   'org.mortbay.log'
    
    info   'grails.app.controller',
		   'grails.app.service',
		   'grails.app.domain'
		   
	info additivity: false,
		 requestLog: 'grails.app.filters.RequestLogFilters'
		   
    //debug  'org.apache.http.headers',
	//       'org.apache.http.wire'
		   
}