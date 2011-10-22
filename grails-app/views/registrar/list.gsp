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
                       	"${item.stateType}"
            		]);
            	</g:each>
				var store = new Ext.data.Store({
					proxy: new Ext.ux.data.PagingMemoryProxy(data),
					reader: new Ext.data.ArrayReader({
						fields: [
							{name: 'id'},
							{name: 'userId'},
							{name: 'name'},
							{name: 'email'},
							{name: 'phone'},
							{name: 'homeSchool'},
							{name: 'courseSchool'},
							{name: 'courseInstanceId'},
							{name: 'courseShortTitle'},
							{name: 'term'},
							{name: 'instructorName'},
							{name: 'instructorEmail'},
							{name: 'instructorPhone'},
							{name: 'state'},
							{name: 'stateTerminal'},
							{name: 'stateType'}
						]
					})
                });
                store.load({params:{start:0, limit:1000}});

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
						            text: 'Approve'
						        },{
						        	iconCls: 'deny',
						            text: 'Deny'
						        },{
						        	iconCls: 'export',
						            text: 'Export'
						        }]
						    })
						}, '->', 'Status:', {
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
                            value: '1'
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
                            width: 225,
                            value: '1'
                        }, ' ', 'Students:', {
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
                            value: '1'
                        }]
                    },
                    bbar: new Ext.PagingToolbar({
                        pageSize: 1000,
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
                                dataIndex: 'name', 
                                renderer: function(value, metadata, record){
                                    return String.format('{0}<br/><a href="mailto:{1}">{1}</a><br/>{2}<br/>', 
                                            value, record.get('email'), record.get('phone'));
                                }
                            },
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