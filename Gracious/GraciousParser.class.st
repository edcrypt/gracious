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
	^'2021-06-01T15:50:00.250052-03:00'
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
			{(GraciousMethodNode 
				selector: '1' value asSymbol
				arguments: #() 
				body: '2' last) 
					""tags: '2' first; ""
					yourself}
	| BinaryMethodName MethodSequenceNode 
			{(GraciousMethodNode 
				selector: '1' first 
				arguments: '1' last 
				body: '2' last) 
					""tags: '2' first; ""
					yourself}
	| KeywordMethodName MethodSequenceNode 
			{(GraciousMethodNode 
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

{ #category : #generated }
GraciousParser class >> reduceTable [
^#(
	#(40 0 #reduceActionForTemporaries1: 2864129 false ) 
	#(36 0 #reduceActionForPrimitives1: 1714177 false ) 
	#(40 1 #reduceActionForTemporaries1: 2864130 false ) 
	#(43 0 #reduceFor: 3451905 false ) 
	#(33 2 #reduceActionForMethod1: 717825 false ) 
	#(62 1 #reduceActionForVariable1: 6688769 false ) 
	#(62 1 #reduceActionForVariable1: 6688770 false ) 
	#(35 2 #reduceActionForKeywordMethodName1: 1391617 false ) 
	#(34 2 #reduceActionForBinaryMethodName1: 1281025 false ) 
	#(33 2 #reduceActionForMethod2: 717826 false ) 
	#(33 2 #reduceActionForMethod3: 717827 false ) 
	#(41 1 #reduceActionForTemporaryVariables1: 2949121 false ) 
	#(45 1 #reduceFor: 3596289 false ) 
	#(39 2 #reduceActionForSequenceNode1: 2765825 false ) 
	#(42 1 #reduceActionForPrimitives1: 3095553 false ) 
	#(43 1 #reduceFor: 3451906 false ) 
	#(37 0 #reduceFor: 1881089 false ) 
	#(38 2 #reduceActionForMethodSequenceNode3: 2322435 false ) 
	#(40 3 #liftSecondValue: 2864131 false ) 
	#(45 2 #reduceFor: 3596290 false ) 
	#(63 1 #reduceActionForLiteral2: 6805506 false ) 
	#(63 1 #nil 6805507 false ) 
	#(63 1 #reduceActionForLiteral1: 6805505 false ) 
	#(63 1 #reduceActionForLiteral4: 6805508 false ) 
	#(63 1 #reduceActionForLiteral4: 6805509 false ) 
	#(63 1 #reduceActionForLiteral7: 6805511 false ) 
	#(63 1 #reduceActionForLiteral6: 6805510 false ) 
	#(61 1 #liftFirstValue: 6407172 false ) 
	#(44 1 #reduceFor: 3486721 false ) 
	#(48 1 #liftFirstValue: 4154370 false ) 
	#(51 0 #reduceActionForPrimitives1: 4807681 false ) 
	#(50 1 #liftFirstValue: 4657153 false ) 
	#(50 1 #liftFirstValue: 4657154 false ) 
	#(50 1 #liftFirstValue: 4657155 false ) 
	#(49 1 #liftFirstValue: 4281346 false ) 
	#(61 1 #liftFirstValue: 6407171 false ) 
	#(61 1 #reduceActionForPrimary2: 6407170 false ) 
	#(35 4 #reduceActionForKeywordMethodName2: 1391618 false ) 
	#(41 3 #reduceActionForTemporaryVariables2: 2949122 false ) 
	#(65 0 #reduceActionForArray1: 7720961 false ) 
	#(64 0 #reduceActionForByteArray1: 7596033 false ) 
	#(63 2 #reduceActionForLiteral9: 6805513 false ) 
	#(63 2 #reduceActionForLiteral8: 6805512 false ) 
	#(63 2 #reduceActionForLiteral9: 6805515 false ) 
	#(63 2 #reduceActionForLiteral9: 6805516 false ) 
	#(63 2 #reduceActionForLiteral9: 6805514 false ) 
	#(61 2 #reduceActionForPrimary6: 6407174 false ) 
	#(42 3 #liftSecondValue: 3095554 false ) 
	#(49 2 #reduceActionForCascade1: 4281345 false ) 
	#(53 2 #reduceActionForKeywordMessageSend1: 5066753 false ) 
	#(56 2 #reduceActionForKeywordMessageSend1: 5750785 false ) 
	#(60 1 #reduceActionForUnaryMessage1: 6323201 false ) 
	#(53 2 #reduceActionForKeywordMessageSend1: 5066754 false ) 
	#(56 2 #reduceActionForKeywordMessageSend1: 5750786 false ) 
	#(59 2 #reduceActionForKeywordMessageSend1: 6181889 false ) 
	#(53 2 #reduceActionForKeywordMessageSend1: 5066755 false ) 
	#(56 2 #reduceActionForKeywordMessageSend1: 5750787 false ) 
	#(59 2 #reduceActionForKeywordMessageSend1: 6181890 false ) 
	#(37 2 #nil 1881092 false ) 
	#(37 2 #nil 1881093 false ) 
	#(37 2 #nil 1881097 false ) 
	#(37 2 #nil 1881096 false ) 
	#(36 4 #reduceActionForPrimitives2: 1714178 false ) 
	#(37 2 #nil 1881094 false ) 
	#(37 2 #nil 1881095 false ) 
	#(37 2 #nil 1881098 false ) 
	#(37 2 #nil 1881090 false ) 
	#(37 2 #nil 1881099 false ) 
	#(37 2 #nil 1881091 false ) 
	#(38 4 #reduceActionForMethodSequenceNode2: 2322434 false ) 
	#(61 3 #liftSecondValue: 6407169 false ) 
	#(47 2 #reduceActionForBlockArgs1: 4023297 false ) 
	#(46 3 #reduceActionForBlock2: 3630082 false ) 
	#(46 3 #reduceActionForBlock3: 3630083 false ) 
	#(42 4 #reduceActionForStatements4: 3095556 false ) 
	#(44 3 #reduceActionForTemporaryVariables2: 3486722 false ) 
	#(54 2 #reduceActionForKeywordMethodName1: 5280769 false ) 
	#(55 1 #liftFirstValue: 5607425 false ) 
	#(55 1 #liftFirstValue: 5607426 false ) 
	#(55 1 #liftFirstValue: 5607427 false ) 
	#(57 2 #reduceActionForBinaryMessage1: 5961729 false ) 
	#(58 1 #liftFirstValue: 6084609 false ) 
	#(58 1 #liftFirstValue: 6084610 false ) 
	#(48 3 #reduceActionForExpression1: 4154369 false ) 
	#(63 4 #reduceActionForLiteral14: 6805518 false ) 
	#(66 1 #reduceActionForArrayLiteral2: 8094722 false ) 
	#(66 1 #reduceActionForArrayLiteral2: 8094724 false ) 
	#(66 1 #reduceActionForArrayLiteral2: 8094725 false ) 
	#(66 1 #reduceActionForArrayLiteral2: 8094723 false ) 
	#(66 1 #reduceActionForLiteral4: 8094731 false ) 
	#(66 1 #reduceActionForArrayLiteral2: 8094730 false ) 
	#(66 1 #liftFirstValue: 8094721 false ) 
	#(65 2 #reduceActionForArray2: 7720962 false ) 
	#(63 4 #reduceActionForLiteral14: 6805517 false ) 
	#(64 2 #reduceActionForByteArray2: 7596034 false ) 
	#(63 4 #reduceActionForLiteral15: 6805519 false ) 
	#(63 4 #reduceActionForLiteral15: 6805520 false ) 
	#(47 3 #reduceActionForTemporaryVariables2: 4023298 false ) 
	#(61 4 #reduceActionForPrimary5: 6407173 false ) 
	#(51 3 #reduceActionForTemporaryVariables2: 4807682 false ) 
	#(52 1 #liftFirstValue: 4926467 false ) 
	#(52 1 #liftFirstValue: 4926466 false ) 
	#(52 1 #liftFirstValue: 4926465 false ) 
	#(54 3 #reduceActionForKeywordMessage2: 5280770 false ) 
	#(38 6 #reduceActionForMethodSequenceNode1: 2322433 false ) 
	#(65 3 #reduceActionForArray3: 7720963 false ) 
	#(46 5 #reduceActionForBlock1: 3630081 false ) 
	#(42 6 #reduceActionForStatements3: 3095555 false ) 
	#(66 3 #reduceActionForArrayLiteral8: 8094728 false ) 
	#(66 3 #reduceActionForArrayLiteral8: 8094729 false ) 
	#(66 3 #reduceActionForArrayLiteral6: 8094726 false ) 
	#(66 3 #reduceActionForArrayLiteral6: 8094727 false ) 
	#(46 7 #reduceActionForBlock4: 3630084 false )
	).
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

{ #category : #generated }
GraciousParser class >> symbolNames [
	^ #('"#"' '"("' '")"' '"."' '":"' '":="' '";"' '"<"' '">"' '"["' '"]"' '"^"' '"false"' '"nil"' '"true"' '"{"' '"|"' '"||"' '"}"' '<name>' '<number>' '<negativeNumber>' '<string>' '<keyword>' '<multikeyword>' '<binarySymbol>' '<whitespace>' '<comment>' '<dottedName>' '<character>' '<anyChar>' 'B e g i n' 'Method' 'BinaryMethodName' 'KeywordMethodName' 'Primitives' 'PrimitiveMessageSend' 'MethodSequenceNode' 'SequenceNode' 'Temporaries' 'TemporaryVariables' 'Statements' 'OptionalPeriod' 'StatementList' 'Periods' 'Block' 'BlockArgs' 'Expression' 'Cascade' 'MessageSend' 'CascadeList' 'SimpleMessage' 'KeywordMessageSend' 'KeywordMessage' 'KeywordArgument' 'BinaryMessageSend' 'BinaryMessage' 'BinaryArgument' 'UnaryMessageSend' 'UnaryMessage' 'Primary' 'Variable' 'Literal' 'ByteArray' 'Array' 'ArrayLiteral' 'E O F' 'error')
]

{ #category : #generated }
GraciousParser class >> transitionTable [
^#(
#[1 0 13 0 20 0 17 0 24 0 21 0 26 0 25 0 33 0 29 0 34 0 33 0 35] 
#[1 0 6 0 1 0 6 0 2 0 6 0 4 0 6 0 10 0 6 0 12 0 6 0 13 0 6 0 14 0 6 0 15 0 6 0 16 0 37 0 17 0 41 0 18 0 6 0 20 0 6 0 21 0 6 0 22 0 6 0 23 0 6 0 29 0 6 0 30 0 45 0 39 0 49 0 40 0 6 0 67] 
#[1 0 10 0 1 0 10 0 2 0 10 0 4 0 10 0 8 0 10 0 10 0 10 0 12 0 10 0 13 0 10 0 14 0 10 0 15 0 10 0 16 0 10 0 17 0 10 0 18 0 10 0 20 0 10 0 21 0 10 0 22 0 10 0 23 0 10 0 29 0 10 0 30 0 53 0 36 0 57 0 38 0 10 0 67] 
#[1 0 61 0 20 0 65 0 29 0 69 0 62] 
#[1 0 61 0 20 0 65 0 29 0 73 0 62] 
#[0 0 0 0 67] 
#[1 0 10 0 1 0 10 0 2 0 10 0 4 0 10 0 8 0 10 0 10 0 10 0 12 0 10 0 13 0 10 0 14 0 10 0 15 0 10 0 16 0 10 0 17 0 10 0 18 0 10 0 20 0 10 0 21 0 10 0 22 0 10 0 23 0 10 0 29 0 10 0 30 0 53 0 36 0 77 0 38 0 10 0 67] 
#[1 0 10 0 1 0 10 0 2 0 10 0 4 0 81 0 7 0 10 0 8 0 10 0 10 0 10 0 12 0 10 0 13 0 10 0 14 0 10 0 15 0 10 0 16 0 10 0 17 0 10 0 18 0 10 0 20 0 10 0 21 0 10 0 22 0 10 0 23 0 10 0 29 0 10 0 30 0 53 0 36 0 85 0 38 0 10 0 67] 
#[1 0 61 0 20 0 65 0 29 0 89 0 41 0 93 0 62] 
#[0 0 14 0 1 0 2 0 4 0 10 0 11 0 12 0 13 0 14 0 15 0 16 0 20 0 21 0 22 0 23 0 29 0 30 0 67] 
#[0 0 0 0 67] 
#[1 0 18 0 1 0 18 0 2 0 97 0 4 0 18 0 10 0 18 0 11 0 18 0 12 0 18 0 13 0 18 0 14 0 18 0 15 0 18 0 16 0 18 0 20 0 18 0 21 0 18 0 22 0 18 0 23 0 18 0 29 0 18 0 30 0 101 0 42 0 105 0 43 0 109 0 45 0 18 0 67] 
#[1 0 18 0 1 0 18 0 2 0 97 0 4 0 113 0 8 0 18 0 10 0 18 0 12 0 18 0 13 0 18 0 14 0 18 0 15 0 18 0 16 0 117 0 17 0 121 0 18 0 18 0 20 0 18 0 21 0 18 0 22 0 18 0 23 0 18 0 29 0 18 0 30 0 125 0 42 0 105 0 43 0 109 0 45 0 18 0 67] 
#[0 0 22 0 67] 
#[0 0 26 0 1 0 2 0 3 0 4 0 5 0 6 0 7 0 8 0 10 0 11 0 12 0 13 0 14 0 15 0 16 0 17 0 18 0 19 0 20 0 21 0 22 0 23 0 24 0 26 0 29 0 30 0 67] 
#[0 0 30 0 1 0 2 0 3 0 4 0 5 0 6 0 7 0 8 0 10 0 11 0 12 0 13 0 14 0 15 0 16 0 17 0 18 0 19 0 20 0 21 0 22 0 23 0 24 0 26 0 29 0 30 0 67] 
#[0 0 34 0 1 0 2 0 4 0 7 0 8 0 10 0 12 0 13 0 14 0 15 0 16 0 17 0 18 0 20 0 21 0 22 0 23 0 29 0 30 0 67] 
#[0 0 38 0 1 0 2 0 4 0 8 0 10 0 12 0 13 0 14 0 15 0 16 0 17 0 18 0 20 0 21 0 22 0 23 0 29 0 30 0 67] 
#[0 0 42 0 67] 
#[0 0 129 0 24] 
#[0 0 46 0 67] 
#[1 0 97 0 4 0 133 0 17 0 137 0 45] 
#[0 0 50 0 4 0 17] 
#[1 0 54 0 1 0 54 0 2 0 97 0 4 0 54 0 10 0 54 0 11 0 54 0 12 0 54 0 13 0 54 0 14 0 54 0 15 0 54 0 16 0 54 0 19 0 54 0 20 0 54 0 21 0 54 0 22 0 54 0 23 0 54 0 29 0 54 0 30 0 141 0 45 0 54 0 67] 
#[0 0 58 0 11 0 67] 
#[1 0 145 0 1 0 149 0 2 0 153 0 10 0 62 0 11 0 157 0 12 0 161 0 13 0 165 0 14 0 169 0 15 0 173 0 16 0 61 0 20 0 177 0 21 0 181 0 22 0 185 0 23 0 65 0 29 0 189 0 30 0 193 0 44 0 225 0 46 0 201 0 48 0 201 0 49 0 209 0 50 0 209 0 53 0 217 0 56 0 221 0 59 0 225 0 61 0 229 0 62 0 233 0 63 0 62 0 67] 
#[0 0 66 0 1 0 2 0 10 0 11 0 12 0 13 0 14 0 15 0 16 0 20 0 21 0 22 0 23 0 29 0 30 0 67] 
#[1 0 70 0 1 0 70 0 2 0 70 0 3 0 70 0 4 0 70 0 7 0 70 0 9 0 70 0 13 0 70 0 14 0 70 0 15 0 70 0 16 0 70 0 19 0 70 0 20 0 70 0 21 0 70 0 22 0 70 0 23 0 70 0 24 0 70 0 26 0 70 0 30 0 237 0 37] 
#[1 0 61 0 20 0 65 0 29 0 241 0 41 0 93 0 62] 
#[1 0 10 0 1 0 10 0 2 0 10 0 4 0 10 0 8 0 10 0 10 0 10 0 12 0 10 0 13 0 10 0 14 0 10 0 15 0 10 0 16 0 10 0 20 0 10 0 21 0 10 0 22 0 10 0 23 0 10 0 29 0 10 0 30 0 245 0 36 0 10 0 67] 
#[0 0 74 0 67] 
#[1 0 61 0 20 0 65 0 29 0 249 0 62] 
#[0 0 78 0 1 0 2 0 4 0 10 0 11 0 12 0 13 0 14 0 15 0 16 0 20 0 21 0 22 0 23 0 29 0 30 0 67] 
#[1 0 61 0 20 0 65 0 29 0 253 0 62] 
#[0 0 82 0 1 0 2 0 10 0 11 0 12 0 13 0 14 0 15 0 16 0 19 0 20 0 21 0 22 0 23 0 29 0 30 0 67] 
#[1 1 1 0 2 1 5 0 10 1 9 0 16 1 13 0 20 1 17 0 23 1 21 0 24 1 25 0 25 1 29 0 26] 
#[1 0 145 0 1 0 149 0 2 0 153 0 10 0 161 0 13 0 165 0 14 0 169 0 15 0 173 0 16 0 61 0 20 0 177 0 21 0 181 0 22 0 185 0 23 0 65 0 29 0 189 0 30 0 225 0 46 1 33 0 48 1 33 0 49 0 209 0 50 0 209 0 53 0 217 0 56 0 221 0 59 0 225 0 61 0 229 0 62 0 233 0 63] 
#[1 0 6 0 1 0 6 0 2 0 6 0 4 1 37 0 5 0 6 0 10 0 6 0 11 0 6 0 12 0 6 0 13 0 6 0 14 0 6 0 15 0 6 0 16 0 37 0 17 0 41 0 18 0 6 0 20 0 6 0 21 0 6 0 22 0 6 0 23 0 6 0 29 0 6 0 30 1 41 0 39 0 49 0 40 1 45 0 47] 
#[1 0 145 0 1 0 149 0 2 0 153 0 10 0 161 0 13 0 165 0 14 0 169 0 15 0 173 0 16 0 61 0 20 0 177 0 21 0 181 0 22 0 185 0 23 0 65 0 29 0 189 0 30 0 225 0 46 1 49 0 48 1 49 0 49 0 209 0 50 0 209 0 53 0 217 0 56 0 221 0 59 0 225 0 61 0 229 0 62 0 233 0 63] 
#[0 0 86 0 1 0 2 0 3 0 4 0 7 0 9 0 10 0 11 0 13 0 14 0 15 0 16 0 19 0 20 0 21 0 22 0 23 0 24 0 25 0 26 0 29 0 30 0 31 0 67] 
#[0 0 90 0 1 0 2 0 3 0 4 0 7 0 9 0 10 0 11 0 13 0 14 0 15 0 16 0 19 0 20 0 21 0 22 0 23 0 24 0 25 0 26 0 29 0 30 0 31 0 67] 
#[0 0 94 0 1 0 2 0 3 0 4 0 7 0 9 0 10 0 11 0 13 0 14 0 15 0 16 0 19 0 20 0 21 0 22 0 23 0 24 0 25 0 26 0 29 0 30 0 31 0 67] 
#[1 0 145 0 1 0 149 0 2 0 153 0 10 0 161 0 13 0 165 0 14 0 169 0 15 0 173 0 16 1 53 0 19 0 61 0 20 0 177 0 21 0 181 0 22 0 185 0 23 0 65 0 29 0 189 0 30 1 57 0 44 0 225 0 46 0 201 0 48 0 201 0 49 0 209 0 50 0 209 0 53 0 217 0 56 0 221 0 59 0 225 0 61 0 229 0 62 0 233 0 63] 
#[0 0 98 0 1 0 2 0 3 0 4 0 7 0 9 0 10 0 11 0 13 0 14 0 15 0 16 0 19 0 20 0 21 0 22 0 23 0 24 0 25 0 26 0 29 0 30 0 31 0 67] 
#[0 0 102 0 1 0 2 0 3 0 4 0 7 0 9 0 10 0 11 0 13 0 14 0 15 0 16 0 19 0 20 0 21 0 22 0 23 0 24 0 25 0 26 0 29 0 30 0 31 0 67] 
#[0 0 106 0 1 0 2 0 3 0 4 0 7 0 9 0 10 0 11 0 13 0 14 0 15 0 16 0 19 0 20 0 21 0 22 0 23 0 24 0 25 0 26 0 29 0 30 0 31 0 67] 
#[0 0 110 0 1 0 2 0 3 0 4 0 7 0 9 0 10 0 11 0 13 0 14 0 15 0 16 0 19 0 20 0 21 0 22 0 23 0 24 0 25 0 26 0 29 0 30 0 31 0 67] 
#[1 0 97 0 4 0 18 0 11 1 61 0 43 1 65 0 45 0 18 0 67] 
#[0 0 114 0 3 0 4 0 7 0 11 0 19 0 20 0 24 0 26 0 67] 
#[0 0 118 0 4 0 11 0 19 0 67] 
#[0 0 122 0 3 0 4 0 11 0 19 0 67] 
#[1 0 126 0 3 0 126 0 4 0 126 0 7 0 126 0 11 0 126 0 19 1 69 0 51 0 126 0 67] 
#[0 0 130 0 3 0 4 0 7 0 11 0 19 0 67] 
#[1 0 134 0 3 0 134 0 4 0 134 0 7 0 134 0 11 0 134 0 19 1 73 0 24 1 77 0 26 1 81 0 54 1 85 0 57 0 134 0 67] 
#[1 0 138 0 3 0 138 0 4 0 138 0 7 0 138 0 11 0 138 0 19 1 89 0 20 1 73 0 24 1 77 0 26 1 93 0 54 1 97 0 57 1 101 0 60 0 138 0 67] 
#[1 0 142 0 3 0 142 0 4 0 142 0 11 0 142 0 19 1 89 0 20 1 73 0 24 1 77 0 26 1 105 0 54 1 109 0 57 1 113 0 60 0 142 0 67] 
#[1 0 146 0 3 0 146 0 4 1 117 0 6 0 146 0 11 0 146 0 19 0 146 0 20 0 146 0 24 0 146 0 26 0 146 0 67] 
#[0 0 150 0 3 0 4 0 7 0 11 0 19 0 20 0 24 0 26 0 67] 
#[1 0 145 0 1 1 121 0 2 1 125 0 3 1 129 0 4 1 133 0 7 1 137 0 9 0 161 0 13 0 165 0 14 0 169 0 15 1 141 0 16 1 145 0 19 1 149 0 20 0 177 0 21 0 181 0 22 0 185 0 23 1 153 0 24 1 157 0 26 0 189 0 30 1 161 0 63] 
#[1 0 97 0 4 1 165 0 17 0 137 0 45] 
#[1 0 18 0 1 0 18 0 2 0 97 0 4 0 113 0 8 0 18 0 10 0 18 0 12 0 18 0 13 0 18 0 14 0 18 0 15 0 18 0 16 0 18 0 20 0 18 0 21 0 18 0 22 0 18 0 23 0 18 0 29 0 18 0 30 1 169 0 42 0 105 0 43 0 109 0 45 0 18 0 67] 
#[0 0 154 0 1 0 2 0 4 0 7 0 8 0 10 0 12 0 13 0 14 0 15 0 16 0 17 0 18 0 20 0 21 0 22 0 23 0 29 0 30 0 67] 
#[0 0 158 0 4 0 17] 
#[1 0 162 0 1 0 162 0 2 0 162 0 3 0 162 0 10 0 162 0 13 0 162 0 14 0 162 0 15 0 162 0 16 0 162 0 20 0 162 0 21 0 162 0 22 0 162 0 23 0 162 0 24 0 162 0 25 0 162 0 26 0 162 0 29 0 162 0 30 0 162 0 31 1 173 0 65] 
#[1 0 166 0 11 0 166 0 21 1 177 0 64] 
#[1 1 181 0 20 1 185 0 29] 
#[0 0 170 0 1 0 2 0 3 0 4 0 7 0 9 0 10 0 11 0 13 0 14 0 15 0 16 0 19 0 20 0 21 0 22 0 23 0 24 0 25 0 26 0 29 0 30 0 31 0 67] 
#[0 0 174 0 1 0 2 0 3 0 4 0 7 0 9 0 10 0 11 0 13 0 14 0 15 0 16 0 19 0 20 0 21 0 22 0 23 0 24 0 25 0 26 0 29 0 30 0 31 0 67] 
#[0 0 178 0 1 0 2 0 3 0 4 0 7 0 9 0 10 0 11 0 13 0 14 0 15 0 16 0 19 0 20 0 21 0 22 0 23 0 24 0 25 0 26 0 29 0 30 0 31 0 67] 
#[0 0 182 0 1 0 2 0 3 0 4 0 7 0 9 0 10 0 11 0 13 0 14 0 15 0 16 0 19 0 20 0 21 0 22 0 23 0 24 0 25 0 26 0 29 0 30 0 31 0 67] 
#[0 0 186 0 1 0 2 0 3 0 4 0 7 0 9 0 10 0 11 0 13 0 14 0 15 0 16 0 19 0 20 0 21 0 22 0 23 0 24 0 25 0 26 0 29 0 30 0 31 0 67] 
#[0 1 189 0 3] 
#[1 0 61 0 20 0 65 0 29 1 193 0 62] 
#[0 1 197 0 11] 
#[1 1 201 0 5 1 205 0 11 1 209 0 17 1 213 0 18] 
#[1 0 97 0 4 0 18 0 11 1 217 0 43 0 109 0 45 0 18 0 67] 
#[0 0 190 0 3 0 4 0 7 0 11 0 19 0 20 0 24 0 26 0 67] 
#[1 0 97 0 4 0 18 0 19 1 221 0 43 1 225 0 45] 
#[0 0 194 0 11 0 67] 
#[1 0 145 0 1 0 149 0 2 0 153 0 10 0 66 0 11 1 229 0 12 0 161 0 13 0 165 0 14 0 169 0 15 0 173 0 16 0 61 0 20 0 177 0 21 0 181 0 22 0 185 0 23 0 65 0 29 0 189 0 30 0 225 0 46 1 233 0 48 1 233 0 49 0 209 0 50 0 209 0 53 0 217 0 56 0 221 0 59 0 225 0 61 0 229 0 62 0 233 0 63 0 66 0 67] 
#[1 0 198 0 3 0 198 0 4 1 237 0 7 0 198 0 11 0 198 0 19 0 198 0 67] 
#[1 0 145 0 1 0 149 0 2 0 153 0 10 0 161 0 13 0 165 0 14 0 169 0 15 0 173 0 16 0 61 0 20 0 177 0 21 0 181 0 22 0 185 0 23 0 65 0 29 0 189 0 30 1 253 0 46 1 241 0 55 1 245 0 56 1 249 0 59 1 253 0 61 1 253 0 62 0 233 0 63] 
#[1 0 145 0 1 0 149 0 2 0 153 0 10 0 161 0 13 0 165 0 14 0 169 0 15 0 173 0 16 0 61 0 20 0 177 0 21 0 181 0 22 0 185 0 23 0 65 0 29 0 189 0 30 2 13 0 46 2 5 0 58 2 9 0 59 2 13 0 61 2 13 0 62 0 233 0 63] 
#[1 0 202 0 3 0 202 0 4 0 202 0 7 0 202 0 11 0 202 0 19 2 17 0 24 0 202 0 67] 
#[0 0 206 0 3 0 4 0 7 0 11 0 19 0 24 0 26 0 67] 
#[0 0 210 0 3 0 4 0 7 0 11 0 19 0 20 0 24 0 26 0 67] 
#[1 0 214 0 3 0 214 0 4 0 214 0 7 0 214 0 11 0 214 0 19 2 17 0 24 0 214 0 67] 
#[0 0 218 0 3 0 4 0 7 0 11 0 19 0 24 0 26 0 67] 
#[0 0 222 0 3 0 4 0 7 0 11 0 19 0 20 0 24 0 26 0 67] 
#[1 0 226 0 3 0 226 0 4 0 226 0 7 0 226 0 11 0 226 0 19 2 17 0 24 0 226 0 67] 
#[0 0 230 0 3 0 4 0 7 0 11 0 19 0 24 0 26 0 67] 
#[0 0 234 0 3 0 4 0 7 0 11 0 19 0 20 0 24 0 26 0 67] 
#[1 0 145 0 1 0 149 0 2 0 153 0 10 0 161 0 13 0 165 0 14 0 169 0 15 0 173 0 16 0 61 0 20 0 177 0 21 0 181 0 22 0 185 0 23 0 65 0 29 0 189 0 30 0 225 0 46 2 21 0 48 2 21 0 49 0 209 0 50 0 209 0 53 0 217 0 56 0 221 0 59 0 225 0 61 0 229 0 62 0 233 0 63] 
#[0 0 238 0 1 0 2 0 3 0 4 0 7 0 9 0 13 0 14 0 15 0 16 0 19 0 20 0 21 0 22 0 23 0 24 0 26 0 30] 
#[0 0 242 0 1 0 2 0 3 0 4 0 7 0 9 0 13 0 14 0 15 0 16 0 19 0 20 0 21 0 22 0 23 0 24 0 26 0 30] 
#[0 0 246 0 1 0 2 0 3 0 4 0 7 0 9 0 13 0 14 0 15 0 16 0 19 0 20 0 21 0 22 0 23 0 24 0 26 0 30] 
#[0 0 250 0 1 0 2 0 3 0 4 0 7 0 9 0 13 0 14 0 15 0 16 0 19 0 20 0 21 0 22 0 23 0 24 0 26 0 30] 
#[0 0 254 0 1 0 2 0 4 0 8 0 10 0 12 0 13 0 14 0 15 0 16 0 17 0 18 0 20 0 21 0 22 0 23 0 29 0 30 0 67] 
#[0 1 2 0 1 0 2 0 3 0 4 0 7 0 9 0 13 0 14 0 15 0 16 0 19 0 20 0 21 0 22 0 23 0 24 0 26 0 30] 
#[0 1 6 0 1 0 2 0 3 0 4 0 7 0 9 0 13 0 14 0 15 0 16 0 19 0 20 0 21 0 22 0 23 0 24 0 26 0 30] 
#[0 1 10 0 1 0 2 0 3 0 4 0 7 0 9 0 13 0 14 0 15 0 16 0 19 0 20 0 21 0 22 0 23 0 24 0 26 0 30] 
#[0 1 14 0 1 0 2 0 3 0 4 0 7 0 9 0 13 0 14 0 15 0 16 0 19 0 20 0 21 0 22 0 23 0 24 0 26 0 30] 
#[0 1 18 0 1 0 2 0 3 0 4 0 7 0 9 0 13 0 14 0 15 0 16 0 19 0 20 0 21 0 22 0 23 0 24 0 26 0 30] 
#[0 1 22 0 1 0 2 0 3 0 4 0 7 0 9 0 13 0 14 0 15 0 16 0 19 0 20 0 21 0 22 0 23 0 24 0 26 0 30] 
#[1 0 10 0 1 0 10 0 2 0 10 0 4 0 10 0 8 0 10 0 10 0 10 0 12 0 10 0 13 0 10 0 14 0 10 0 15 0 10 0 16 0 10 0 20 0 10 0 21 0 10 0 22 0 10 0 23 0 10 0 29 0 10 0 30 2 25 0 36 0 10 0 67] 
#[0 1 26 0 67] 
#[1 0 145 0 1 2 29 0 2 2 33 0 3 2 37 0 10 0 161 0 13 0 165 0 14 0 169 0 15 2 41 0 16 2 45 0 20 0 177 0 21 0 181 0 22 0 185 0 23 2 49 0 24 2 53 0 25 2 57 0 26 2 61 0 29 0 189 0 30 2 65 0 31 2 73 0 63 2 73 0 66] 
#[1 2 77 0 11 2 81 0 21] 
#[0 2 85 0 19] 
#[0 2 89 0 19] 
#[0 1 30 0 3 0 4 0 7 0 11 0 19 0 20 0 24 0 26 0 67] 
#[0 1 34 0 5 0 11 0 17 0 18] 
#[0 1 38 0 3 0 4 0 7 0 11 0 19 0 20 0 24 0 26 0 67] 
#[1 0 61 0 20 0 65 0 29 2 93 0 62] 
#[0 1 42 0 3 0 4 0 7 0 11 0 19 0 20 0 24 0 26 0 67] 
#[1 0 6 0 1 0 6 0 2 0 6 0 4 0 6 0 10 0 6 0 11 0 6 0 12 0 6 0 13 0 6 0 14 0 6 0 15 0 6 0 16 0 37 0 17 0 41 0 18 0 6 0 20 0 6 0 21 0 6 0 22 0 6 0 23 0 6 0 29 0 6 0 30 2 97 0 39 0 49 0 40] 
#[1 0 61 0 20 0 65 0 29 2 101 0 41 0 93 0 62] 
#[0 1 46 0 11 0 67] 
#[0 2 105 0 19] 
#[1 0 145 0 1 0 149 0 2 0 153 0 10 0 161 0 13 0 165 0 14 0 169 0 15 0 173 0 16 0 66 0 19 0 61 0 20 0 177 0 21 0 181 0 22 0 185 0 23 0 65 0 29 0 189 0 30 0 225 0 46 1 233 0 48 1 233 0 49 0 209 0 50 0 209 0 53 0 217 0 56 0 221 0 59 0 225 0 61 0 229 0 62 0 233 0 63] 
#[1 0 145 0 1 0 149 0 2 0 153 0 10 0 161 0 13 0 165 0 14 0 169 0 15 0 173 0 16 0 61 0 20 0 177 0 21 0 181 0 22 0 185 0 23 0 65 0 29 0 189 0 30 0 225 0 46 2 109 0 48 2 109 0 49 0 209 0 50 0 209 0 53 0 217 0 56 0 221 0 59 0 225 0 61 0 229 0 62 0 233 0 63] 
#[0 1 50 0 4 0 11 0 19 0 67] 
#[1 1 89 0 20 1 73 0 24 1 77 0 26 2 113 0 52 2 117 0 54 2 113 0 57 2 113 0 60] 
#[0 1 54 0 3 0 4 0 7 0 11 0 19 0 24 0 67] 
#[1 1 58 0 3 1 58 0 4 1 58 0 7 1 58 0 11 1 58 0 19 1 58 0 24 1 77 0 26 1 85 0 57 1 58 0 67] 
#[1 1 62 0 3 1 62 0 4 1 62 0 7 1 62 0 11 1 62 0 19 1 89 0 20 1 62 0 24 1 77 0 26 1 97 0 57 1 101 0 60 1 62 0 67] 
#[1 1 66 0 3 1 66 0 4 1 66 0 7 1 66 0 11 1 66 0 19 1 89 0 20 1 66 0 24 1 77 0 26 1 109 0 57 1 113 0 60 1 66 0 67] 
#[0 0 146 0 3 0 4 0 7 0 11 0 19 0 20 0 24 0 26 0 67] 
#[0 1 70 0 3 0 4 0 7 0 11 0 19 0 24 0 26 0 67] 
#[1 1 74 0 3 1 74 0 4 1 74 0 7 1 74 0 11 1 74 0 19 1 89 0 20 1 74 0 24 1 74 0 26 1 101 0 60 1 74 0 67] 
#[1 1 78 0 3 1 78 0 4 1 78 0 7 1 78 0 11 1 78 0 19 1 89 0 20 1 78 0 24 1 78 0 26 1 113 0 60 1 78 0 67] 
#[1 0 145 0 1 0 149 0 2 0 153 0 10 0 161 0 13 0 165 0 14 0 169 0 15 0 173 0 16 0 61 0 20 0 177 0 21 0 181 0 22 0 185 0 23 0 65 0 29 0 189 0 30 1 253 0 46 2 129 0 55 1 245 0 56 1 249 0 59 1 253 0 61 1 253 0 62 0 233 0 63] 
#[0 1 82 0 3 0 4 0 11 0 19 0 67] 
#[1 0 18 0 1 0 18 0 2 0 97 0 4 0 113 0 8 0 18 0 10 0 18 0 12 0 18 0 13 0 18 0 14 0 18 0 15 0 18 0 16 0 18 0 20 0 18 0 21 0 18 0 22 0 18 0 23 0 18 0 29 0 18 0 30 2 133 0 42 0 105 0 43 0 109 0 45 0 18 0 67] 
#[1 0 162 0 1 0 162 0 2 0 162 0 3 0 162 0 10 0 162 0 13 0 162 0 14 0 162 0 15 0 162 0 16 0 162 0 20 0 162 0 21 0 162 0 22 0 162 0 23 0 162 0 24 0 162 0 25 0 162 0 26 0 162 0 29 0 162 0 30 0 162 0 31 2 137 0 65] 
#[0 1 86 0 1 0 2 0 3 0 4 0 7 0 9 0 10 0 11 0 13 0 14 0 15 0 16 0 19 0 20 0 21 0 22 0 23 0 24 0 25 0 26 0 29 0 30 0 31 0 67] 
#[1 0 166 0 11 0 166 0 21 2 141 0 64] 
#[1 2 145 0 20 2 149 0 29] 
#[1 1 90 0 1 1 90 0 2 1 90 0 3 2 153 0 6 1 90 0 10 1 90 0 13 1 90 0 14 1 90 0 15 1 90 0 16 1 90 0 20 1 90 0 21 1 90 0 22 1 90 0 23 1 90 0 24 1 90 0 25 1 90 0 26 1 90 0 29 1 90 0 30 1 90 0 31] 
#[0 1 94 0 1 0 2 0 3 0 10 0 13 0 14 0 15 0 16 0 20 0 21 0 22 0 23 0 24 0 25 0 26 0 29 0 30 0 31] 
#[0 1 98 0 1 0 2 0 3 0 10 0 13 0 14 0 15 0 16 0 20 0 21 0 22 0 23 0 24 0 25 0 26 0 29 0 30 0 31] 
#[0 1 102 0 1 0 2 0 3 0 10 0 13 0 14 0 15 0 16 0 20 0 21 0 22 0 23 0 24 0 25 0 26 0 29 0 30 0 31] 
#[0 1 106 0 1 0 2 0 3 0 10 0 13 0 14 0 15 0 16 0 20 0 21 0 22 0 23 0 24 0 25 0 26 0 29 0 30 0 31] 
#[0 1 110 0 1 0 2 0 3 0 10 0 13 0 14 0 15 0 16 0 20 0 21 0 22 0 23 0 24 0 25 0 26 0 29 0 30 0 31] 
#[0 1 114 0 1 0 2 0 3 0 10 0 13 0 14 0 15 0 16 0 20 0 21 0 22 0 23 0 24 0 25 0 26 0 29 0 30 0 31] 
#[0 1 118 0 1 0 2 0 3 0 10 0 13 0 14 0 15 0 16 0 20 0 21 0 22 0 23 0 24 0 25 0 26 0 29 0 30 0 31] 
#[0 1 122 0 1 0 2 0 3 0 4 0 7 0 9 0 10 0 11 0 13 0 14 0 15 0 16 0 19 0 20 0 21 0 22 0 23 0 24 0 25 0 26 0 29 0 30 0 31 0 67] 
#[0 1 126 0 11 0 21] 
#[0 1 130 0 1 0 2 0 3 0 4 0 7 0 9 0 10 0 11 0 13 0 14 0 15 0 16 0 19 0 20 0 21 0 22 0 23 0 24 0 25 0 26 0 29 0 30 0 31 0 67] 
#[0 1 134 0 1 0 2 0 3 0 4 0 7 0 9 0 10 0 11 0 13 0 14 0 15 0 16 0 19 0 20 0 21 0 22 0 23 0 24 0 25 0 26 0 29 0 30 0 31 0 67] 
#[0 1 138 0 5 0 11 0 17 0 18] 
#[0 2 157 0 11] 
#[1 0 97 0 4 2 161 0 17 0 137 0 45] 
#[0 1 142 0 3 0 4 0 7 0 11 0 19 0 20 0 24 0 26 0 67] 
#[1 0 97 0 4 0 18 0 11 2 165 0 43 0 109 0 45 0 18 0 67] 
#[0 1 146 0 3 0 4 0 7 0 11 0 19 0 67] 
#[1 1 150 0 3 1 150 0 4 1 150 0 7 1 150 0 11 1 150 0 19 2 17 0 24 1 150 0 67] 
#[0 1 154 0 3 0 4 0 7 0 11 0 19 0 67] 
#[0 1 158 0 3 0 4 0 7 0 11 0 19 0 67] 
#[0 1 162 0 3 0 4 0 7 0 11 0 19 0 24 0 67] 
#[0 1 166 0 67] 
#[1 0 145 0 1 2 29 0 2 2 169 0 3 2 37 0 10 0 161 0 13 0 165 0 14 0 169 0 15 2 41 0 16 2 45 0 20 0 177 0 21 0 181 0 22 0 185 0 23 2 49 0 24 2 53 0 25 2 57 0 26 2 61 0 29 0 189 0 30 2 65 0 31 2 73 0 63 2 73 0 66] 
#[1 2 173 0 11 2 81 0 21] 
#[0 2 177 0 19] 
#[0 2 181 0 19] 
#[0 1 170 0 1 0 2 0 3 0 10 0 13 0 14 0 15 0 16 0 20 0 21 0 22 0 23 0 24 0 25 0 26 0 29 0 30 0 31] 
#[0 1 174 0 3 0 4 0 7 0 11 0 19 0 20 0 24 0 26 0 67] 
#[1 0 18 0 1 0 18 0 2 0 97 0 4 0 18 0 10 0 18 0 11 0 18 0 12 0 18 0 13 0 18 0 14 0 18 0 15 0 18 0 16 0 18 0 20 0 18 0 21 0 18 0 22 0 18 0 23 0 18 0 29 0 18 0 30 2 185 0 42 0 105 0 43 0 109 0 45] 
#[0 1 178 0 11 0 67] 
#[0 1 182 0 1 0 2 0 3 0 10 0 13 0 14 0 15 0 16 0 20 0 21 0 22 0 23 0 24 0 25 0 26 0 29 0 30 0 31] 
#[0 1 186 0 1 0 2 0 3 0 10 0 13 0 14 0 15 0 16 0 20 0 21 0 22 0 23 0 24 0 25 0 26 0 29 0 30 0 31] 
#[0 1 190 0 1 0 2 0 3 0 10 0 13 0 14 0 15 0 16 0 20 0 21 0 22 0 23 0 24 0 25 0 26 0 29 0 30 0 31] 
#[0 1 194 0 1 0 2 0 3 0 10 0 13 0 14 0 15 0 16 0 20 0 21 0 22 0 23 0 24 0 25 0 26 0 29 0 30 0 31] 
#[0 2 189 0 11] 
#[0 1 198 0 3 0 4 0 7 0 11 0 19 0 20 0 24 0 26 0 67]
	).
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
GraciousParser >> reduceActionForKeywordMessageSend1: nodes [
	^ #createMessageNodeFrom:
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
	^ (GraciousMethodNode
		selector: (nodes at: 1) value asSymbol
		arguments: #()
		body:
			(nodes at: 2) last) yourself
]

{ #category : #'generated-reduction actions' }
GraciousParser >> reduceActionForMethod2: nodes [
	^ (GraciousMethodNode
		selector: (nodes at: 1) first
		arguments: (nodes at: 1) last
		body:
			(nodes at: 2) last) yourself
]

{ #category : #'generated-reduction actions' }
GraciousParser >> reduceActionForMethod3: nodes [
	^ (GraciousMethodNode
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
GraciousParser >> reduceActionForVariable1: nodes [
	^ RBVariableNode named: (nodes at: 1) value
]
