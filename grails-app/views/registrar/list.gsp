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
							{name: 'homeSchool', mapping: 'homeSchoolDisplay'},
							{name: 'hostSchool', mapping: 'hostSchoolDisplay'},
							{name: 'courseInstanceId', mapping: 'courseInstanceId'},
							{name: 'courseShortTitle', mapping: 'courseShortTitle'},
							{name: 'term', mapping: 'term'},
							{name: 'instructorName', mapping: 'instructorName'},
							{name: 'instructorEmail', mapping: 'instructorEmail'},
							{name: 'instructorPhone', mapping: 'instructorPhone'},
							{name: 'state', mapping: 'state'},
							{name: 'stateTerminal', mapping: 'stateTerminal'},
							{name: 'stateType', mapping: 'stateType'},
							{name: 'petitionCreated', mapping: 'petitionCreated'},
							{name: 'gradingOption', mapping: 'gradingOption'},
							{name: 'processed', mapping: 'processed'}
						]
					//})
                });
                store.load();

                var sm = new Ext.grid.CheckboxSelectionModel({
                    listeners: {
                        'selectionchange': function(selectionModel) {
                            if (selectionModel.hasSelection()) {
                                Ext.getCmp('processBtn').enable();
                                Ext.getCmp('approveBtn').enable();
                                Ext.getCmp('denyBtn').enable();
                            } else {
                            	Ext.getCmp('processBtn').disable();
                                Ext.getCmp('approveBtn').disable();
                                Ext.getCmp('denyBtn').disable();
                            }
                        }
                    }
                });
                var dataPnl = new Ext.grid.GridPanel({
                    id: 'data',
                    renderTo: 'petition-data-pnl',
                    height: 400,
                    loadMask: {
                        msg: 'Please wait...'
                    },
                    store: store,
                    tbar: {
                        items: [{
						    text: 'Actions',
						    iconCls: 'action',
						    menu: new Ext.menu.Menu({
						        id: 'actionMenu',
						        items: [{
							        id: 'processBtn',
						        	iconCls: 'process',
						            text: 'Mark as processed',
						            disabled: true,
						            handler: function() {
							        	var records = sm.getSelections();
							    		var ids = '';
							    		$(records).each(function(){
							    			ids += ' ' + this.get('id');
							    		});
							    		dataPnl.loadMask.show();
							        	$.ajax({
							            	url: CourseRegistration.constructUrl('registrar/process?format=json', topicId),
							            	type: CourseRegistration.requestType('POST'),
							            	headers: {
							                	'Accept': 'application/json'
							                },
							                data: {
							                    ids: ids
							                },
							                dataType: 'json',
							            	success: function(data){
							            		dataPnl.loadMask.hide();
							                	$(data).each(function(){
							                    	var rec = store.getAt(store.find('id', this.id));
							                		rec.set('processed', 'Processed');
							                		store.commitChanges();
							                    });
							                }
							            });
							        }
						        },{
							        id: 'approveBtn',
						        	iconCls: 'approve',
						            text: 'Approve',
						            disabled: true,
						            handler: function() {
								        var records = sm.getSelections();
							    		var ids = '';
							    		$(records).each(function(){
							    			ids += ' ' + this.get('id');
							    		});
							    		dataPnl.loadMask.show();
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
							            		dataPnl.loadMask.hide();
							                	$(data).each(function(){
							                    	var rec = store.getAt(store.find('id', this.id));
							                		var state = this.state.state;
							                    	var stateTerminal = this.state.terminal;
							                    	var stateType = this.state.type;
							                		rec.set('state', state);
							                		rec.set('stateTerminal', stateTerminal);
							                		rec.set('stateType', stateType);
							                		store.commitChanges();
												});
							                }
							            });
							        }
						        },{
							        id: 'denyBtn',
						        	iconCls: 'deny',
						            text: 'Deny',
						            disabled: true,
						            handler: function() {
								        var records = sm.getSelections();
							    		var ids = '';
							    		$(records).each(function(){
							    			ids += ' ' + this.get('id');
							    		});
							    		dataPnl.loadMask.show();
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
							            		dataPnl.loadMask.hide();
							                	$(data).each(function(){
							                    	var rec = store.getAt(store.find('id', this.id));
							                		var state = this.state.state;
							                    	var stateTerminal = this.state.terminal;
							                    	var stateType = this.state.type;
							                		rec.set('state', state);
							                		rec.set('stateTerminal', stateTerminal);
							                		rec.set('stateType', stateType);
							                		store.commitChanges();
												});
							                }
							            });
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
									            window.open(CourseRegistration.constructUrl('registrar/export?format=excel', topicId), '_self');
									        }
								        },/*{
							            	iconCls: 'pdf',
								            text: 'PDF'
								        },*/{
							            	iconCls: 'xml',
								            text: 'XML',
								            handler: function(){
									            window.open(CourseRegistration.constructUrl('registrar/list?format=xml', topicId), '_self');
									        }
								        },{
							            	iconCls: 'json',
								            text: 'JSON',
								            handler: function(){
									            window.open(CourseRegistration.constructUrl('registrar/list?format=json', topicId), '_self');
									        }
								        }]
							        })
						        }]
						    })
						}, '->', 'Petition Status', {
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
                                        delete params["state"];
                                    } else {
                                        params["state"] = record.get('name');
                                    }
                                	store.load({params:params});
                                }
                            }
                        }, ' ', 'Student Home School', {
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
                            value: '1',
                            listeners: {
                                select: function(combo, record, index) {
                                    if (index == 0) {
                                        delete params["homeSchool"];
                                    } else {
                                        params["homeSchool"] = record.get('name');
                                    }
                                    store.load({params:params});
                                }
                            }
                        }, ' ', 'Search', new Ext.ux.form.SearchField({
			                store: store,
			                width:200
			            })]
                    },
                    bbar: new Ext.PagingToolbar({
                        pageSize: 50,
                        store: store,
                        displayInfo: true,
                        plugins: new Ext.ux.SlidingPager()
                    }),
                    /*bbar: {
                        items: [
                        	'->',
                        	'200 Petitions Found'
                        ]
                    },*/
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
                            	header: 'Registrar Status', 
                                dataIndex: 'processed', 
                                renderer: function(value, metadata, record){
                                    return String.format('<div class="icon-text {0}">{1}</div>', (value == 'Processed' ? 'process' : 'pending'), value);
                                }
							},
							{
                            	header: 'Petition Status', 
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
                            {header: 'Student Home School', dataIndex: 'homeSchool'},
                            {header: 'Date Submitted', dataIndex: 'petitionCreated'},
                            {header: 'Grading Option', dataIndex: 'gradingOption'},
                            //{header: 'Host School', dataIndex: 'courseSchool'},
                            {header: 'Course', dataIndex: 'courseShortTitle'},
                            {
                                header: 'Faculty', 
                                dataIndex: 'instructorName', 
                                renderer: function(value, metadata, record){
                                    return String.format('{0}<br/><a href="mailto:{1}">{1}</a><br/>{2}<br/>', 
                                            value, record.get('instructorEmail'), record.get('instructorPhone'));
                                }
                            },
                            {header: 'Term', dataIndex: 'term'},
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