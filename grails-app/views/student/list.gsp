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

        		$('.level-option-combo').each(function(){
	        		var combo = new Ext.form.ComboBox({
		        		transform: this,
	        			id: this.id,
	        			value: undefined,
	        	        triggerAction: 'all',
	        	        forceSelection: true,
	        	        allowBlank: false,
	        	        msgTarget: 'under',
	        	        emptyText: 'Please select...',
	        	        emptyClass: '',
		        	    validationEvent: false
	        	    });
	        	    combo.setRawValue('Please select...');
        		});
        		
        		$('.grading-option-combo').each(function(){
	        		var combo = new Ext.form.ComboBox({
		        		transform: this,
	        			id: this.id,
	        			value: undefined,
	        	        triggerAction: 'all',
	        	        forceSelection: true,
	        	        allowBlank: false,
	        	        msgTarget: 'under',
	        	        emptyText: 'Please select...',
	        	        emptyClass: '',
		        	    validationEvent: false
	        	    });
	        	    combo.setRawValue('Please select...');
        		});
        	    
        		var topicId = '${topicId}';
        		var regStudent = {
	        		<g:if test="${regStudent}">
		        		programDepartment: '${regStudent.programDepartment}',
		        		degreeYear: '${regStudent.degreeYear}'
		        	</g:if>
        		};
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
						{name: 'levelOptions'},
						{name: 'gradingOptions'},
						{name: 'schoolOptions'},
						{name: 'instructor'},
						{name: 'state'}
					]
                });
                store.loadData(data);

            	$('.course_create a').click(function(){
            		var tr = $(this).parents('tr').first();
            		var trEl = tr[0];
                	var rec = store.getAt(store.find('id', tr.attr('id')));

                	var id = rec.get('id');
                	var levelCombo = Ext.getCmp('level_option_' + id);
                	var gradingCombo = Ext.getCmp('grading_option_' + id);
                	var levelValid = !levelCombo || levelCombo.validate();
                	var gradingValid = !gradingCombo || gradingCombo.validate();
                	if (!levelValid || !gradingValid) {
                    	return;
                    }
                    
                    var win = new CourseRegistration.CreatePetitionWindow({
                        studentCourse: rec,
                        programDepartment: regStudent.programDepartment,
                        degreeYear: regStudent.degreeYear,
                        listeners: {
                            'createpetition': function(options){
                                regStudent.programDepartment = options.programDepartment;
                                regStudent.degreeYear = options.degreeYear;
                            	var mask = new Ext.LoadMask(this.body, {msg:"Please wait...", removeMask:true});
                            	mask.show();
                            	$.ajax({
        	                    	url: CourseRegistration.constructUrl('student/register/' + rec.get('courseInstanceId') + '?format=json', topicId, rec.get('userId')),
        	                    	type: CourseRegistration.requestType('POST'),
        	                    	headers: {
        	                        	'Accept': 'application/json'
        	                        },
        	                        dataType: 'json',
        	                        data: {
            	                        levelOption: levelCombo ? levelCombo.getValue() : undefined,
            	                        gradingOption: gradingCombo ? gradingCombo.getValue() : undefined,
            	                        homeSchoolId: options.homeSchoolId ? options.homeSchoolId : undefined,
                    	                programDepartment: options.programDepartment,
                    	                degreeYear: options.degreeYear
        	                        },
        	                    	success: function(data){
            	                    	mask.hide();
            	                    	win.close();
            	                    	if (data.state) {
                	                    	var state = data.state.state;
                	                    	var stateTerminal = data.state.terminal;
                	                    	var stateType = data.state.type;
            	                    		var stateRec = rec.get('state');
            	                    		stateRec.state = state;
            	                    		stateRec.terminal = stateTerminal;
            	                    		stateRec.type = stateType;
            	                    		store.commitChanges();

            	                    		if (levelCombo) {
                	                    		levelCombo.destroy();
                	                    		$('.course_level_option div', trEl).html(data.levelOption);
                	                    	}
                	                    	if (gradingCombo) {
                    	                    	gradingCombo.destroy();
                	                    		$('.course_grading_option div', trEl).html(data.gradingOption);
                    	                    }
                    	                    
            	                    		$('.course_create', trEl).remove();
            	                    		$('.status div', trEl).html(String.format('<div class="course_status icon-text {0}">{1}</div>', stateType, state));
            	                    	}
            	                    	$(trEl).effect('highlight', 1000);
        	                        }
        	                    });
                            }
                        }
                    });
                    win.show();
                });

                $('.course_remove a').click(function(){
                    var tr = $(this).parents('tr').first();
                	var rec = store.getAt(store.find('id', tr.attr('id')));
                	$.ajax({
                    	url: CourseRegistration.constructUrl('course/remove/' + rec.get('courseInstanceId') + '?format=json', topicId, rec.get('userId')),
                    	type: CourseRegistration.requestType('DELETE'),
                    	headers: {
                        	'Accept': 'application/json'
                        },
                        dataType: 'json',
                        success: function(data){
                        	store.remove(rec);
                        	if (tr.siblings().length == 0) {
                            	tr.parents('fieldset').first().slideUp(500, function(){
	                            	$(this).remove();
	                            });
                            } else {
	                        	tr.first().slideUp(500, function(){
	                        		$(this).remove();
	                            });
                            }
                        }
                    });
                });

                $('.course_print a').click(function(){
                	var tr = $(this).parents('tr').first();
            		var trEl = tr[0];
                	var rec = store.getAt(store.find('id', tr.attr('id')));

                	var id = rec.get('id');
                	var levelCombo = Ext.getCmp('level_option_' + id);
                	var gradingCombo = Ext.getCmp('grading_option_' + id);
                	var levelValid = !levelCombo || levelCombo.validate();
                	var gradingValid = !gradingCombo || gradingCombo.validate();
                	if (!levelValid || !gradingValid) {
                    	return;
                    }

                	var params = '';
                	if (levelCombo) {
                    	params += 'levelOption=' + levelCombo.getValue();
                    }
                    if (gradingCombo) {
                        if (levelCombo) {
                            params += '&';
                        }
                        params += 'gradingOption=' + gradingCombo.getValue();
                    }
                    if (params.length > 0) {
                        params = '?' +  params;
                    }
                	window.open(CourseRegistration.constructUrl('student/showPetitionForm/' + rec.get('id') + params, topicId), '_blank');
                });
            });
        	// ]]>
        </script>
    </head>
    <body>
    	<div class="course_catalog_tool">
    	<div class="result">
    	<g:if test="${model.size() == 0}">
    		<p>Use the <a href="/CourseCatalog">University Course Catalog</a> to find courses and add them to this list.</p>
    	</g:if>
    	<g:each in="${model}" var="entry">
	    	<fieldset>
				<legend>${entry.key}</legend>
				<table class="grid petition_form">
					<thead>
						<tr>
							<th style="width: 100%" rowspan="1" colspan="1">Course</th>
							<th rowspan="1" colspan="1">Level</th>
							<th rowspan="1" colspan="1">Grading Option</th>
							<th rowspan="1" colspan="1">Status</th>
							<th rowspan="1" colspan="1">Action</th>
						</tr>
					</thead>
					<tbody>
		    			<g:each in="${entry.value}" var="studentCourse">
							<tr class="course" id="${studentCourse.id}">
								<td rowspan="1" colspan="1">
									<span>${studentCourse.courseInstance.title} - ${studentCourse.courseInstance.subTitle} (${studentCourse.courseInstance.course.registrarCodeDisplay})</span>
									<br/>${studentCourse.courseInstance.instructorsDisplay}<br/>${studentCourse.courseInstance.meetingTime}
								</td>
								<td class="course_level_option" rowspan="1" colspan="1">
									<div>
										<g:if test="${studentCourse.courseSchool.id != 'hks' && studentCourse.courseSchool.schoolId != 'ksg'}">
											<g:if test="${studentCourse.levelOption}">
												${studentCourse.levelOption}
											</g:if>
											<g:else>
												<select id="level_option_${studentCourse.id}" class="level-option-combo">
													<g:each in="${studentCourse.levelOptions}" var="option">
														<option value="${option.id}">${option.name}</option>
													</g:each>
												</select>
											</g:else>
										</g:if>
									</div>
								</td>
								<td class="course_grading_option" rowspan="1" colspan="1">
									<div>
										<g:if test="${studentCourse.courseSchool.id != 'hks' && studentCourse.courseSchool.schoolId != 'ksg'}">
											<g:if test="${studentCourse.gradingOption}">
												${studentCourse.gradingOption}
											</g:if>
											<g:else>
												<select id="grading_option_${studentCourse.id}" class="grading-option-combo">
													<g:each in="${studentCourse.gradingOptions}" var="option">
														<option value="${option.id}">${option.name}</option>
													</g:each>
												</select>
											</g:else>
										</g:if>
									</div>
								</td>
								<td class="status" rowspan="1" colspan="1">
									<div>
										<g:if test="${studentCourse.state}">
											<div class="course_status icon-text ${studentCourse.state.type}">${studentCourse.state.state}</div>
										</g:if>
									</div>
								</td>
								<td class="registration_action" rowspan="1" colspan="1">
									<div>
										<g:if test="${studentCourse.courseSchool.id != 'hks' && studentCourse.courseSchool.schoolId != 'ksg'}">
											<g:if test="${!studentCourse.state}">
												<g:if test="${studentCourse.checkPilot()}">
													<div class="course_create"><a style="font-size: small" title="" href="javascript:void(0);">Submit Online Petition</a></div>
												</g:if>
												<g:else>
													<div class="course_print"><a style="font-size: small" title="" href="javascript:void(0);" target="">Create and Print Petition</a></div>
												</g:else>
											</g:if>
										</g:if>
										<g:else>
											<a href="https://secure.ksg.harvard.edu/degrees/HKSCrossRegistration/Default.aspx">Use HKS Online Cross Registration System</a>
										</g:else>
										<g:if test="${!studentCourse.state || (studentCourse.state && studentCourse.state.terminal == 0)}">
											<div class="course_remove"><a style="font-size: small" title="" href="javascript:void(0);">Remove</a></div>
										</g:if>
									</div>
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