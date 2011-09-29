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
        	$(document).ready(function(){
        		Ext.QuickTips.init();
        		var topicId = '${topicId}';
        		var data = [];
            	<g:each in="${model}" var="item">
            		data.push([
						'${item.value.id[0]}',
						'${item.value.userId[0]}',
                       	'${item.value.courseInstance.id[0]}',
                       	${item.value.levelOptions as JSON},
                       	${item.value.gradingOptions as JSON}
            		]);
            	</g:each>
				var store = new Ext.data.ArrayStore({
					fields: [
						{name: 'id'},
						{name: 'userId'},
						{name: 'courseInstanceId'},
						{name: 'levelOptions'},
						{name: 'gradingOptions'}
					]
                });
                store.loadData(data);

            	$('.course_add').click(function(){
            		var tr = $(this).parents('tr').first();
                	var rec = store.getAt(store.find('id', tr.attr('id')));
                    var win = new CourseRegistration.CreatePetitionWindow({
                        studentCourse: rec,
                        listeners: {
                            'createpetition': function(petition){
                            	/*$.ajax({
        	                    	url: CourseRegistration.constructUrl('petition/create?format=json', topicId),
        	                    	type: CourseRegistration.requestType('PUT'),
        	                    	headers: {
        	                        	'Accept': 'application/json'
        	                        },
        	                        dataType: 'json',
        	                        data: {
            	                        petition: JSON.stringify(petition)
        	                        },
        	                    	success: function(data){
            	                    	rec.set('state', data.state);
            	                    	grid.getStore().commitChanges();
            	                    	grid.loadMask.hide();
        	                        }
        	                    });*/
                            }
                        }
                    });
                    win.show();
                });

                $('.course_remove').click(function(){
                    var tr = $(this).parents('tr').first();
                	var rec = store.getAt(store.find('id', tr.attr('id')));
                	$.ajax({
                    	url: CourseRegistration.constructUrl('course/remove/' + rec.get('courseInstanceId') + '?format=json', topicId),
                    	type: CourseRegistration.requestType('DELETE'),
                    	headers: {
                        	'Accept': 'application/json'
                        },
                        dataType: 'json',
                        success: function(data){
                        	store.remove(rec);
                        	if (tr.parent().length == 1) {
                            	tr.parents('fieldset').first().slideUp(500, function(){
	                            	$(this).remove();
	                            });
                            } else {
	                        	tr.slideUp(500, function(){
	                            	tr.remove();
	                            });
                            }
                        }
                    });
                });
            });
        </script>
    </head>
    <body>
    	<g:each in="${model}" var="entry">
	    	<fieldset>
				<legend>${entry.key}</legend>
				<table class="grid petition_form">
					<thead>
						<tr>
							<th style="width: 100%" rowspan="1" colspan="1">Course</th>
							<th rowspan="1" colspan="1">Level</th>
							<th rowspan="1" colspan="1">Grading&nbsp;Option</th>
							<th rowspan="1" colspan="1">Status</th>
						</tr>
					</thead>
					<tbody>
		    			<g:each in="${entry.value}" var="studentCourse">
							<tr class="course" id="${studentCourse.id}">
								<td rowspan="1" colspan="1">
									<span>${studentCourse.courseInstance.title} - ${studentCourse.courseInstance.subTitle} (${studentCourse.courseInstance.course.registrarCodeDisplay})</span>
									<br/>${studentCourse.courseInstance.instructorsDisplay}<br/>${studentCourse.courseInstance.meetingTime}
								</td>
								<td rowspan="1" colspan="1">
									<g:if test="${studentCourse.studentCourseAttributes['levelOption']}">
										${studentCourse.studentCourseAttributes['levelOption']}
									</g:if>
								</td>
								<td rowspan="1" colspan="1">
									<g:if test="${studentCourse.studentCourseAttributes['gradingOption']}">
										${studentCourse.studentCourseAttributes['gradingOption']}
									</g:if>
								</td>
								<td rowspan="1" colspan="1">
									<a class="course_add addthis isites-button" style="font-size: small" title="" href="javascript:void(0);" shape="rect">Add</a>
									<a class="course_print printthis isites-button" style="font-size: small" title="" href="javascript:void(0);" shape="rect">Print</a>
									<a class="course_remove removethis isites-button" style="font-size: small" title="" href="javascript:void(0);" shape="rect">Remove</a>
								</td>
							</tr>
						</g:each>
					</tbody>
				</table>
			</fieldset>
		</g:each>
    </body>
</html>