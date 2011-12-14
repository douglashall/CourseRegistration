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
				var topicId = '${params.topicId}';
				var direction = '${params.direction}';
            	var dataUrl = 'registrar/' + direction;
				var store = new Ext.data.JsonStore({
					url: CourseRegistration.constructUrl(dataUrl + '?format=json', topicId),
					root: 'root',
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
					],
					listeners: {
						'load': function(){
							$('.petition-count').html('Displaying ' + this.getCount() + ' petitions');
						}
					}
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
                var schoolLabel = direction == 'incoming' ? 'Student Home School' : 'Host School';
                var schoolParam = direction == 'incoming' ? 'homeSchool' : 'hostSchool';
                var dataPnl = new Ext.grid.GridPanel({
                    id: 'data',
                    renderTo: 'petition-data-pnl',
                    autoHeight: true,
                    width: 960,
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
						        items: [
						        <g:if test="${params.direction == 'incoming'}">
							        {
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
								            	url: CourseRegistration.constructUrl('registrar/approve?format=json', topicId),
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
								            	url: CourseRegistration.constructUrl('registrar/deny?format=json', topicId),
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
							        },
							        </g:if>
							        {
							        	iconCls: 'export',
							            text: 'Export All',
							            menu: new Ext.menu.Menu({
								            id: 'exportMenu',
								            items: [{
								            	iconCls: 'excel',
									            text: 'Excel',
									            handler: function(){
										            window.open(CourseRegistration.constructUrl(dataUrl + '?format=xls', topicId), '_self');
										        }
									        },/*{
								            	iconCls: 'pdf',
									            text: 'PDF'
									        },*/{
								            	iconCls: 'xml',
									            text: 'XML',
									            handler: function(){
										            window.open(CourseRegistration.constructUrl(dataUrl + '?format=xml', topicId), '_self');
										        }
									        },{
								            	iconCls: 'json',
									            text: 'JSON',
									            handler: function(){
										            window.open(CourseRegistration.constructUrl(dataUrl + '?format=json', topicId), '_self');
										        }
									        }]
								        })
							        }
						        ]
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
                            width: 150,
                            value: '1',
                            listeners: {
                                select: function(combo, record, index) {
                                	if (index == 0) {
                                        delete store.baseParams["status"];
                                    } else {
                                        store.baseParams["status"] = record.get('name');
                                    }
                                	store.load();
                                }
                            }
                        }, ' ', schoolLabel, {
                            xtype: 'combo',
                            store: new Ext.data.ArrayStore({
                                autoDestroy: true,
                                fields: ['id', 'name'],
                                data : [
									['all', 'All'],
                                    ['fas', 'Faculty of Arts and Sciences'],
                                    ['hbsdoc', 'Harvard Business School - Doctoral Program'],
                                    ['hbsmba', 'Harvard Business School - MBA Program'],
                                    ['hds', 'Harvard Divinity School'],
                                    ['ext', 'Harvard Extension School'],
                                    ['gsd', 'Harvard Graduate School of Design'],
                                    ['gse', 'Harvard Graduate School of Education'],
                                    ['hks', 'Harvard Kennedy School'],
                                    ['hls', 'Harvard Law School'],
                                    ['hms', 'Harvard Medical School'],
                                    ['hsdm', 'Harvard School of Dental Medicine'],
                                    ['hsph', 'Harvard School of Public Health'],
                                    ['sum', 'Harvard Summer School']
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
                            value: 'all',
                            listeners: {
                                select: function(combo, record, index) {
                                    if (index == 0) {
                                        delete store.baseParams[schoolParam];
                                    } else {
                                        store.baseParams[schoolParam] = record.get('id');
                                    }
                                    store.load();
                                }
                            }
                        }, ' ', 'Search', new Ext.ux.form.SearchField({
			                store: store,
			                width:175
			            })]
                    },
                    colModel: new Ext.grid.ColumnModel({
                        defaults: {
                            sortable: true
                        },
                        columns: [
                        	<g:if test="${params.direction == 'incoming'}">
                            sm,
							{
                            	header: 'Registrar Status', 
                                dataIndex: 'processed', 
                                renderer: function(value, metadata, record){
                                    return String.format('<div class="icon-text {0}">{1}</div>', (value == 'Processed' ? 'process' : 'pending'), value);
                                }
							},
							</g:if>
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
                            {header: 'Date Submitted', dataIndex: 'petitionCreated'},
                            {header: 'Grading Option', dataIndex: 'gradingOption'},
                            {header: schoolLabel, dataIndex: schoolParam},
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
                        forceFit: true,
                        scrollOffset: 0
                    },
                    sm: sm,
                    frame: true
                });
        	});
			// ]]>
        </script>
    </head>
    <body>
    	<div class="data-pnl-header">
	    	<h3 class="school-header">${school}</h3>
	    	<h3 class="petition-count"></h3>
	    </div>
    	<div id="petition-data-pnl"></div>
    </body>
</html>