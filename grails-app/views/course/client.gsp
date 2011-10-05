<%@ page import="edu.harvard.coursereg.StudentCourse" %>
<%@ page import="edu.harvard.icommons.coursedata.CourseInstance" %>
<%@ page import="edu.harvard.icommons.coursedata.Course" %>
<%@ page import="edu.harvard.icommons.coursedata.Term" %>
<%@ page import="grails.converters.JSON" %>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
        <meta name="layout" content="main" />
        <script>
        	// <![CDATA[
        	$(document).ready(function(){
            	$('.add-course').click(function(){
			        $.ajax({
		            	url: Isites.constructUrl('/course/add/' + this.id) + '&topicId=icb.topic940957',
		            	type: 'POST',
		            	headers: {
		                	'Accept': 'application/json'
		                },
		                dataType: 'json',
		                success: function(data){
		                	alert('Course Added!');
		                }
		            });
            	});
        	});
        	// ]]>
        </script>
    </head>
    <body>
    	<div>
    		<button id="293523" class="add-course">Computer Science 50</button>
    	</div>
    	<div>
    		<button id="282016" class="add-course">Spiritual Formation</button>
    	</div>
    	<div>
    		<button id="274412" class="add-course">Genetic Epi</button>
    	</div>
    	<div>
    		<button id="281703" class="add-course">Public Health Surveillance</button>
    	</div>
    	<div>
    		<button id="272900" class="add-course">Children and Emotion</button>
    	</div>
    	<div>
    		<button id="272892" class="add-course">Cognitive Development</button>
    	</div>
    </body>
</html>