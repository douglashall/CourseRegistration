grails.project.class.dir = "target/classes"
grails.project.test.class.dir = "target/test-classes"
grails.project.test.reports.dir = "target/test-reports"
//grails.project.war.file = "target/${appName}-${appVersion}.war"
grails.project.dependency.resolution = {
    // inherit Grails' default dependencies
    inherits("global") {
        // uncomment to disable ehcache
        // excludes 'ehcache'
    }
    log "warn" // log level of Ivy resolver, either 'error', 'warn', 'info', 'debug' or 'verbose'
    repositories {
        grailsPlugins()
        grailsHome()
        grailsCentral()
		mavenLocal()

        // uncomment the below to enable remote dependency resolution
        // from public Maven repositories
        //mavenCentral()
        //mavenRepo "http://snapshots.repository.codehaus.org"
        //mavenRepo "http://repository.codehaus.org"
        //mavenRepo "http://download.java.net/maven/2/"
        //mavenRepo "http://repository.jboss.com/maven2/"
		mavenRepo "http://artifactory.icommons.harvard.edu/artifactory/libs-release/"
    }
    dependencies {
        // specify dependencies here under either 'build', 'compile', 'runtime', 'test' or 'provided' scopes eg.

        compile(
			'org.codehaus.groovy.modules.http-builder:http-builder:0.5.2',
			'org.apache.httpcomponents:httpclient:4.1.2',
			'net.sourceforge.saxon:saxon:9.1.0.8',
			'org.apache.xmlgraphics:fop:0.93'
		) {
			excludes([group: 'xml-apis', name: 'xmlParserAPIs'], "xercesImpl")
		}
		
        runtime('com.oracle:ojdbc6:11.2.0.2')
    }
	plugins {
		compile(
			'edu.harvard.icommons.grails.plugins:isites-coursedata:0.3',
			'edu.harvard.grails.plugins:baseline:0.1',
			':mail:1.0'
		)
	}
}
