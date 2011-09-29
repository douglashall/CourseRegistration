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
	        		this.items = [{
	        	    	id: 'level-option-combo',
	        	    	xtype: 'combo',
	        	        fieldLabel: 'Level',
	        	        name: 'levelOption',
	        	        store: new Ext.data.JsonStore({
	        	            root: 'options',
	        	            idProperty: 'id',
	        	            fields: ['id', 'name'],
	        	            data: {options: this.studentCourse.get('levelOptions')[0]}
	        	        }),
	        	        displayField: 'name',
	        	        valueField: 'id',
	        	        mode: 'local',
	        	        triggerAction: 'all',
	        	        forceSelection: true,
	        	        allowBlank: false,
	        	        msgTarget: 'side',
	        	        emptyText: 'Please select...'
	        	    },{
	        			id: 'grading-option-combo',
	        			xtype: 'combo',
	        	        fieldLabel: 'Grading Option',
	        	        name: 'gradingOption',
	        	        store: new Ext.data.JsonStore({
	        	            root: 'options',
	        	            idProperty: 'id',
	        	            fields: ['id', 'name'],
	        	            data: {options: this.studentCourse.get('gradingOptions')[0]}
	        	        }),
	        	        displayField: 'name',
	        	        valueField: 'id',
	        	        mode: 'local',
	        	        triggerAction: 'all',
	        	        forceSelection: true,
	        	        allowBlank: false,
	        	        msgTarget: 'side',
	        	        emptyText: 'Please select...'
	        	    }/*,{
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
	        	    }*/];
	
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
	        			html: String.format('<p>Submitting this form will begin the cross-registration process for {0}. {1} will receive a notification and either approve or deny your request. The faculty member may require a separate application process.</p>', this.studentCourse.get('courseShortTitle'), this.studentCourse.get('instructor')[0].name)
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
	        					var p = {
	                                courseId: this.studentCourse.get('courseId'),
	                                levelOption: Ext.getCmp('level-option-combo').getValue(),
	                                gradingOption: Ext.getCmp('grading-option-combo').getValue(),
	                                homeSchoolId: Ext.getCmp('home-school-combo').getValue()
	                            };
	        					this.fireEvent('createpetition', p);
	        					this.close();
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
        </script>
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
                       	'${item.value.courseInstance.shortTitle[0]}',
                       	${item.value.levelOptions as JSON},
                       	${item.value.gradingOptions as JSON},
                       	${item.value.instructor as JSON}
            		]);
            	</g:each>
				var store = new Ext.data.ArrayStore({
					fields: [
						{name: 'id'},
						{name: 'userId'},
						{name: 'courseInstanceId'},
						{name: 'courseShortTitle'},
						{name: 'levelOptions'},
						{name: 'gradingOptions'},
						{name: 'instructor'}
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
									<g:if test="${studentCourse.checkPilot()}">
										<a class="course_add addthis isites-button" style="font-size: small" title="" href="javascript:void(0);">Add</a>
									</g:if>
									<g:else>
										<a class="course_print printthis isites-button" style="font-size: small" title="" href="javascript:void(0);">Print</a>
									</g:else>
									<a class="course_remove removethis isites-button" style="font-size: small" title="" href="javascript:void(0);">Remove</a>
								</td>
							</tr>
						</g:each>
					</tbody>
				</table>
			</fieldset>
		</g:each>
    </body>
</html>