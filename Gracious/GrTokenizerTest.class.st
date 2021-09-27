Class {
	#name : #GrTokenizerTest,
	#superclass : #TestCase,
	#instVars : [
		'tokenizer'
	],
	#classInstVars : [
		'tokens'
	],
	#category : #'Gracious-Tests'
}

{ #category : #running }
GrTokenizerTest >> setUp [
	super setUp.
	
	tokenizer := GrTokenizer new.
]

{ #category : #tests }
GrTokenizerTest >> testScan [
	| tokens |
	tokens := (tokenizer scan: 'Foo Bar, do bar:') contents.
	self assert: tokens first equals: #('Identifier or Unary Selector' 'Foo Bar').
	self assert: tokens second equals: #('Message Send Operator' ',').
	self assert: tokens last equals: #('Keyword Selector' 'do bar:').

	tokens := (tokenizer scan: 'Foo Bar, do bar: asdf') contents.
	self assert: tokens last equals: #('Identifier or Unary Selector' 'asdf').
	self assert: tokens size equals: 4.
	
	tokens := (tokenizer scan: '42.42') contents.
	self assert: tokens first equals: #('Floating Point Number' '42.42').
	self assert: tokens size equals: 1.

	tokens := (tokenizer scan: '-42.0') contents.
	self assert: tokens first equals: #('Floating Point Number' '-42.0').
	self assert: tokens size equals: 1.

	tokens := (tokenizer scan: '.0') contents.
	self assert: tokens first equals: #('Floating Point Number' '.0').
	self assert: tokens size equals: 1.

	tokens := (tokenizer scan: '-42') contents.
	self assert: tokens first equals: #('Integer Number' '-42').

	tokens := (tokenizer scan: '42 42 42. 42.42') contents.
	self assert: tokens size equals: 5.
	self assert: ((tokens copyFrom: 1 to: 3) allSatisfy: [ :item | item first = 'Integer Number']).
	self assert: tokens fourth equals: #('Expression Terminator' '.').
	self assert: tokens last equals: #('Floating Point Number' '42.42').
	self assert: tokens size equals: 5.
	
	self should: [(tokenizer scan: '$') contents] raise: GrTokenError 

]
