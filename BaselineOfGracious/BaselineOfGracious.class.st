Class {
	#name : #BaselineOfGracious,
	#superclass : #BaselineOf,
	#category : #BaselineOfGracious
}

{ #category : #baselines }
BaselineOfGracious >> baseline: spec [ 
	<baseline>
	spec
		for: #common
		do: [ 
			self smaCC: spec.
			
			spec package: 'Gracious' with: [ spec requires: #('SmaCC') ].
			]
]

{ #category : #dependencies }
BaselineOfGracious >> smaCC: spec [
	spec baseline: 'SmaCC'
		   with: [ spec repository: 'github://j-brant/SmaCC/src' ]
]
