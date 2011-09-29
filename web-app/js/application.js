Ext.namespace('CourseRegistration');

CourseRegistration.schoolOptions = new Ext.data.ArrayStore({
	fields: ['id', 'title'],
	data: [
		['ext', 'Harvard Extension School'],
		['hds', 'Harvard Divinity School'],
		['fas', 'Faculty of Arts and Sciences'],
		['colgsas', 'Graduate School of Arts and Sciences'],
		['gsd', 'Graduate School of Design'],
		['gse', 'Graduate School of Education'],
		['hbs', 'Harvard Business School'],
		['hls', 'Harvard Law School'],
		['hms', 'Harvard Medical School'],
		['hsdm', 'Harvard School of Dental Medicine'],
		['hsph', 'Harvard School of Public Health'],
		['sum', 'Harvard Summer School'],
		['hks', 'Harvard Kennedy School']
	]
});

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
		this.items = [{
	    	id: 'level-option-combo',
	    	xtype: 'combo',
	        fieldLabel: 'Level',
	        name: 'levelOption',
	        store: new Ext.data.JsonStore({
	            root: 'options',
	            idProperty: 'id',
	            fields: ['id', 'name'],
	            data: {options: this.studentCourse.get('levelOptions')[0]}
	        }),
	        displayField: 'name',
	        valueField: 'id',
	        mode: 'local',
	        forceSelection: true,
	        allowBlank: false,
	        msgTarget: 'side',
	        emptyText: 'Please select...'
	    },{
			id: 'grading-option-combo',
			xtype: 'combo',
	        fieldLabel: 'Grading Option',
	        name: 'gradingOption',
	        store: new Ext.data.JsonStore({
	            root: 'options',
	            idProperty: 'id',
	            fields: ['id', 'name'],
	            data: {options: this.studentCourse.get('gradingOptions')[0]}
	        }),
	        displayField: 'name',
	        valueField: 'id',
	        mode: 'local',
	        forceSelection: true,
	        allowBlank: false,
	        msgTarget: 'side',
	        emptyText: 'Please select...'
	    }/*,{
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
	    }*/];

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
			html: String.format('<p>Submitting this form will begin the cross-registration process for {0}. {1} will receive a notification and either approve or deny your request. The faculty member may require a separate application process.</p>', this.studentCourse.get('courseNumber'), this.studentCourse.get('courseInstructor'))
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
					var p = {
                        courseId: this.studentCourse.get('courseId'),
                        levelOption: Ext.getCmp('level-option-combo').getValue(),
                        gradingOption: Ext.getCmp('grading-option-combo').getValue(),
                        homeSchoolId: Ext.getCmp('home-school-combo').getValue()
                    };
					this.fireEvent('createpetition', p);
					this.close();
				}
			},
			scope: this
		},{
			text: 'Cancel',
			handler: function(){
				this.ownerCt.ownerCt.close();
			}
		}];
		
		CourseRegistration.CreatePetitionWindow.superclass.initComponent.apply(this);
		
		this.addEvents('createpetition');
	}
});