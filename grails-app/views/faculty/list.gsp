<%@ page import="edu.harvard.coursereg.StudentCourse" %>
<%@ page import="edu.harvard.icommons.coursedata.CourseInstance" %>
<%@ page import="edu.harvard.icommons.coursedata.Course" %>
<%@ page import="edu.harvard.icommons.coursedata.Term" %>
<%@ page import="grails.converters.JSON" %>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
        <script>
        	// <![CDATA[
        	$(document).ready(function(){
        		Ext.QuickTips.init();
				var topicId = '${topicId}';
        		var data = [];
            	<g:each in="${model}" var="entry">
            		<g:each in="${entry.value}" var="item">
	            		data.push([
							'${item.id}',
							'${item.userId}',
	                       	'${item.courseInstance.id}',
	                       	'${item.courseInstance.shortTitle}',
	                       	${item.levelOptions as JSON},
	                       	${item.gradingOptions as JSON},
	                    	${item.schoolOptions as JSON},
	                       	${item.instructor as JSON}
	            		]);
	            	</g:each>
            	</g:each>
				var store = new Ext.data.ArrayStore({
					fields: [
						{name: 'id'},
						{name: 'userId'},
						{name: 'courseInstanceId'},
						{name: 'courseShortTitle'},
						{name: 'levelOptions'},
						{name: 'gradingOptions'},
						{name: 'schoolOptions'},
						{name: 'instructor'}
					]
                });
                store.loadData(data);

                $('.course_approve a').click(function(){
                	var tr = $(this).parents('tr').first();
                	var rec = store.getAt(store.find('id', tr.attr('id')));
                	var win = new CourseRegistration.ApprovePetitionWindow({
                        studentCourse: rec,
                        listeners: {
                            'approvepetition': function(){
                            	win.close();
                            }
                        }
                    });
                    win.show();
                });

                $('.course_deny a').click(function(){
                });

                $('.bulk-select').click(function(){
                    if (!$(this).attr('checked')) {
                    	$(this).parents('table.petition_form').find('input:checkbox').removeAttr('checked');
                    } else {
                    	$(this).parents('table.petition_form').find('input:checkbox').attr('checked', 'checked');
                    }
                    toggleBulkOperations($(this).parents('fieldset').first());
                });

                $('.approved-denied-toggle input').click(function(){
                    var val = $(this).val();
                    if (val.indexOf('Hide') >= 0) {
                        $(this).val('Show Approved/Denied');
                    } else {
                    	$(this).val('Hide Approved/Denied');
                    }
                });
                
                $('.course input:checkbox').click(function(){
                	toggleBulkOperations($(this).parents('fieldset').first());
                });

                function toggleBulkOperations(selector) {
                    if (selector.find('tbody input:checked').length > 0) {
                        selector.find('.bulk-operations input').removeAttr('disabled');
                    } else {
                    	selector.find('.bulk-operations input').attr('disabled', 'disabled');
                    	selector.find('.bulk-select').removeAttr('checked');
                    }
                }
        	});
			// ]]>
        </script>
    </head>
    <body>
    	<div class="course_catalog_tool">
    	<div class="approved-denied-toggle">
    		<input type="button" value="Hide Approved/Denied" />
    	</div>
    	<div class="result">
    	<g:each in="${model}" var="entry">
	    	<fieldset>
				<legend>${entry.key}</legend>
				<div class="bulk-operations">
					<input type="button" value="Approve All Selected" disabled="disabled" />
					<input type="button" value="Deny All Selected" disabled="disabled" />
				</div>
				<table class="grid petition_form">
					<thead>
						<tr>
							<th style="width: 100%" rowspan="1" colspan="1">Student</th>
							<th rowspan="1" colspan="1">School</th>
							<th rowspan="1" colspan="1">Level</th>
							<th rowspan="1" colspan="1">Grading&nbsp;Option</th>
							<th rowspan="1" colspan="1">Status</th>
							<th rowspan="1" colspan="1"><input type="checkbox" class="bulk-select" /></th>
						</tr>
					</thead>
					<tbody>
		    			<g:each in="${entry.value}" var="studentCourse">
							<tr class="course" id="${studentCourse.id}">
								<td rowspan="1" colspan="1">
									<span>${studentCourse.student.firstName} ${studentCourse.student.lastName}</span>
									<br/>
									<a href="mailto:${studentCourse.student.email}">${studentCourse.student.email}</a>
								</td>
								<td class="school_option" rowspan="1" colspan="1">
									<div>${studentCourse.student.school}</div>
								</td>
								<td class="course_level_option" rowspan="1" colspan="1">
									<div>${studentCourse.levelOption}</div>
								</td>
								<td class="course_grading_option" rowspan="1" colspan="1">
									<div>${studentCourse.gradingOption}</div>
								</td>
								<td class="status" rowspan="1" colspan="1">
									<g:if test="${studentCourse.state}">
										<div class="course_status">${studentCourse.state}</div>
									</g:if>
									<div class="course_approve"><a style="font-size: small" title="" href="javascript:void(0);">Approve</a></div>
									<div class="course_deny"><a style="font-size: small" title="" href="javascript:void(0);">Deny</a></div>
								</td>
								<td>
									<input type="checkbox"/>
								</td>
							</tr>
						</g:each>
					</tbody>
				</table>
			</fieldset>
		</g:each>
		</div>
		</div>
    </body>
</html>