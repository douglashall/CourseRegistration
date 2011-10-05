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
	        Ext.namespace('CourseRegistration');
	
	        CourseRegistration.constructUrl = function(url, topicId) {
	        	try {
	        		return Isites.constructUrl(url) + '&topicId=' + topicId;
	        	} catch(e) {
	        		return '/CourseRegistration/' + url + '&userid=10564158';
	        	}
	        }
	
	        CourseRegistration.requestType = function(type) {
	        	try {
	        		if (Isites) {
	        			if (type == 'GET') {
	        				return type;
	        			} else {
	        				return 'POST';
	        			}
	        		}
	        	} catch(e) {
	        		return type;
	        	}
	        }
	
	        CourseRegistration.CreatePetitionFormPanel = Ext.extend(Ext.form.FormPanel, {
	        	border: false,
	        	labelWidth: 125,
	        	padding: 10,
	        	studentCourse: undefined,
	        	
	        	initComponent: function(){
		        	var schoolOptions = this.studentCourse.get('schoolOptions');
		        	this.items = [];
		        	if (schoolOptions.length > 1) {
		        	    this.items.push({
		        	    	id: 'home-school-combo',
		        	    	xtype: 'combo',
		        	        fieldLabel: 'Your school affiliation',
		        	        name: 'homeSchoolId',
		        	        store: CourseRegistration.schoolOptions,
		        	        displayField: 'title',
		        	        valueField: 'id',
		        	        mode: 'local',
		        	        forceSelection: true,
		        	        allowBlank: false,
		        	        msgTarget: 'side',
		        	        emptyText: 'Please select...'
		        	    });
	        		}
	
	        		CourseRegistration.CreatePetitionFormPanel.superclass.initComponent.apply(this);
	        	}
	        });
	
	        CourseRegistration.CreatePetitionWindow = Ext.extend(Ext.Window, {
	        	layout: 'border',
	        	title: 'Create a New Cross Registration Petition',
	        	buttonAlign: 'center',
	        	height: 300,
	        	width: 400,
	        	modal: true,
	        	studentCourse: undefined,
	        	
	        	initComponent: function(){
	        		this.items = [{
	        			region: 'north', 
	        			layout: 'fit', 
	        			border: false,
	        			padding: 10,
	        			html: String.format('<p>Submitting this form will begin the cross-registration process for {0}. {1} will receive a notification and either approve or deny your request. The faculty member may require a separate application process.</p>', this.studentCourse.get('courseShortTitle'), this.studentCourse.get('instructor').name)
	        		}, new CourseRegistration.CreatePetitionFormPanel({region: 'center', id: 'create-petition-form-panel', studentCourse: this.studentCourse})];
	        		this.buttons = [{
	        			text: 'Create',
	        			handler: function(){
	        				var isValid = true;
	        				var pnl = Ext.getCmp('create-petition-form-panel');
	        				pnl.cascade(function(){
	        					if (this.validate) {
	        						isValid = this.validate() && isValid;
	        					}
	        				});
	        				
	        				if (isValid) {
	        					var options = {};
	        					var levelOptionCombo = Ext.getCmp('level-option-combo');
	        					var gradingOptionCombo = Ext.getCmp('grading-option-combo');
	        					var homeSchoolCombo = Ext.getCmp('home-school-combo');
	        					if (levelOptionCombo) {
		        					var combo = Ext.getCmp('level-option-combo');
		        					var store = combo.getStore();
		        					var selected = store.getById(combo.getValue());
	                                options.levelOption = {
	    	                        	id: selected.id,
	    	                        	name: selected.get('name')
	                                };
	        					}
	        					if (gradingOptionCombo) {
	        						var combo = Ext.getCmp('grading-option-combo');
		        					var store = combo.getStore();
		        					var selected = store.getById(combo.getValue());
	                                options.gradingOption = {
	    	                        	id: selected.id,
	    	                        	name: selected.get('name')
	                                };
	        					}
	        					if (homeSchoolCombo) {
	                                options.homeSchoolId = Ext.getCmp('home-school-combo').getValue();
	        					}
	        					this.fireEvent('createpetition', options);
	        				}
	        			},
	        			scope: this
	        		},{
	        			text: 'Cancel',
	        			handler: function(){
	        				this.ownerCt.ownerCt.close();
	        			}
	        		}];
	        		
	        		CourseRegistration.CreatePetitionWindow.superclass.initComponent.apply(this);
	        		
	        		this.addEvents('createpetition');
	        	}
	        });
	        // ]]>
        </script>
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
                        listeners: {
                            'createpetition': function(options){
                            	var mask = new Ext.LoadMask(this.body, {msg:"Please wait...", removeMask:true});
                            	mask.show();
                            	$.ajax({
        	                    	url: CourseRegistration.constructUrl('student/register/' + rec.get('courseInstanceId') + '?format=json', topicId),
        	                    	type: CourseRegistration.requestType('POST'),
        	                    	headers: {
        	                        	'Accept': 'application/json'
        	                        },
        	                        dataType: 'json',
        	                        data: {
            	                        levelOption: levelCombo ? levelCombo.getValue() : undefined,
            	                        gradingOption: gradingCombo ? gradingCombo.getValue() : undefined,
            	                        homeSchoolId: options.homeSchoolId ? options.homeSchoolId : undefined
        	                        },
        	                    	success: function(data){
            	                    	mask.hide();
            	                    	win.close();
            	                    	if (data.state) {
                	                    	var state = data.state;
            	                    		rec.set('state', state);
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
            	                    		$('.course_remove', trEl).before(state + ' ');
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
                    	url: CourseRegistration.constructUrl('course/remove/' + rec.get('courseInstanceId') + '?format=json', topicId),
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
                    
                    var win = new CourseRegistration.CreatePetitionWindow({
                        studentCourse: rec,
                        listeners: {
                            'createpetition': function(options){
                            	win.close();
                            }
                        }
                    });
                    win.show();
                });
            });
        	// ]]>
        </script>
    </head>
    <body>
    	<div class="course_catalog_tool">
    	<div class="result">
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
								<td class="course_level_option" rowspan="1" colspan="1">
									<div>
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
									</div>
								</td>
								<td class="course_grading_option" rowspan="1" colspan="1">
									<div>
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
									</div>
								</td>
								<td class="status" rowspan="1" colspan="1">
									<g:if test="${studentCourse.state}">
										<div class="course_status">${studentCourse.state}</div>
									</g:if>
									<g:else>
										<g:if test="${studentCourse.checkPilot()}">
											<div class="course_create"><a style="font-size: small" title="" href="javascript:void(0);">Create Petition</a></div>
										</g:if>
										<g:else>
											<div class="course_print"><a style="font-size: small" title="" href="javascript:void(0);">Create PDF Petition Form</a></div>
										</g:else>
									</g:else>
									<div class="course_remove"><a style="font-size: small" title="" href="javascript:void(0);">Remove</a></div>
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