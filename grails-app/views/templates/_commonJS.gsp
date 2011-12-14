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