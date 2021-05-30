Class {
	#name : #GraciousParserTests,
	#superclass : #TestCase,
	#category : #Gracious
}

{ #category : #resources }
GraciousParserTests >> blockMethod [
	"a method without messages"
	^ 'do it
			^ [:a b :c d |
				| e f. g h | x y z ]'
]

{ #category : #resources }
GraciousParserTests >> cascadeMessageMethod [
	"a method without messages"
	^ 'do it
^ self, 
      | first
      | second: arg; and: other
      | << 42'
]

{ #category : #resources }
GraciousParserTests >> simpleElementsKeywordMethod [
	"a method without messages"
	^ 'do it: x y
    | a b |
    a b := 42.
    a b := c d.
    ^ a b'
]

{ #category : #resources }
GraciousParserTests >> simpleElementsMethod [
	"a method without messages"
	^ 'do it
    | a b |
    a b := 42.
    a b := c d.
    ^ a b'
]

{ #category : #resources }
GraciousParserTests >> simpleElementsMethodWithMultipleVars [
	"a method without messages"
	^ 'do it
    | a b. c d.. e f|
    a b := 42.
    a b := c d.
    ^ a b'
]

{ #category : #resources }
GraciousParserTests >> simpleElementsMultiKeywordMethod [
	"a method without messages"
	^ 'do it: x y; and also: z w
    | a b |
    a b := 42.
    a b := c d.
    ^ a b'
]

{ #category : #tests }
GraciousParserTests >> testBlockMethod [
	| ast |
	self shouldnt: [ast := GraciousParser parseMethod: self blockMethod] 
		   raise: SmaCCParserError.
]

{ #category : #tests }
GraciousParserTests >> testCascadeMessageMethod [
	| ast |
	self shouldnt: [ast := GraciousParser parseMethod: self cascadeMessageMethod] 
		   raise: SmaCCParserError.
]

{ #category : #'simple tests' }
GraciousParserTests >> testSimpleElementsKeywordMethod [
	| ast |
	self shouldnt: [ast := GraciousParser parseMethod: self simpleElementsKeywordMethod]
	     raise: SmaCCParserError.
	self assert: ast selector equals: #'do it:'.
	self assert: ast arguments size equals: 1.
	self assert: ast arguments first name equals: 'x y'.

]

{ #category : #'simple tests' }
GraciousParserTests >> testSimpleElementsMethod [
	| ast |
	self shouldnt: [ast := GraciousParser parseMethod: self simpleElementsMethod]
			raise: SmaCCParserError.
	self assert: ast selector equals: #'do it'.
	self assert: ast body temporaries first name equals: 'a b'.
	self assert: ast body statements first variable name equals: 'a b'.
	"TODO: subclass RBLiteralNode to know the type of literal?"
	self assert: ast body statements first value value equals: '42'.
]

{ #category : #'simple tests' }
GraciousParserTests >> testSimpleElementsMethodWithMultipleVars [
	| ast |
	self
		shouldnt: [ ast := GraciousParser
				parseMethod: self simpleElementsMethodWithMultipleVars ]
		raise: SmaCCParserError.
	self assert: ast temporaries size equals: 3.
	"TODO: extend RBSimpleFormatter>>formatTemporariesFor: and RBProgramNode>>formatterClass 
	       to show | a b. c d | instead of | a b c d |"
	self assert: ast temporaries first name equals: #'a b'.
	self assert: ast temporaries second name equals: #'c d'.
	self assert: ast temporaries last name equals: #'e f'
	
]

{ #category : #'simple tests' }
GraciousParserTests >> testsimpleElementsMultiKeywordMethod [
	| ast |
	self shouldnt: [ 
			ast := GraciousParser parseMethod: self simpleElementsMultiKeywordMethod.
		] 
		raise: SmaCCParserError.
	self assert: ast arguments size equals: 2.
	"TODO: extend the ast to show the ';' separator"
	self assert: ast arguments first name equals: #'x y'.
	self assert: ast arguments last name equals: #'z w'.
]
