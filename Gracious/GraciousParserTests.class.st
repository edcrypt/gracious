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
	self
		shouldnt:
			(GraciousParser 
				parseMethod: self blockMethod)
		raise: SmaCCParserError
]

{ #category : #tests }
GraciousParserTests >> testCascadeMessageMethod [
	self
		shouldnt:
			(GraciousParser 
				parseMethod: self cascadeMessageMethod )
		raise: SmaCCParserError
]

{ #category : #'simple tests' }
GraciousParserTests >> testSimpleElementsKeywordMethod [
	self
		shouldnt:
			(GraciousParser 
				parseMethod: self simpleElementsKeywordMethod )
		raise: SmaCCParserError
]

{ #category : #'simple tests' }
GraciousParserTests >> testSimpleElementsMethod [
	self
		shouldnt:
			(GraciousParser 
				parseMethod: self simpleElementsMethod )
		raise: SmaCCParserError
]

{ #category : #'simple tests' }
GraciousParserTests >> testSimpleElementsMethodWithMultipleVars [
	self
		shouldnt:
			(GraciousParser 
				parseMethod: self simpleElementsMethodWithMultipleVars )
		raise: SmaCCParserError
]

{ #category : #'simple tests' }
GraciousParserTests >> testsimpleElementsMultiKeywordMethod [
	self
		shouldnt:
			(GraciousParser 
				parseMethod: self simpleElementsMultiKeywordMethod )
		raise: SmaCCParserError
]
