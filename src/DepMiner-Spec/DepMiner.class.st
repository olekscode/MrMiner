Class {
	#name : #DepMiner,
	#superclass : #SpPresenter,
	#instVars : [
		'settings',
		'projectHistory',
		'recommendations',
		'controller',
		'ownerNameInput',
		'projectNameInput',
		'projectLoadedLabel',
		'loadProjectButton',
		'oldVersionInput',
		'newVersionInput',
		'loadChangesButton',
		'minCountSelect',
		'minConfidenceSelect',
		'mineRulesButton',
		'oldVersionNotebook',
		'oldVersionAllMethodsTree',
		'oldVersionDeletedMethodsTree',
		'oldVersionDeprecatedMethodsTree',
		'newVersionNotebook',
		'newVersionAllMethodsTree',
		'newVersionAddedMethodsTree',
		'newVersionDeprecatedMethodsTree',
		'recommendationsNotebook',
		'staleDeprecationsTree',
		'proposedDeprecationsTree',
		'missingRulesTree',
		'replacementsList',
		'generatedCode',
		'generateButton'
	],
	#category : #'DepMiner-Spec-Views'
}

{ #category : #specs }
DepMiner class >> defaultSpec [
	| buttonWidth inputWidth spacing |
	
	buttonWidth := 95.
	inputWidth := 150.
	spacing := 4.
	
	^ SpBoxLayout newHorizontal
		spacing: spacing;
		add: (SpBoxLayout newVertical
			spacing: spacing;
			add: (SpBoxLayout newVertical
				add: (SpBoxLayout newHorizontal
					add: 'Owner name';
					add: #ownerNameInput width: inputWidth;
					yourself) height: self inputTextHeight;
				add: (SpBoxLayout newHorizontal
					add: 'Project name';
					add: #projectNameInput width: inputWidth;
					yourself) height: self inputTextHeight;
				add: (SpBoxLayout newHorizontal
					add: #projectLoadedLabel;
					add: #loadProjectButton width: buttonWidth;
					yourself) height: self buttonHeight;
				yourself);
			add: (SpBoxLayout newVertical
				add: (SpBoxLayout newHorizontal
					add: 'Old version';
					add: #oldVersionInput width: inputWidth;
					yourself) height: self inputTextHeight;
				add: (SpBoxLayout newHorizontal
					add: 'New version';
					add: #newVersionInput width: inputWidth;
					yourself) height: self inputTextHeight;
				add: (SpBoxLayout newHorizontal
					add: '';
					add: #loadChangesButton width: buttonWidth;
					yourself) height: self buttonHeight;
				yourself);
			add: (SpBoxLayout newVertical
				add: (SpBoxLayout newHorizontal
					add: 'Min count';
					add: #minCountSelect width: inputWidth;
					yourself) height: self inputTextHeight;
				add: (SpBoxLayout newHorizontal
					add: 'Min confidence';
					add: #minConfidenceSelect width: inputWidth;
					yourself) height: self inputTextHeight;
				add: (SpBoxLayout newHorizontal
					add: '';
					add: #mineRulesButton width: buttonWidth;
					yourself) height: self buttonHeight;
				yourself);
			add: '';
			yourself) width: 250;
		add: (SpPanedLayout newVertical
			add: (SpBoxLayout newHorizontal
				spacing: spacing;
				add: (SpBoxLayout newVertical
					add: 'Methods in the old version' height: self labelHeight;
					add: #oldVersionNotebook;
					yourself);
				add: (SpBoxLayout newVertical
					add: 'Methods in the new version' height: self labelHeight;
					add: #newVersionNotebook;
					yourself);
				add: (SpBoxLayout newVertical
					add: 'Recommendations' height: self labelHeight;
					add: #recommendationsNotebook;
					yourself);
				yourself);
			add: (SpBoxLayout newVertical
				add: (SpBoxLayout newHorizontal
					spacing: spacing;
					add: (SpBoxLayout newVertical
						add: 'Replacements' height: self labelHeight;
						add: #replacementsList;
						yourself) width: 250;
					add: (SpBoxLayout newVertical
						add: 'Generated code' height: self labelHeight;
						add: #generatedCode;
						yourself);
					yourself);
				add: (SpBoxLayout newHorizontal
					add: '';
					add: #generateButton width: self buttonWidth;
					yourself) height: self buttonHeight;
				yourself);
			yourself);
		yourself.
]

{ #category : #accessing }
DepMiner class >> defaultTitle [
	^ 'DepMiner'
]

{ #category : #'world menu' }
DepMiner class >> menuCommandOn: aBuilder [
	<worldMenu>
	(aBuilder item: #DepMiner)
		parent: #Tools;
		action: [ self open ];
		order: 15;
		help: 'A tool for mining transformation rules for deprecations based on the commit history of the project';
		icon: (self iconNamed: #databaseAdd).
]

{ #category : #examples }
DepMiner class >> open [
	<example>
	self new openWithSpec
]

{ #category : #accessing }
DepMiner class >> preferredExtent [
	^ 1300@700
]

{ #category : #'private builder' }
DepMiner >> buildToolbar [
	^ self toolbarActions 
		asToolbarPresenterWith: [ :presenter | 
			presenter 
				displayMode: SpToolbarDisplayMode modeIconAndLabel;
				addStyle: 'stToolbar' ]
]

{ #category : #initialization }
DepMiner >> connectPresenters [
	super connectPresenters.
	
	loadProjectButton action: [ self onLoadProjectClicked ].
	
	oldVersionInput action: [
		(DepCommitSelector on: controller candidateCommitsForOldVersion)
			callback: [ :commit | self onOldVersionSelected: commit ];
			openWithSpec ].
		
	newVersionInput action: [
		(DepCommitSelector on: controller candidateCommitsForNewVersion)
			callback: [ :commit | self onNewVersionSelected: commit ];
			openWithSpec ].
		
	loadChangesButton action: [ self onLoadChangesClicked ].
	mineRulesButton action: [ self onMineRulesClicked ].
	
	{
		oldVersionAllMethodsTree .
		oldVersionDeletedMethodsTree .
		oldVersionDeprecatedMethodsTree .
		newVersionAllMethodsTree .
		newVersionAddedMethodsTree .
		newVersionDeprecatedMethodsTree
	} do: [ :tree | tree actionOnMethodClicked: [ :method | self onMethodClicked: method ] ].
	
	proposedDeprecationsTree actionOnMethodClicked: [ :method | self onProposedDeprecationClicked: method ].
	
]

{ #category : #initialization }
DepMiner >> initialize [
	super initialize.
	
	settings := DepSettings new.
	projectHistory := DepProjectHistory new.
	recommendations := DepRecommendations new.
	
	controller := DepMinerController new
		settings: settings;
		projectHistory: projectHistory;
		recommendations: recommendations;
		yourself.
]

{ #category : #initialization }
DepMiner >> initializePresenters [
	super initializePresenters.
	
	ownerNameInput := self newTextInput.
	projectNameInput := self newTextInput.
	
	projectLoadedLabel := self newLabel.
	
	loadProjectButton := self newButton
		label: 'Load project';
		yourself.
		
	oldVersionInput := DepCommitInput new.
	newVersionInput := DepCommitInput new.
	
	loadChangesButton := self newButton
		label: 'Load changes';
		yourself.
		
	minCountSelect := self newNumberInput.
	minConfidenceSelect := self newNumberInput.
	
	mineRulesButton := self newButton
		label: 'Mine rules';
		yourself.
		
	oldVersionAllMethodsTree := self instantiate: DepMethodsTree.	
	oldVersionDeletedMethodsTree := self instantiate: DepMethodsTree.
	oldVersionDeprecatedMethodsTree := self instantiate: DepMethodsTree.
	
	oldVersionNotebook := self newNotebook
		addPage: (self newNotebookPage
			title: 'All';
			presenterProvider: [ oldVersionAllMethodsTree ];
			yourself);
		addPage: (self newNotebookPage
			title: 'Deleted';
			presenterProvider: [ oldVersionDeletedMethodsTree ];
			yourself);
		addPage: (self newNotebookPage
			title: 'Deprecated';
			presenterProvider: [ oldVersionDeprecatedMethodsTree ];
			yourself);
		yourself.
		
	newVersionAllMethodsTree := self instantiate: DepMethodsTree.
	newVersionAddedMethodsTree := self instantiate: DepMethodsTree.
	newVersionDeprecatedMethodsTree := self instantiate: DepMethodsTree.
	
	newVersionNotebook := self newNotebook
		addPage: (self newNotebookPage
			title: 'All';
			presenterProvider: [ newVersionAllMethodsTree ];
			yourself);
		addPage: (self newNotebookPage
			title: 'Added';
			presenterProvider: [ newVersionAddedMethodsTree ];
			yourself);
		addPage: (self newNotebookPage
			title: 'Deprecated';
			presenterProvider: [ newVersionDeprecatedMethodsTree ];
			yourself);
		yourself.
	
	proposedDeprecationsTree := self instantiate: DepMethodsTree.
	missingRulesTree := self instantiate: DepMethodsTree.
	staleDeprecationsTree := self instantiate: DepMethodsTree.
	
	recommendationsNotebook := self newNotebook
		addPage: (self newNotebookPage
			title: 'Proposed Deprecations';
			presenterProvider: [ proposedDeprecationsTree ];
			yourself);
		addPage: (self newNotebookPage
			title: 'Missing Rules';
			presenterProvider: [ missingRulesTree ];
			yourself);
		addPage: (self newNotebookPage
			title: 'Stale Deprecations';
			presenterProvider: [ staleDeprecationsTree ];
			yourself);
		yourself.
	
	replacementsList := self newList.
	
	generatedCode := self newCode
		withoutLineNumbers;
		beNotEditable;
		yourself.
	
	generateButton := self newButton
		label: 'Generate';
		yourself.
]

{ #category : #initialization }
DepMiner >> initializeWindow: aWindowPresenter [
	super initializeWindow: aWindowPresenter.
	
	aWindowPresenter
		title: self class defaultTitle;
		initialExtent: self class preferredExtent;
		toolbar: self buildToolbar.
]

{ #category : #'as yet unclassified' }
DepMiner >> onLoadChangesClicked [
	| oldVersionString newVersionString oldCommit newCommit |
	
	oldVersionString := oldVersionInput text.
	newVersionString := newVersionInput text.

	oldVersionString ifEmpty: [ 
		self inform: 'Please select the old version'.
		^ self ].

	newVersionString ifEmpty: [ 
		self inform: 'Please select the new version'.
		^ self ].
	
	oldCommit := projectHistory
		commitThatMatches: oldVersionString
		ifNone: [
			self inform: 'Old version with this commit SHA or tag was not found'.
			^ self ].
		
	newCommit := projectHistory
		commitThatMatches: newVersionString
		ifNone: [
			self inform: 'New version with this commit SHA or tag was not found'.
			^ self ].
		
	settings oldCommitSha: oldCommit sha.
	settings newCommitSha: newCommit sha.
				
	controller loadChanges.
	
	self showOldVersion.
	self showNewVersion.
]

{ #category : #'as yet unclassified' }
DepMiner >> onLoadProjectClicked [
	settings ownerName: ownerNameInput text.
	settings projectName: projectNameInput text.
	
	controller loadProject.
]

{ #category : #events }
DepMiner >> onMethodClicked: aMethod [
	generatedCode text: aMethod sourceCode
]

{ #category : #'as yet unclassified' }
DepMiner >> onMineRulesClicked [
	| minCount minConfidence |
	
	minCount := minCountSelect number.
	minConfidence := minConfidenceSelect number.
	
	controller mineRulesWithMinCount: minCount minConfidence: minConfidence.
	self showRecommendations.
]

{ #category : #'as yet unclassified' }
DepMiner >> onNewVersionSelected: aCommit [
	newVersionInput text: aCommit shortSha.
	settings newCommitSha: aCommit sha.
]

{ #category : #'as yet unclassified' }
DepMiner >> onOldVersionSelected: aCommit [
	oldVersionInput text: aCommit shortSha.
	settings oldCommitSha: aCommit sha.
]

{ #category : #'as yet unclassified' }
DepMiner >> onProposedDeprecationClicked: aMethod [
	| applicableRules |
	
	applicableRules := recommendations rules select: [ :rule |
		rule key size = 1 and: [ rule key anyOne = aMethod selector ] ].
	
	replacementsList
		items: applicableRules;
		display: [ :rule | ', ' join: rule value ].
		
	generatedCode text: aMethod sourceCode.
]

{ #category : #'as yet unclassified' }
DepMiner >> showMissingRules [
	proposedDeprecationsTree methods: (projectHistory sortedMethods select: [ :method | method isInNewVersion and: [ method isDeprecated and: [ method hasTransformationRule not ] ] ]).
]

{ #category : #'as yet unclassified' }
DepMiner >> showNewVersion [
	self showNewVersionAllMethods.
	self showNewVersionAddedMethods.
	self showNewVersionDeprecatedMethods.
]

{ #category : #'as yet unclassified' }
DepMiner >> showNewVersionAddedMethods [
	newVersionAddedMethodsTree methods:
		(projectHistory sortedMethods select: [ :method | method wasAdded ]).
]

{ #category : #'as yet unclassified' }
DepMiner >> showNewVersionAllMethods [
	newVersionAllMethodsTree methods:
		(projectHistory sortedMethods select: [ :method | method isInNewVersion ])
]

{ #category : #'as yet unclassified' }
DepMiner >> showNewVersionDeprecatedMethods [
	newVersionDeprecatedMethodsTree methods:
		(projectHistory sortedMethods select: [ :method | method isInNewVersion and: [ method isDeprecated ] ])
]

{ #category : #'as yet unclassified' }
DepMiner >> showOldVersion [
	self showOldVersionAllMethods.
	self showOldVersionDeletedMethods.
	self showOldVersionDeprecatedMethods.
]

{ #category : #'as yet unclassified' }
DepMiner >> showOldVersionAllMethods [
	oldVersionAllMethodsTree methods:
		(projectHistory sortedMethods select: [ :method | method wasInOldVersion ])
]

{ #category : #'as yet unclassified' }
DepMiner >> showOldVersionDeletedMethods [
	oldVersionDeletedMethodsTree methods:
		(projectHistory sortedMethods select: [ :method | method wasDeleted ])
]

{ #category : #'as yet unclassified' }
DepMiner >> showOldVersionDeprecatedMethods [
	oldVersionDeprecatedMethodsTree methods:
		(projectHistory sortedMethods select: [ :method | method wasInOldVersion and: [ method wasDeprecatedInOldVersion ] ])
]

{ #category : #'as yet unclassified' }
DepMiner >> showProposedDeprecations [
	proposedDeprecationsTree methods:
		(projectHistory sortedMethods select: [ :method |
			method wasDeleted and: [ method isDeprecated not and: [ recommendations rules anySatisfy: [ :rule | rule key includes: method selector ] ] ] ]).
]

{ #category : #'as yet unclassified' }
DepMiner >> showRecommendations [
	self showStaleDeprecations.
	self showProposedDeprecations.
	self showMissingRules.
]

{ #category : #'as yet unclassified' }
DepMiner >> showStaleDeprecations [
	staleDeprecationsTree methods:
		(projectHistory sortedMethods select: [ :method | method isDeprecated and: [ method wasUnchanged ] ])
]

{ #category : #building }
DepMiner >> toolbarActions [
	^ CmCommandGroup forSpec
		register: (CmCommandGroup forSpec
			register: (DepOpenCommand forSpecContext: self);
			register: (DepSaveCommand forSpecContext: self);
			yourself);
		yourself
]