<%@ page import="edu.harvard.coursereg.StudentCourse" %>
<%@ page import="edu.harvard.icommons.coursedata.CourseInstance" %>
<%@ page import="edu.harvard.icommons.coursedata.Course" %>
<%@ page import="edu.harvard.icommons.coursedata.Term" %>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
        <meta name="layout" content="main" />
        <script>
        	$(document).ready(function(){
        		Ext.QuickTips.init();
        		var topicId = '${topicId}';
        		var data = [];
            	<g:each in="${studentCourseList}" var="studentCourse">
            		data.push([
                       	'${studentCourse.courseInstance.id}',
                       	'${studentCourse.studentCourseAttributes['gradingOption']}',
                       	'${studentCourse.studentCourseAttributes['levelOption']}',
                       	'${studentCourse.courseInstance.course.schoolId}',
            			'${studentCourse.courseInstance.title}', 
            			'${studentCourse.courseInstance.course.registrarCodeDisplay}', 
            			'${studentCourse.courseInstance.instructorsDisplay}',
            			'${studentCourse.courseInstance.meetingTime}',
            			'${studentCourse.courseInstance.term.displayName}',
            			'${studentCourse.student.id}',
            			'${studentCourse.student.firstName}',
            			'${studentCourse.student.lastName}',
            			'${studentCourse.student.email}',
            			<g:if test="${studentCourse.registrationStates.size() > 0}">
            				'${studentCourse.registrationStates[0].state}'
        				</g:if>
        				
            		]);
            	</g:each>
            	var store = new Ext.data.ArrayStore({
                    fields: [
                       {name: 'courseInstanceId'},
                       {name: 'gradingOption'},
                       {name: 'levelOption'},
                       {name: 'courseSchool'},
                       {name: 'courseTitle'},
                       {name: 'courseNumber'},
                       {name: 'courseInstructor'},
                       {name: 'courseMeetingTime'},
                       {name: 'termDescription'},
                       {name: 'studentId'},
                       {name: 'firstName'},
                       {name: 'lastName'},
                       {name: 'email'},
                       {name: 'state'}
                    ]
                });
                store.loadData(data);

                var grid = new Ext.grid.GridPanel({
                    store: store,
                    columns: [
						{
                            id       : 'student',
                            header   : 'Student', 
                            width    : 300, 
                            sortable : true, 
                            dataIndex: 'studentId',
                            renderer : function(val, p, record){
                                return String.format('{0} {1}<br/>{2}', 
                                        record.get('firstName'),
                                        record.get('lastName'),
                                        record.get('email')
                                );
                            }
                        },
                        {
                            header   : 'School', 
                            sortable : true, 
                            dataIndex: 'levelOption'
                        },
                        {
                            header   : 'Level', 
                            sortable : true, 
                            dataIndex: 'levelOption'
                        },
                        {
                            header   : 'Grading Option', 
                            sortable : true, 
                            dataIndex: 'gradingOpiton'
                        },
                        {
                            header   : 'Status',
                            xtype: 'actioncolumn',
                            items: [{
                            	getClass: function(v, meta, rec) {
                                    if (rec.get('state')) {
                                        return '';
                                    } else {
                                        return 'create-col';
                                    }
                                },
                                tooltip: 'Approve',
                                handler: function(grid, rowIndex, colIndex) {
                                    var rec = store.getAt(rowIndex);
                                    var win = new CourseRegistration.CreatePetitionWindow({
                                        petition: rec,
                                        listeners: {
                                            'createpetition': function(petition){
                                                grid.loadMask.show();
                                            	$.ajax({
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
                        	                    });
                                            }
                                        }
                                    });
                                    win.show();
                                }
                            },{
                                icon   : 'http://isites.harvard.edu/js/isites/resources/images/cross.png',
                                tooltip: 'Deny',
                                handler: function(grid, rowIndex, colIndex) {
                                    var rec = store.getAt(rowIndex);
                                    grid.loadMask.show();
                                	$.ajax({
                                    	url: CourseRegistration.constructUrl('course/remove/' + rec.get('courseInstanceId') + '?format=json', topicId),
                                    	type: CourseRegistration.requestType('DELETE'),
                                    	headers: {
                                        	'Accept': 'application/json'
                                        },
                                        dataType: 'json',
                                        success: function(data){
                                        	store.remove(rec);
                                        	grid.loadMask.hide();
                                        }
                                    });
                                }
                            }]
                        }
                    ],
                    loadMask: {msg: 'Processing...'},
                    disableSelection: true,
                    stripeRows: true,
                    autoExpandColumn: 'course',
                    enableColumnHide: false,
                    enableColumnMove: false,
                    height: 350,
                    width: 700,
                    title: 'My Cross-Registration List',
                    header: false,
                    viewConfig: {
                        autoFill: true,
                        forceFit: true,
                        deferEmptyText: false,
                        emptyText: 'Use the <a href="http://coursecatalog.harvard.edu">Course Catalog</a> to add courses to your cross-registration list.'
                    }
                });

                grid.render('petition-ct');
            });
        </script>
    </head>
    <body>
    	<div id="petition-ct"></div>
    </body>
</html>
