<script>
	// <![CDATA[
	Ext.namespace('CourseRegistration');
	
	CourseRegistration.constructUrl = function(url, topicId) {
		try {
			return Isites.constructUrl(url) + '&topicId=' + topicId;
		} catch(e) {
			var userId;
			var params = location.href.substring(location.href.indexOf('?') + 1).split('&');
			$(params).each(function(index, param){
				var keyValue = param.split('=');
				var key = keyValue[0];
				if (key == 'userid') {
					userId = keyValue[1];
					return false;
				}
			});
			return '/CourseRegistration/' + url + '&userid=' + userId;
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
    
    CourseRegistration.denyPetitions = function(records, store, topicId) {
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
    
	CourseRegistration.CreatePetitionFormPanel = Ext.extend(Ext.form.FormPanel, {
		border: false,
		labelWidth: 125,
		padding: 10,
		studentCourse: undefined,
		homeSchoolId: undefined,
		programDepartment: undefined,
		degreeYear: undefined,
		
		initComponent: function(){
		 	var schoolOptions = this.studentCourse.get('schoolOptions');
		 	this.items = [];
		 	if (schoolOptions.length > 1) {
		 	    this.items.push({
		 	    	id: 'home-school-combo',
		 	    	xtype: 'combo',
		 	    	width: 225,
		 	        fieldLabel: 'School Affiliation',
		 	        labelSeparator: '',
		 	        name: 'homeSchoolId',
		 	        value: this.homeSchoolId,
		 	        store: new Ext.data.ArrayStore({
				        fields: ['id', 'name'],
				        data : this.studentCourse.get('schoolOptions')
				    }),
		 	        displayField: 'name',
		 	        valueField: 'id',
		 	        mode: 'local',
		 	        triggerAction: 'all',
		 	        forceSelection: true,
		 	        allowBlank: false,
		 	        msgTarget: 'side',
		 	        emptyText: 'Please select...',
		 	        validationEvent: false
		 	    });
			}
			if (this.studentCourse.get('approvalRequired')) {
				this.items.push({
					id: 'program-department-field',
					xtype: 'textfield',
					fieldLabel: 'Program/Department',
			 	    labelSeparator: '',
			 	    name: 'programDepartment',
			 	    value: this.programDepartment,
			 	    allowBlank: false,
			 	    msgTarget: 'side',
			 	    width: 225,
			 	    validationEvent: false
				},{
		 	    	id: 'degree-year-combo',
		 	    	xtype: 'combo',
		 	    	width: 225,
		 	        fieldLabel: 'Degree Year',
		 	        labelSeparator: '',
		 	        name: 'degreeYear',
		 	        value: this.degreeYear,
		 	        store: new Ext.data.ArrayStore({
				        fields: ['id', 'name'],
				        data : [
				        	['2012', '2012'],
				        	['2013', '2013'],
				        	['2014', '2014'],
				        	['2015', '2015'],
				        	['2016', '2016'],
				        ]
				    }),
		 	        displayField: 'name',
		 	        valueField: 'id',
		 	        mode: 'local',
		 	        triggerAction: 'all',
		 	        forceSelection: true,
		 	        allowBlank: false,
		 	        msgTarget: 'side',
		 	        emptyText: 'Please select...',
		 	        validationEvent: false
		 	    });
		 	}
	
			CourseRegistration.CreatePetitionFormPanel.superclass.initComponent.apply(this);
		}
	});
	
	CourseRegistration.CreatePetitionWindow = Ext.extend(Ext.Window, {
		layout: {
            type: 'vbox',
            align: 'stretch'  // Child items are stretched to full width
        },
		title: 'Submit a New Online Cross Registration Petition',
		buttonAlign: 'center',
		height: 300,
		width: 400,
		modal: true,
		bodyStyle: 'background-color: #FFFFFF',
		studentCourse: undefined,
		homeSchoolId: undefined,
		programDepartment: undefined,
		degreeYear: undefined,
		
		initComponent: function(){
			this.items = [];
			if (this.studentCourse.get('approvalRequired')) {
				this.items.push(
					{
						layout: 'fit',
						border: false,
						padding: '2px 10px 0px 10px',
						html: '<p>Please let the faculty member know your:</p>'
					},
					new CourseRegistration.CreatePetitionFormPanel({
						id: 'create-petition-form-panel', 
						studentCourse: this.studentCourse,
						homeSchoolId: this.homeSchoolId,
						programDepartment: this.programDepartment,
						degreeYear: this.degreeYear
					}),
					{
						border: false,
						padding: '0px 10px 0px 10px',
						html: '<p>The faculty member may require a separate application process.</p><p>You will receive a confirmation email, once the faculty member takes action on your petition.</p><p>Please click confirm to finalize your Cross Registration Petition.</p>'
					}
				);
			} else {
				this.items.push(
					new CourseRegistration.CreatePetitionFormPanel({
						id: 'create-petition-form-panel', 
						studentCourse: this.studentCourse,
						homeSchoolId: this.homeSchoolId,
						programDepartment: this.programDepartment,
						degreeYear: this.degreeYear
					}),
					{
						layout: 'fit',
						border: false,
						padding: '2px 10px 0px 10px',
						html: '<p>Please click confirm to finalize your Cross Registration Petition.</p>'
					}
				)
			}
			this.buttons = [{
				text: 'Confirm',
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
						var homeSchoolCombo = Ext.getCmp('home-school-combo');
						var programDepartmentField = Ext.getCmp('program-department-field');
						var degreeYearCombo = Ext.getCmp('degree-year-combo')
						if (homeSchoolCombo) {
	                        options.homeSchoolId = Ext.getCmp('home-school-combo').getValue();
						}
						if (programDepartmentField) {
							options.programDepartment = Ext.getCmp('program-department-field').getValue();
						}
						if (degreeYearCombo) {
							options.degreeYear = Ext.getCmp('degree-year-combo').getValue();
						}
						this.fireEvent('createpetition', options);
					}
				},
				scope: this
			},{
				text: 'Cancel',
				handler: function(){
					this.close();
				},
				scope: this
			}];
			
			CourseRegistration.CreatePetitionWindow.superclass.initComponent.apply(this);
			
			this.addEvents('createpetition');
		}
	});

	CourseRegistration.ApprovePetitionWindow = Ext.extend(Ext.Window, {
		layout: 'fit',
		title: 'Approve Cross Registration Petition',
		buttonAlign: 'center',
		height: 300,
		width: 400,
		modal: true,
		studentCourse: undefined,
		
		initComponent: function(){
			this.items = [{
				layout: 'fit', 
				border: false,
				padding: 10,
				html: 'Approving this cross-registration petition will submit it to the Registrar for processing.'
			}];
			this.buttons = [{
				text: 'Approve',
				handler: function(){
					this.fireEvent('approvepetition');
				},
				scope: this
			},{
				text: 'Cancel',
				handler: function(){
					this.close();
				},
				scope: this
			}];
			
			CourseRegistration.ApprovePetitionWindow.superclass.initComponent.apply(this);
			
			this.addEvents('approvepetition');
		}
	});

	Ext.ux.SlidingPager = Ext.extend(Object, {
	    init : function(pbar){
	        var idx = pbar.items.indexOf(pbar.inputItem);
	        Ext.each(pbar.items.getRange(idx - 2, idx + 2), function(c){
	            c.hide();
	        });
	        var slider = new Ext.Slider({
	            width: 114,
	            minValue: 1,
	            maxValue: 1,
	            plugins: new Ext.slider.Tip({
	                getText : function(thumb) {
	                    return String.format('Page <b>{0}</b> of <b>{1}</b>', thumb.value, thumb.slider.maxValue);
	                }
	            }),
	            listeners: {
	                changecomplete: function(s, v){
	                    pbar.changePage(v);
	                }
	            }
	        });
	        pbar.insert(idx + 1, slider);
	        pbar.on({
	            change: function(pb, data){
	                slider.setMaxValue(data.pages);
	                slider.setValue(data.activePage);
	            }
	        });
	    }
	});
	Ext.ux.PanelResizer = Ext.extend(Ext.util.Observable, {
	    minHeight: 0,
	    maxHeight:10000000,

	    constructor: function(config){
	        Ext.apply(this, config);
	        this.events = {};
	        Ext.ux.PanelResizer.superclass.constructor.call(this, config);
	    },

	    init : function(p){
	        this.panel = p;

	        if(this.panel.elements.indexOf('footer')==-1){
	            p.elements += ',footer';
	        }
	        p.on('render', this.onRender, this);
	    },

	    onRender : function(p){
	        this.handle = p.footer.createChild({cls:'x-panel-resize'});

	        this.tracker = new Ext.dd.DragTracker({
	            onStart: this.onDragStart.createDelegate(this),
	            onDrag: this.onDrag.createDelegate(this),
	            onEnd: this.onDragEnd.createDelegate(this),
	            tolerance: 3,
	            autoStart: 300
	        });
	        this.tracker.initEl(this.handle);
	        p.on('beforedestroy', this.tracker.destroy, this.tracker);
	    },

		// private
	    onDragStart: function(e){
	        this.dragging = true;
	        this.startHeight = this.panel.el.getHeight();
	        this.fireEvent('dragstart', this, e);
	    },

		// private
	    onDrag: function(e){
	        this.panel.setHeight((this.startHeight-this.tracker.getOffset()[1]).constrain(this.minHeight, this.maxHeight));
	        this.fireEvent('drag', this, e);
	    },

		// private
	    onDragEnd: function(e){
	        this.dragging = false;
	        this.fireEvent('dragend', this, e);
	    }
	});
	if (!Array.prototype.map) {
	    Array.prototype.map = function(fun){
	        var len = this.length;
	        if (typeof fun != 'function') {
	            throw new TypeError();
	        }
	        var res = new Array(len);
	        var thisp = arguments[1];
	        for (var i = 0; i < len; i++) {
	            if (i in this) {
	                res[i] = fun.call(thisp, this[i], i, this);
	            }
	        }
	        return res;
	    };
	}

	Ext.ns('Ext.ux.data');

	/**
	 * @class Ext.ux.data.PagingMemoryProxy
	 * @extends Ext.data.MemoryProxy
	 * <p>Paging Memory Proxy, allows to use paging grid with in memory dataset</p>
	 */
	Ext.ux.data.PagingMemoryProxy = Ext.extend(Ext.data.MemoryProxy, {
	    constructor : function(data){
	        Ext.ux.data.PagingMemoryProxy.superclass.constructor.call(this);
	        this.data = data;
	    },
	    doRequest : function(action, rs, params, reader, callback, scope, options){
	        params = params ||
	        {};
	        var result;
	        try {
	            result = reader.readRecords(this.data);
	        } 
	        catch (e) {
	            this.fireEvent('loadexception', this, options, null, e);
	            callback.call(scope, null, options, false);
	            return;
	        }
	        
	        // filtering
	        if (params.filter !== undefined) {
	            result.records = result.records.filter(function(el){
	                if (typeof(el) == 'object') {
	                    var att = params.filterCol || 0;
	                    return String(el.data[att]).match(params.filter) ? true : false;
	                }
	                else {
	                    return String(el).match(params.filter) ? true : false;
	                }
	            });
	            result.totalRecords = result.records.length;
	        }
	        
	        // sorting
	        if (params.sort !== undefined) {
	            // use integer as params.sort to specify column, since arrays are not named
	            // params.sort=0; would also match a array without columns
	            var dir = String(params.dir).toUpperCase() == 'DESC' ? -1 : 1;
	            var fn = function(v1, v2){
	                return v1 > v2 ? 1 : (v1 < v2 ? -1 : 0);
	            };
	            result.records.sort(function(a, b){
	                var v = 0;
	                if (typeof(a) == 'object') {
	                    v = fn(a.data[params.sort], b.data[params.sort]) * dir;
	                }
	                else {
	                    v = fn(a, b) * dir;
	                }
	                if (v == 0) {
	                    v = (a.index < b.index ? -1 : 1);
	                }
	                return v;
	            });
	        }
	        // paging (use undefined cause start can also be 0 (thus false))
	        if (params.start !== undefined && params.limit !== undefined) {
	            result.records = result.records.slice(params.start, params.start + params.limit);
	        }
	        callback.call(scope, result, options, true);
	    }
	});

	 Ext.ns('Ext.ux.form');

	 Ext.ux.form.SearchField = Ext.extend(Ext.form.TwinTriggerField, {
	     initComponent : function(){
	         Ext.ux.form.SearchField.superclass.initComponent.call(this);
	         this.on('specialkey', function(f, e){
	             if(e.getKey() == e.ENTER){
	                 this.onTrigger2Click();
	             }
	         }, this);
	     },

	     validationEvent:false,
	     validateOnBlur:false,
	     trigger1Class:'x-form-clear-trigger',
	     trigger2Class:'x-form-search-trigger',
	     hideTrigger1:true,
	     width:180,
	     hasSearch : false,
	     paramName : 'query',

	     onTrigger1Click : function(){
	         if(this.hasSearch){
	             this.el.dom.value = '';
	             var o = {start: 0};
	             this.store.baseParams = this.store.baseParams || {};
	             this.store.baseParams[this.paramName] = '';
	             this.store.reload({params:o});
	             this.triggers[0].hide();
	             this.hasSearch = false;
	         }
	     },

	     onTrigger2Click : function(){
	         var v = this.getRawValue();
	         if(v.length < 1){
	             this.onTrigger1Click();
	             return;
	         }
	         var o = {start: 0};
	         this.store.baseParams = this.store.baseParams || {};
	         this.store.baseParams[this.paramName] = v;
	         this.store.reload({params:o});
	         this.hasSearch = true;
	         this.triggers[0].show();
	     }
	 });
	// ]]>
</script>