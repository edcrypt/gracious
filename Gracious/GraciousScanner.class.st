Class {
	#name : #GraciousScanner,
	#superclass : #SmaCCScanner,
	#category : #Gracious
}

{ #category : #'generated-initialization' }
GraciousScanner class >> initializeKeywordMap [
	keywordMap := Dictionary new.
	#(#(20 'false' 13) #(20 'nil' 14) #(20 'true' 15) #(26 '||' 18))
		do: [ :each | 
			(keywordMap at: each first ifAbsentPut: [ Dictionary new ])
				at: (each at: 2)
				put: each last ].
	^ keywordMap
]

{ #category : #generated }
GraciousScanner >> binarySymbolId [
	^ 26
]

{ #category : #generated }
GraciousScanner >> emptySymbolTokenId [
	^ 67
]

{ #category : #generated }
GraciousScanner >> errorTokenId [
	^ 68
]

{ #category : #generated }
GraciousScanner >> nameId [
	^ 20
]

{ #category : #generated }
GraciousScanner >> negativeNumberId [
	^ 22
]

{ #category : #generated }
GraciousScanner >> numberId [
	^ 21
]

{ #category : #generated }
GraciousScanner >> scan1 [
	[ self step.
	currentCharacter == $'
		ifTrue: [ ^ self scan2 ].
	true ] whileTrue
]

{ #category : #generated }
GraciousScanner >> scan2 [
	self recordMatch: #(23).
	self step.
	currentCharacter == $'
		ifTrue: [ ^ self scan1 ].
	^ self reportLastMatch
]

{ #category : #generated }
GraciousScanner >> scan3 [
	[ self step.
	currentCharacter isSeparator
		or: [ currentCharacter == Character pageUp ] ] whileTrue.
	(currentCharacter isAlphaNumeric or: [ currentCharacter == $_ ])
		ifTrue: [ ^ self scan4 ].
	^ self reportLastMatch
]

{ #category : #generated }
GraciousScanner >> scan4 [
	[ self recordMatch: #(20).
	self step.
	currentCharacter == $.
		ifTrue: [ ^ self scan5 ].
	currentCharacter == $:
		ifTrue: [ ^ self scan7 ].
	(currentCharacter isSeparator
		or: [ currentCharacter == Character pageUp ])
		ifTrue: [ ^ self scan3 ].
	currentCharacter isAlphaNumeric or: [ currentCharacter == $_ ] ]
		whileTrue.
	^ self reportLastMatch
]

{ #category : #generated }
GraciousScanner >> scan5 [
	self step.
	(currentCharacter isLetter or: [ currentCharacter == $_ ])
		ifTrue: [ ^ self scan6 ].
	^ self reportLastMatch
]

{ #category : #generated }
GraciousScanner >> scan6 [
	[ self recordMatch: #(29).
	self step.
	currentCharacter == $.
		ifTrue: [ ^ self scan5 ].
	(currentCharacter isSeparator
		or: [ currentCharacter == Character pageUp ])
		ifTrue: [ [ self step.
			currentCharacter isSeparator
				or: [ currentCharacter == Character pageUp ] ] whileTrue.
			(currentCharacter isAlphaNumeric or: [ currentCharacter == $_ ])
				ifTrue: [ ^ self scan6 ].
			^ self reportLastMatch ].
	currentCharacter isAlphaNumeric or: [ currentCharacter == $_ ] ]
		whileTrue.
	^ self reportLastMatch
]

{ #category : #generated }
GraciousScanner >> scan7 [
	self recordMatch: #(24).
	self step.
	(currentCharacter isLetter or: [ currentCharacter == $_ ])
		ifTrue: [ ^ self scan8 ].
	^ self reportLastMatch
]

{ #category : #generated }
GraciousScanner >> scan8 [
	[ self step.
	currentCharacter == $:
		ifTrue: [ self recordMatch: #(25).
			self step.
			(currentCharacter isLetter or: [ currentCharacter == $_ ])
				ifTrue: [ ^ self scan8 ].
			^ self reportLastMatch ].
	(currentCharacter isSeparator
		or: [ currentCharacter == Character pageUp ])
		ifTrue: [ [ self step.
			currentCharacter isSeparator
				or: [ currentCharacter == Character pageUp ] ] whileTrue.
			(currentCharacter isAlphaNumeric or: [ currentCharacter == $_ ])
				ifTrue: [ ^ self scan8 ].
			^ self reportLastMatch ].
	currentCharacter isAlphaNumeric or: [ currentCharacter == $_ ] ]
		whileTrue.
	^ self reportLastMatch
]

{ #category : #generated }
GraciousScanner >> scanForToken [
	self step.
	currentCharacter == $"
		ifTrue: [ ^ self scanForTokenX8 ].
	currentCharacter == $#
		ifTrue: [ ^ self recordAndReportMatch: #(1 31) ].
	currentCharacter == $$
		ifTrue: [ ^ self scanForTokenX12 ].
	currentCharacter == $'
		ifTrue: [ ^ self scanForTokenX11 ].
	^ self scanForTokenX14
]

{ #category : #generated }
GraciousScanner >> scanForTokenX1 [
	self recordMatch: #(26 31).
	self step.
	currentCharacter isDigit
		ifTrue: [ [ self recordMatch: #(22).
			self step.
			currentCharacter isDigit ] whileTrue.
			^ self reportLastMatch ].
	(currentCharacter == $!
		or: [ (currentCharacter between: $% and: $&)
				or: [ (currentCharacter between: $* and: $+)
						or: [ ('-/' includes: currentCharacter)
								or: [ (currentCharacter between: $< and: $@)
										or: [ '\|~' includes: currentCharacter ] ] ] ] ])
		ifTrue: [ [ self recordMatch: #(26).
			self step.
			currentCharacter == $!
				or: [ (currentCharacter between: $% and: $&)
						or: [ (currentCharacter between: $* and: $+)
								or: [ ('-/' includes: currentCharacter)
										or: [ (currentCharacter between: $< and: $@)
												or: [ '\|~' includes: currentCharacter ] ] ] ] ] ]
				whileTrue ].
	^ self reportLastMatch
]

{ #category : #generated }
GraciousScanner >> scanForTokenX10 [
	self recordMatch: #(21 31).
	self step.
	currentCharacter isDigit
		ifTrue: [ [ self recordMatch: #(21).
			self step.
			currentCharacter isDigit ] whileTrue ].
	^ self reportLastMatch
]

{ #category : #generated }
GraciousScanner >> scanForTokenX11 [
	self recordMatch: #(31).
	self step.
	currentCharacter == $'
		ifTrue: [ ^ self scan2 ].
	^ self scan1
]

{ #category : #generated }
GraciousScanner >> scanForTokenX12 [
	self recordMatch: #(31).
	self step.
	^ self recordAndReportMatch: #(30)
]

{ #category : #generated }
GraciousScanner >> scanForTokenX13 [
	currentCharacter == $|
		ifTrue: [ ^ self scanForTokenX3 ].
	currentCharacter == $}
		ifTrue: [ ^ self recordAndReportMatch: #(19 31) ].
	currentCharacter isDigit
		ifTrue: [ ^ self scanForTokenX10 ].
	(currentCharacter isSeparator
		or: [ currentCharacter == Character null ])
		ifTrue: [ ^ self scanForTokenX7 ].
	(currentCharacter == $!
		or: [ (currentCharacter between: $% and: $&)
				or: [ (currentCharacter between: $* and: $+)
						or: [ ('/=' includes: currentCharacter)
								or: [ (currentCharacter between: $? and: $@)
										or: [ '\~' includes: currentCharacter ] ] ] ] ])
		ifTrue: [ ^ self scanForTokenX2 ].
	(currentCharacter isLetter or: [ currentCharacter == $_ ])
		ifTrue: [ ^ self scanForTokenX6 ].
	^ self recordAndReportMatch: #(31)
]

{ #category : #generated }
GraciousScanner >> scanForTokenX14 [
	currentCharacter == $(
		ifTrue: [ ^ self recordAndReportMatch: #(2 31) ].
	currentCharacter == $)
		ifTrue: [ ^ self recordAndReportMatch: #(3 31) ].
	currentCharacter == $-
		ifTrue: [ ^ self scanForTokenX1 ].
	currentCharacter == $.
		ifTrue: [ ^ self recordAndReportMatch: #(4 31) ].
	currentCharacter == $:
		ifTrue: [ ^ self scanForTokenX9 ].
	currentCharacter == $;
		ifTrue: [ ^ self recordAndReportMatch: #(7 31) ].
	currentCharacter == $<
		ifTrue: [ ^ self scanForTokenX5 ].
	currentCharacter == $>
		ifTrue: [ ^ self scanForTokenX4 ].
	currentCharacter == $[
		ifTrue: [ ^ self recordAndReportMatch: #(10 31) ].
	currentCharacter == $]
		ifTrue: [ ^ self recordAndReportMatch: #(11 31) ].
	currentCharacter == $^
		ifTrue: [ ^ self recordAndReportMatch: #(12 31) ].
	currentCharacter == ${
		ifTrue: [ ^ self recordAndReportMatch: #(16 31) ].
	^ self scanForTokenX13
]

{ #category : #generated }
GraciousScanner >> scanForTokenX2 [
	self recordMatch: #(26 31).
	self step.
	(currentCharacter == $!
		or: [ (currentCharacter between: $% and: $&)
				or: [ (currentCharacter between: $* and: $+)
						or: [ ('-/' includes: currentCharacter)
								or: [ (currentCharacter between: $< and: $@)
										or: [ '\|~' includes: currentCharacter ] ] ] ] ])
		ifTrue: [ [ self recordMatch: #(26).
			self step.
			currentCharacter == $!
				or: [ (currentCharacter between: $% and: $&)
						or: [ (currentCharacter between: $* and: $+)
								or: [ ('-/' includes: currentCharacter)
										or: [ (currentCharacter between: $< and: $@)
												or: [ '\|~' includes: currentCharacter ] ] ] ] ] ]
				whileTrue ].
	^ self reportLastMatch
]

{ #category : #generated }
GraciousScanner >> scanForTokenX3 [
	self recordMatch: #(17 26 31).
	self step.
	(currentCharacter == $!
		or: [ (currentCharacter between: $% and: $&)
				or: [ (currentCharacter between: $* and: $+)
						or: [ ('-/' includes: currentCharacter)
								or: [ (currentCharacter between: $< and: $@)
										or: [ '\|~' includes: currentCharacter ] ] ] ] ])
		ifTrue: [ [ self recordMatch: #(26).
			self step.
			currentCharacter == $!
				or: [ (currentCharacter between: $% and: $&)
						or: [ (currentCharacter between: $* and: $+)
								or: [ ('-/' includes: currentCharacter)
										or: [ (currentCharacter between: $< and: $@)
												or: [ '\|~' includes: currentCharacter ] ] ] ] ] ]
				whileTrue ].
	^ self reportLastMatch
]

{ #category : #generated }
GraciousScanner >> scanForTokenX4 [
	self recordMatch: #(9 26 31).
	self step.
	(currentCharacter == $!
		or: [ (currentCharacter between: $% and: $&)
				or: [ (currentCharacter between: $* and: $+)
						or: [ ('-/' includes: currentCharacter)
								or: [ (currentCharacter between: $< and: $@)
										or: [ '\|~' includes: currentCharacter ] ] ] ] ])
		ifTrue: [ [ self recordMatch: #(26).
			self step.
			currentCharacter == $!
				or: [ (currentCharacter between: $% and: $&)
						or: [ (currentCharacter between: $* and: $+)
								or: [ ('-/' includes: currentCharacter)
										or: [ (currentCharacter between: $< and: $@)
												or: [ '\|~' includes: currentCharacter ] ] ] ] ] ]
				whileTrue ].
	^ self reportLastMatch
]

{ #category : #generated }
GraciousScanner >> scanForTokenX5 [
	self recordMatch: #(8 26 31).
	self step.
	(currentCharacter == $!
		or: [ (currentCharacter between: $% and: $&)
				or: [ (currentCharacter between: $* and: $+)
						or: [ ('-/' includes: currentCharacter)
								or: [ (currentCharacter between: $< and: $@)
										or: [ '\|~' includes: currentCharacter ] ] ] ] ])
		ifTrue: [ [ self recordMatch: #(26).
			self step.
			currentCharacter == $!
				or: [ (currentCharacter between: $% and: $&)
						or: [ (currentCharacter between: $* and: $+)
								or: [ ('-/' includes: currentCharacter)
										or: [ (currentCharacter between: $< and: $@)
												or: [ '\|~' includes: currentCharacter ] ] ] ] ] ]
				whileTrue ].
	^ self reportLastMatch
]

{ #category : #generated }
GraciousScanner >> scanForTokenX6 [
	self recordMatch: #(20 31).
	self step.
	currentCharacter == $.
		ifTrue: [ ^ self scan5 ].
	currentCharacter == $:
		ifTrue: [ ^ self scan7 ].
	(currentCharacter isSeparator
		or: [ currentCharacter == Character pageUp ])
		ifTrue: [ ^ self scan3 ].
	(currentCharacter isAlphaNumeric or: [ currentCharacter == $_ ])
		ifTrue: [ ^ self scan4 ].
	^ self reportLastMatch
]

{ #category : #generated }
GraciousScanner >> scanForTokenX7 [
	self recordMatch: #(27 31).
	self step.
	(currentCharacter isSeparator
		or: [ currentCharacter == Character null ])
		ifTrue: [ [ self recordMatch: #(27).
			self step.
			currentCharacter isSeparator
				or: [ currentCharacter == Character null ] ] whileTrue ].
	^ self reportLastMatch
]

{ #category : #generated }
GraciousScanner >> scanForTokenX8 [
	self recordMatch: #(31).
	self step.
	currentCharacter == $"
		ifTrue: [ ^ self recordAndReportMatch: #(28) ].
	true
		ifTrue: [ [ self step.
			currentCharacter == $"
				ifTrue: [ ^ self recordAndReportMatch: #(28) ].
			true ] whileTrue ].
	^ self reportLastMatch
]

{ #category : #generated }
GraciousScanner >> scanForTokenX9 [
	self recordMatch: #(5 31).
	self step.
	currentCharacter == $=
		ifTrue: [ ^ self recordAndReportMatch: #(6) ].
	^ self reportLastMatch
]

{ #category : #generated }
GraciousScanner >> tokenActions [
	^ #(nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil #whitespace #comment)
]
