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
            	<g:each in="${studentCourses}" var="item">
            		data.push([
						"${item.id}",
						"${item.studentHuid}",
						"${item.studentLastName}, ${item.studentFirstName}",
						"${item.studentEmail}",
						"${item.studentPhone}",
						"${item.homeSchool}",
						"${item.courseSchool}",
                       	"${item.courseInstanceId}",
                       	"${item.courseShortTitle}",
                       	"${item.term}",
                       	"${item.instructorName}",
                       	"${item.instructorEmail}",
                       	"${item.instructorPhone}",
                       	"${item.state}",
                       	"${item.stateTerminal}",
                       	"${item.stateType}",
                       	"${item.petitionCreated}"
            		]);
            	</g:each>
            	var params = {};
				var store = new Ext.data.JsonStore({
					url: CourseRegistration.constructUrl('registrar/list?format=json', topicId),
					root: 'root',
					//proxy: new Ext.ux.data.PagingMemoryProxy(data),
					//reader: new Ext.data.ArrayReader({
						fields: [
							{name: 'id', mapping: 'id'},
							{name: 'userId', mapping: 'studentHuid'},
							{name: 'firstName', mapping: 'studentFirstName'},
							{name: 'lastName', mapping: 'studentLastName'},
							{name: 'email', mapping: 'studentEmail'},
							{name: 'phone', mapping: 'studentPhone'},
							{name: 'homeSchool', mapping: 'homeSchool'},
							{name: 'courseSchool', mapping: 'courseSchool'},
							{name: 'courseInstanceId', mapping: 'courseInstanceId'},
							{name: 'courseShortTitle', mapping: 'courseShortTitle'},
							{name: 'term', mapping: 'term'},
							{name: 'instructorName', mapping: 'instructorName'},
							{name: 'instructorEmail', mapping: 'instructorEmail'},
							{name: 'instructorPhone', mapping: 'instructorPhone'},
							{name: 'state', mapping: 'state'},
							{name: 'stateTerminal', mapping: 'stateTerminal'},
							{name: 'stateType', mapping: 'stateType'},
							{name: 'petitionCreated', mapping: 'petitionCreated'}
						]
					//})
                });
                store.load({params:{start:0, limit:50}});

                var sm = new Ext.grid.CheckboxSelectionModel();
                var dataPnl = new Ext.grid.GridPanel({
                    id: 'data',
                    renderTo: 'petition-data-pnl',
                    height: 400,
                    store: store,
                    tbar: {
                        items: [{
						    text: 'Actions',
						    iconCls: 'action',
						    menu: new Ext.menu.Menu({
						        id: 'actionMenu',
						        items: [{
						        	iconCls: 'approve',
						            text: 'Approve',
						            handler: function(){
							            CourseRegistration.approvePetitions(sm.getSelections(), store, undefined, undefined, topicId);
							        }
						        },{
						        	iconCls: 'deny',
						            text: 'Deny',
						            handler: function(){
						            	CourseRegistration.denyPetitions(sm.getSelections(), store, topicId);
							        }
						        },{
						        	iconCls: 'export',
						            text: 'Export',
						            menu: new Ext.menu.Menu({
							            id: 'exportMenu',
							            items: [{
							            	iconCls: 'excel',
								            text: 'Excel',
								            handler: function(){
									            window.open('http://localhost:8080/CourseRegistration/registrar/export?userid=10564158', '_self');
									        }
								        },{
							            	iconCls: 'pdf',
								            text: 'PDF'
								        },{
							            	iconCls: 'xml',
								            text: 'XML'
								        },{
							            	iconCls: 'json',
								            text: 'JSON'
								        }]
							        })
						        }]
						    })
						}, ' ', new Ext.ux.form.SearchField({
			                store: store,
			                width:200
			            }), '->', 'Status:', {
                            xtype: 'combo',
                            store: new Ext.data.ArrayStore({
                                autoDestroy: true,
                                fields: ['id', 'name'],
                                data : [
                                    ['1', 'All'],
                                    ['2', 'Approved'],
                                    ['3', 'Awaiting Faculty Approval'],
                                    ['4', 'Denied'],
                                ]
                            }),
                            valueField: 'id',
                            displayField: 'name',
                            mode: 'local',
                            editable: false,
                            forceSelection: true,
                            triggerAction: 'all',
                            selectOnFocus: true,
                            width: 175,
                            value: '1',
                            listeners: {
                                select: function(combo, record, index) {
                                	if (index == 0) {
                                        delete params["status"];
                                    } else {
                                        params["status"] = record.get('name');
                                    }
                                	store.load({params:params});
                                }
                            }
                        }, ' ', 'School:', {
                            xtype: 'combo',
                            store: new Ext.data.ArrayStore({
                                autoDestroy: true,
                                fields: ['id', 'name'],
                                data : [
									['1', 'All'],
                                    ['2', 'Faculty of Arts and Sciences'],
                                    ['3', 'Harvard Business School - Doctoral Program'],
                                    ['4', 'Harvard Business School - MBA Program'],
                                    ['5', 'Harvard Divinity School'],
                                    ['6', 'Harvard Extension School'],
                                    ['7', 'Harvard Graduate School of Design'],
                                    ['8', 'Harvard Graduate School of Education'],
                                    ['9', 'Harvard Kennedy School'],
                                    ['10', 'Harvard Law School'],
                                    ['11', 'Harvard Medical School'],
                                    ['12', 'Harvard School of Dental Medicine'],
                                    ['13', 'Harvard School of Public Health'],
                                    ['14', 'Harvard Summer School']
                                ]
                            }),
                            valueField: 'id',
                            displayField: 'name',
                            mode: 'local',
                            editable: false,
                            forceSelection: true,
                            triggerAction: 'all',
                            selectOnFocus: true,
                            width: 250,
                            value: '8',
                            listeners: {
                                select: function(combo, record, index) {
                                    if (index == 0) {
                                        delete params["school"];
                                    } else {
                                        params["school"] = record.get('name');
                                    }
                                    store.load({params:params});
                                }
                            }
                        }/*, ' ', 'Students:', {
                            xtype: 'combo',
                            store: new Ext.data.ArrayStore({
                                autoDestroy: true,
                                fields: ['id', 'name'],
                                data : [
									['1', 'All'],
                                    ['2', 'Incoming'],
                                    ['3', 'Outgoing']
                                ]
                            }),
                            valueField: 'id',
                            displayField: 'name',
                            mode: 'local',
                            editable: false,
                            forceSelection: true,
                            triggerAction: 'all',
                            selectOnFocus: true,
                            width: 150,
                            value: '2'
                        }*/]
                    },
                    bbar: new Ext.PagingToolbar({
                        pageSize: 50,
                        store: store,
                        displayInfo: true,
                        plugins: new Ext.ux.SlidingPager()
                    }),
                    colModel: new Ext.grid.ColumnModel({
                        defaults: {
                            sortable: true
                        },
                        columns: [
                            sm,
							/*{
							    xtype: 'actioncolumn',
							    header: 'Status',
							    width: 75,
							    align: 'center',
							    items: [{
							        icon   : 'http://isites.harvard.edu/js/isites/resources/images/fugue/tick-circle-frame.png',
							        iconCls: 'column-btn',
							        tooltip: 'Approve',
							        handler: function(grid, rowIndex, colIndex) {
							            alert('Approved');
							        }
							    },{
							        icon   : 'http://isites.harvard.edu/js/isites/resources/images/fugue/cross-circle-frame.png',
									iconCls: 'column-btn',
							        tooltip: 'Deny',
							        handler: function(grid, rowIndex, colIndex) {
							            alert('Denied');
							        }
							    }]
							},*/
							{
                            	header: 'Status', 
                                dataIndex: 'state', 
                                renderer: function(value, metadata, record){
                                    return String.format('<div class="icon-text {0}">{1}</div>', record.get('stateType'), value);
                                }
							},
                            {
                                header: 'Student', 
                                dataIndex: 'lastName', 
                                renderer: function(value, metadata, record){
                                    return String.format('{0}, {1}<br/><a href="mailto:{2}">{2}</a><br/>{3}<br/>', 
                                            value, record.get('firstName'), record.get('email'), record.get('phone'));
                                }
                            },
                            {header: 'Submitted On', dataIndex: 'petitionCreated'},
                            {header: 'Home School', dataIndex: 'homeSchool'},
                            {header: 'School', dataIndex: 'courseSchool'},
                            {header: 'Course', dataIndex: 'courseShortTitle'},
                            {header: 'Term', dataIndex: 'term'},
                            {
                                header: 'Faculty', 
                                dataIndex: 'instructorName', 
                                renderer: function(value, metadata, record){
                                    return String.format('{0}<br/><a href="mailto:{1}">{1}</a><br/>{2}<br/>', 
                                            value, record.get('instructorEmail'), record.get('instructorPhone'));
                                }
                            }
                        ]
                    }),
                    viewConfig: {
                        forceFit: true
                    },
                    sm: sm,
                    frame: true,
                    plugins: new Ext.ux.PanelResizer({
                        minHeight: 100
                    })
                });
        	});
			// ]]>
        </script>
    </head>
    <body>
    	<div id="petition-data-pnl"></div>
    </body>
</html>