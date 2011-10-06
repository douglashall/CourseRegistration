<script>
	// <![CDATA[
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
	// ]]>
</script>