Class {
	#name : #GrParser,
	#superclass : #Object,
	#instVars : [
		'scanner'
	],
	#category : #'Gracious-Core'
}

{ #category : #initialization }
GrParser >> initialize [ 
	scanner := GrTokenizer new
]

{ #category : #parsing }
GrParser >> parse: source [
	| tokenStream |
	tokenStream := scanner scan: source
]
