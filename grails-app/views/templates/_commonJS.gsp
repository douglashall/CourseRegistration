<script>
	// <![CDATA[
	Ext.namespace('CourseRegistration');
	
	CourseRegistration.constructUrl = function(url, topicId) {
		try {
			return Isites.constructUrlWithParams(url, {topicId: topicId});
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
			var delimiter = url.indexOf('?') >= 0 ? '&' : '?';
			return '/CourseRegistration/' + url + delimiter + 'userid=' + userId;
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
    
	CourseRegistration.ApprovePetitionWindow = Ext.extend(Ext.Window, {
		layout: 'fit',
		title: 'Approve Cross Registration Petition',
		buttonAlign: 'center',
		height: 300,
		width: 400,
		modal: true,
		content: '',
		
		initComponent: function(){
			this.items = [{
				layout: 'fit', 
				border: false,
				padding: 10,
				html: this.content
			}];
			this.buttons = [{
				text: 'Confirm',
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

	CourseRegistration.DenyPetitionWindow = Ext.extend(Ext.Window, {
		layout: 'fit',
		title: 'Deny Cross Registration Petition',
		buttonAlign: 'center',
		height: 300,
		width: 400,
		modal: true,
		content: '',
		
		initComponent: function(){
			this.items = [{
				layout: 'fit', 
				border: false,
				padding: 10,
				html: this.content
			}];
			this.buttons = [{
				text: 'Confirm',
				handler: function(){
					this.fireEvent('denypetition');
				},
				scope: this
			},{
				text: 'Cancel',
				handler: function(){
					this.close();
				},
				scope: this
			}];
			
			CourseRegistration.DenyPetitionWindow.superclass.initComponent.apply(this);
			
			this.addEvents('denypetition');
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