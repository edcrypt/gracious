"
I parse Gracious Language methods and expressions, in order to build (Pharo) ASTs.
"
Class {
	#name : #GraciousParser,
	#superclass : #SmaCCParser,
	#category : #Gracious
}

{ #category : #'generated-accessing' }
GraciousParser class >> cacheId [
	^'2021-05-29T17:58:52.257102-03:00'
]

{ #category : #generated }
GraciousParser class >> definitionComment [
"<name>
	: (<isLetter> | \_) ((<isLetter> | [\d\_\s] ) * (<isLetter> | [\d\_])) # cant use '?' :(
	| (<isLetter> | \_)
	;
<number>
	: \d+
	;
<negativeNumber>
	: \- <number>
	;
<string>
	: \'  [^\']* \' (\' [^\']* \')*
	;
<keyword>
	: <name> \:
	;
<multikeyword>
	: <name> \: (<name> \: )+
	;
<binarySymbol>
	: [\~\-\!\@\%\&\*\+\=\\\|\?\/\>\<] [\~\-\!\@\%\&\*\+\=\\\|\?\/\>\<]*
	;
<whitespace>
	: (<isSeparator> | \cA)+
	;
<comment>
	: \"" [^\""]* \""
	;
<dottedName>
	: <name> (\. <name>)+
	;
<character>
	: \$ .
	;
<variableAssignment>
	: <name> \: \=
	;
<anyChar>
	:  .
	; # For VW literal arrays that handle #(;) -> #(#';')

%id <number> <negativeNumber> <name> <binarySymbol>;
%start SequenceNode ;

Method
	: <name> MethodSequenceNode 
			{(RBMethodNode 
				selector: '1' value asSymbol
				arguments: #() 
				body: '2' last) 
					""tags: '2' first; ""
					yourself}
	| BinaryMethodName MethodSequenceNode 
			{(RBMethodNode 
				selector: '1' first 
				arguments: '1' last 
				body: '2' last) 
					""tags: '2' first; ""
					yourself}
	| KeywordMethodName MethodSequenceNode 
			{(RBMethodNode 
				selector: '1' first contents asSymbol 
				arguments: '1' last 
				body: '2' last) 
					""tags: '2' first; ""
					yourself}
	;
BinaryMethodName
	: <binarySymbol> Variable 
			{Array with: '1' value asSymbol with: (Array with: '2')}
	;
KeywordMethodName
	: <keyword> Variable 
			{| stream | 
			stream := WriteStream on: (String new: 30). 
			stream nextPutAll: '1' value. 
			Array with: stream with: (OrderedCollection with: '2')}
	| KeywordMethodName "";"" <keyword> Variable 
			{'1' first nextPutAll: '3' value. 
			'1' last add: '4'. 
			'1'}
	;
Primitives
	: 		{OrderedCollection new}
	| Primitives ""<"" PrimitiveMessageSend "">"" 
			{'1' 
				add: ('2' startPosition to: '4' startPosition); 
				yourself}
	;
PrimitiveMessageSend
	:
	| PrimitiveMessageSend <keyword> 
			{nil}
	| PrimitiveMessageSend Literal 
			{nil}
	| PrimitiveMessageSend ""("" 
			{nil}
	| PrimitiveMessageSend "")"" 
			{nil}
	| PrimitiveMessageSend ""{"" 
			{nil}
	| PrimitiveMessageSend ""}"" 
			{nil}
	| PrimitiveMessageSend "";"" 
			{nil}
	| PrimitiveMessageSend ""."" 
			{nil}
	| PrimitiveMessageSend <name> 
			{nil}
	| PrimitiveMessageSend <binarySymbol> 
			{nil}
	;
MethodSequenceNode
	: Primitives ""|"" TemporaryVariables ""|"" Primitives Statements 
			{Array with: ('1' addAll: '5'; yourself) with: (RBSequenceNode temporaries: '3' statements: '6')}
	| Primitives ""||"" Primitives Statements 
			{Array with: ('1' addAll: '3'; yourself) with: (RBSequenceNode temporaries: #() statements: '4')}
	| Primitives Statements 
			{Array with: '1' with: (RBSequenceNode temporaries: #() statements: '2')}
	;
SequenceNode
	: Temporaries Statements 
			{RBSequenceNode temporaries: '1' statements: '2'}
	;
Temporaries
	: 		{#()}
	| ""||""
			{#()}
	| ""|"" TemporaryVariables ""|"" 
			{'2'}
	;
TemporaryVariables
	:  Variable {OrderedCollection with: '1'}
	| TemporaryVariables Periods Variable 
			{'1' 
				add: '3'; 
				yourself}
	;
Statements
	: OptionalPeriod		{OrderedCollection new}
	| OptionalPeriod StatementList OptionalPeriod
			{ '2' }
	| OptionalPeriod StatementList Periods ""^"" Expression OptionalPeriod
			{'2' 
				add: (RBReturnNode value: '5'); 
				yourself}
	| OptionalPeriod ""^"" Expression OptionalPeriod
			{OrderedCollection with: (RBReturnNode value: '3')}
	;
OptionalPeriod
	: 
	| Periods
	;

StatementList
	: Expression
	| StatementList Periods Expression 
			{'1' 
				add: '3'; 
				yourself}
	;

Periods:
	"".""
	| ""."" Periods
	;

Block
	: ""["" BlockArgs ""|"" SequenceNode ""]"" 
			{RBBlockNode arguments: '2' body: '4'}
	| ""["" SequenceNode ""]"" 
			{RBBlockNode body: '2'}
	| ""["" BlockArgs ""]"" 
			{RBBlockNode arguments: '2' body: (RBSequenceNode statements: #())}
	| ""["" BlockArgs ""||"" TemporaryVariables ""|"" Statements ""]"" 
			{RBBlockNode arguments: '2' body: (RBSequenceNode temporaries: '4' statements: '6')}
	;
BlockArgs
	: "":"" Variable 
			{OrderedCollection with: '2'}
	| BlockArgs "":"" Variable 
			{'1' 
				add: '3'; 
				yourself}
	;
Expression
	: Variable "":="" Expression 
			{RBAssignmentNode variable: '1' value: '3'}
	| Cascade 
			{#liftFirstValue:}
	;
Cascade
	: MessageSend CascadeList 
			{| messages |
			'2' isEmpty ifTrue: [^'1'].
			messages := OrderedCollection new: '2' size + 1.
			messages add: '1'.
			'2' do: [:each | messages add: (RBMessageNode receiver: '1' receiver selector: each first contents asSymbol arguments: each last)].
			RBCascadeNode messages: messages}
	| Primary 
			{#liftFirstValue:}
	;
MessageSend
	: KeywordMessageSend 
			{#liftFirstValue:}
	| BinaryMessageSend 
			{#liftFirstValue:}
	| UnaryMessageSend 
			{#liftFirstValue:}
	;
CascadeList
	: 		{OrderedCollection new}
	| CascadeList "";"" SimpleMessage 
			{'1' 
				add: '3'; 
				yourself}
	;
SimpleMessage
	: UnaryMessage 
			{#liftFirstValue:}
	| BinaryMessage 
			{#liftFirstValue:}
	| KeywordMessage 
			{#liftFirstValue:}
	;
KeywordMessageSend
	: BinaryMessageSend KeywordMessage 
			{#createMessageNodeFrom:}
	| UnaryMessageSend KeywordMessage 
			{#createMessageNodeFrom:}
	| Primary KeywordMessage 
			{#createMessageNodeFrom:}
	;
KeywordMessage
	: <keyword> KeywordArgument 
			{| stream | 
			stream := WriteStream on: (String new: 30). 
			stream nextPutAll: '1' value. 
			Array with: stream with: (OrderedCollection with: '2')}
	| KeywordMessage <keyword> KeywordArgument 
			{'1' first nextPutAll: '2' value. 
			'1' last add: '3'. 
			'1'}
	;
KeywordArgument
	: BinaryMessageSend 
			{#liftFirstValue:}
	| UnaryMessageSend 
			{#liftFirstValue:}
	| Primary 
			{#liftFirstValue:}
	;
BinaryMessageSend
	: BinaryMessageSend BinaryMessage 
			{#createMessageNodeFrom:}
	| UnaryMessageSend BinaryMessage 
			{#createMessageNodeFrom:}
	| Primary BinaryMessage 
			{#createMessageNodeFrom:} 
	;
BinaryMessage 
	: <binarySymbol> BinaryArgument 
			{Array with: (ReadStream on: '1' value) with: (Array with: '2')}
	;
BinaryArgument
	: UnaryMessageSend 
			{#liftFirstValue:}
	| Primary 
			{#liftFirstValue:}
	;
UnaryMessageSend 
	: UnaryMessageSend UnaryMessage 
			{#createMessageNodeFrom:}
	| Primary UnaryMessage 
			{#createMessageNodeFrom:}
	;
UnaryMessage 
	: <name> 
			{Array with: (ReadStream on: '1' value) with: #()}
	;
Primary
	: ""("" Expression "")"" 
			{#liftSecondValue:}
	| Literal 
			{RBLiteralNode value: '1'}
	| Variable 
			{#liftFirstValue:}
	| Block 
			{#liftFirstValue:}
	| ""{"" StatementList OptionalPeriod ""}""
			{ RBArrayNode statements: '2' }
	| ""{"" ""}""
			{ RBArrayNode new }
	;
Variable
	: <name> 
			{RBVariableNode named: '1' value}
	| <dottedName> 
			{RBVariableNode named: '1' value}
	;
Literal
	: ""true"" 
			{true}
	| ""false"" 
			{false}
	| ""nil"" 
			{nil}
	| <number> 
			{'1' value}
	| <negativeNumber> 
			{'1' value}
	| <character> 
			{'1' value at: 2}
	| <string> 
			{('1' value copyFrom: 2 to: '1' value size - 1) copyReplaceAll: '''''' with: ''''}
	|  ""#"" <string> 
			{(('2' value copyFrom: 2 to: '2' value size - 1) copyReplaceAll: '''''' with: '''') asSymbol}
	| ""#"" <name> 
			{'2' value asSymbol}
	| ""#"" <binarySymbol> 
			{'2' value asSymbol}
	| ""#"" <keyword> 
			{'2' value asSymbol}
	| ""#"" <multikeyword> 
			{'2' value asSymbol}
	| ""#"" ""["" ByteArray ""]"" 
			{'3' contents}
	| ""#"" ""("" Array "")"" 
			{'3' contents}
	| ""#"" ""{"" <name> ""}"" 
			{'3' value asQualifiedReference}
	| ""#"" ""{"" <dottedName> ""}"" 
			{'3' value asQualifiedReference}
	;
ByteArray
	: 		{WriteStream on: ByteArray new}
	| ByteArray <number> 
			{'1' 
				nextPut: '2' value; 
				yourself}
	;

Array
	: 		{WriteStream on: Array new}
	| Array ArrayLiteral 
			{'1' 
				nextPut: '2'; 
				yourself} 
	| Array <name> "":="" 
			{'2' stopPosition + 1 = '3' startPosition 
				ifTrue: ['1' nextPut: ('2' value, ':') asSymbol] 
				ifFalse: ['1' nextPut: '2' value asSymbol; nextPut: #':']. 
			self position: '3' startPosition. 
			currentToken := nil. 
			'1'}
	;
ArrayLiteral
	: Literal 
			{#liftFirstValue:}
	| <name> 
			{'1' value asSymbol}
	| <binarySymbol> 
			{'1' value asSymbol}
	| <keyword> 
			{'1' value asSymbol}
	| <multikeyword> 
			{'1' value asSymbol}
	| ""{"" <name> ""}"" 
			{'2' value asQualifiedReference}
	| ""{"" <dottedName> ""}"" 
			{'2' value asQualifiedReference}
	| ""("" Array "")"" 
			{'2' contents}
	| ""["" ByteArray ""]"" 
			{'2' contents}
	| <anyChar> 
			{'1' value asSymbol}
	| <dottedName> 
			{'1' value}
	;"
]

{ #category : #parsing }
GraciousParser class >> parseMethod: aString [ 
	^self parse: aString startingAt: self startingStateForMethod
]

{ #category : #'generated-accessing' }
GraciousParser class >> scannerClass [
	^GraciousScanner
]

{ #category : #generated }
GraciousParser class >> startingStateForMethod [
	^ 1
]

{ #category : #generated }
GraciousParser class >> startingStateForSequenceNode [
	^ 2
]

{ #category : #'generated-reduction actions' }
GraciousParser >> reduceActionForArray1: nodes [
	^ WriteStream on: Array new
]

{ #category : #'generated-reduction actions' }
GraciousParser >> reduceActionForArray2: nodes [
	^ (nodes at: 1)
		nextPut: (nodes at: 2);
		yourself
]

{ #category : #'generated-reduction actions' }
GraciousParser >> reduceActionForArray3: nodes [
	(nodes at: 2) stopPosition + 1 = (nodes at: 3) startPosition
		ifTrue: [ (nodes at: 1) nextPut: ((nodes at: 2) value , ':') asSymbol ]
		ifFalse: [ (nodes at: 1)
				nextPut:
					(nodes at: 2) value asSymbol;
				nextPut: #':' ].
	self position:
		(nodes at: 3) startPosition.
	currentToken := nil.
	^ nodes at: 1
]

{ #category : #'generated-reduction actions' }
GraciousParser >> reduceActionForArrayLiteral2: nodes [
	^ (nodes at: 1) value asSymbol
]

{ #category : #'generated-reduction actions' }
GraciousParser >> reduceActionForArrayLiteral6: nodes [
	^ (nodes at: 2) value asQualifiedReference
]

{ #category : #'generated-reduction actions' }
GraciousParser >> reduceActionForArrayLiteral8: nodes [
	^ (nodes at: 2) contents
]

{ #category : #'generated-reduction actions' }
GraciousParser >> reduceActionForBinaryMessage1: nodes [
	^ Array
		with: (ReadStream on: (nodes at: 1) value)
		with: (Array with: (nodes at: 2))
]

{ #category : #'generated-reduction actions' }
GraciousParser >> reduceActionForBinaryMethodName1: nodes [
	^ Array
		with: (nodes at: 1) value asSymbol
		with: (Array with: (nodes at: 2))
]

{ #category : #'generated-reduction actions' }
GraciousParser >> reduceActionForBlock1: nodes [
	^ RBBlockNode arguments: (nodes at: 2) body: (nodes at: 4)
]

{ #category : #'generated-reduction actions' }
GraciousParser >> reduceActionForBlock2: nodes [
	^ RBBlockNode body: (nodes at: 2)
]

{ #category : #'generated-reduction actions' }
GraciousParser >> reduceActionForBlock3: nodes [
	^ RBBlockNode
		arguments: (nodes at: 2)
		body: (RBSequenceNode statements: #())
]

{ #category : #'generated-reduction actions' }
GraciousParser >> reduceActionForBlock4: nodes [
	^ RBBlockNode
		arguments: (nodes at: 2)
		body: (RBSequenceNode temporaries: (nodes at: 4) statements: (nodes at: 6))
]

{ #category : #'generated-reduction actions' }
GraciousParser >> reduceActionForBlockArgs1: nodes [
	^ OrderedCollection with: (nodes at: 2)
]

{ #category : #'generated-reduction actions' }
GraciousParser >> reduceActionForByteArray1: nodes [
	^ WriteStream on: ByteArray new
]

{ #category : #'generated-reduction actions' }
GraciousParser >> reduceActionForByteArray2: nodes [
	^ (nodes at: 1)
		nextPut: (nodes at: 2) value;
		yourself
]

{ #category : #'generated-reduction actions' }
GraciousParser >> reduceActionForCascade1: nodes [
	| messages |
	(nodes at: 2) isEmpty
		ifTrue: [ ^ nodes at: 1 ].
	messages := OrderedCollection new:
		(nodes at: 2) size + 1.
	messages add: (nodes at: 1).
	(nodes at: 2)
		do: [ :each | 
			messages
				add:
					(RBMessageNode
						receiver:
							(nodes at: 1) receiver
						selector: each first contents asSymbol
						arguments: each last) ].
	^ RBCascadeNode messages: messages
]

{ #category : #'generated-reduction actions' }
GraciousParser >> reduceActionForExpression1: nodes [
	^ RBAssignmentNode variable: (nodes at: 1) value: (nodes at: 3)
]

{ #category : #'generated-reduction actions' }
GraciousParser >> reduceActionForKeywordMessage2: nodes [
	(nodes at: 1) first nextPutAll: (nodes at: 2) value.
	(nodes at: 1) last add: (nodes at: 3).
	^ nodes at: 1
]

{ #category : #'generated-reduction actions' }
GraciousParser >> reduceActionForKeywordMethodName1: nodes [
	| stream |
	stream := WriteStream on: (String new: 30).
	stream nextPutAll:
		(nodes at: 1) value.
	^ Array with: stream with: (OrderedCollection with: (nodes at: 2))
]

{ #category : #'generated-reduction actions' }
GraciousParser >> reduceActionForKeywordMethodName2: nodes [
	(nodes at: 1) first nextPutAll: (nodes at: 3) value.
	(nodes at: 1) last add: (nodes at: 4).
	^ nodes at: 1
]

{ #category : #'generated-reduction actions' }
GraciousParser >> reduceActionForLiteral14: nodes [
	^ (nodes at: 3) contents
]

{ #category : #'generated-reduction actions' }
GraciousParser >> reduceActionForLiteral15: nodes [
	^ (nodes at: 3) value asQualifiedReference
]

{ #category : #'generated-reduction actions' }
GraciousParser >> reduceActionForLiteral1: nodes [
	^ true
]

{ #category : #'generated-reduction actions' }
GraciousParser >> reduceActionForLiteral2: nodes [
	^ false
]

{ #category : #'generated-reduction actions' }
GraciousParser >> reduceActionForLiteral4: nodes [
	^ (nodes at: 1) value
]

{ #category : #'generated-reduction actions' }
GraciousParser >> reduceActionForLiteral6: nodes [
	^ (nodes at: 1) value at: 2
]

{ #category : #'generated-reduction actions' }
GraciousParser >> reduceActionForLiteral7: nodes [
	^ ((nodes at: 1) value copyFrom: 2 to: (nodes at: 1) value size - 1)
		copyReplaceAll: ''''''
		with: ''''
]

{ #category : #'generated-reduction actions' }
GraciousParser >> reduceActionForLiteral8: nodes [
	^ (((nodes at: 2) value copyFrom: 2 to: (nodes at: 2) value size - 1)
		copyReplaceAll: ''''''
		with: '''') asSymbol
]

{ #category : #'generated-reduction actions' }
GraciousParser >> reduceActionForLiteral9: nodes [
	^ (nodes at: 2) value asSymbol
]

{ #category : #'generated-reduction actions' }
GraciousParser >> reduceActionForMethod1: nodes [
	^ (RBMethodNode
		selector: (nodes at: 1) value asSymbol
		arguments: #()
		body:
			(nodes at: 2) last) yourself
]

{ #category : #'generated-reduction actions' }
GraciousParser >> reduceActionForMethod2: nodes [
	^ (RBMethodNode
		selector: (nodes at: 1) first
		arguments: (nodes at: 1) last
		body:
			(nodes at: 2) last) yourself
]

{ #category : #'generated-reduction actions' }
GraciousParser >> reduceActionForMethod3: nodes [
	^ (RBMethodNode
		selector: (nodes at: 1) first contents asSymbol
		arguments:
			(nodes at: 1) last
		body:
			(nodes at: 2) last) yourself
]

{ #category : #'generated-reduction actions' }
GraciousParser >> reduceActionForMethodSequenceNode1: nodes [
	^ Array
		with:
			((nodes at: 1)
				addAll: (nodes at: 5);
				yourself)
		with: (RBSequenceNode temporaries: (nodes at: 3) statements: (nodes at: 6))
]

{ #category : #'generated-reduction actions' }
GraciousParser >> reduceActionForMethodSequenceNode2: nodes [
	^ Array
		with:
			((nodes at: 1)
				addAll: (nodes at: 3);
				yourself)
		with: (RBSequenceNode temporaries: #() statements: (nodes at: 4))
]

{ #category : #'generated-reduction actions' }
GraciousParser >> reduceActionForMethodSequenceNode3: nodes [
	^ Array
		with: (nodes at: 1)
		with: (RBSequenceNode temporaries: #() statements: (nodes at: 2))
]

{ #category : #'generated-reduction actions' }
GraciousParser >> reduceActionForPrimary2: nodes [
	^ RBLiteralNode value: (nodes at: 1)
]

{ #category : #'generated-reduction actions' }
GraciousParser >> reduceActionForPrimary5: nodes [
	^ RBArrayNode statements: (nodes at: 2)
]

{ #category : #'generated-reduction actions' }
GraciousParser >> reduceActionForPrimary6: nodes [
	^ RBArrayNode new
]

{ #category : #'generated-reduction actions' }
GraciousParser >> reduceActionForPrimitives1: nodes [
	^ OrderedCollection new
]

{ #category : #'generated-reduction actions' }
GraciousParser >> reduceActionForPrimitives2: nodes [
	^ (nodes at: 1)
		add: ((nodes at: 2) startPosition to: (nodes at: 4) startPosition);
		yourself
]

{ #category : #'generated-reduction actions' }
GraciousParser >> reduceActionForSequenceNode1: nodes [
	^ RBSequenceNode temporaries: (nodes at: 1) statements: (nodes at: 2)
]

{ #category : #'generated-reduction actions' }
GraciousParser >> reduceActionForStatements3: nodes [
	^ (nodes at: 2)
		add: (RBReturnNode value: (nodes at: 5));
		yourself
]

{ #category : #'generated-reduction actions' }
GraciousParser >> reduceActionForStatements4: nodes [
	^ OrderedCollection with: (RBReturnNode value: (nodes at: 3))
]

{ #category : #'generated-reduction actions' }
GraciousParser >> reduceActionForTemporaries1: nodes [
	^ #()
]

{ #category : #'generated-reduction actions' }
GraciousParser >> reduceActionForTemporaryVariables1: nodes [
	^ OrderedCollection with: (nodes at: 1)
]

{ #category : #'generated-reduction actions' }
GraciousParser >> reduceActionForTemporaryVariables2: nodes [
	^ (nodes at: 1)
		add: (nodes at: 3);
		yourself
]

{ #category : #'generated-reduction actions' }
GraciousParser >> reduceActionForUnaryMessage1: nodes [
	^ Array with: (ReadStream on: (nodes at: 1) value) with: #()
]

{ #category : #'generated-reduction actions' }
GraciousParser >> reduceActionForUnaryMessageSend2: nodes [
	^ #createMessageNodeFrom:
]

{ #category : #'generated-reduction actions' }
GraciousParser >> reduceActionForVariable1: nodes [
	^ RBVariableNode named: (nodes at: 1) value
]

{ #category : #generated }
GraciousParser >> reduceTable [
^#(
	#(37 0 #reduceActionForTemporaries1:) 
	#(32 0 #reduceActionForPrimitives1:) 
	#(37 1 #reduceActionForTemporaries1:) 
	#(39 0 #reduceFor:) 
	#(67 2 #reduceActionForMethod1:) 
	#(57 1 #reduceActionForVariable1:) 
	#(46 2 #reduceActionForKeywordMethodName1:) 
	#(34 2 #reduceActionForBinaryMethodName1:) 
	#(67 2 #reduceActionForMethod2:) 
	#(67 2 #reduceActionForMethod3:) 
	#(35 1 #reduceActionForTemporaryVariables1:) 
	#(38 1 #reduceFor:) 
	#(60 2 #reduceActionForSequenceNode1:) 
	#(39 1 #reduceFor:) 
	#(36 1 #reduceActionForPrimitives1:) 
	#(33 0 #reduceFor:) 
	#(59 2 #reduceActionForMethodSequenceNode3:) 
	#(37 3 #liftSecondValue:) 
	#(38 2 #reduceFor:) 
	#(68 1 #reduceActionForLiteral1:) 
	#(68 1 #reduceActionForLiteral2:) 
	#(68 1 #nil) 
	#(68 1 #reduceActionForLiteral4:) 
	#(68 1 #reduceActionForLiteral7:) 
	#(68 1 #reduceActionForLiteral6:) 
	#(40 1 #reduceFor:) 
	#(47 1 #liftFirstValue:) 
	#(41 1 #liftFirstValue:) 
	#(64 0 #reduceActionForPrimitives1:) 
	#(44 1 #liftFirstValue:) 
	#(45 1 #liftFirstValue:) 
	#(47 1 #reduceActionForPrimary2:) 
	#(46 4 #reduceActionForKeywordMethodName2:) 
	#(35 3 #reduceActionForTemporaryVariables2:) 
	#(62 0 #reduceActionForArray1:) 
	#(61 0 #reduceActionForByteArray1:) 
	#(68 2 #reduceActionForLiteral9:) 
	#(68 2 #reduceActionForLiteral8:) 
	#(47 2 #reduceActionForPrimary6:) 
	#(36 3 #liftSecondValue:) 
	#(44 2 #reduceActionForCascade1:) 
	#(52 1 #reduceActionForUnaryMessage1:) 
	#(50 2 #reduceActionForUnaryMessageSend2:) 
	#(49 2 #reduceActionForUnaryMessageSend2:) 
	#(48 2 #reduceActionForUnaryMessageSend2:) 
	#(33 2 #nil) 
	#(32 4 #reduceActionForPrimitives2:) 
	#(59 4 #reduceActionForMethodSequenceNode2:) 
	#(47 3 #liftSecondValue:) 
	#(36 4 #reduceActionForStatements4:) 
	#(42 2 #reduceActionForBlockArgs1:) 
	#(43 3 #reduceActionForBlock3:) 
	#(43 3 #reduceActionForBlock2:) 
	#(40 3 #reduceActionForTemporaryVariables2:) 
	#(55 1 #liftFirstValue:) 
	#(54 2 #reduceActionForKeywordMethodName1:) 
	#(56 1 #liftFirstValue:) 
	#(53 2 #reduceActionForBinaryMessage1:) 
	#(41 3 #reduceActionForExpression1:) 
	#(68 4 #reduceActionForLiteral14:) 
	#(63 1 #reduceActionForArrayLiteral2:) 
	#(63 1 #reduceActionForLiteral4:) 
	#(62 2 #reduceActionForArray2:) 
	#(63 1 #liftFirstValue:) 
	#(68 4 #reduceActionForLiteral15:) 
	#(61 2 #reduceActionForByteArray2:) 
	#(47 4 #reduceActionForPrimary5:) 
	#(42 3 #reduceActionForTemporaryVariables2:) 
	#(64 3 #reduceActionForTemporaryVariables2:) 
	#(51 1 #liftFirstValue:) 
	#(54 3 #reduceActionForKeywordMessage2:) 
	#(59 6 #reduceActionForMethodSequenceNode1:) 
	#(62 3 #reduceActionForArray3:) 
	#(43 5 #reduceActionForBlock1:) 
	#(36 6 #reduceActionForStatements3:) 
	#(63 3 #reduceActionForArrayLiteral8:) 
	#(63 3 #reduceActionForArrayLiteral6:) 
	#(43 7 #reduceActionForBlock4:)
	).
]

{ #category : #generated }
GraciousParser >> symbolNames [
	^ #('"#"' '"}"' '")"' '"("' '"."' '";"' '"<"' '"{"' '"|"' '">"' '"true"' '"false"' '":="' '"nil"' '"||"' '"^"' '"["' '":"' '"]"' '<name>' '<number>' '<negativeNumber>' '<string>' '<keyword>' '<multikeyword>' '<binarySymbol>' '<whitespace>' '<comment>' '<dottedName>' '<character>' '<anyChar>' 'Primitives' 'PrimitiveMessageSend' 'BinaryMethodName' 'TemporaryVariables' 'Statements' 'Temporaries' 'Periods' 'OptionalPeriod' 'StatementList' 'Expression' 'BlockArgs' 'Block' 'Cascade' 'MessageSend' 'KeywordMethodName' 'Primary' 'KeywordMessageSend' 'BinaryMessageSend' 'UnaryMessageSend' 'SimpleMessage' 'UnaryMessage' 'BinaryMessage' 'KeywordMessage' 'KeywordArgument' 'BinaryArgument' 'Variable' 'B e g i n' 'MethodSequenceNode' 'SequenceNode' 'ByteArray' 'Array' 'ArrayLiteral' 'CascadeList' 'E O F' 'error' 'Method' 'Literal')
]

{ #category : #generated }
GraciousParser >> transitionTable [
^#(
#[1 0 13 0 20 0 17 0 24 0 21 0 26 0 25 0 34 0 29 0 46 0 33 0 67] 
#[1 0 6 0 1 0 6 0 4 0 6 0 5 0 6 0 8 0 37 0 9 0 6 0 11 0 6 0 12 0 6 0 14 0 41 0 15 0 6 0 16 0 6 0 17 0 6 0 20 0 6 0 21 0 6 0 22 0 6 0 23 0 6 0 29 0 6 0 30 0 45 0 37 0 49 0 60 0 6 0 65] 
#[1 0 10 0 1 0 10 0 4 0 10 0 5 0 10 0 7 0 10 0 8 0 10 0 9 0 10 0 11 0 10 0 12 0 10 0 14 0 10 0 15 0 10 0 16 0 10 0 17 0 10 0 20 0 10 0 21 0 10 0 22 0 10 0 23 0 10 0 29 0 10 0 30 0 53 0 32 0 57 0 59 0 10 0 65] 
#[1 0 61 0 20 0 65 0 29 0 69 0 57] 
#[1 0 73 0 20 0 77 0 29 0 81 0 57] 
#[1 0 10 0 1 0 10 0 4 0 10 0 5 0 10 0 7 0 10 0 8 0 10 0 9 0 10 0 11 0 10 0 12 0 10 0 14 0 10 0 15 0 10 0 16 0 10 0 17 0 10 0 20 0 10 0 21 0 10 0 22 0 10 0 23 0 10 0 29 0 10 0 30 0 53 0 32 0 85 0 59 0 10 0 65] 
#[1 0 10 0 1 0 10 0 4 0 10 0 5 0 89 0 6 0 10 0 7 0 10 0 8 0 10 0 9 0 10 0 11 0 10 0 12 0 10 0 14 0 10 0 15 0 10 0 16 0 10 0 17 0 10 0 20 0 10 0 21 0 10 0 22 0 10 0 23 0 10 0 29 0 10 0 30 0 53 0 32 0 93 0 59 0 10 0 65] 
#[0 0 0 0 65] 
#[1 0 97 0 20 0 101 0 29 0 105 0 35 0 109 0 57] 
#[0 0 14 0 1 0 4 0 5 0 8 0 11 0 12 0 14 0 16 0 17 0 20 0 21 0 22 0 23 0 29 0 30 0 65] 
#[1 0 18 0 1 0 18 0 4 0 113 0 5 0 18 0 8 0 18 0 11 0 18 0 12 0 18 0 14 0 18 0 16 0 18 0 17 0 18 0 20 0 18 0 21 0 18 0 22 0 18 0 23 0 18 0 29 0 18 0 30 0 117 0 36 0 121 0 38 0 125 0 39 0 18 0 65] 
#[0 0 0 0 65] 
#[1 0 18 0 1 0 18 0 4 0 113 0 5 0 129 0 7 0 18 0 8 0 133 0 9 0 18 0 11 0 18 0 12 0 18 0 14 0 137 0 15 0 18 0 16 0 18 0 17 0 18 0 20 0 18 0 21 0 18 0 22 0 18 0 23 0 18 0 29 0 18 0 30 0 141 0 36 0 121 0 38 0 125 0 39 0 18 0 65] 
#[0 0 22 0 65] 
#[0 0 26 0 1 0 4 0 5 0 6 0 7 0 8 0 9 0 11 0 12 0 14 0 15 0 16 0 17 0 20 0 21 0 22 0 23 0 29 0 30 0 65] 
#[0 0 26 0 1 0 4 0 5 0 6 0 7 0 8 0 9 0 11 0 12 0 14 0 15 0 16 0 17 0 20 0 21 0 22 0 23 0 29 0 30 0 65] 
#[0 0 30 0 1 0 4 0 5 0 6 0 7 0 8 0 9 0 11 0 12 0 14 0 15 0 16 0 17 0 20 0 21 0 22 0 23 0 29 0 30 0 65] 
#[0 0 26 0 1 0 4 0 5 0 7 0 8 0 9 0 11 0 12 0 14 0 15 0 16 0 17 0 20 0 21 0 22 0 23 0 29 0 30 0 65] 
#[0 0 26 0 1 0 4 0 5 0 7 0 8 0 9 0 11 0 12 0 14 0 15 0 16 0 17 0 20 0 21 0 22 0 23 0 29 0 30 0 65] 
#[0 0 34 0 1 0 4 0 5 0 7 0 8 0 9 0 11 0 12 0 14 0 15 0 16 0 17 0 20 0 21 0 22 0 23 0 29 0 30 0 65] 
#[0 0 38 0 65] 
#[0 0 145 0 24] 
#[0 0 42 0 65] 
#[0 0 26 0 5 0 9] 
#[0 0 26 0 5 0 9] 
#[1 0 149 0 5 0 153 0 9 0 157 0 38] 
#[0 0 46 0 5 0 9] 
#[1 0 50 0 1 0 50 0 4 0 113 0 5 0 50 0 8 0 50 0 11 0 50 0 12 0 50 0 14 0 50 0 16 0 50 0 17 0 50 0 20 0 50 0 21 0 50 0 22 0 50 0 23 0 50 0 29 0 50 0 30 0 161 0 38 0 50 0 65] 
#[0 0 54 0 65] 
#[0 0 58 0 1 0 4 0 8 0 11 0 12 0 14 0 16 0 17 0 20 0 21 0 22 0 23 0 29 0 30 0 65] 
#[1 0 165 0 1 0 169 0 4 0 173 0 8 0 177 0 11 0 181 0 12 0 185 0 14 0 189 0 16 0 193 0 17 0 197 0 20 0 201 0 21 0 205 0 22 0 209 0 23 0 213 0 29 0 217 0 30 0 221 0 40 0 225 0 41 0 241 0 43 0 225 0 44 0 237 0 45 0 241 0 47 0 237 0 48 0 249 0 49 0 253 0 50 1 1 0 57 0 62 0 65 1 5 0 68] 
#[1 0 66 0 1 0 66 0 2 0 66 0 3 0 66 0 4 0 66 0 5 0 66 0 6 0 66 0 8 0 66 0 10 0 66 0 11 0 66 0 12 0 66 0 14 0 66 0 20 0 66 0 21 0 66 0 22 0 66 0 23 0 66 0 24 0 66 0 26 0 66 0 30 1 9 0 33] 
#[1 0 97 0 20 0 101 0 29 1 13 0 35 0 109 0 57] 
#[1 0 10 0 1 0 10 0 4 0 10 0 5 0 10 0 7 0 10 0 8 0 10 0 11 0 10 0 12 0 10 0 14 0 10 0 16 0 10 0 17 0 10 0 20 0 10 0 21 0 10 0 22 0 10 0 23 0 10 0 29 0 10 0 30 1 17 0 32 0 10 0 65] 
#[0 0 70 0 65] 
#[1 0 61 0 20 0 65 0 29 1 21 0 57] 
#[1 0 149 0 5 0 50 0 20 0 50 0 29 1 25 0 38] 
#[0 0 74 0 1 0 4 0 5 0 8 0 11 0 12 0 14 0 16 0 17 0 20 0 21 0 22 0 23 0 29 0 30 0 65] 
#[1 0 97 0 20 0 101 0 29 1 29 0 57] 
#[0 0 78 0 1 0 4 0 8 0 11 0 12 0 14 0 16 0 17 0 20 0 21 0 22 0 23 0 29 0 30 0 65] 
#[1 1 33 0 4 1 37 0 8 1 41 0 17 1 45 0 20 1 49 0 23 1 53 0 24 1 57 0 25 1 61 0 26] 
#[1 1 65 0 1 1 69 0 4 1 73 0 8 1 77 0 11 1 81 0 12 1 85 0 14 1 89 0 17 1 93 0 20 1 97 0 21 1 101 0 22 1 105 0 23 1 109 0 29 1 113 0 30 1 117 0 41 1 133 0 43 1 117 0 44 1 129 0 45 1 133 0 47 1 129 0 48 1 141 0 49 1 145 0 50 1 149 0 57 1 153 0 68] 
#[1 1 157 0 1 1 161 0 2 1 165 0 4 1 169 0 8 1 173 0 11 1 177 0 12 1 181 0 14 1 185 0 17 1 189 0 20 1 193 0 21 1 197 0 22 1 201 0 23 1 205 0 29 1 209 0 30 1 213 0 40 1 217 0 41 1 233 0 43 1 217 0 44 1 229 0 45 1 233 0 47 1 229 0 48 1 241 0 49 1 245 0 50 1 249 0 57 1 253 0 68] 
#[0 0 82 0 5 0 20 0 24 0 26 0 65] 
#[0 0 86 0 5 0 20 0 24 0 26 0 65] 
#[0 0 90 0 5 0 20 0 24 0 26 0 65] 
#[1 0 165 0 1 0 169 0 4 0 173 0 8 0 177 0 11 0 181 0 12 0 185 0 14 0 193 0 17 0 197 0 20 0 201 0 21 0 205 0 22 0 209 0 23 0 213 0 29 0 217 0 30 2 1 0 41 0 241 0 43 2 1 0 44 0 237 0 45 0 241 0 47 0 237 0 48 0 249 0 49 0 253 0 50 1 1 0 57 1 5 0 68] 
#[1 0 6 0 1 0 6 0 4 0 6 0 5 0 6 0 8 2 5 0 9 0 6 0 11 0 6 0 12 0 6 0 14 2 9 0 15 0 6 0 16 0 6 0 17 2 13 0 18 0 6 0 19 0 6 0 20 0 6 0 21 0 6 0 22 0 6 0 23 0 6 0 29 0 6 0 30 2 17 0 37 2 21 0 42 2 25 0 60] 
#[0 0 26 0 5 0 13 0 20 0 24 0 26 0 65] 
#[0 0 94 0 5 0 20 0 24 0 26 0 65] 
#[0 0 94 0 5 0 20 0 24 0 26 0 65] 
#[0 0 98 0 5 0 20 0 24 0 26 0 65] 
#[0 0 26 0 5 0 13 0 20 0 24 0 26 0 65] 
#[0 0 102 0 5 0 20 0 24 0 26 0 65] 
#[1 0 113 0 5 2 29 0 38 2 33 0 39 0 18 0 65] 
#[0 0 106 0 5 0 65] 
#[0 0 110 0 5 0 20 0 24 0 26 0 65] 
#[0 0 114 0 5 0 65] 
#[1 0 118 0 5 0 118 0 6 2 37 0 64 0 118 0 65] 
#[1 0 122 0 5 2 41 0 20 2 45 0 24 2 49 0 26 2 53 0 52 2 57 0 53 2 61 0 54 0 122 0 65] 
#[0 0 126 0 5 0 6 0 65] 
#[1 0 126 0 5 0 126 0 6 2 45 0 24 2 49 0 26 2 65 0 53 2 69 0 54 0 126 0 65] 
#[1 0 126 0 5 0 126 0 6 2 41 0 20 2 45 0 24 2 49 0 26 2 73 0 52 2 77 0 53 2 81 0 54 0 126 0 65] 
#[1 0 110 0 5 2 85 0 13 0 110 0 20 0 110 0 24 0 110 0 26 0 110 0 65] 
#[0 0 130 0 5 0 20 0 24 0 26 0 65] 
#[1 2 89 0 1 2 93 0 2 2 97 0 3 2 101 0 4 2 105 0 5 2 109 0 6 2 113 0 8 2 117 0 10 2 121 0 11 2 125 0 12 2 129 0 14 2 133 0 20 2 137 0 21 2 141 0 22 2 145 0 23 2 149 0 24 2 153 0 26 2 157 0 30 2 161 0 68] 
#[1 0 149 0 5 2 165 0 9 0 157 0 38] 
#[1 0 18 0 1 0 18 0 4 0 113 0 5 2 169 0 7 0 18 0 8 0 18 0 11 0 18 0 12 0 18 0 14 0 18 0 16 0 18 0 17 0 18 0 20 0 18 0 21 0 18 0 22 0 18 0 23 0 18 0 29 0 18 0 30 2 173 0 36 0 121 0 38 0 125 0 39 0 18 0 65] 
#[0 0 134 0 1 0 4 0 5 0 6 0 7 0 8 0 9 0 11 0 12 0 14 0 15 0 16 0 17 0 20 0 21 0 22 0 23 0 29 0 30 0 65] 
#[0 0 78 0 20 0 29] 
#[0 0 138 0 5 0 9] 
#[1 0 142 0 1 0 142 0 3 0 142 0 4 0 142 0 8 0 142 0 11 0 142 0 12 0 142 0 14 0 142 0 17 0 142 0 20 0 142 0 21 0 142 0 22 0 142 0 23 0 142 0 24 0 142 0 25 0 142 0 26 0 142 0 29 0 142 0 30 0 142 0 31 2 177 0 62] 
#[1 2 181 0 20 2 185 0 29] 
#[1 0 146 0 19 0 146 0 21 2 189 0 61] 
#[0 0 150 0 5 0 20 0 24 0 26 0 65] 
#[0 0 154 0 5 0 20 0 24 0 26 0 65] 
#[0 0 150 0 5 0 20 0 24 0 26 0 65] 
#[0 0 150 0 5 0 20 0 24 0 26 0 65] 
#[0 0 150 0 5 0 20 0 24 0 26 0 65] 
#[1 2 193 0 4 2 197 0 8 2 201 0 17 2 205 0 20 2 209 0 23 2 213 0 24 2 217 0 25 2 221 0 26] 
#[1 1 65 0 1 1 69 0 4 1 73 0 8 1 77 0 11 1 81 0 12 1 85 0 14 1 89 0 17 1 93 0 20 1 97 0 21 1 101 0 22 1 105 0 23 1 109 0 29 1 113 0 30 2 225 0 41 1 133 0 43 2 225 0 44 1 129 0 45 1 133 0 47 1 129 0 48 1 141 0 49 1 145 0 50 1 149 0 57 1 153 0 68] 
#[1 1 157 0 1 2 229 0 2 1 165 0 4 1 169 0 8 1 173 0 11 1 177 0 12 1 181 0 14 1 185 0 17 1 189 0 20 1 193 0 21 1 197 0 22 1 201 0 23 1 205 0 29 1 209 0 30 2 233 0 40 1 217 0 41 1 233 0 43 1 217 0 44 1 229 0 45 1 233 0 47 1 229 0 48 1 241 0 49 1 245 0 50 1 249 0 57 1 253 0 68] 
#[0 0 82 0 3 0 20 0 24 0 26] 
#[0 0 86 0 3 0 20 0 24 0 26] 
#[0 0 90 0 3 0 20 0 24 0 26] 
#[1 0 6 0 1 0 6 0 4 0 6 0 5 0 6 0 8 2 5 0 9 0 6 0 11 0 6 0 12 0 6 0 14 2 9 0 15 0 6 0 16 0 6 0 17 2 13 0 18 0 6 0 19 0 6 0 20 0 6 0 21 0 6 0 22 0 6 0 23 0 6 0 29 0 6 0 30 2 17 0 37 2 237 0 42 2 241 0 60] 
#[0 0 26 0 3 0 13 0 20 0 24 0 26] 
#[0 0 94 0 3 0 20 0 24 0 26] 
#[0 0 94 0 3 0 20 0 24 0 26] 
#[0 0 98 0 3 0 20 0 24 0 26] 
#[0 0 26 0 3 0 13 0 20 0 24 0 26] 
#[0 0 102 0 3 0 20 0 24 0 26] 
#[0 2 245 0 3] 
#[0 0 110 0 3 0 20 0 24 0 26] 
#[0 0 114 0 3] 
#[1 0 118 0 3 0 118 0 6 2 249 0 64] 
#[1 0 122 0 3 2 253 0 20 3 1 0 24 3 5 0 26 3 9 0 52 3 13 0 53 3 17 0 54] 
#[0 0 126 0 3 0 6] 
#[1 0 126 0 3 0 126 0 6 3 1 0 24 3 5 0 26 3 21 0 53 3 25 0 54] 
#[1 0 126 0 3 0 126 0 6 2 253 0 20 3 1 0 24 3 5 0 26 3 29 0 52 3 33 0 53 3 37 0 54] 
#[1 0 110 0 3 3 41 0 13 0 110 0 20 0 110 0 24 0 110 0 26] 
#[0 0 130 0 3 0 20 0 24 0 26] 
#[1 3 45 0 4 3 49 0 8 3 53 0 17 3 57 0 20 3 61 0 23 3 65 0 24 3 69 0 25 3 73 0 26] 
#[0 0 158 0 5 0 20 0 24 0 26 0 65] 
#[1 1 65 0 1 1 69 0 4 1 73 0 8 1 77 0 11 1 81 0 12 1 85 0 14 1 89 0 17 1 93 0 20 1 97 0 21 1 101 0 22 1 105 0 23 1 109 0 29 1 113 0 30 3 77 0 41 1 133 0 43 3 77 0 44 1 129 0 45 1 133 0 47 1 129 0 48 1 141 0 49 1 145 0 50 1 149 0 57 1 153 0 68] 
#[1 1 157 0 1 3 81 0 2 1 165 0 4 1 169 0 8 1 173 0 11 1 177 0 12 1 181 0 14 1 185 0 17 1 189 0 20 1 193 0 21 1 197 0 22 1 201 0 23 1 205 0 29 1 209 0 30 3 85 0 40 1 217 0 41 1 233 0 43 1 217 0 44 1 229 0 45 1 233 0 47 1 229 0 48 1 241 0 49 1 245 0 50 1 249 0 57 1 253 0 68] 
#[0 0 82 0 2 0 5 0 20 0 24 0 26] 
#[0 0 86 0 2 0 5 0 20 0 24 0 26] 
#[0 0 90 0 2 0 5 0 20 0 24 0 26] 
#[1 0 6 0 1 0 6 0 4 0 6 0 5 0 6 0 8 2 5 0 9 0 6 0 11 0 6 0 12 0 6 0 14 2 9 0 15 0 6 0 16 0 6 0 17 2 13 0 18 0 6 0 19 0 6 0 20 0 6 0 21 0 6 0 22 0 6 0 23 0 6 0 29 0 6 0 30 2 17 0 37 3 89 0 42 3 93 0 60] 
#[0 0 26 0 2 0 5 0 13 0 20 0 24 0 26] 
#[0 0 94 0 2 0 5 0 20 0 24 0 26] 
#[0 0 94 0 2 0 5 0 20 0 24 0 26] 
#[0 0 98 0 2 0 5 0 20 0 24 0 26] 
#[0 0 26 0 2 0 5 0 13 0 20 0 24 0 26] 
#[0 0 102 0 2 0 5 0 20 0 24 0 26] 
#[1 0 18 0 2 3 97 0 5 3 101 0 38 3 105 0 39] 
#[0 0 106 0 2 0 5] 
#[0 0 110 0 2 0 5 0 20 0 24 0 26] 
#[0 0 114 0 2 0 5] 
#[1 0 118 0 2 0 118 0 5 0 118 0 6 3 109 0 64] 
#[1 0 122 0 2 0 122 0 5 3 113 0 20 3 117 0 24 3 121 0 26 3 125 0 52 3 129 0 53 3 133 0 54] 
#[0 0 126 0 2 0 5 0 6] 
#[1 0 126 0 2 0 126 0 5 0 126 0 6 3 117 0 24 3 121 0 26 3 137 0 53 3 141 0 54] 
#[1 0 126 0 2 0 126 0 5 0 126 0 6 3 113 0 20 3 117 0 24 3 121 0 26 3 145 0 52 3 149 0 53 3 153 0 54] 
#[1 0 110 0 2 0 110 0 5 3 157 0 13 0 110 0 20 0 110 0 24 0 110 0 26] 
#[0 0 130 0 2 0 5 0 20 0 24 0 26] 
#[1 3 161 0 5 3 165 0 38 3 169 0 39 0 18 0 65] 
#[1 0 97 0 20 0 101 0 29 3 173 0 35 0 109 0 57] 
#[0 0 14 0 1 0 4 0 5 0 8 0 11 0 12 0 14 0 16 0 17 0 19 0 20 0 21 0 22 0 23 0 29 0 30] 
#[1 3 177 0 20 3 181 0 29 3 185 0 57] 
#[1 0 18 0 1 0 18 0 4 3 189 0 5 0 18 0 8 0 18 0 11 0 18 0 12 0 18 0 14 0 18 0 16 0 18 0 17 0 18 0 19 0 18 0 20 0 18 0 21 0 18 0 22 0 18 0 23 0 18 0 29 0 18 0 30 3 193 0 36 3 197 0 38 3 201 0 39] 
#[1 3 205 0 9 3 209 0 15 3 213 0 18 3 217 0 19] 
#[0 3 221 0 19] 
#[1 0 165 0 1 0 169 0 4 0 173 0 8 0 177 0 11 0 181 0 12 0 185 0 14 3 225 0 16 0 193 0 17 0 197 0 20 0 201 0 21 0 205 0 22 0 209 0 23 0 213 0 29 0 217 0 30 3 229 0 41 0 241 0 43 3 229 0 44 0 237 0 45 0 241 0 47 0 237 0 48 0 249 0 49 0 253 0 50 1 1 0 57 0 58 0 65 1 5 0 68] 
#[0 0 162 0 65] 
#[1 0 166 0 5 3 233 0 6 0 166 0 65] 
#[0 0 170 0 5 0 6 0 20 0 24 0 26 0 65] 
#[1 3 237 0 1 3 241 0 4 3 245 0 8 3 249 0 11 3 253 0 12 4 1 0 14 4 5 0 17 4 9 0 20 4 13 0 21 4 17 0 22 4 21 0 23 4 25 0 29 4 29 0 30 4 37 0 43 4 37 0 47 4 41 0 49 4 45 0 50 4 49 0 55 4 37 0 57 4 57 0 68] 
#[1 3 237 0 1 3 241 0 4 3 245 0 8 3 249 0 11 3 253 0 12 4 1 0 14 4 5 0 17 4 9 0 20 4 13 0 21 4 17 0 22 4 21 0 23 4 25 0 29 4 29 0 30 4 61 0 43 4 61 0 47 4 65 0 50 4 69 0 56 4 61 0 57 4 57 0 68] 
#[0 0 174 0 5 0 6 0 20 0 24 0 26 0 65] 
#[0 0 178 0 5 0 6 0 24 0 26 0 65] 
#[1 0 182 0 5 0 182 0 6 4 73 0 24 0 182 0 65] 
#[0 0 178 0 5 0 6 0 24 0 26 0 65] 
#[1 0 182 0 5 0 182 0 6 4 73 0 24 0 182 0 65] 
#[0 0 174 0 5 0 6 0 20 0 24 0 26 0 65] 
#[0 0 178 0 5 0 6 0 24 0 26 0 65] 
#[1 0 182 0 5 0 182 0 6 4 73 0 24 0 182 0 65] 
#[1 0 165 0 1 0 169 0 4 0 173 0 8 0 177 0 11 0 181 0 12 0 185 0 14 0 193 0 17 0 197 0 20 0 201 0 21 0 205 0 22 0 209 0 23 0 213 0 29 0 217 0 30 4 77 0 41 0 241 0 43 4 77 0 44 0 237 0 45 0 241 0 47 0 237 0 48 0 249 0 49 0 253 0 50 1 1 0 57 1 5 0 68] 
#[1 4 81 0 4 4 85 0 8 4 89 0 17 4 93 0 20 4 97 0 23 4 101 0 24 4 105 0 25 4 109 0 26] 
#[0 0 186 0 1 0 2 0 3 0 4 0 5 0 6 0 8 0 10 0 11 0 12 0 14 0 20 0 21 0 22 0 23 0 24 0 26 0 30] 
#[0 0 186 0 1 0 2 0 3 0 4 0 5 0 6 0 8 0 10 0 11 0 12 0 14 0 20 0 21 0 22 0 23 0 24 0 26 0 30] 
#[0 0 186 0 1 0 2 0 3 0 4 0 5 0 6 0 8 0 10 0 11 0 12 0 14 0 20 0 21 0 22 0 23 0 24 0 26 0 30] 
#[0 0 186 0 1 0 2 0 3 0 4 0 5 0 6 0 8 0 10 0 11 0 12 0 14 0 20 0 21 0 22 0 23 0 24 0 26 0 30] 
#[0 0 186 0 1 0 2 0 3 0 4 0 5 0 6 0 8 0 10 0 11 0 12 0 14 0 20 0 21 0 22 0 23 0 24 0 26 0 30] 
#[0 0 186 0 1 0 2 0 3 0 4 0 5 0 6 0 8 0 10 0 11 0 12 0 14 0 20 0 21 0 22 0 23 0 24 0 26 0 30] 
#[0 0 190 0 1 0 4 0 5 0 7 0 8 0 9 0 11 0 12 0 14 0 15 0 16 0 17 0 20 0 21 0 22 0 23 0 29 0 30 0 65] 
#[0 0 82 0 1 0 2 0 3 0 4 0 5 0 6 0 8 0 10 0 11 0 12 0 14 0 20 0 21 0 22 0 23 0 24 0 26 0 30] 
#[0 0 86 0 1 0 2 0 3 0 4 0 5 0 6 0 8 0 10 0 11 0 12 0 14 0 20 0 21 0 22 0 23 0 24 0 26 0 30] 
#[0 0 90 0 1 0 2 0 3 0 4 0 5 0 6 0 8 0 10 0 11 0 12 0 14 0 20 0 21 0 22 0 23 0 24 0 26 0 30] 
#[0 0 186 0 1 0 2 0 3 0 4 0 5 0 6 0 8 0 10 0 11 0 12 0 14 0 20 0 21 0 22 0 23 0 24 0 26 0 30] 
#[0 0 94 0 1 0 2 0 3 0 4 0 5 0 6 0 8 0 10 0 11 0 12 0 14 0 20 0 21 0 22 0 23 0 24 0 26 0 30] 
#[0 0 94 0 1 0 2 0 3 0 4 0 5 0 6 0 8 0 10 0 11 0 12 0 14 0 20 0 21 0 22 0 23 0 24 0 26 0 30] 
#[0 0 98 0 1 0 2 0 3 0 4 0 5 0 6 0 8 0 10 0 11 0 12 0 14 0 20 0 21 0 22 0 23 0 24 0 26 0 30] 
#[0 0 186 0 1 0 2 0 3 0 4 0 5 0 6 0 8 0 10 0 11 0 12 0 14 0 20 0 21 0 22 0 23 0 24 0 26 0 30] 
#[0 0 186 0 1 0 2 0 3 0 4 0 5 0 6 0 8 0 10 0 11 0 12 0 14 0 20 0 21 0 22 0 23 0 24 0 26 0 30] 
#[0 0 102 0 1 0 2 0 3 0 4 0 5 0 6 0 8 0 10 0 11 0 12 0 14 0 20 0 21 0 22 0 23 0 24 0 26 0 30] 
#[0 0 186 0 1 0 2 0 3 0 4 0 5 0 6 0 8 0 10 0 11 0 12 0 14 0 20 0 21 0 22 0 23 0 24 0 26 0 30] 
#[1 0 10 0 1 0 10 0 4 0 10 0 5 0 10 0 7 0 10 0 8 0 10 0 11 0 10 0 12 0 10 0 14 0 10 0 16 0 10 0 17 0 10 0 20 0 10 0 21 0 10 0 22 0 10 0 23 0 10 0 29 0 10 0 30 4 113 0 32 0 10 0 65] 
#[1 0 66 0 1 0 66 0 2 0 66 0 3 0 66 0 4 0 66 0 5 0 66 0 6 0 66 0 8 0 66 0 10 0 66 0 11 0 66 0 12 0 66 0 14 0 66 0 20 0 66 0 21 0 66 0 22 0 66 0 23 0 66 0 24 0 66 0 26 0 66 0 30 4 117 0 33] 
#[0 0 194 0 65] 
#[1 4 121 0 1 4 125 0 3 4 129 0 4 4 133 0 8 4 137 0 11 4 141 0 12 4 145 0 14 4 149 0 17 4 153 0 20 4 157 0 21 4 161 0 22 4 165 0 23 4 169 0 24 4 173 0 25 4 177 0 26 4 181 0 29 4 185 0 30 4 189 0 31 4 193 0 63 4 193 0 68] 
#[0 4 201 0 2] 
#[0 4 205 0 2] 
#[1 4 209 0 19 4 213 0 21] 
#[1 0 142 0 1 0 142 0 3 0 142 0 4 0 142 0 8 0 142 0 11 0 142 0 12 0 142 0 14 0 142 0 17 0 142 0 20 0 142 0 21 0 142 0 22 0 142 0 23 0 142 0 24 0 142 0 25 0 142 0 26 0 142 0 29 0 142 0 30 0 142 0 31 4 217 0 62] 
#[1 4 221 0 20 4 225 0 29] 
#[1 0 146 0 19 0 146 0 21 4 229 0 61] 
#[0 0 150 0 3 0 20 0 24 0 26] 
#[0 0 154 0 3 0 20 0 24 0 26] 
#[0 0 150 0 3 0 20 0 24 0 26] 
#[0 0 150 0 3 0 20 0 24 0 26] 
#[0 0 150 0 3 0 20 0 24 0 26] 
#[0 4 233 0 3] 
#[0 0 158 0 3 0 20 0 24 0 26] 
#[1 0 18 0 2 3 97 0 5 3 101 0 38 4 237 0 39] 
#[1 4 241 0 9 4 245 0 15 3 213 0 18 4 249 0 19] 
#[0 4 253 0 19] 
#[0 0 198 0 5 0 20 0 24 0 26 0 65] 
#[1 0 166 0 3 5 1 0 6] 
#[0 0 170 0 3 0 6 0 20 0 24 0 26] 
#[1 5 5 0 1 5 9 0 4 5 13 0 8 5 17 0 11 5 21 0 12 5 25 0 14 5 29 0 17 5 33 0 20 5 37 0 21 5 41 0 22 5 45 0 23 5 49 0 29 5 53 0 30 5 61 0 43 5 61 0 47 5 65 0 49 5 69 0 50 5 73 0 55 5 61 0 57 5 81 0 68] 
#[1 5 5 0 1 5 9 0 4 5 13 0 8 5 17 0 11 5 21 0 12 5 25 0 14 5 29 0 17 5 33 0 20 5 37 0 21 5 41 0 22 5 45 0 23 5 49 0 29 5 53 0 30 5 85 0 43 5 85 0 47 5 89 0 50 5 93 0 56 5 85 0 57 5 81 0 68] 
#[0 0 174 0 3 0 6 0 20 0 24 0 26] 
#[0 0 178 0 3 0 6 0 24 0 26] 
#[1 0 182 0 3 0 182 0 6 5 97 0 24] 
#[0 0 178 0 3 0 6 0 24 0 26] 
#[1 0 182 0 3 0 182 0 6 5 97 0 24] 
#[0 0 174 0 3 0 6 0 20 0 24 0 26] 
#[0 0 178 0 3 0 6 0 24 0 26] 
#[1 0 182 0 3 0 182 0 6 5 97 0 24] 
#[1 1 65 0 1 1 69 0 4 1 73 0 8 1 77 0 11 1 81 0 12 1 85 0 14 1 89 0 17 1 93 0 20 1 97 0 21 1 101 0 22 1 105 0 23 1 109 0 29 1 113 0 30 5 101 0 41 1 133 0 43 5 101 0 44 1 129 0 45 1 133 0 47 1 129 0 48 1 141 0 49 1 145 0 50 1 149 0 57 1 153 0 68] 
#[1 0 142 0 1 0 142 0 3 0 142 0 4 0 142 0 8 0 142 0 11 0 142 0 12 0 142 0 14 0 142 0 17 0 142 0 20 0 142 0 21 0 142 0 22 0 142 0 23 0 142 0 24 0 142 0 25 0 142 0 26 0 142 0 29 0 142 0 30 0 142 0 31 5 105 0 62] 
#[1 5 109 0 20 5 113 0 29] 
#[1 0 146 0 19 0 146 0 21 5 117 0 61] 
#[0 0 150 0 2 0 5 0 20 0 24 0 26] 
#[0 0 154 0 2 0 5 0 20 0 24 0 26] 
#[0 0 150 0 2 0 5 0 20 0 24 0 26] 
#[0 0 150 0 2 0 5 0 20 0 24 0 26] 
#[0 0 150 0 2 0 5 0 20 0 24 0 26] 
#[0 5 121 0 3] 
#[0 0 158 0 2 0 5 0 20 0 24 0 26] 
#[1 0 18 0 2 3 97 0 5 3 101 0 38 5 125 0 39] 
#[1 5 129 0 9 5 133 0 15 3 213 0 18 5 137 0 19] 
#[0 5 141 0 19] 
#[1 0 50 0 1 0 50 0 2 0 50 0 4 3 97 0 5 0 50 0 8 0 50 0 11 0 50 0 12 0 50 0 14 0 50 0 17 0 50 0 20 0 50 0 21 0 50 0 22 0 50 0 23 0 50 0 29 0 50 0 30 5 145 0 38] 
#[1 1 157 0 1 0 58 0 2 1 165 0 4 1 169 0 8 1 173 0 11 1 177 0 12 1 181 0 14 1 185 0 17 1 189 0 20 1 193 0 21 1 197 0 22 1 201 0 23 1 205 0 29 1 209 0 30 5 149 0 41 1 233 0 43 5 149 0 44 1 229 0 45 1 233 0 47 1 229 0 48 1 241 0 49 1 245 0 50 1 249 0 57 1 253 0 68] 
#[0 5 153 0 2] 
#[1 0 166 0 2 0 166 0 5 5 157 0 6] 
#[0 0 170 0 2 0 5 0 6 0 20 0 24 0 26] 
#[1 5 161 0 1 5 165 0 4 5 169 0 8 5 173 0 11 5 177 0 12 5 181 0 14 5 185 0 17 5 189 0 20 5 193 0 21 5 197 0 22 5 201 0 23 5 205 0 29 5 209 0 30 5 217 0 43 5 217 0 47 5 221 0 49 5 225 0 50 5 229 0 55 5 217 0 57 5 237 0 68] 
#[1 5 161 0 1 5 165 0 4 5 169 0 8 5 173 0 11 5 177 0 12 5 181 0 14 5 185 0 17 5 189 0 20 5 193 0 21 5 197 0 22 5 201 0 23 5 205 0 29 5 209 0 30 5 241 0 43 5 241 0 47 5 245 0 50 5 249 0 56 5 241 0 57 5 237 0 68] 
#[0 0 174 0 2 0 5 0 6 0 20 0 24 0 26] 
#[0 0 178 0 2 0 5 0 6 0 24 0 26] 
#[1 0 182 0 2 0 182 0 5 0 182 0 6 5 253 0 24] 
#[0 0 178 0 2 0 5 0 6 0 24 0 26] 
#[1 0 182 0 2 0 182 0 5 0 182 0 6 5 253 0 24] 
#[0 0 174 0 2 0 5 0 6 0 20 0 24 0 26] 
#[0 0 178 0 2 0 5 0 6 0 24 0 26] 
#[1 0 182 0 2 0 182 0 5 0 182 0 6 5 253 0 24] 
#[1 1 157 0 1 1 165 0 4 1 169 0 8 1 173 0 11 1 177 0 12 1 181 0 14 1 185 0 17 1 189 0 20 1 193 0 21 1 197 0 22 1 201 0 23 1 205 0 29 1 209 0 30 6 1 0 41 1 233 0 43 6 1 0 44 1 229 0 45 1 233 0 47 1 229 0 48 1 241 0 49 1 245 0 50 1 249 0 57 1 253 0 68] 
#[1 3 161 0 5 6 5 0 38 0 50 0 65] 
#[0 0 58 0 65] 
#[0 0 202 0 65] 
#[1 0 149 0 5 6 9 0 9 0 157 0 38] 
#[0 0 26 0 9 0 15 0 18 0 19] 
#[0 0 26 0 9 0 15 0 18 0 19] 
#[0 0 206 0 9 0 15 0 18 0 19] 
#[1 0 50 0 1 0 50 0 4 3 189 0 5 0 50 0 8 0 50 0 11 0 50 0 12 0 50 0 14 0 50 0 16 0 50 0 17 0 50 0 19 0 50 0 20 0 50 0 21 0 50 0 22 0 50 0 23 0 50 0 29 0 50 0 30 6 13 0 38] 
#[0 0 54 0 19] 
#[0 0 58 0 1 0 4 0 8 0 11 0 12 0 14 0 16 0 17 0 19 0 20 0 21 0 22 0 23 0 29 0 30] 
#[1 6 17 0 1 6 21 0 4 6 25 0 8 6 29 0 11 6 33 0 12 6 37 0 14 6 41 0 16 6 45 0 17 0 62 0 19 6 49 0 20 6 53 0 21 6 57 0 22 6 61 0 23 6 65 0 29 6 69 0 30 6 73 0 40 6 77 0 41 6 93 0 43 6 77 0 44 6 89 0 45 6 93 0 47 6 89 0 48 6 101 0 49 6 105 0 50 6 109 0 57 6 113 0 68] 
#[1 0 6 0 1 0 6 0 4 0 6 0 5 0 6 0 8 2 5 0 9 0 6 0 11 0 6 0 12 0 6 0 14 2 9 0 15 0 6 0 16 0 6 0 17 0 6 0 19 0 6 0 20 0 6 0 21 0 6 0 22 0 6 0 23 0 6 0 29 0 6 0 30 2 17 0 37 6 117 0 60] 
#[1 0 97 0 20 0 101 0 29 6 121 0 35 0 109 0 57] 
#[1 3 177 0 20 3 181 0 29 6 125 0 57] 
#[0 0 210 0 5 0 20 0 24 0 26 0 65] 
#[0 0 214 0 5 0 20 0 24 0 26 0 65] 
#[1 0 165 0 1 0 169 0 4 0 173 0 8 0 177 0 11 0 181 0 12 0 185 0 14 0 193 0 17 0 197 0 20 0 201 0 21 0 205 0 22 0 209 0 23 0 213 0 29 0 217 0 30 6 129 0 41 0 241 0 43 6 129 0 44 0 237 0 45 0 241 0 47 0 237 0 48 0 249 0 49 0 253 0 50 1 1 0 57 1 5 0 68] 
#[0 0 218 0 5 0 65] 
#[1 6 133 0 20 2 45 0 24 6 137 0 26 6 141 0 51 6 141 0 52 6 141 0 53 6 153 0 54] 
#[1 6 157 0 4 6 161 0 8 6 165 0 17 6 169 0 20 6 173 0 23 6 177 0 24 6 181 0 25 6 185 0 26] 
#[1 1 65 0 1 1 69 0 4 1 73 0 8 1 77 0 11 1 81 0 12 1 85 0 14 1 89 0 17 1 93 0 20 1 97 0 21 1 101 0 22 1 105 0 23 1 109 0 29 1 113 0 30 6 189 0 41 1 133 0 43 6 189 0 44 1 129 0 45 1 133 0 47 1 129 0 48 1 141 0 49 1 145 0 50 1 149 0 57 1 153 0 68] 
#[1 1 157 0 1 6 193 0 2 1 165 0 4 1 169 0 8 1 173 0 11 1 177 0 12 1 181 0 14 1 185 0 17 1 189 0 20 1 193 0 21 1 197 0 22 1 201 0 23 1 205 0 29 1 209 0 30 6 197 0 40 1 217 0 41 1 233 0 43 1 217 0 44 1 229 0 45 1 233 0 47 1 229 0 48 1 241 0 49 1 245 0 50 1 249 0 57 1 253 0 68] 
#[0 0 82 0 5 0 6 0 20 0 24 0 26 0 65] 
#[0 0 86 0 5 0 6 0 20 0 24 0 26 0 65] 
#[0 0 90 0 5 0 6 0 20 0 24 0 26 0 65] 
#[1 0 6 0 1 0 6 0 4 0 6 0 5 0 6 0 8 2 5 0 9 0 6 0 11 0 6 0 12 0 6 0 14 2 9 0 15 0 6 0 16 0 6 0 17 2 13 0 18 0 6 0 19 0 6 0 20 0 6 0 21 0 6 0 22 0 6 0 23 0 6 0 29 0 6 0 30 2 17 0 37 6 201 0 42 6 205 0 60] 
#[0 0 26 0 5 0 6 0 20 0 24 0 26 0 65] 
#[0 0 94 0 5 0 6 0 20 0 24 0 26 0 65] 
#[0 0 94 0 5 0 6 0 20 0 24 0 26 0 65] 
#[0 0 98 0 5 0 6 0 20 0 24 0 26 0 65] 
#[0 0 26 0 5 0 6 0 20 0 24 0 26 0 65] 
#[0 0 102 0 5 0 6 0 20 0 24 0 26 0 65] 
#[0 0 110 0 5 0 6 0 20 0 24 0 26 0 65] 
#[1 0 222 0 5 0 222 0 6 2 41 0 20 0 222 0 24 2 49 0 26 2 53 0 52 2 57 0 53 0 222 0 65] 
#[1 0 222 0 5 0 222 0 6 0 222 0 24 2 49 0 26 2 65 0 53 0 222 0 65] 
#[1 0 222 0 5 0 222 0 6 2 41 0 20 0 222 0 24 2 49 0 26 2 73 0 52 2 77 0 53 0 222 0 65] 
#[0 0 226 0 5 0 6 0 24 0 65] 
#[0 0 110 0 5 0 6 0 20 0 24 0 26 0 65] 
#[0 0 130 0 5 0 6 0 20 0 24 0 26 0 65] 
#[1 0 230 0 5 0 230 0 6 2 41 0 20 0 230 0 24 0 230 0 26 2 53 0 52 0 230 0 65] 
#[1 0 230 0 5 0 230 0 6 2 41 0 20 0 230 0 24 0 230 0 26 2 73 0 52 0 230 0 65] 
#[0 0 234 0 5 0 6 0 24 0 26 0 65] 
#[1 3 237 0 1 3 241 0 4 3 245 0 8 3 249 0 11 3 253 0 12 4 1 0 14 4 5 0 17 4 9 0 20 4 13 0 21 4 17 0 22 4 21 0 23 4 25 0 29 4 29 0 30 4 37 0 43 4 37 0 47 4 41 0 49 4 45 0 50 6 209 0 55 4 37 0 57 4 57 0 68] 
#[0 0 238 0 5 0 65] 
#[1 0 142 0 1 0 142 0 3 0 142 0 4 0 142 0 8 0 142 0 11 0 142 0 12 0 142 0 14 0 142 0 17 0 142 0 20 0 142 0 21 0 142 0 22 0 142 0 23 0 142 0 24 0 142 0 25 0 142 0 26 0 142 0 29 0 142 0 30 0 142 0 31 6 213 0 62] 
#[1 6 217 0 20 6 221 0 29] 
#[1 0 146 0 19 0 146 0 21 6 225 0 61] 
#[0 0 150 0 1 0 2 0 3 0 4 0 5 0 6 0 8 0 10 0 11 0 12 0 14 0 20 0 21 0 22 0 23 0 24 0 26 0 30] 
#[0 0 154 0 1 0 2 0 3 0 4 0 5 0 6 0 8 0 10 0 11 0 12 0 14 0 20 0 21 0 22 0 23 0 24 0 26 0 30] 
#[0 0 150 0 1 0 2 0 3 0 4 0 5 0 6 0 8 0 10 0 11 0 12 0 14 0 20 0 21 0 22 0 23 0 24 0 26 0 30] 
#[0 0 150 0 1 0 2 0 3 0 4 0 5 0 6 0 8 0 10 0 11 0 12 0 14 0 20 0 21 0 22 0 23 0 24 0 26 0 30] 
#[0 0 150 0 1 0 2 0 3 0 4 0 5 0 6 0 8 0 10 0 11 0 12 0 14 0 20 0 21 0 22 0 23 0 24 0 26 0 30] 
#[1 0 18 0 1 0 18 0 4 0 113 0 5 2 169 0 7 0 18 0 8 0 18 0 11 0 18 0 12 0 18 0 14 0 18 0 16 0 18 0 17 0 18 0 20 0 18 0 21 0 18 0 22 0 18 0 23 0 18 0 29 0 18 0 30 6 229 0 36 0 121 0 38 0 125 0 39 0 18 0 65] 
#[1 2 89 0 1 2 93 0 2 2 97 0 3 2 101 0 4 2 105 0 5 2 109 0 6 2 113 0 8 6 233 0 10 2 121 0 11 2 125 0 12 2 129 0 14 2 133 0 20 2 137 0 21 2 141 0 22 2 145 0 23 2 149 0 24 2 153 0 26 2 157 0 30 2 161 0 68] 
#[1 6 237 0 4 6 241 0 8 6 245 0 17 6 249 0 20 6 253 0 23 7 1 0 24 7 5 0 25 7 9 0 26] 
#[0 0 242 0 5 0 20 0 24 0 26 0 65] 
#[1 0 142 0 1 0 142 0 3 0 142 0 4 0 142 0 8 0 142 0 11 0 142 0 12 0 142 0 14 0 142 0 17 0 142 0 20 0 142 0 21 0 142 0 22 0 142 0 23 0 142 0 24 0 142 0 25 0 142 0 26 0 142 0 29 0 142 0 30 0 142 0 31 7 13 0 62] 
#[1 7 17 0 20 7 21 0 29] 
#[0 0 82 0 1 0 3 0 4 0 8 0 11 0 12 0 14 0 17 0 20 0 21 0 22 0 23 0 24 0 25 0 26 0 29 0 30 0 31] 
#[0 0 86 0 1 0 3 0 4 0 8 0 11 0 12 0 14 0 17 0 20 0 21 0 22 0 23 0 24 0 25 0 26 0 29 0 30 0 31] 
#[0 0 90 0 1 0 3 0 4 0 8 0 11 0 12 0 14 0 17 0 20 0 21 0 22 0 23 0 24 0 25 0 26 0 29 0 30 0 31] 
#[1 0 146 0 19 0 146 0 21 7 25 0 61] 
#[1 0 246 0 1 0 246 0 3 0 246 0 4 0 246 0 8 0 246 0 11 0 246 0 12 7 29 0 13 0 246 0 14 0 246 0 17 0 246 0 20 0 246 0 21 0 246 0 22 0 246 0 23 0 246 0 24 0 246 0 25 0 246 0 26 0 246 0 29 0 246 0 30 0 246 0 31] 
#[0 0 94 0 1 0 3 0 4 0 8 0 11 0 12 0 14 0 17 0 20 0 21 0 22 0 23 0 24 0 25 0 26 0 29 0 30 0 31] 
#[0 0 94 0 1 0 3 0 4 0 8 0 11 0 12 0 14 0 17 0 20 0 21 0 22 0 23 0 24 0 25 0 26 0 29 0 30 0 31] 
#[0 0 98 0 1 0 3 0 4 0 8 0 11 0 12 0 14 0 17 0 20 0 21 0 22 0 23 0 24 0 25 0 26 0 29 0 30 0 31] 
#[0 0 246 0 1 0 3 0 4 0 8 0 11 0 12 0 14 0 17 0 20 0 21 0 22 0 23 0 24 0 25 0 26 0 29 0 30 0 31] 
#[0 0 246 0 1 0 3 0 4 0 8 0 11 0 12 0 14 0 17 0 20 0 21 0 22 0 23 0 24 0 25 0 26 0 29 0 30 0 31] 
#[0 0 246 0 1 0 3 0 4 0 8 0 11 0 12 0 14 0 17 0 20 0 21 0 22 0 23 0 24 0 25 0 26 0 29 0 30 0 31] 
#[0 0 250 0 1 0 3 0 4 0 8 0 11 0 12 0 14 0 17 0 20 0 21 0 22 0 23 0 24 0 25 0 26 0 29 0 30 0 31] 
#[0 0 102 0 1 0 3 0 4 0 8 0 11 0 12 0 14 0 17 0 20 0 21 0 22 0 23 0 24 0 25 0 26 0 29 0 30 0 31] 
#[0 0 246 0 1 0 3 0 4 0 8 0 11 0 12 0 14 0 17 0 20 0 21 0 22 0 23 0 24 0 25 0 26 0 29 0 30 0 31] 
#[0 0 254 0 1 0 3 0 4 0 8 0 11 0 12 0 14 0 17 0 20 0 21 0 22 0 23 0 24 0 25 0 26 0 29 0 30 0 31] 
#[0 1 2 0 1 0 3 0 4 0 8 0 11 0 12 0 14 0 17 0 20 0 21 0 22 0 23 0 24 0 25 0 26 0 29 0 30 0 31] 
#[0 1 6 0 5 0 20 0 24 0 26 0 65] 
#[0 1 6 0 5 0 20 0 24 0 26 0 65] 
#[0 0 242 0 5 0 20 0 24 0 26 0 65] 
#[0 1 10 0 19 0 21] 
#[1 4 121 0 1 7 33 0 3 4 129 0 4 4 133 0 8 4 137 0 11 4 141 0 12 4 145 0 14 4 149 0 17 4 153 0 20 4 157 0 21 4 161 0 22 4 165 0 23 4 169 0 24 4 173 0 25 4 177 0 26 4 181 0 29 4 185 0 30 4 189 0 31 4 193 0 63 4 193 0 68] 
#[0 7 37 0 2] 
#[0 7 41 0 2] 
#[1 7 45 0 19 4 213 0 21] 
#[0 0 198 0 3 0 20 0 24 0 26] 
#[0 7 49 0 2] 
#[1 0 6 0 1 0 6 0 4 0 6 0 5 0 6 0 8 2 5 0 9 0 6 0 11 0 6 0 12 0 6 0 14 2 9 0 15 0 6 0 16 0 6 0 17 0 6 0 19 0 6 0 20 0 6 0 21 0 6 0 22 0 6 0 23 0 6 0 29 0 6 0 30 2 17 0 37 7 53 0 60] 
#[1 0 97 0 20 0 101 0 29 7 57 0 35 0 109 0 57] 
#[0 0 210 0 3 0 20 0 24 0 26] 
#[0 0 214 0 3 0 20 0 24 0 26] 
#[1 7 61 0 20 3 1 0 24 7 65 0 26 7 69 0 51 7 69 0 52 7 69 0 53 7 81 0 54] 
#[1 7 85 0 4 7 89 0 8 7 93 0 17 7 97 0 20 7 101 0 23 7 105 0 24 7 109 0 25 7 113 0 26] 
#[1 1 65 0 1 1 69 0 4 1 73 0 8 1 77 0 11 1 81 0 12 1 85 0 14 1 89 0 17 1 93 0 20 1 97 0 21 1 101 0 22 1 105 0 23 1 109 0 29 1 113 0 30 7 117 0 41 1 133 0 43 7 117 0 44 1 129 0 45 1 133 0 47 1 129 0 48 1 141 0 49 1 145 0 50 1 149 0 57 1 153 0 68] 
#[1 1 157 0 1 7 121 0 2 1 165 0 4 1 169 0 8 1 173 0 11 1 177 0 12 1 181 0 14 1 185 0 17 1 189 0 20 1 193 0 21 1 197 0 22 1 201 0 23 1 205 0 29 1 209 0 30 7 125 0 40 1 217 0 41 1 233 0 43 1 217 0 44 1 229 0 45 1 233 0 47 1 229 0 48 1 241 0 49 1 245 0 50 1 249 0 57 1 253 0 68] 
#[0 0 82 0 3 0 6 0 20 0 24 0 26] 
#[0 0 86 0 3 0 6 0 20 0 24 0 26] 
#[0 0 90 0 3 0 6 0 20 0 24 0 26] 
#[1 0 6 0 1 0 6 0 4 0 6 0 5 0 6 0 8 2 5 0 9 0 6 0 11 0 6 0 12 0 6 0 14 2 9 0 15 0 6 0 16 0 6 0 17 2 13 0 18 0 6 0 19 0 6 0 20 0 6 0 21 0 6 0 22 0 6 0 23 0 6 0 29 0 6 0 30 2 17 0 37 7 129 0 42 7 133 0 60] 
#[0 0 26 0 3 0 6 0 20 0 24 0 26] 
#[0 0 94 0 3 0 6 0 20 0 24 0 26] 
#[0 0 94 0 3 0 6 0 20 0 24 0 26] 
#[0 0 98 0 3 0 6 0 20 0 24 0 26] 
#[0 0 26 0 3 0 6 0 20 0 24 0 26] 
#[0 0 102 0 3 0 6 0 20 0 24 0 26] 
#[0 0 110 0 3 0 6 0 20 0 24 0 26] 
#[1 0 222 0 3 0 222 0 6 2 253 0 20 0 222 0 24 3 5 0 26 3 9 0 52 3 13 0 53] 
#[1 0 222 0 3 0 222 0 6 0 222 0 24 3 5 0 26 3 21 0 53] 
#[1 0 222 0 3 0 222 0 6 2 253 0 20 0 222 0 24 3 5 0 26 3 29 0 52 3 33 0 53] 
#[0 0 226 0 3 0 6 0 24] 
#[0 0 110 0 3 0 6 0 20 0 24 0 26] 
#[0 0 130 0 3 0 6 0 20 0 24 0 26] 
#[1 0 230 0 3 0 230 0 6 2 253 0 20 0 230 0 24 0 230 0 26 3 9 0 52] 
#[1 0 230 0 3 0 230 0 6 2 253 0 20 0 230 0 24 0 230 0 26 3 29 0 52] 
#[0 0 234 0 3 0 6 0 24 0 26] 
#[1 5 5 0 1 5 9 0 4 5 13 0 8 5 17 0 11 5 21 0 12 5 25 0 14 5 29 0 17 5 33 0 20 5 37 0 21 5 41 0 22 5 45 0 23 5 49 0 29 5 53 0 30 5 61 0 43 5 61 0 47 5 65 0 49 5 69 0 50 7 137 0 55 5 61 0 57 5 81 0 68] 
#[0 0 238 0 3] 
#[1 4 121 0 1 7 141 0 3 4 129 0 4 4 133 0 8 4 137 0 11 4 141 0 12 4 145 0 14 4 149 0 17 4 153 0 20 4 157 0 21 4 161 0 22 4 165 0 23 4 169 0 24 4 173 0 25 4 177 0 26 4 181 0 29 4 185 0 30 4 189 0 31 4 193 0 63 4 193 0 68] 
#[0 7 145 0 2] 
#[0 7 149 0 2] 
#[1 7 153 0 19 4 213 0 21] 
#[0 0 198 0 2 0 5 0 20 0 24 0 26] 
#[0 7 157 0 2] 
#[1 0 6 0 1 0 6 0 4 0 6 0 5 0 6 0 8 2 5 0 9 0 6 0 11 0 6 0 12 0 6 0 14 2 9 0 15 0 6 0 16 0 6 0 17 0 6 0 19 0 6 0 20 0 6 0 21 0 6 0 22 0 6 0 23 0 6 0 29 0 6 0 30 2 17 0 37 7 161 0 60] 
#[1 0 97 0 20 0 101 0 29 7 165 0 35 0 109 0 57] 
#[0 0 210 0 2 0 5 0 20 0 24 0 26] 
#[0 0 214 0 2 0 5 0 20 0 24 0 26] 
#[0 0 78 0 1 0 2 0 4 0 8 0 11 0 12 0 14 0 17 0 20 0 21 0 22 0 23 0 29 0 30] 
#[0 0 218 0 2 0 5] 
#[0 1 14 0 5 0 20 0 24 0 26 0 65] 
#[1 7 169 0 20 3 117 0 24 7 173 0 26 7 177 0 51 7 177 0 52 7 177 0 53 7 189 0 54] 
#[1 7 193 0 4 7 197 0 8 7 201 0 17 7 205 0 20 7 209 0 23 7 213 0 24 7 217 0 25 7 221 0 26] 
#[1 1 65 0 1 1 69 0 4 1 73 0 8 1 77 0 11 1 81 0 12 1 85 0 14 1 89 0 17 1 93 0 20 1 97 0 21 1 101 0 22 1 105 0 23 1 109 0 29 1 113 0 30 7 225 0 41 1 133 0 43 7 225 0 44 1 129 0 45 1 133 0 47 1 129 0 48 1 141 0 49 1 145 0 50 1 149 0 57 1 153 0 68] 
#[1 1 157 0 1 7 229 0 2 1 165 0 4 1 169 0 8 1 173 0 11 1 177 0 12 1 181 0 14 1 185 0 17 1 189 0 20 1 193 0 21 1 197 0 22 1 201 0 23 1 205 0 29 1 209 0 30 7 233 0 40 1 217 0 41 1 233 0 43 1 217 0 44 1 229 0 45 1 233 0 47 1 229 0 48 1 241 0 49 1 245 0 50 1 249 0 57 1 253 0 68] 
#[0 0 82 0 2 0 5 0 6 0 20 0 24 0 26] 
#[0 0 86 0 2 0 5 0 6 0 20 0 24 0 26] 
#[0 0 90 0 2 0 5 0 6 0 20 0 24 0 26] 
#[1 0 6 0 1 0 6 0 4 0 6 0 5 0 6 0 8 2 5 0 9 0 6 0 11 0 6 0 12 0 6 0 14 2 9 0 15 0 6 0 16 0 6 0 17 2 13 0 18 0 6 0 19 0 6 0 20 0 6 0 21 0 6 0 22 0 6 0 23 0 6 0 29 0 6 0 30 2 17 0 37 7 237 0 42 7 241 0 60] 
#[0 0 26 0 2 0 5 0 6 0 20 0 24 0 26] 
#[0 0 94 0 2 0 5 0 6 0 20 0 24 0 26] 
#[0 0 94 0 2 0 5 0 6 0 20 0 24 0 26] 
#[0 0 98 0 2 0 5 0 6 0 20 0 24 0 26] 
#[0 0 26 0 2 0 5 0 6 0 20 0 24 0 26] 
#[0 0 102 0 2 0 5 0 6 0 20 0 24 0 26] 
#[0 0 110 0 2 0 5 0 6 0 20 0 24 0 26] 
#[1 0 222 0 2 0 222 0 5 0 222 0 6 3 113 0 20 0 222 0 24 3 121 0 26 3 125 0 52 3 129 0 53] 
#[1 0 222 0 2 0 222 0 5 0 222 0 6 0 222 0 24 3 121 0 26 3 137 0 53] 
#[1 0 222 0 2 0 222 0 5 0 222 0 6 3 113 0 20 0 222 0 24 3 121 0 26 3 145 0 52 3 149 0 53] 
#[0 0 226 0 2 0 5 0 6 0 24] 
#[0 0 110 0 2 0 5 0 6 0 20 0 24 0 26] 
#[0 0 130 0 2 0 5 0 6 0 20 0 24 0 26] 
#[1 0 230 0 2 0 230 0 5 0 230 0 6 3 113 0 20 0 230 0 24 0 230 0 26 3 125 0 52] 
#[1 0 230 0 2 0 230 0 5 0 230 0 6 3 113 0 20 0 230 0 24 0 230 0 26 3 145 0 52] 
#[0 0 234 0 2 0 5 0 6 0 24 0 26] 
#[1 5 161 0 1 5 165 0 4 5 169 0 8 5 173 0 11 5 177 0 12 5 181 0 14 5 185 0 17 5 189 0 20 5 193 0 21 5 197 0 22 5 201 0 23 5 205 0 29 5 209 0 30 5 217 0 43 5 217 0 47 5 221 0 49 5 225 0 50 7 245 0 55 5 217 0 57 5 237 0 68] 
#[0 0 238 0 2 0 5] 
#[0 0 78 0 65] 
#[0 0 74 0 1 0 4 0 5 0 8 0 11 0 12 0 14 0 16 0 17 0 19 0 20 0 21 0 22 0 23 0 29 0 30] 
#[0 0 78 0 1 0 4 0 8 0 11 0 12 0 14 0 16 0 17 0 19 0 20 0 21 0 22 0 23 0 29 0 30] 
#[1 7 249 0 4 7 253 0 8 8 1 0 17 8 5 0 20 8 9 0 23 8 13 0 24 8 17 0 25 8 21 0 26] 
#[1 1 65 0 1 1 69 0 4 1 73 0 8 1 77 0 11 1 81 0 12 1 85 0 14 1 89 0 17 1 93 0 20 1 97 0 21 1 101 0 22 1 105 0 23 1 109 0 29 1 113 0 30 8 25 0 41 1 133 0 43 8 25 0 44 1 129 0 45 1 133 0 47 1 129 0 48 1 141 0 49 1 145 0 50 1 149 0 57 1 153 0 68] 
#[1 1 157 0 1 8 29 0 2 1 165 0 4 1 169 0 8 1 173 0 11 1 177 0 12 1 181 0 14 1 185 0 17 1 189 0 20 1 193 0 21 1 197 0 22 1 201 0 23 1 205 0 29 1 209 0 30 8 33 0 40 1 217 0 41 1 233 0 43 1 217 0 44 1 229 0 45 1 233 0 47 1 229 0 48 1 241 0 49 1 245 0 50 1 249 0 57 1 253 0 68] 
#[0 0 82 0 5 0 19 0 20 0 24 0 26] 
#[0 0 86 0 5 0 19 0 20 0 24 0 26] 
#[0 0 90 0 5 0 19 0 20 0 24 0 26] 
#[1 6 17 0 1 6 21 0 4 6 25 0 8 6 29 0 11 6 33 0 12 6 37 0 14 6 45 0 17 6 49 0 20 6 53 0 21 6 57 0 22 6 61 0 23 6 65 0 29 6 69 0 30 8 37 0 41 6 93 0 43 8 37 0 44 6 89 0 45 6 93 0 47 6 89 0 48 6 101 0 49 6 105 0 50 6 109 0 57 6 113 0 68] 
#[1 0 6 0 1 0 6 0 4 0 6 0 5 0 6 0 8 2 5 0 9 0 6 0 11 0 6 0 12 0 6 0 14 2 9 0 15 0 6 0 16 0 6 0 17 2 13 0 18 0 6 0 19 0 6 0 20 0 6 0 21 0 6 0 22 0 6 0 23 0 6 0 29 0 6 0 30 2 17 0 37 8 41 0 42 8 45 0 60] 
#[0 0 26 0 5 0 13 0 19 0 20 0 24 0 26] 
#[0 0 94 0 5 0 19 0 20 0 24 0 26] 
#[0 0 94 0 5 0 19 0 20 0 24 0 26] 
#[0 0 98 0 5 0 19 0 20 0 24 0 26] 
#[0 0 26 0 5 0 13 0 19 0 20 0 24 0 26] 
#[0 0 102 0 5 0 19 0 20 0 24 0 26] 
#[1 3 189 0 5 0 18 0 19 8 49 0 38 8 53 0 39] 
#[0 0 106 0 5 0 19] 
#[0 0 110 0 5 0 19 0 20 0 24 0 26] 
#[0 0 114 0 5 0 19] 
#[1 0 118 0 5 0 118 0 6 0 118 0 19 8 57 0 64] 
#[1 0 122 0 5 0 122 0 19 8 61 0 20 8 65 0 24 8 69 0 26 8 73 0 52 8 77 0 53 8 81 0 54] 
#[0 0 126 0 5 0 6 0 19] 
#[1 0 126 0 5 0 126 0 6 0 126 0 19 8 65 0 24 8 69 0 26 8 85 0 53 8 89 0 54] 
#[1 0 126 0 5 0 126 0 6 0 126 0 19 8 61 0 20 8 65 0 24 8 69 0 26 8 93 0 52 8 97 0 53 8 101 0 54] 
#[1 0 110 0 5 8 105 0 13 0 110 0 19 0 110 0 20 0 110 0 24 0 110 0 26] 
#[0 0 130 0 5 0 19 0 20 0 24 0 26] 
#[0 8 109 0 19] 
#[1 0 149 0 5 8 113 0 9 0 157 0 38] 
#[0 1 18 0 9 0 15 0 18 0 19] 
#[1 3 161 0 5 3 165 0 38 8 117 0 39 0 18 0 65] 
#[0 0 170 0 5 0 6 0 65] 
#[1 8 121 0 1 8 125 0 4 8 129 0 8 8 133 0 11 8 137 0 12 8 141 0 14 8 145 0 17 8 149 0 20 8 153 0 21 8 157 0 22 8 161 0 23 8 165 0 29 8 169 0 30 8 177 0 43 8 177 0 47 8 181 0 50 8 185 0 56 8 177 0 57 8 193 0 68] 
#[0 1 22 0 5 0 6 0 65] 
#[0 1 26 0 5 0 6 0 65] 
#[0 1 26 0 5 0 6 0 65] 
#[1 1 26 0 5 1 26 0 6 4 73 0 24 1 26 0 65] 
#[1 0 142 0 1 0 142 0 3 0 142 0 4 0 142 0 8 0 142 0 11 0 142 0 12 0 142 0 14 0 142 0 17 0 142 0 20 0 142 0 21 0 142 0 22 0 142 0 23 0 142 0 24 0 142 0 25 0 142 0 26 0 142 0 29 0 142 0 30 0 142 0 31 8 197 0 62] 
#[1 8 201 0 20 8 205 0 29] 
#[1 0 146 0 19 0 146 0 21 8 209 0 61] 
#[0 0 150 0 5 0 6 0 20 0 24 0 26 0 65] 
#[0 0 154 0 5 0 6 0 20 0 24 0 26 0 65] 
#[0 0 150 0 5 0 6 0 20 0 24 0 26 0 65] 
#[0 0 150 0 5 0 6 0 20 0 24 0 26 0 65] 
#[0 0 150 0 5 0 6 0 20 0 24 0 26 0 65] 
#[0 8 213 0 3] 
#[0 0 158 0 5 0 6 0 20 0 24 0 26 0 65] 
#[1 0 18 0 2 3 97 0 5 3 101 0 38 8 217 0 39] 
#[1 8 221 0 9 8 225 0 15 3 213 0 18 8 229 0 19] 
#[0 8 233 0 19] 
#[0 1 30 0 5 0 6 0 24 0 65] 
#[1 4 121 0 1 8 237 0 3 4 129 0 4 4 133 0 8 4 137 0 11 4 141 0 12 4 145 0 14 4 149 0 17 4 153 0 20 4 157 0 21 4 161 0 22 4 165 0 23 4 169 0 24 4 173 0 25 4 177 0 26 4 181 0 29 4 185 0 30 4 189 0 31 4 193 0 63 4 193 0 68] 
#[0 8 241 0 2] 
#[0 8 245 0 2] 
#[1 8 249 0 19 4 213 0 21] 
#[0 1 34 0 65] 
#[0 0 190 0 1 0 4 0 5 0 7 0 8 0 11 0 12 0 14 0 16 0 17 0 20 0 21 0 22 0 23 0 29 0 30 0 65] 
#[1 0 142 0 1 0 142 0 3 0 142 0 4 0 142 0 8 0 142 0 11 0 142 0 12 0 142 0 14 0 142 0 17 0 142 0 20 0 142 0 21 0 142 0 22 0 142 0 23 0 142 0 24 0 142 0 25 0 142 0 26 0 142 0 29 0 142 0 30 0 142 0 31 8 253 0 62] 
#[1 9 1 0 20 9 5 0 29] 
#[1 0 146 0 19 0 146 0 21 9 9 0 61] 
#[0 0 150 0 1 0 3 0 4 0 8 0 11 0 12 0 14 0 17 0 20 0 21 0 22 0 23 0 24 0 25 0 26 0 29 0 30 0 31] 
#[0 0 154 0 1 0 3 0 4 0 8 0 11 0 12 0 14 0 17 0 20 0 21 0 22 0 23 0 24 0 25 0 26 0 29 0 30 0 31] 
#[0 0 150 0 1 0 3 0 4 0 8 0 11 0 12 0 14 0 17 0 20 0 21 0 22 0 23 0 24 0 25 0 26 0 29 0 30 0 31] 
#[0 0 150 0 1 0 3 0 4 0 8 0 11 0 12 0 14 0 17 0 20 0 21 0 22 0 23 0 24 0 25 0 26 0 29 0 30 0 31] 
#[0 0 150 0 1 0 3 0 4 0 8 0 11 0 12 0 14 0 17 0 20 0 21 0 22 0 23 0 24 0 25 0 26 0 29 0 30 0 31] 
#[1 4 121 0 1 9 13 0 3 4 129 0 4 4 133 0 8 4 137 0 11 4 141 0 12 4 145 0 14 4 149 0 17 4 153 0 20 4 157 0 21 4 161 0 22 4 165 0 23 4 169 0 24 4 173 0 25 4 177 0 26 4 181 0 29 4 185 0 30 4 189 0 31 4 193 0 63 4 193 0 68] 
#[0 9 17 0 2] 
#[0 9 21 0 2] 
#[1 9 25 0 19 4 213 0 21] 
#[0 1 38 0 1 0 3 0 4 0 8 0 11 0 12 0 14 0 17 0 20 0 21 0 22 0 23 0 24 0 25 0 26 0 29 0 30 0 31] 
#[0 0 242 0 3 0 20 0 24 0 26] 
#[0 1 6 0 3 0 20 0 24 0 26] 
#[0 1 6 0 3 0 20 0 24 0 26] 
#[0 0 242 0 3 0 20 0 24 0 26] 
#[0 1 14 0 3 0 20 0 24 0 26] 
#[0 9 29 0 19] 
#[1 0 149 0 5 9 33 0 9 0 157 0 38] 
#[0 0 170 0 3 0 6] 
#[1 9 37 0 1 9 41 0 4 9 45 0 8 9 49 0 11 9 53 0 12 9 57 0 14 9 61 0 17 9 65 0 20 9 69 0 21 9 73 0 22 9 77 0 23 9 81 0 29 9 85 0 30 9 93 0 43 9 93 0 47 9 97 0 50 9 101 0 56 9 93 0 57 9 109 0 68] 
#[0 1 22 0 3 0 6] 
#[0 1 26 0 3 0 6] 
#[0 1 26 0 3 0 6] 
#[1 1 26 0 3 1 26 0 6 5 97 0 24] 
#[1 0 142 0 1 0 142 0 3 0 142 0 4 0 142 0 8 0 142 0 11 0 142 0 12 0 142 0 14 0 142 0 17 0 142 0 20 0 142 0 21 0 142 0 22 0 142 0 23 0 142 0 24 0 142 0 25 0 142 0 26 0 142 0 29 0 142 0 30 0 142 0 31 9 113 0 62] 
#[1 9 117 0 20 9 121 0 29] 
#[1 0 146 0 19 0 146 0 21 9 125 0 61] 
#[0 0 150 0 3 0 6 0 20 0 24 0 26] 
#[0 0 154 0 3 0 6 0 20 0 24 0 26] 
#[0 0 150 0 3 0 6 0 20 0 24 0 26] 
#[0 0 150 0 3 0 6 0 20 0 24 0 26] 
#[0 0 150 0 3 0 6 0 20 0 24 0 26] 
#[0 9 129 0 3] 
#[0 0 158 0 3 0 6 0 20 0 24 0 26] 
#[1 0 18 0 2 3 97 0 5 3 101 0 38 9 133 0 39] 
#[1 9 137 0 9 9 141 0 15 3 213 0 18 9 145 0 19] 
#[0 9 149 0 19] 
#[0 1 30 0 3 0 6 0 24] 
#[0 0 242 0 2 0 5 0 20 0 24 0 26] 
#[0 1 6 0 2 0 5 0 20 0 24 0 26] 
#[0 1 6 0 2 0 5 0 20 0 24 0 26] 
#[0 0 242 0 2 0 5 0 20 0 24 0 26] 
#[0 1 14 0 2 0 5 0 20 0 24 0 26] 
#[0 9 153 0 19] 
#[1 0 149 0 5 9 157 0 9 0 157 0 38] 
#[0 0 170 0 2 0 5 0 6] 
#[1 9 161 0 1 9 165 0 4 9 169 0 8 9 173 0 11 9 177 0 12 9 181 0 14 9 185 0 17 9 189 0 20 9 193 0 21 9 197 0 22 9 201 0 23 9 205 0 29 9 209 0 30 9 217 0 43 9 217 0 47 9 221 0 50 9 225 0 56 9 217 0 57 9 233 0 68] 
#[0 1 22 0 2 0 5 0 6] 
#[0 1 26 0 2 0 5 0 6] 
#[0 1 26 0 2 0 5 0 6] 
#[1 1 26 0 2 1 26 0 5 1 26 0 6 5 253 0 24] 
#[1 0 142 0 1 0 142 0 3 0 142 0 4 0 142 0 8 0 142 0 11 0 142 0 12 0 142 0 14 0 142 0 17 0 142 0 20 0 142 0 21 0 142 0 22 0 142 0 23 0 142 0 24 0 142 0 25 0 142 0 26 0 142 0 29 0 142 0 30 0 142 0 31 9 237 0 62] 
#[1 9 241 0 20 9 245 0 29] 
#[1 0 146 0 19 0 146 0 21 9 249 0 61] 
#[0 0 150 0 2 0 5 0 6 0 20 0 24 0 26] 
#[0 0 154 0 2 0 5 0 6 0 20 0 24 0 26] 
#[0 0 150 0 2 0 5 0 6 0 20 0 24 0 26] 
#[0 0 150 0 2 0 5 0 6 0 20 0 24 0 26] 
#[0 0 150 0 2 0 5 0 6 0 20 0 24 0 26] 
#[0 9 253 0 3] 
#[0 0 158 0 2 0 5 0 6 0 20 0 24 0 26] 
#[1 0 18 0 2 3 97 0 5 3 101 0 38 10 1 0 39] 
#[1 10 5 0 9 10 9 0 15 3 213 0 18 10 13 0 19] 
#[0 10 17 0 19] 
#[0 1 30 0 2 0 5 0 6 0 24] 
#[1 0 142 0 1 0 142 0 3 0 142 0 4 0 142 0 8 0 142 0 11 0 142 0 12 0 142 0 14 0 142 0 17 0 142 0 20 0 142 0 21 0 142 0 22 0 142 0 23 0 142 0 24 0 142 0 25 0 142 0 26 0 142 0 29 0 142 0 30 0 142 0 31 10 21 0 62] 
#[1 10 25 0 20 10 29 0 29] 
#[1 0 146 0 19 0 146 0 21 10 33 0 61] 
#[0 0 150 0 5 0 19 0 20 0 24 0 26] 
#[0 0 154 0 5 0 19 0 20 0 24 0 26] 
#[0 0 150 0 5 0 19 0 20 0 24 0 26] 
#[0 0 150 0 5 0 19 0 20 0 24 0 26] 
#[0 0 150 0 5 0 19 0 20 0 24 0 26] 
#[0 10 37 0 3] 
#[0 0 158 0 5 0 19 0 20 0 24 0 26] 
#[1 0 18 0 2 3 97 0 5 3 101 0 38 10 41 0 39] 
#[1 10 45 0 5 0 18 0 19 10 49 0 38 10 53 0 39] 
#[1 10 57 0 9 10 61 0 15 3 213 0 18 10 65 0 19] 
#[0 10 69 0 19] 
#[1 6 17 0 1 6 21 0 4 6 25 0 8 6 29 0 11 6 33 0 12 6 37 0 14 10 73 0 16 6 45 0 17 0 58 0 19 6 49 0 20 6 53 0 21 6 57 0 22 6 61 0 23 6 65 0 29 6 69 0 30 10 77 0 41 6 93 0 43 10 77 0 44 6 89 0 45 6 93 0 47 6 89 0 48 6 101 0 49 6 105 0 50 6 109 0 57 6 113 0 68] 
#[0 0 162 0 19] 
#[1 0 166 0 5 10 81 0 6 0 166 0 19] 
#[0 0 170 0 5 0 6 0 19 0 20 0 24 0 26] 
#[1 10 85 0 1 10 89 0 4 10 93 0 8 10 97 0 11 10 101 0 12 10 105 0 14 10 109 0 17 10 113 0 20 10 117 0 21 10 121 0 22 10 125 0 23 10 129 0 29 10 133 0 30 10 141 0 43 10 141 0 47 10 145 0 49 10 149 0 50 10 153 0 55 10 141 0 57 10 161 0 68] 
#[1 10 85 0 1 10 89 0 4 10 93 0 8 10 97 0 11 10 101 0 12 10 105 0 14 10 109 0 17 10 113 0 20 10 117 0 21 10 121 0 22 10 125 0 23 10 129 0 29 10 133 0 30 10 165 0 43 10 165 0 47 10 169 0 50 10 173 0 56 10 165 0 57 10 161 0 68] 
#[0 0 174 0 5 0 6 0 19 0 20 0 24 0 26] 
#[0 0 178 0 5 0 6 0 19 0 24 0 26] 
#[1 0 182 0 5 0 182 0 6 0 182 0 19 10 177 0 24] 
#[0 0 178 0 5 0 6 0 19 0 24 0 26] 
#[1 0 182 0 5 0 182 0 6 0 182 0 19 10 177 0 24] 
#[0 0 174 0 5 0 6 0 19 0 20 0 24 0 26] 
#[0 0 178 0 5 0 6 0 19 0 24 0 26] 
#[1 0 182 0 5 0 182 0 6 0 182 0 19 10 177 0 24] 
#[1 6 17 0 1 6 21 0 4 6 25 0 8 6 29 0 11 6 33 0 12 6 37 0 14 6 45 0 17 6 49 0 20 6 53 0 21 6 57 0 22 6 61 0 23 6 65 0 29 6 69 0 30 10 181 0 41 6 93 0 43 10 181 0 44 6 89 0 45 6 93 0 47 6 89 0 48 6 101 0 49 6 105 0 50 6 109 0 57 6 113 0 68] 
#[0 1 42 0 5 0 20 0 24 0 26 0 65] 
#[1 0 18 0 1 0 18 0 4 3 189 0 5 0 18 0 8 0 18 0 11 0 18 0 12 0 18 0 14 0 18 0 16 0 18 0 17 0 18 0 19 0 18 0 20 0 18 0 21 0 18 0 22 0 18 0 23 0 18 0 29 0 18 0 30 10 185 0 36 3 197 0 38 3 201 0 39] 
#[0 1 46 0 65] 
#[1 10 189 0 4 10 193 0 8 10 197 0 17 10 201 0 20 10 205 0 23 10 209 0 24 10 213 0 25 10 217 0 26] 
#[1 1 65 0 1 1 69 0 4 1 73 0 8 1 77 0 11 1 81 0 12 1 85 0 14 1 89 0 17 1 93 0 20 1 97 0 21 1 101 0 22 1 105 0 23 1 109 0 29 1 113 0 30 10 221 0 41 1 133 0 43 10 221 0 44 1 129 0 45 1 133 0 47 1 129 0 48 1 141 0 49 1 145 0 50 1 149 0 57 1 153 0 68] 
#[1 1 157 0 1 10 225 0 2 1 165 0 4 1 169 0 8 1 173 0 11 1 177 0 12 1 181 0 14 1 185 0 17 1 189 0 20 1 193 0 21 1 197 0 22 1 201 0 23 1 205 0 29 1 209 0 30 10 229 0 40 1 217 0 41 1 233 0 43 1 217 0 44 1 229 0 45 1 233 0 47 1 229 0 48 1 241 0 49 1 245 0 50 1 249 0 57 1 253 0 68] 
#[0 0 82 0 5 0 6 0 20 0 65] 
#[0 0 86 0 5 0 6 0 20 0 65] 
#[0 0 90 0 5 0 6 0 20 0 65] 
#[1 0 6 0 1 0 6 0 4 0 6 0 5 0 6 0 8 2 5 0 9 0 6 0 11 0 6 0 12 0 6 0 14 2 9 0 15 0 6 0 16 0 6 0 17 2 13 0 18 0 6 0 19 0 6 0 20 0 6 0 21 0 6 0 22 0 6 0 23 0 6 0 29 0 6 0 30 2 17 0 37 10 233 0 42 10 237 0 60] 
#[0 0 26 0 5 0 6 0 20 0 65] 
#[0 0 94 0 5 0 6 0 20 0 65] 
#[0 0 94 0 5 0 6 0 20 0 65] 
#[0 0 98 0 5 0 6 0 20 0 65] 
#[0 0 26 0 5 0 6 0 20 0 65] 
#[0 0 102 0 5 0 6 0 20 0 65] 
#[0 0 110 0 5 0 6 0 20 0 65] 
#[1 0 230 0 5 0 230 0 6 10 241 0 20 10 245 0 52 0 230 0 65] 
#[1 0 230 0 5 0 230 0 6 10 241 0 20 10 249 0 52 0 230 0 65] 
#[0 0 234 0 5 0 6 0 65] 
#[0 0 110 0 5 0 6 0 20 0 65] 
#[0 0 130 0 5 0 6 0 20 0 65] 
#[1 4 121 0 1 10 253 0 3 4 129 0 4 4 133 0 8 4 137 0 11 4 141 0 12 4 145 0 14 4 149 0 17 4 153 0 20 4 157 0 21 4 161 0 22 4 165 0 23 4 169 0 24 4 173 0 25 4 177 0 26 4 181 0 29 4 185 0 30 4 189 0 31 4 193 0 63 4 193 0 68] 
#[0 11 1 0 2] 
#[0 11 5 0 2] 
#[1 11 9 0 19 4 213 0 21] 
#[0 0 198 0 5 0 6 0 20 0 24 0 26 0 65] 
#[0 11 13 0 2] 
#[1 0 6 0 1 0 6 0 4 0 6 0 5 0 6 0 8 2 5 0 9 0 6 0 11 0 6 0 12 0 6 0 14 2 9 0 15 0 6 0 16 0 6 0 17 0 6 0 19 0 6 0 20 0 6 0 21 0 6 0 22 0 6 0 23 0 6 0 29 0 6 0 30 2 17 0 37 11 17 0 60] 
#[1 0 97 0 20 0 101 0 29 11 21 0 35 0 109 0 57] 
#[0 0 210 0 5 0 6 0 20 0 24 0 26 0 65] 
#[0 0 214 0 5 0 6 0 20 0 24 0 26 0 65] 
#[0 0 242 0 1 0 2 0 3 0 4 0 5 0 6 0 8 0 10 0 11 0 12 0 14 0 20 0 21 0 22 0 23 0 24 0 26 0 30] 
#[0 1 6 0 1 0 2 0 3 0 4 0 5 0 6 0 8 0 10 0 11 0 12 0 14 0 20 0 21 0 22 0 23 0 24 0 26 0 30] 
#[0 1 6 0 1 0 2 0 3 0 4 0 5 0 6 0 8 0 10 0 11 0 12 0 14 0 20 0 21 0 22 0 23 0 24 0 26 0 30] 
#[0 0 242 0 1 0 2 0 3 0 4 0 5 0 6 0 8 0 10 0 11 0 12 0 14 0 20 0 21 0 22 0 23 0 24 0 26 0 30] 
#[1 4 121 0 1 11 25 0 3 4 129 0 4 4 133 0 8 4 137 0 11 4 141 0 12 4 145 0 14 4 149 0 17 4 153 0 20 4 157 0 21 4 161 0 22 4 165 0 23 4 169 0 24 4 173 0 25 4 177 0 26 4 181 0 29 4 185 0 30 4 189 0 31 4 193 0 63 4 193 0 68] 
#[0 11 29 0 2] 
#[0 11 33 0 2] 
#[1 11 37 0 19 4 213 0 21] 
#[0 1 50 0 1 0 3 0 4 0 8 0 11 0 12 0 14 0 17 0 20 0 21 0 22 0 23 0 24 0 25 0 26 0 29 0 30 0 31] 
#[0 1 54 0 1 0 3 0 4 0 8 0 11 0 12 0 14 0 17 0 20 0 21 0 22 0 23 0 24 0 25 0 26 0 29 0 30 0 31] 
#[0 1 54 0 1 0 3 0 4 0 8 0 11 0 12 0 14 0 17 0 20 0 21 0 22 0 23 0 24 0 25 0 26 0 29 0 30 0 31] 
#[0 1 50 0 1 0 3 0 4 0 8 0 11 0 12 0 14 0 17 0 20 0 21 0 22 0 23 0 24 0 25 0 26 0 29 0 30 0 31] 
#[0 1 42 0 3 0 20 0 24 0 26] 
#[1 0 18 0 1 0 18 0 4 3 189 0 5 0 18 0 8 0 18 0 11 0 18 0 12 0 18 0 14 0 18 0 16 0 18 0 17 0 18 0 19 0 18 0 20 0 18 0 21 0 18 0 22 0 18 0 23 0 18 0 29 0 18 0 30 11 41 0 36 3 197 0 38 3 201 0 39] 
#[1 11 45 0 4 11 49 0 8 11 53 0 17 11 57 0 20 11 61 0 23 11 65 0 24 11 69 0 25 11 73 0 26] 
#[1 1 65 0 1 1 69 0 4 1 73 0 8 1 77 0 11 1 81 0 12 1 85 0 14 1 89 0 17 1 93 0 20 1 97 0 21 1 101 0 22 1 105 0 23 1 109 0 29 1 113 0 30 11 77 0 41 1 133 0 43 11 77 0 44 1 129 0 45 1 133 0 47 1 129 0 48 1 141 0 49 1 145 0 50 1 149 0 57 1 153 0 68] 
#[1 1 157 0 1 11 81 0 2 1 165 0 4 1 169 0 8 1 173 0 11 1 177 0 12 1 181 0 14 1 185 0 17 1 189 0 20 1 193 0 21 1 197 0 22 1 201 0 23 1 205 0 29 1 209 0 30 11 85 0 40 1 217 0 41 1 233 0 43 1 217 0 44 1 229 0 45 1 233 0 47 1 229 0 48 1 241 0 49 1 245 0 50 1 249 0 57 1 253 0 68] 
#[0 0 82 0 3 0 6 0 20] 
#[0 0 86 0 3 0 6 0 20] 
#[0 0 90 0 3 0 6 0 20] 
#[1 0 6 0 1 0 6 0 4 0 6 0 5 0 6 0 8 2 5 0 9 0 6 0 11 0 6 0 12 0 6 0 14 2 9 0 15 0 6 0 16 0 6 0 17 2 13 0 18 0 6 0 19 0 6 0 20 0 6 0 21 0 6 0 22 0 6 0 23 0 6 0 29 0 6 0 30 2 17 0 37 11 89 0 42 11 93 0 60] 
#[0 0 26 0 3 0 6 0 20] 
#[0 0 94 0 3 0 6 0 20] 
#[0 0 94 0 3 0 6 0 20] 
#[0 0 98 0 3 0 6 0 20] 
#[0 0 26 0 3 0 6 0 20] 
#[0 0 102 0 3 0 6 0 20] 
#[0 0 110 0 3 0 6 0 20] 
#[1 0 230 0 3 0 230 0 6 11 97 0 20 11 101 0 52] 
#[1 0 230 0 3 0 230 0 6 11 97 0 20 11 105 0 52] 
#[0 0 234 0 3 0 6] 
#[0 0 110 0 3 0 6 0 20] 
#[0 0 130 0 3 0 6 0 20] 
#[1 4 121 0 1 11 109 0 3 4 129 0 4 4 133 0 8 4 137 0 11 4 141 0 12 4 145 0 14 4 149 0 17 4 153 0 20 4 157 0 21 4 161 0 22 4 165 0 23 4 169 0 24 4 173 0 25 4 177 0 26 4 181 0 29 4 185 0 30 4 189 0 31 4 193 0 63 4 193 0 68] 
#[0 11 113 0 2] 
#[0 11 117 0 2] 
#[1 11 121 0 19 4 213 0 21] 
#[0 0 198 0 3 0 6 0 20 0 24 0 26] 
#[0 11 125 0 2] 
#[1 0 6 0 1 0 6 0 4 0 6 0 5 0 6 0 8 2 5 0 9 0 6 0 11 0 6 0 12 0 6 0 14 2 9 0 15 0 6 0 16 0 6 0 17 0 6 0 19 0 6 0 20 0 6 0 21 0 6 0 22 0 6 0 23 0 6 0 29 0 6 0 30 2 17 0 37 11 129 0 60] 
#[1 0 97 0 20 0 101 0 29 11 133 0 35 0 109 0 57] 
#[0 0 210 0 3 0 6 0 20 0 24 0 26] 
#[0 0 214 0 3 0 6 0 20 0 24 0 26] 
#[0 1 42 0 2 0 5 0 20 0 24 0 26] 
#[1 0 18 0 1 0 18 0 4 3 189 0 5 0 18 0 8 0 18 0 11 0 18 0 12 0 18 0 14 0 18 0 16 0 18 0 17 0 18 0 19 0 18 0 20 0 18 0 21 0 18 0 22 0 18 0 23 0 18 0 29 0 18 0 30 11 137 0 36 3 197 0 38 3 201 0 39] 
#[1 11 141 0 4 11 145 0 8 11 149 0 17 11 153 0 20 11 157 0 23 11 161 0 24 11 165 0 25 11 169 0 26] 
#[1 1 65 0 1 1 69 0 4 1 73 0 8 1 77 0 11 1 81 0 12 1 85 0 14 1 89 0 17 1 93 0 20 1 97 0 21 1 101 0 22 1 105 0 23 1 109 0 29 1 113 0 30 11 173 0 41 1 133 0 43 11 173 0 44 1 129 0 45 1 133 0 47 1 129 0 48 1 141 0 49 1 145 0 50 1 149 0 57 1 153 0 68] 
#[1 1 157 0 1 11 177 0 2 1 165 0 4 1 169 0 8 1 173 0 11 1 177 0 12 1 181 0 14 1 185 0 17 1 189 0 20 1 193 0 21 1 197 0 22 1 201 0 23 1 205 0 29 1 209 0 30 11 181 0 40 1 217 0 41 1 233 0 43 1 217 0 44 1 229 0 45 1 233 0 47 1 229 0 48 1 241 0 49 1 245 0 50 1 249 0 57 1 253 0 68] 
#[0 0 82 0 2 0 5 0 6 0 20] 
#[0 0 86 0 2 0 5 0 6 0 20] 
#[0 0 90 0 2 0 5 0 6 0 20] 
#[1 0 6 0 1 0 6 0 4 0 6 0 5 0 6 0 8 2 5 0 9 0 6 0 11 0 6 0 12 0 6 0 14 2 9 0 15 0 6 0 16 0 6 0 17 2 13 0 18 0 6 0 19 0 6 0 20 0 6 0 21 0 6 0 22 0 6 0 23 0 6 0 29 0 6 0 30 2 17 0 37 11 185 0 42 11 189 0 60] 
#[0 0 26 0 2 0 5 0 6 0 20] 
#[0 0 94 0 2 0 5 0 6 0 20] 
#[0 0 94 0 2 0 5 0 6 0 20] 
#[0 0 98 0 2 0 5 0 6 0 20] 
#[0 0 26 0 2 0 5 0 6 0 20] 
#[0 0 102 0 2 0 5 0 6 0 20] 
#[0 0 110 0 2 0 5 0 6 0 20] 
#[1 0 230 0 2 0 230 0 5 0 230 0 6 11 193 0 20 11 197 0 52] 
#[1 0 230 0 2 0 230 0 5 0 230 0 6 11 193 0 20 11 201 0 52] 
#[0 0 234 0 2 0 5 0 6] 
#[0 0 110 0 2 0 5 0 6 0 20] 
#[0 0 130 0 2 0 5 0 6 0 20] 
#[1 4 121 0 1 11 205 0 3 4 129 0 4 4 133 0 8 4 137 0 11 4 141 0 12 4 145 0 14 4 149 0 17 4 153 0 20 4 157 0 21 4 161 0 22 4 165 0 23 4 169 0 24 4 173 0 25 4 177 0 26 4 181 0 29 4 185 0 30 4 189 0 31 4 193 0 63 4 193 0 68] 
#[0 11 209 0 2] 
#[0 11 213 0 2] 
#[1 11 217 0 19 4 213 0 21] 
#[0 0 198 0 2 0 5 0 6 0 20 0 24 0 26] 
#[0 11 221 0 2] 
#[1 0 6 0 1 0 6 0 4 0 6 0 5 0 6 0 8 2 5 0 9 0 6 0 11 0 6 0 12 0 6 0 14 2 9 0 15 0 6 0 16 0 6 0 17 0 6 0 19 0 6 0 20 0 6 0 21 0 6 0 22 0 6 0 23 0 6 0 29 0 6 0 30 2 17 0 37 11 225 0 60] 
#[1 0 97 0 20 0 101 0 29 11 229 0 35 0 109 0 57] 
#[0 0 210 0 2 0 5 0 6 0 20 0 24 0 26] 
#[0 0 214 0 2 0 5 0 6 0 20 0 24 0 26] 
#[1 4 121 0 1 11 233 0 3 4 129 0 4 4 133 0 8 4 137 0 11 4 141 0 12 4 145 0 14 4 149 0 17 4 153 0 20 4 157 0 21 4 161 0 22 4 165 0 23 4 169 0 24 4 173 0 25 4 177 0 26 4 181 0 29 4 185 0 30 4 189 0 31 4 193 0 63 4 193 0 68] 
#[0 11 237 0 2] 
#[0 11 241 0 2] 
#[1 11 245 0 19 4 213 0 21] 
#[0 0 198 0 5 0 19 0 20 0 24 0 26] 
#[0 11 249 0 2] 
#[1 10 45 0 5 0 50 0 19 11 253 0 38] 
#[0 0 58 0 19] 
#[0 0 202 0 19] 
#[1 0 6 0 1 0 6 0 4 0 6 0 5 0 6 0 8 2 5 0 9 0 6 0 11 0 6 0 12 0 6 0 14 2 9 0 15 0 6 0 16 0 6 0 17 0 6 0 19 0 6 0 20 0 6 0 21 0 6 0 22 0 6 0 23 0 6 0 29 0 6 0 30 2 17 0 37 12 1 0 60] 
#[1 0 97 0 20 0 101 0 29 12 5 0 35 0 109 0 57] 
#[0 0 210 0 5 0 19 0 20 0 24 0 26] 
#[0 0 214 0 5 0 19 0 20 0 24 0 26] 
#[1 6 17 0 1 6 21 0 4 6 25 0 8 6 29 0 11 6 33 0 12 6 37 0 14 6 45 0 17 6 49 0 20 6 53 0 21 6 57 0 22 6 61 0 23 6 65 0 29 6 69 0 30 12 9 0 41 6 93 0 43 12 9 0 44 6 89 0 45 6 93 0 47 6 89 0 48 6 101 0 49 6 105 0 50 6 109 0 57 6 113 0 68] 
#[0 0 218 0 5 0 19] 
#[1 12 13 0 20 8 65 0 24 12 17 0 26 12 21 0 51 12 21 0 52 12 21 0 53 12 33 0 54] 
#[1 12 37 0 4 12 41 0 8 12 45 0 17 12 49 0 20 12 53 0 23 12 57 0 24 12 61 0 25 12 65 0 26] 
#[1 1 65 0 1 1 69 0 4 1 73 0 8 1 77 0 11 1 81 0 12 1 85 0 14 1 89 0 17 1 93 0 20 1 97 0 21 1 101 0 22 1 105 0 23 1 109 0 29 1 113 0 30 12 69 0 41 1 133 0 43 12 69 0 44 1 129 0 45 1 133 0 47 1 129 0 48 1 141 0 49 1 145 0 50 1 149 0 57 1 153 0 68] 
#[1 1 157 0 1 12 73 0 2 1 165 0 4 1 169 0 8 1 173 0 11 1 177 0 12 1 181 0 14 1 185 0 17 1 189 0 20 1 193 0 21 1 197 0 22 1 201 0 23 1 205 0 29 1 209 0 30 12 77 0 40 1 217 0 41 1 233 0 43 1 217 0 44 1 229 0 45 1 233 0 47 1 229 0 48 1 241 0 49 1 245 0 50 1 249 0 57 1 253 0 68] 
#[0 0 82 0 5 0 6 0 19 0 20 0 24 0 26] 
#[0 0 86 0 5 0 6 0 19 0 20 0 24 0 26] 
#[0 0 90 0 5 0 6 0 19 0 20 0 24 0 26] 
#[1 0 6 0 1 0 6 0 4 0 6 0 5 0 6 0 8 2 5 0 9 0 6 0 11 0 6 0 12 0 6 0 14 2 9 0 15 0 6 0 16 0 6 0 17 2 13 0 18 0 6 0 19 0 6 0 20 0 6 0 21 0 6 0 22 0 6 0 23 0 6 0 29 0 6 0 30 2 17 0 37 12 81 0 42 12 85 0 60] 
#[0 0 26 0 5 0 6 0 19 0 20 0 24 0 26] 
#[0 0 94 0 5 0 6 0 19 0 20 0 24 0 26] 
#[0 0 94 0 5 0 6 0 19 0 20 0 24 0 26] 
#[0 0 98 0 5 0 6 0 19 0 20 0 24 0 26] 
#[0 0 26 0 5 0 6 0 19 0 20 0 24 0 26] 
#[0 0 102 0 5 0 6 0 19 0 20 0 24 0 26] 
#[0 0 110 0 5 0 6 0 19 0 20 0 24 0 26] 
#[1 0 222 0 5 0 222 0 6 0 222 0 19 8 61 0 20 0 222 0 24 8 69 0 26 8 73 0 52 8 77 0 53] 
#[1 0 222 0 5 0 222 0 6 0 222 0 19 0 222 0 24 8 69 0 26 8 85 0 53] 
#[1 0 222 0 5 0 222 0 6 0 222 0 19 8 61 0 20 0 222 0 24 8 69 0 26 8 93 0 52 8 97 0 53] 
#[0 0 226 0 5 0 6 0 19 0 24] 
#[0 0 110 0 5 0 6 0 19 0 20 0 24 0 26] 
#[0 0 130 0 5 0 6 0 19 0 20 0 24 0 26] 
#[1 0 230 0 5 0 230 0 6 0 230 0 19 8 61 0 20 0 230 0 24 0 230 0 26 8 73 0 52] 
#[1 0 230 0 5 0 230 0 6 0 230 0 19 8 61 0 20 0 230 0 24 0 230 0 26 8 93 0 52] 
#[0 0 234 0 5 0 6 0 19 0 24 0 26] 
#[1 10 85 0 1 10 89 0 4 10 93 0 8 10 97 0 11 10 101 0 12 10 105 0 14 10 109 0 17 10 113 0 20 10 117 0 21 10 121 0 22 10 125 0 23 10 129 0 29 10 133 0 30 10 141 0 43 10 141 0 47 10 145 0 49 10 149 0 50 12 89 0 55 10 141 0 57 10 161 0 68] 
#[0 0 238 0 5 0 19] 
#[0 12 93 0 19] 
#[1 0 142 0 1 0 142 0 3 0 142 0 4 0 142 0 8 0 142 0 11 0 142 0 12 0 142 0 14 0 142 0 17 0 142 0 20 0 142 0 21 0 142 0 22 0 142 0 23 0 142 0 24 0 142 0 25 0 142 0 26 0 142 0 29 0 142 0 30 0 142 0 31 12 97 0 62] 
#[1 12 101 0 20 12 105 0 29] 
#[1 0 146 0 19 0 146 0 21 12 109 0 61] 
#[0 0 150 0 5 0 6 0 20 0 65] 
#[0 0 154 0 5 0 6 0 20 0 65] 
#[0 0 150 0 5 0 6 0 20 0 65] 
#[0 0 150 0 5 0 6 0 20 0 65] 
#[0 0 150 0 5 0 6 0 20 0 65] 
#[0 12 113 0 3] 
#[0 0 158 0 5 0 6 0 20 0 65] 
#[1 0 18 0 2 3 97 0 5 3 101 0 38 12 117 0 39] 
#[1 12 121 0 9 12 125 0 15 3 213 0 18 12 129 0 19] 
#[0 12 133 0 19] 
#[0 0 170 0 5 0 6 0 20 0 65] 
#[0 0 174 0 5 0 6 0 20 0 65] 
#[0 0 174 0 5 0 6 0 20 0 65] 
#[0 0 242 0 5 0 6 0 20 0 24 0 26 0 65] 
#[0 1 6 0 5 0 6 0 20 0 24 0 26 0 65] 
#[0 1 6 0 5 0 6 0 20 0 24 0 26 0 65] 
#[0 0 242 0 5 0 6 0 20 0 24 0 26 0 65] 
#[0 1 14 0 5 0 6 0 20 0 24 0 26 0 65] 
#[0 12 137 0 19] 
#[1 0 149 0 5 12 141 0 9 0 157 0 38] 
#[0 0 242 0 1 0 3 0 4 0 8 0 11 0 12 0 14 0 17 0 20 0 21 0 22 0 23 0 24 0 25 0 26 0 29 0 30 0 31] 
#[0 1 6 0 1 0 3 0 4 0 8 0 11 0 12 0 14 0 17 0 20 0 21 0 22 0 23 0 24 0 25 0 26 0 29 0 30 0 31] 
#[0 1 6 0 1 0 3 0 4 0 8 0 11 0 12 0 14 0 17 0 20 0 21 0 22 0 23 0 24 0 25 0 26 0 29 0 30 0 31] 
#[0 0 242 0 1 0 3 0 4 0 8 0 11 0 12 0 14 0 17 0 20 0 21 0 22 0 23 0 24 0 25 0 26 0 29 0 30 0 31] 
#[0 12 145 0 19] 
#[1 0 142 0 1 0 142 0 3 0 142 0 4 0 142 0 8 0 142 0 11 0 142 0 12 0 142 0 14 0 142 0 17 0 142 0 20 0 142 0 21 0 142 0 22 0 142 0 23 0 142 0 24 0 142 0 25 0 142 0 26 0 142 0 29 0 142 0 30 0 142 0 31 12 149 0 62] 
#[1 12 153 0 20 12 157 0 29] 
#[1 0 146 0 19 0 146 0 21 12 161 0 61] 
#[0 0 150 0 3 0 6 0 20] 
#[0 0 154 0 3 0 6 0 20] 
#[0 0 150 0 3 0 6 0 20] 
#[0 0 150 0 3 0 6 0 20] 
#[0 0 150 0 3 0 6 0 20] 
#[0 12 165 0 3] 
#[0 0 158 0 3 0 6 0 20] 
#[1 0 18 0 2 3 97 0 5 3 101 0 38 12 169 0 39] 
#[1 12 173 0 9 12 177 0 15 3 213 0 18 12 181 0 19] 
#[0 12 185 0 19] 
#[0 0 170 0 3 0 6 0 20] 
#[0 0 174 0 3 0 6 0 20] 
#[0 0 174 0 3 0 6 0 20] 
#[0 0 242 0 3 0 6 0 20 0 24 0 26] 
#[0 1 6 0 3 0 6 0 20 0 24 0 26] 
#[0 1 6 0 3 0 6 0 20 0 24 0 26] 
#[0 0 242 0 3 0 6 0 20 0 24 0 26] 
#[0 1 14 0 3 0 6 0 20 0 24 0 26] 
#[0 12 189 0 19] 
#[1 0 149 0 5 12 193 0 9 0 157 0 38] 
#[0 12 197 0 19] 
#[1 0 142 0 1 0 142 0 3 0 142 0 4 0 142 0 8 0 142 0 11 0 142 0 12 0 142 0 14 0 142 0 17 0 142 0 20 0 142 0 21 0 142 0 22 0 142 0 23 0 142 0 24 0 142 0 25 0 142 0 26 0 142 0 29 0 142 0 30 0 142 0 31 12 201 0 62] 
#[1 12 205 0 20 12 209 0 29] 
#[1 0 146 0 19 0 146 0 21 12 213 0 61] 
#[0 0 150 0 2 0 5 0 6 0 20] 
#[0 0 154 0 2 0 5 0 6 0 20] 
#[0 0 150 0 2 0 5 0 6 0 20] 
#[0 0 150 0 2 0 5 0 6 0 20] 
#[0 0 150 0 2 0 5 0 6 0 20] 
#[0 12 217 0 3] 
#[0 0 158 0 2 0 5 0 6 0 20] 
#[1 0 18 0 2 3 97 0 5 3 101 0 38 12 221 0 39] 
#[1 12 225 0 9 12 229 0 15 3 213 0 18 12 233 0 19] 
#[0 12 237 0 19] 
#[0 0 170 0 2 0 5 0 6 0 20] 
#[0 0 174 0 2 0 5 0 6 0 20] 
#[0 0 174 0 2 0 5 0 6 0 20] 
#[0 0 242 0 2 0 5 0 6 0 20 0 24 0 26] 
#[0 1 6 0 2 0 5 0 6 0 20 0 24 0 26] 
#[0 1 6 0 2 0 5 0 6 0 20 0 24 0 26] 
#[0 0 242 0 2 0 5 0 6 0 20 0 24 0 26] 
#[0 1 14 0 2 0 5 0 6 0 20 0 24 0 26] 
#[0 12 241 0 19] 
#[1 0 149 0 5 12 245 0 9 0 157 0 38] 
#[0 0 242 0 5 0 19 0 20 0 24 0 26] 
#[0 1 6 0 5 0 19 0 20 0 24 0 26] 
#[0 1 6 0 5 0 19 0 20 0 24 0 26] 
#[0 0 242 0 5 0 19 0 20 0 24 0 26] 
#[0 1 14 0 5 0 19 0 20 0 24 0 26] 
#[0 0 78 0 19] 
#[0 12 249 0 19] 
#[1 0 149 0 5 12 253 0 9 0 157 0 38] 
#[1 10 45 0 5 0 18 0 19 10 49 0 38 13 1 0 39] 
#[0 0 170 0 5 0 6 0 19] 
#[1 13 5 0 1 13 9 0 4 13 13 0 8 13 17 0 11 13 21 0 12 13 25 0 14 13 29 0 17 13 33 0 20 13 37 0 21 13 41 0 22 13 45 0 23 13 49 0 29 13 53 0 30 13 61 0 43 13 61 0 47 13 65 0 50 13 69 0 56 13 61 0 57 13 77 0 68] 
#[0 1 22 0 5 0 6 0 19] 
#[0 1 26 0 5 0 6 0 19] 
#[0 1 26 0 5 0 6 0 19] 
#[1 1 26 0 5 1 26 0 6 1 26 0 19 10 177 0 24] 
#[1 0 142 0 1 0 142 0 3 0 142 0 4 0 142 0 8 0 142 0 11 0 142 0 12 0 142 0 14 0 142 0 17 0 142 0 20 0 142 0 21 0 142 0 22 0 142 0 23 0 142 0 24 0 142 0 25 0 142 0 26 0 142 0 29 0 142 0 30 0 142 0 31 13 81 0 62] 
#[1 13 85 0 20 13 89 0 29] 
#[1 0 146 0 19 0 146 0 21 13 93 0 61] 
#[0 0 150 0 5 0 6 0 19 0 20 0 24 0 26] 
#[0 0 154 0 5 0 6 0 19 0 20 0 24 0 26] 
#[0 0 150 0 5 0 6 0 19 0 20 0 24 0 26] 
#[0 0 150 0 5 0 6 0 19 0 20 0 24 0 26] 
#[0 0 150 0 5 0 6 0 19 0 20 0 24 0 26] 
#[0 13 97 0 3] 
#[0 0 158 0 5 0 6 0 19 0 20 0 24 0 26] 
#[1 0 18 0 2 3 97 0 5 3 101 0 38 13 101 0 39] 
#[1 13 105 0 9 13 109 0 15 3 213 0 18 13 113 0 19] 
#[0 13 117 0 19] 
#[0 1 30 0 5 0 6 0 19 0 24] 
#[0 1 58 0 5 0 20 0 24 0 26 0 65] 
#[1 4 121 0 1 13 121 0 3 4 129 0 4 4 133 0 8 4 137 0 11 4 141 0 12 4 145 0 14 4 149 0 17 4 153 0 20 4 157 0 21 4 161 0 22 4 165 0 23 4 169 0 24 4 173 0 25 4 177 0 26 4 181 0 29 4 185 0 30 4 189 0 31 4 193 0 63 4 193 0 68] 
#[0 13 125 0 2] 
#[0 13 129 0 2] 
#[1 13 133 0 19 4 213 0 21] 
#[0 0 198 0 5 0 6 0 20 0 65] 
#[0 13 137 0 2] 
#[1 0 6 0 1 0 6 0 4 0 6 0 5 0 6 0 8 2 5 0 9 0 6 0 11 0 6 0 12 0 6 0 14 2 9 0 15 0 6 0 16 0 6 0 17 0 6 0 19 0 6 0 20 0 6 0 21 0 6 0 22 0 6 0 23 0 6 0 29 0 6 0 30 2 17 0 37 13 141 0 60] 
#[1 0 97 0 20 0 101 0 29 13 145 0 35 0 109 0 57] 
#[0 0 210 0 5 0 6 0 20 0 65] 
#[0 0 214 0 5 0 6 0 20 0 65] 
#[0 1 42 0 5 0 6 0 20 0 24 0 26 0 65] 
#[1 0 18 0 1 0 18 0 4 3 189 0 5 0 18 0 8 0 18 0 11 0 18 0 12 0 18 0 14 0 18 0 16 0 18 0 17 0 18 0 19 0 18 0 20 0 18 0 21 0 18 0 22 0 18 0 23 0 18 0 29 0 18 0 30 13 149 0 36 3 197 0 38 3 201 0 39] 
#[0 1 58 0 3 0 20 0 24 0 26] 
#[1 4 121 0 1 13 153 0 3 4 129 0 4 4 133 0 8 4 137 0 11 4 141 0 12 4 145 0 14 4 149 0 17 4 153 0 20 4 157 0 21 4 161 0 22 4 165 0 23 4 169 0 24 4 173 0 25 4 177 0 26 4 181 0 29 4 185 0 30 4 189 0 31 4 193 0 63 4 193 0 68] 
#[0 13 157 0 2] 
#[0 13 161 0 2] 
#[1 13 165 0 19 4 213 0 21] 
#[0 0 198 0 3 0 6 0 20] 
#[0 13 169 0 2] 
#[1 0 6 0 1 0 6 0 4 0 6 0 5 0 6 0 8 2 5 0 9 0 6 0 11 0 6 0 12 0 6 0 14 2 9 0 15 0 6 0 16 0 6 0 17 0 6 0 19 0 6 0 20 0 6 0 21 0 6 0 22 0 6 0 23 0 6 0 29 0 6 0 30 2 17 0 37 13 173 0 60] 
#[1 0 97 0 20 0 101 0 29 13 177 0 35 0 109 0 57] 
#[0 0 210 0 3 0 6 0 20] 
#[0 0 214 0 3 0 6 0 20] 
#[0 1 42 0 3 0 6 0 20 0 24 0 26] 
#[1 0 18 0 1 0 18 0 4 3 189 0 5 0 18 0 8 0 18 0 11 0 18 0 12 0 18 0 14 0 18 0 16 0 18 0 17 0 18 0 19 0 18 0 20 0 18 0 21 0 18 0 22 0 18 0 23 0 18 0 29 0 18 0 30 13 181 0 36 3 197 0 38 3 201 0 39] 
#[0 1 58 0 2 0 5 0 20 0 24 0 26] 
#[1 4 121 0 1 13 185 0 3 4 129 0 4 4 133 0 8 4 137 0 11 4 141 0 12 4 145 0 14 4 149 0 17 4 153 0 20 4 157 0 21 4 161 0 22 4 165 0 23 4 169 0 24 4 173 0 25 4 177 0 26 4 181 0 29 4 185 0 30 4 189 0 31 4 193 0 63 4 193 0 68] 
#[0 13 189 0 2] 
#[0 13 193 0 2] 
#[1 13 197 0 19 4 213 0 21] 
#[0 0 198 0 2 0 5 0 6 0 20] 
#[0 13 201 0 2] 
#[1 0 6 0 1 0 6 0 4 0 6 0 5 0 6 0 8 2 5 0 9 0 6 0 11 0 6 0 12 0 6 0 14 2 9 0 15 0 6 0 16 0 6 0 17 0 6 0 19 0 6 0 20 0 6 0 21 0 6 0 22 0 6 0 23 0 6 0 29 0 6 0 30 2 17 0 37 13 205 0 60] 
#[1 0 97 0 20 0 101 0 29 13 209 0 35 0 109 0 57] 
#[0 0 210 0 2 0 5 0 6 0 20] 
#[0 0 214 0 2 0 5 0 6 0 20] 
#[0 1 42 0 2 0 5 0 6 0 20 0 24 0 26] 
#[1 0 18 0 1 0 18 0 4 3 189 0 5 0 18 0 8 0 18 0 11 0 18 0 12 0 18 0 14 0 18 0 16 0 18 0 17 0 18 0 19 0 18 0 20 0 18 0 21 0 18 0 22 0 18 0 23 0 18 0 29 0 18 0 30 13 213 0 36 3 197 0 38 3 201 0 39] 
#[0 1 42 0 5 0 19 0 20 0 24 0 26] 
#[1 0 18 0 1 0 18 0 4 3 189 0 5 0 18 0 8 0 18 0 11 0 18 0 12 0 18 0 14 0 18 0 16 0 18 0 17 0 18 0 19 0 18 0 20 0 18 0 21 0 18 0 22 0 18 0 23 0 18 0 29 0 18 0 30 13 217 0 36 3 197 0 38 3 201 0 39] 
#[0 1 46 0 19] 
#[1 13 221 0 4 13 225 0 8 13 229 0 17 13 233 0 20 13 237 0 23 13 241 0 24 13 245 0 25 13 249 0 26] 
#[1 1 65 0 1 1 69 0 4 1 73 0 8 1 77 0 11 1 81 0 12 1 85 0 14 1 89 0 17 1 93 0 20 1 97 0 21 1 101 0 22 1 105 0 23 1 109 0 29 1 113 0 30 13 253 0 41 1 133 0 43 13 253 0 44 1 129 0 45 1 133 0 47 1 129 0 48 1 141 0 49 1 145 0 50 1 149 0 57 1 153 0 68] 
#[1 1 157 0 1 14 1 0 2 1 165 0 4 1 169 0 8 1 173 0 11 1 177 0 12 1 181 0 14 1 185 0 17 1 189 0 20 1 193 0 21 1 197 0 22 1 201 0 23 1 205 0 29 1 209 0 30 14 5 0 40 1 217 0 41 1 233 0 43 1 217 0 44 1 229 0 45 1 233 0 47 1 229 0 48 1 241 0 49 1 245 0 50 1 249 0 57 1 253 0 68] 
#[0 0 82 0 5 0 6 0 19 0 20] 
#[0 0 86 0 5 0 6 0 19 0 20] 
#[0 0 90 0 5 0 6 0 19 0 20] 
#[1 0 6 0 1 0 6 0 4 0 6 0 5 0 6 0 8 2 5 0 9 0 6 0 11 0 6 0 12 0 6 0 14 2 9 0 15 0 6 0 16 0 6 0 17 2 13 0 18 0 6 0 19 0 6 0 20 0 6 0 21 0 6 0 22 0 6 0 23 0 6 0 29 0 6 0 30 2 17 0 37 14 9 0 42 14 13 0 60] 
#[0 0 26 0 5 0 6 0 19 0 20] 
#[0 0 94 0 5 0 6 0 19 0 20] 
#[0 0 94 0 5 0 6 0 19 0 20] 
#[0 0 98 0 5 0 6 0 19 0 20] 
#[0 0 26 0 5 0 6 0 19 0 20] 
#[0 0 102 0 5 0 6 0 19 0 20] 
#[0 0 110 0 5 0 6 0 19 0 20] 
#[1 0 230 0 5 0 230 0 6 0 230 0 19 14 17 0 20 14 21 0 52] 
#[1 0 230 0 5 0 230 0 6 0 230 0 19 14 17 0 20 14 25 0 52] 
#[0 0 234 0 5 0 6 0 19] 
#[0 0 110 0 5 0 6 0 19 0 20] 
#[0 0 130 0 5 0 6 0 19 0 20] 
#[1 4 121 0 1 14 29 0 3 4 129 0 4 4 133 0 8 4 137 0 11 4 141 0 12 4 145 0 14 4 149 0 17 4 153 0 20 4 157 0 21 4 161 0 22 4 165 0 23 4 169 0 24 4 173 0 25 4 177 0 26 4 181 0 29 4 185 0 30 4 189 0 31 4 193 0 63 4 193 0 68] 
#[0 14 33 0 2] 
#[0 14 37 0 2] 
#[1 14 41 0 19 4 213 0 21] 
#[0 0 198 0 5 0 6 0 19 0 20 0 24 0 26] 
#[0 14 45 0 2] 
#[1 0 6 0 1 0 6 0 4 0 6 0 5 0 6 0 8 2 5 0 9 0 6 0 11 0 6 0 12 0 6 0 14 2 9 0 15 0 6 0 16 0 6 0 17 0 6 0 19 0 6 0 20 0 6 0 21 0 6 0 22 0 6 0 23 0 6 0 29 0 6 0 30 2 17 0 37 14 49 0 60] 
#[1 0 97 0 20 0 101 0 29 14 53 0 35 0 109 0 57] 
#[0 0 210 0 5 0 6 0 19 0 20 0 24 0 26] 
#[0 0 214 0 5 0 6 0 19 0 20 0 24 0 26] 
#[0 0 242 0 5 0 6 0 20 0 65] 
#[0 1 6 0 5 0 6 0 20 0 65] 
#[0 1 6 0 5 0 6 0 20 0 65] 
#[0 0 242 0 5 0 6 0 20 0 65] 
#[0 1 14 0 5 0 6 0 20 0 65] 
#[0 14 57 0 19] 
#[1 0 149 0 5 14 61 0 9 0 157 0 38] 
#[0 14 65 0 19] 
#[0 0 242 0 3 0 6 0 20] 
#[0 1 6 0 3 0 6 0 20] 
#[0 1 6 0 3 0 6 0 20] 
#[0 0 242 0 3 0 6 0 20] 
#[0 1 14 0 3 0 6 0 20] 
#[0 14 69 0 19] 
#[1 0 149 0 5 14 73 0 9 0 157 0 38] 
#[0 14 77 0 19] 
#[0 0 242 0 2 0 5 0 6 0 20] 
#[0 1 6 0 2 0 5 0 6 0 20] 
#[0 1 6 0 2 0 5 0 6 0 20] 
#[0 0 242 0 2 0 5 0 6 0 20] 
#[0 1 14 0 2 0 5 0 6 0 20] 
#[0 14 81 0 19] 
#[1 0 149 0 5 14 85 0 9 0 157 0 38] 
#[0 14 89 0 19] 
#[0 14 93 0 19] 
#[1 0 142 0 1 0 142 0 3 0 142 0 4 0 142 0 8 0 142 0 11 0 142 0 12 0 142 0 14 0 142 0 17 0 142 0 20 0 142 0 21 0 142 0 22 0 142 0 23 0 142 0 24 0 142 0 25 0 142 0 26 0 142 0 29 0 142 0 30 0 142 0 31 14 97 0 62] 
#[1 14 101 0 20 14 105 0 29] 
#[1 0 146 0 19 0 146 0 21 14 109 0 61] 
#[0 0 150 0 5 0 6 0 19 0 20] 
#[0 0 154 0 5 0 6 0 19 0 20] 
#[0 0 150 0 5 0 6 0 19 0 20] 
#[0 0 150 0 5 0 6 0 19 0 20] 
#[0 0 150 0 5 0 6 0 19 0 20] 
#[0 14 113 0 3] 
#[0 0 158 0 5 0 6 0 19 0 20] 
#[1 0 18 0 2 3 97 0 5 3 101 0 38 14 117 0 39] 
#[1 14 121 0 9 14 125 0 15 3 213 0 18 14 129 0 19] 
#[0 14 133 0 19] 
#[0 0 170 0 5 0 6 0 19 0 20] 
#[0 0 174 0 5 0 6 0 19 0 20] 
#[0 0 174 0 5 0 6 0 19 0 20] 
#[0 0 242 0 5 0 6 0 19 0 20 0 24 0 26] 
#[0 1 6 0 5 0 6 0 19 0 20 0 24 0 26] 
#[0 1 6 0 5 0 6 0 19 0 20 0 24 0 26] 
#[0 0 242 0 5 0 6 0 19 0 20 0 24 0 26] 
#[0 1 14 0 5 0 6 0 19 0 20 0 24 0 26] 
#[0 14 137 0 19] 
#[1 0 149 0 5 14 141 0 9 0 157 0 38] 
#[0 1 42 0 5 0 6 0 20 0 65] 
#[1 0 18 0 1 0 18 0 4 3 189 0 5 0 18 0 8 0 18 0 11 0 18 0 12 0 18 0 14 0 18 0 16 0 18 0 17 0 18 0 19 0 18 0 20 0 18 0 21 0 18 0 22 0 18 0 23 0 18 0 29 0 18 0 30 14 145 0 36 3 197 0 38 3 201 0 39] 
#[0 1 58 0 5 0 6 0 20 0 24 0 26 0 65] 
#[0 1 42 0 3 0 6 0 20] 
#[1 0 18 0 1 0 18 0 4 3 189 0 5 0 18 0 8 0 18 0 11 0 18 0 12 0 18 0 14 0 18 0 16 0 18 0 17 0 18 0 19 0 18 0 20 0 18 0 21 0 18 0 22 0 18 0 23 0 18 0 29 0 18 0 30 14 149 0 36 3 197 0 38 3 201 0 39] 
#[0 1 58 0 3 0 6 0 20 0 24 0 26] 
#[0 1 42 0 2 0 5 0 6 0 20] 
#[1 0 18 0 1 0 18 0 4 3 189 0 5 0 18 0 8 0 18 0 11 0 18 0 12 0 18 0 14 0 18 0 16 0 18 0 17 0 18 0 19 0 18 0 20 0 18 0 21 0 18 0 22 0 18 0 23 0 18 0 29 0 18 0 30 14 153 0 36 3 197 0 38 3 201 0 39] 
#[0 1 58 0 2 0 5 0 6 0 20 0 24 0 26] 
#[0 1 58 0 5 0 19 0 20 0 24 0 26] 
#[1 4 121 0 1 14 157 0 3 4 129 0 4 4 133 0 8 4 137 0 11 4 141 0 12 4 145 0 14 4 149 0 17 4 153 0 20 4 157 0 21 4 161 0 22 4 165 0 23 4 169 0 24 4 173 0 25 4 177 0 26 4 181 0 29 4 185 0 30 4 189 0 31 4 193 0 63 4 193 0 68] 
#[0 14 161 0 2] 
#[0 14 165 0 2] 
#[1 14 169 0 19 4 213 0 21] 
#[0 0 198 0 5 0 6 0 19 0 20] 
#[0 14 173 0 2] 
#[1 0 6 0 1 0 6 0 4 0 6 0 5 0 6 0 8 2 5 0 9 0 6 0 11 0 6 0 12 0 6 0 14 2 9 0 15 0 6 0 16 0 6 0 17 0 6 0 19 0 6 0 20 0 6 0 21 0 6 0 22 0 6 0 23 0 6 0 29 0 6 0 30 2 17 0 37 14 177 0 60] 
#[1 0 97 0 20 0 101 0 29 14 181 0 35 0 109 0 57] 
#[0 0 210 0 5 0 6 0 19 0 20] 
#[0 0 214 0 5 0 6 0 19 0 20] 
#[0 1 42 0 5 0 6 0 19 0 20 0 24 0 26] 
#[1 0 18 0 1 0 18 0 4 3 189 0 5 0 18 0 8 0 18 0 11 0 18 0 12 0 18 0 14 0 18 0 16 0 18 0 17 0 18 0 19 0 18 0 20 0 18 0 21 0 18 0 22 0 18 0 23 0 18 0 29 0 18 0 30 14 185 0 36 3 197 0 38 3 201 0 39] 
#[0 14 189 0 19] 
#[0 14 193 0 19] 
#[0 14 197 0 19] 
#[0 0 242 0 5 0 6 0 19 0 20] 
#[0 1 6 0 5 0 6 0 19 0 20] 
#[0 1 6 0 5 0 6 0 19 0 20] 
#[0 0 242 0 5 0 6 0 19 0 20] 
#[0 1 14 0 5 0 6 0 19 0 20] 
#[0 14 201 0 19] 
#[1 0 149 0 5 14 205 0 9 0 157 0 38] 
#[0 14 209 0 19] 
#[0 1 58 0 5 0 6 0 20 0 65] 
#[0 1 58 0 3 0 6 0 20] 
#[0 1 58 0 2 0 5 0 6 0 20] 
#[0 1 42 0 5 0 6 0 19 0 20] 
#[1 0 18 0 1 0 18 0 4 3 189 0 5 0 18 0 8 0 18 0 11 0 18 0 12 0 18 0 14 0 18 0 16 0 18 0 17 0 18 0 19 0 18 0 20 0 18 0 21 0 18 0 22 0 18 0 23 0 18 0 29 0 18 0 30 14 213 0 36 3 197 0 38 3 201 0 39] 
#[0 1 58 0 5 0 6 0 19 0 20 0 24 0 26] 
#[0 14 217 0 19] 
#[0 1 58 0 5 0 6 0 19 0 20]
	).
]
