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
        	CourseRegistration.approvePetitions = function(records, store, mask, win, topicId) {
				var ids = '';
				$(records).each(function(){
					ids += ' ' + this.get('id');
				});
		    	$.ajax({
		        	url: CourseRegistration.constructUrl('faculty/approve?format=json', topicId),
		        	type: CourseRegistration.requestType('POST'),
		        	headers: {
		            	'Accept': 'application/json'
		            },
		            data: {
		                ids: ids
		            },
		            dataType: 'json',
		        	success: function(data){
		            	if (mask) {
		            		mask.hide();
		            	}
		            	if (win) {
		            		win.close();
		            	}
		            	var trEls = [];
		            	$(data).each(function(){
		                	var rec = store.getAt(store.find('id', this.id));
		            		var state = this.state.state;
		                	var stateTerminal = this.state.terminal;
		                	var stateType = this.state.type;
		            		var stateRec = rec.get('state');
		            		stateRec.state = state;
		            		stateRec.terminal = stateTerminal;
		            		stateRec.type = stateType;
		            		store.commitChanges();
		
		            		trEls.push('#' + this.id);
		            		$('#' + this.id + ' .course_approve').remove();
		            		$('#' + this.id + ' .course_deny').remove();
		            		$('#' + this.id + ' .bulk_select input').remove();
		            		$('#' + this.id + ' .status div').html(String.format('<div class="course_status icon-text {0}{1}">{2}</div>', stateType, stateTerminal ? ' terminal' : '', state));
		                });
		            	$(trEls.join(',')).effect('highlight', 1000);
		            }
		        });
		    }
		    
		    CourseRegistration.denyPetitions = function(records, store, mask, win, topicId) {
		        var ids = '';
				$(records).each(function(){
					ids += ' ' + this.get('id');
				});
		    	$.ajax({
		        	url: CourseRegistration.constructUrl('faculty/deny?format=json', topicId),
		        	type: CourseRegistration.requestType('POST'),
		        	headers: {
		            	'Accept': 'application/json'
		            },
		            data: {
		                ids: ids
		            },
		            dataType: 'json',
		        	success: function(data){
		        		if (mask) {
		            		mask.hide();
		            	}
		            	if (win) {
		            		win.close();
		            	}
		            	var trEls = [];
		            	$(data).each(function(){
		                	var rec = store.getAt(store.find('id', this.id));
		            		var state = this.state.state;
		                	var stateTerminal = this.state.terminal;
		                	var stateType = this.state.type;
		            		var stateRec = rec.get('state');
		            		stateRec.state = state;
		            		stateRec.terminal = stateTerminal;
		            		stateRec.type = stateType;
		            		store.commitChanges();
		
		            		trEls.push('#' + this.id);
		            		$('#' + this.id + ' .course_approve').remove();
		            		$('#' + this.id + ' .course_deny').remove();
		            		$('#' + this.id + ' .bulk_select input').remove();
		            		$('#' + this.id + ' .status div').html(String.format('<div class="course_status icon-text {0}{1}">{2}</div>', stateType, stateTerminal ? ' terminal' : '', state));
		                });
		            	$(trEls.join(',')).effect('highlight', 1000);
		            }
		        });
		    }
    
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
	                       	'${item.courseInstance.shortTitle ? item.courseInstance.shortTitle.replace("'", "\\'") : ""}',
	                       	'${item.courseSchool.id}',
	                       	${item.instructor as JSON},
	                       	${item.state as JSON}
	            		]);
	            	</g:each>
            	</g:each>
				var store = new Ext.data.ArrayStore({
					fields: [
						{name: 'id'},
						{name: 'userId'},
						{name: 'courseInstanceId'},
						{name: 'courseShortTitle'},
						{name: 'courseSchoolId'},
						{name: 'instructor'},
						{name: 'state'}
					]
                });
                store.loadData(data);

                var approvalText = {};
                <g:each in="${approvalText}" var="entry">
                    approvalText['${entry.key}'] = '${entry.value}';
                </g:each>

                var denialText = {};
                <g:each in="${denialText}" var="entry">
                	denialText['${entry.key}'] = '${entry.value}';
                </g:each>

                $('.course_approve a').click(function(){
                	var tr = $(this).parents('tr').first();
                	var rec = store.getAt(store.find('id', tr.attr('id')));
                	var win = new CourseRegistration.ApprovePetitionWindow({
                        content: approvalText[rec.get('courseSchoolId')],
                        listeners: {
                            'approvepetition': function(){
                            	var mask = new Ext.LoadMask(this.body, {msg:"Please wait...", removeMask:true});
                            	mask.show();
                            	CourseRegistration.approvePetitions([rec], store, mask, win, topicId);
                            }
                        }
                    });
                    win.show();
                });

                $('.course_deny a').click(function(){
                	var tr = $(this).parents('tr').first();
                	var rec = store.getAt(store.find('id', tr.attr('id')));
                	var win = new CourseRegistration.DenyPetitionWindow({
                        content: denialText[rec.get('courseSchoolId')],
                        listeners: {
                            'denypetition': function(){
                            	var mask = new Ext.LoadMask(this.body, {msg:"Please wait...", removeMask:true});
                            	mask.show();
                            	CourseRegistration.denyPetitions([rec], store, mask, win, topicId);
                            }
                        }
                    });
                    win.show();
                });

                $('.bulk-operations .course_approve').click(function(){
                	var records = [];
                    $(this).parents('fieldset').find('tbody input:checked').each(function(){
                    	var tr = $(this).parents('tr').first();
                    	var rec = store.getAt(store.find('id', tr.attr('id')));
                        records.push(rec);
                    });

					var win = new CourseRegistration.ApprovePetitionWindow({
                        content: approvalText[records[0].get('courseSchoolId')],
                        listeners: {
                            'approvepetition': function(){
                            	var mask = new Ext.LoadMask(this.body, {msg:"Please wait...", removeMask:true});
                            	mask.show();
                            	CourseRegistration.approvePetitions(records, store, mask, win, topicId);
                            }
                        }
                    });
                    win.show();
                });

                $('.bulk-operations .course_deny').click(function(){
                    var records = [];
                    $(this).parents('fieldset').find('tbody input:checked').each(function(){
                    	var tr = $(this).parents('tr').first();
                    	var rec = store.getAt(store.find('id', tr.attr('id')));
                        records.push(rec);
                    });

                    var win = new CourseRegistration.DenyPetitionWindow({
                        content: denialText[records[0].get('courseSchoolId')],
                        listeners: {
                            'denypetition': function(){
                            	var mask = new Ext.LoadMask(this.body, {msg:"Please wait...", removeMask:true});
                            	mask.show();
                            	CourseRegistration.denyPetitions(records, store, mask, win, topicId);
                            }
                        }
                    });
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
                        $('.terminal').parents('tr.course').hide();
                        $('.terminal').parents('fieldset').each(function(){
                        	if ($('tr.course:visible', this).length == 0) {
                                $(this).hide();
                            }
                        });
                    } else {
                    	$(this).val('Hide Approved/Denied');
                    	$('.terminal').parents('fieldset').show();
                    	$('.terminal').parents('tr.course').show();
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
    	<div class="course_catalog_tool faculty">
    	<g:if test="${model.size() > 0}">
	    	<!-- <div class="approved-denied-toggle">
	    		<input type="button" value="Hide Approved/Denied" />
	    	</div> -->
	    </g:if>
	    <g:else>
	    	<div><p>You currently do not have any cross registration petitions.</p></div>
	    </g:else>
    	<div class="result">
    	<g:each in="${model}" var="entry">
	    	<fieldset>
				<legend>${entry.key}</legend>
				<div class="bulk-operations">
					<input type="button" class="course_approve" value="Approve All Selected" disabled="disabled" />
					<input type="button" class="course_deny" value="Deny All Selected" disabled="disabled" />
				</div>
				<table class="grid petition_form">
					<thead>
						<tr>
							<th style="width: 100%" rowspan="1" colspan="1">Student</th>
							<th rowspan="1" colspan="1">Student&nbsp;Home&nbsp;School</th>
							<th rowspan="1" colspan="1">Program/Department</th>
							<th rowspan="1" colspan="1">Degree&nbsp;Year</th>
							<th rowspan="1" colspan="1">Date&nbsp;Submitted</th>
							<th rowspan="1" colspan="1">Level</th>
							<th rowspan="1" colspan="1">Grading&nbsp;Option</th>
							<th rowspan="1" colspan="1">Status</th>
							<th rowspan="1" colspan="1">Action</th>
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
								<td rowspan="1" colspan="1">
									<div>${studentCourse.student.schoolDisplay}</div>
								</td>
								<td rowspan="1" colspan="1">
									<div>${studentCourse.programDepartment}</div>
								</td>
								<td rowspan="1" colspan="1">
									<div>${studentCourse.degreeYear}</div>
								</td>
								<td rowspan="1" colspan="1">
									<div>${studentCourse.dateSubmitted}</div>
								</td>
								<td class="course_level_option" rowspan="1" colspan="1">
									<div>${studentCourse.levelOption}</div>
								</td>
								<td class="course_grading_option" rowspan="1" colspan="1">
									<div>${studentCourse.gradingOption}</div>
								</td>
								<td class="status" rowspan="1" colspan="1">
									<div>
										<g:if test="${studentCourse.state}">
											<div class="course_status icon-text ${studentCourse.state.type}<g:if test="${studentCourse.state.terminal == 1}"> terminal</g:if>">
												${studentCourse.state.state}
												<g:if test="${studentCourse.state.terminal && studentCourse.stateCreator}">
													<br/><i>by ${studentCourse.stateCreator}</i>
												</g:if>
											</div>
										</g:if>
									</div>
								</td>
								<td class="registration_action" rowspan="1" colspan="1">
									<div>
										<g:if test="${!grailsApplication.config.faculty.actions.disabled || grailsApplication.config.faculty.actions.enabled.schools.contains(studentCourse.courseSchool.id)}">
											<g:if test="${studentCourse.state && !studentCourse.state.terminal}">
												<div class="course_approve"><a style="font-size: small" title="" href="javascript:void(0);">Approve</a></div>
												<div class="course_deny"><a style="font-size: small" title="" href="javascript:void(0);">Deny</a></div>
											</g:if>
										</g:if>
									</div>
								</td>
								<td class="bulk_select">
									<g:if test="${!grailsApplication.config.faculty.actions.disabled || grailsApplication.config.faculty.actions.enabled.schools.contains(studentCourse.courseSchool.id)}">
										<g:if test="${studentCourse.state && !studentCourse.state.terminal}">
											<input type="checkbox"/>
										</g:if>
									</g:if>
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