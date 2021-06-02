Class {
	#name : #GraciousFormatter,
	#superclass : #RBSimpleFormatter,
	#category : #Gracious
}

{ #category : #accessing }
GraciousFormatter >> formatMethodPatternFor: aMethodNode [
	^ super formatMethodPatternFor: aMethodNode
]

{ #category : #accessing }
GraciousFormatter >> formatTemporariesFor: aSequenceNode [
	^ super formatTemporariesFor: aSequenceNode
]
