Class {
	#name : #DepRecommendationPresenter,
	#superclass : #SpPresenter,
	#instVars : [
		'recommendation',
		'replacementImplementations',
		'replacementsList',
		'generateButton'
	],
	#category : #'DepMiner-Spec-Views'
}

{ #category : #specs }
DepRecommendationPresenter class >> codeLayout [
	self subclassResponsibility
]

{ #category : #specs }
DepRecommendationPresenter class >> defaultSpec [
	^ SpBoxLayout newVertical
		add: (SpBoxLayout newHorizontal
			spacing: 2;
			add: (SpBoxLayout newVertical
				add: 'Replacements' height: self labelHeight;
				add: #replacementsList;
				yourself) width: 250;
			add: self codeLayout;
			yourself);
		add: (SpBoxLayout newHorizontal
			add: '';
			add: #generateButton width: self buttonWidth;
			yourself) height: self buttonHeight;
		yourself.
]

{ #category : #initialization }
DepRecommendationPresenter >> connectPresenters [
	super connectPresenters.
	
	replacementsList whenSelectionChangedDo: [ :selectionMode |
		self onReplacementSelectionChanged ].
]

{ #category : #initialization }
DepRecommendationPresenter >> initializeCode [
	self subclassResponsibility
]

{ #category : #initialization }
DepRecommendationPresenter >> initializePresenters [
	super initializePresenters.
	
	replacementsList := self newList.
		
	replacementsList display: [ :rule |
		', ' join: (rule addedMethodCalls collect: [ :call | call selector ]) ].
	
	replacementsList contextMenu: [
		SpMenuPresenter new 
			addGroup: [ :group | group 
				addItem: [ :item | item
					name: 'Inspect';
					action: [ replacementsList selectedItem inspect ] ];
				addItem: [ :item | item
					name: 'Explain why';
					action: [
						(DepMethodChangeBrowser on: replacementsList selectedItem)
							openWithSpec ] ] ] ].
	
	self initializeCode.
	
	generateButton := self newButton
		label: 'Generate';
		yourself.
		
	self showReplacements.
]

{ #category : #'as yet unclassified' }
DepRecommendationPresenter >> onReplacementSelectionChanged [
	self subclassResponsibility
]

{ #category : #'accessing model' }
DepRecommendationPresenter >> setModelBeforeInitialization: aRecommendation [
	recommendation := aRecommendation
]

{ #category : #'as yet unclassified' }
DepRecommendationPresenter >> showReplacements [
	self subclassResponsibility
]