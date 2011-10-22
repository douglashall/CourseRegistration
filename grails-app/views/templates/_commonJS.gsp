<script>
	// <![CDATA[
	Ext.namespace('CourseRegistration');
	
	CourseRegistration.constructUrl = function(url, topicId, userId) {
		try {
			return Isites.constructUrl(url) + '&topicId=' + topicId;
		} catch(e) {
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
	// ]]>
</script>