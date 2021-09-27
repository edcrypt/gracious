"
I provide a lexical scanner for Gracious Language source code.

I know the valid token tree, and use it to scan source code, validade and return a token stream if successful.

- scan: source
"
Class {
	#name : #GrTokenizer,
	#superclass : #Object,
	#instVars : [
		'tokens'
	],
	#category : #'Gracious-Core'
}

{ #category : #initialization }
GrTokenizer >> initialize [

	| NAME KEYWORD FLOAT INT STR UNARY BLOCK_ARG |
	NAME := '[_a-zA-Z]([_a-zA-Z0-9]| \b)*[_a-zA-Z0-9]'.
	KEYWORD := NAME , '\:'.
	UNARY := NAME.
	BLOCK_ARG := '\:(' , NAME , ')'.
	FLOAT := '^[+-]?([0-9]+([.][0-9]+)|[.][0-9]+)'.
	INT := '^[+-]?[0-9]+'.
	STR := ''.

	tokens := {
		'Keyword Selector' -> KEYWORD.
		'Identifier or Unary Selector' -> NAME.
		'Message Send Operator' -> ','.
		'Floating Point Number' -> FLOAT.
		'Integer Number' -> INT.
"		'String' -> STR."
		'Expression Terminator' -> '[.]'.
"		'Local Variables' -> {
				 '.' -> '^|'.
				 'Identifier Name' -> NAME.
				 'Expression Terminator' -> '.'.
				 'END' -> '|'}.
		'Block' -> {
			 '.' -> '['.
			 'Block Argument' -> {
					  '.' -> BLOCK_ARG.
					  'Block Argument' -> BLOCK_ARG.
					  'END' -> '|'}.
			 'Code Block' -> tokens.
			 'END' -> ']'}.
		'Binary Message Selector' -> ''.
		'Partial Message Operator' -> '.'"}
]

{ #category : #'public api' }
GrTokenizer >> scan: aString [

	| rest tokenStream |
	rest := aString.
	tokenStream := WriteStream with: Array new.

	[ rest isNotEmpty ] whileTrue: [ 
		| found tokensReader token |
		tokensReader := tokens readStream.
		token := tokensReader next.
		found := nil.

		[
			found := token value matchGraciousToken: rest.
			found 
				ifNotNil: [ 
					rest :=  (rest copyFrom: found size + 1 to: rest size) trimBoth.
					tokenStream nextPut: { token key . found }.
					false ]
				ifNil: [
					token := tokensReader next ifNil: [ ^ GrTokenError signal ].
					true
				].
		] whileTrue
	 ].
	^  tokenStream 
]
