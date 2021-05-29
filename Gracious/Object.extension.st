Extension { #name : #Object }

{ #category : #'*Gracious' }
Object >> graciousPerform: aGraciousMessage [
	^ self perform: aGraciousMessage asCamelCase uncapitalized asSymbol
]
