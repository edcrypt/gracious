Extension { #name : #String }

{ #category : #'*Gracious' }
String >> matchGraciousToken: source [

	| rx |
	rx := self asRegex.
	(rx matchesPrefix: source) ifTrue: [ 
		^ (rx subexpressions: 1) at: 1
	].
	^ nil
]
