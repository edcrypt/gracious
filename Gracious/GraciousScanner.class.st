Class {
	#name : #GraciousScanner,
	#superclass : #SmaCCScanner,
	#category : #Gracious
}

{ #category : #'generated-initialization' }
GraciousScanner class >> initializeKeywordMap [
	keywordMap := Dictionary new.
	#(#(20 'false' 12) #(20 'nil' 14) #(20 'true' 11) #(26 '||' 15))
		do: [ :each | 
			(keywordMap at: each first ifAbsentPut: [ Dictionary new ])
				at: (each at: 2)
				put: each last ].
	^ keywordMap
]

{ #category : #generated }
GraciousScanner class >> states [
	^ #(#default)
]

{ #category : #generated }
GraciousScanner >> binarySymbolId [
	^ 26
]

{ #category : #generated }
GraciousScanner >> emptySymbolTokenId [
	^ 65
]

{ #category : #generated }
GraciousScanner >> errorTokenId [
	^ 66
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
	((currentCharacter between: $0 and: $9)
		or: [ (currentCharacter between: $A and: $Z)
				or: [ currentCharacter == $_
						or: [ (currentCharacter between: $a and: $z)
								or: [ ('ªµº' includes: currentCharacter)
										or: [ (currentCharacter
												between: (Character value: 192)
												and: (Character value: 214))
												or: [ (currentCharacter
														between: (Character value: 216)
														and: (Character value: 246))
														or: [ currentCharacter >= (Character value: 248) ] ] ] ] ] ] ])
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
	(currentCharacter between: $0 and: $9)
		or: [ (currentCharacter between: $A and: $Z)
				or: [ currentCharacter == $_
						or: [ (currentCharacter between: $a and: $z)
								or: [ ('ªµº' includes: currentCharacter)
										or: [ (currentCharacter
												between: (Character value: 192)
												and: (Character value: 214))
												or: [ (currentCharacter
														between: (Character value: 216)
														and: (Character value: 246))
														or: [ currentCharacter >= (Character value: 248) ] ] ] ] ] ] ] ]
		whileTrue.
	^ self reportLastMatch
]

{ #category : #generated }
GraciousScanner >> scan5 [
	self step.
	((currentCharacter between: $A and: $Z)
		or: [ currentCharacter == $_
				or: [ (currentCharacter between: $a and: $z)
						or: [ ('ªµº' includes: currentCharacter)
								or: [ (currentCharacter
										between: (Character value: 192)
										and: (Character value: 214))
										or: [ (currentCharacter
												between: (Character value: 216)
												and: (Character value: 246))
												or: [ currentCharacter >= (Character value: 248) ] ] ] ] ] ])
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
			((currentCharacter between: $0 and: $9)
				or: [ (currentCharacter between: $A and: $Z)
						or: [ currentCharacter == $_
								or: [ (currentCharacter between: $a and: $z)
										or: [ ('ªµº' includes: currentCharacter)
												or: [ (currentCharacter
														between: (Character value: 192)
														and: (Character value: 214))
														or: [ (currentCharacter
																between: (Character value: 216)
																and: (Character value: 246))
																or: [ currentCharacter >= (Character value: 248) ] ] ] ] ] ] ])
				ifTrue: [ ^ self scan6 ].
			^ self reportLastMatch ].
	(currentCharacter between: $0 and: $9)
		or: [ (currentCharacter between: $A and: $Z)
				or: [ currentCharacter == $_
						or: [ (currentCharacter between: $a and: $z)
								or: [ ('ªµº' includes: currentCharacter)
										or: [ (currentCharacter
												between: (Character value: 192)
												and: (Character value: 214))
												or: [ (currentCharacter
														between: (Character value: 216)
														and: (Character value: 246))
														or: [ currentCharacter >= (Character value: 248) ] ] ] ] ] ] ] ]
		whileTrue.
	^ self reportLastMatch
]

{ #category : #generated }
GraciousScanner >> scan7 [
	self recordMatch: #(24).
	self step.
	((currentCharacter between: $A and: $Z)
		or: [ currentCharacter == $_
				or: [ (currentCharacter between: $a and: $z)
						or: [ ('ªµº' includes: currentCharacter)
								or: [ (currentCharacter
										between: (Character value: 192)
										and: (Character value: 214))
										or: [ (currentCharacter
												between: (Character value: 216)
												and: (Character value: 246))
												or: [ currentCharacter >= (Character value: 248) ] ] ] ] ] ])
		ifTrue: [ ^ self scan8 ].
	^ self reportLastMatch
]

{ #category : #generated }
GraciousScanner >> scan8 [
	[ self step.
	currentCharacter == $:
		ifTrue: [ self recordMatch: #(25).
			self step.
			((currentCharacter between: $A and: $Z)
				or: [ currentCharacter == $_
						or: [ (currentCharacter between: $a and: $z)
								or: [ ('ªµº' includes: currentCharacter)
										or: [ (currentCharacter
												between: (Character value: 192)
												and: (Character value: 214))
												or: [ (currentCharacter
														between: (Character value: 216)
														and: (Character value: 246))
														or: [ currentCharacter >= (Character value: 248) ] ] ] ] ] ])
				ifTrue: [ ^ self scan8 ].
			^ self reportLastMatch ].
	(currentCharacter isSeparator
		or: [ currentCharacter == Character pageUp ])
		ifTrue: [ [ self step.
			currentCharacter isSeparator
				or: [ currentCharacter == Character pageUp ] ] whileTrue.
			((currentCharacter between: $0 and: $9)
				or: [ (currentCharacter between: $A and: $Z)
						or: [ currentCharacter == $_
								or: [ (currentCharacter between: $a and: $z)
										or: [ ('ªµº' includes: currentCharacter)
												or: [ (currentCharacter
														between: (Character value: 192)
														and: (Character value: 214))
														or: [ (currentCharacter
																between: (Character value: 216)
																and: (Character value: 246))
																or: [ currentCharacter >= (Character value: 248) ] ] ] ] ] ] ])
				ifTrue: [ ^ self scan8 ].
			^ self reportLastMatch ].
	(currentCharacter between: $0 and: $9)
		or: [ (currentCharacter between: $A and: $Z)
				or: [ currentCharacter == $_
						or: [ (currentCharacter between: $a and: $z)
								or: [ ('ªµº' includes: currentCharacter)
										or: [ (currentCharacter
												between: (Character value: 192)
												and: (Character value: 214))
												or: [ (currentCharacter
														between: (Character value: 216)
														and: (Character value: 246))
														or: [ currentCharacter >= (Character value: 248) ] ] ] ] ] ] ] ]
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
	currentCharacter == $(
		ifTrue: [ ^ self recordAndReportMatch: #(4 31) ].
	currentCharacter == $)
		ifTrue: [ ^ self recordAndReportMatch: #(3 31) ].
	currentCharacter == $-
		ifTrue: [ ^ self scanForTokenX2 ].
	currentCharacter == $.
		ifTrue: [ ^ self recordAndReportMatch: #(5 31) ].
	currentCharacter == $:
		ifTrue: [ ^ self scanForTokenX10 ].
	currentCharacter == $;
		ifTrue: [ ^ self recordAndReportMatch: #(6 31) ].
	^ self scanForTokenX14
]

{ #category : #generated }
GraciousScanner >> scanForTokenX1 [
	self recordMatch: #(20 31).
	self step.
	^ self scanForTokenX1X1
]

{ #category : #generated }
GraciousScanner >> scanForTokenX10 [
	self recordMatch: #(18 31).
	self step.
	currentCharacter == $=
		ifTrue: [ ^ self recordAndReportMatch: #(13) ].
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
	(currentCharacter == $!
		or: [ (currentCharacter between: $% and: $&)
				or: [ (currentCharacter between: $* and: $+)
						or: [ ('/=' includes: currentCharacter)
								or: [ (currentCharacter between: $? and: $@)
										or: [ '\~' includes: currentCharacter ] ] ] ] ])
		ifTrue: [ ^ self scanForTokenX3 ].
	(currentCharacter isSafeForHTTP
		or: [ ('ªµº' includes: currentCharacter)
				or: [ (currentCharacter
						between: (Character value: 192)
						and: (Character value: 214))
						or: [ (currentCharacter
								between: (Character value: 216)
								and: (Character value: 246))
								or: [ currentCharacter >= (Character value: 248) ] ] ] ])
		ifTrue: [ ^ self scanForTokenX1 ].
	^ self recordAndReportMatch: #(31)
]

{ #category : #generated }
GraciousScanner >> scanForTokenX14 [
	currentCharacter == $<
		ifTrue: [ ^ self scanForTokenX6 ].
	currentCharacter == $>
		ifTrue: [ ^ self scanForTokenX5 ].
	currentCharacter == $[
		ifTrue: [ ^ self recordAndReportMatch: #(17 31) ].
	currentCharacter == $]
		ifTrue: [ ^ self recordAndReportMatch: #(19 31) ].
	currentCharacter == $^
		ifTrue: [ ^ self recordAndReportMatch: #(16 31) ].
	currentCharacter == ${
		ifTrue: [ ^ self recordAndReportMatch: #(8 31) ].
	currentCharacter == $|
		ifTrue: [ ^ self scanForTokenX4 ].
	currentCharacter == $}
		ifTrue: [ ^ self recordAndReportMatch: #(2 31) ].
	(currentCharacter between: $0 and: $9)
		ifTrue: [ ^ self scanForTokenX9 ].
	(currentCharacter isSeparator
		or: [ currentCharacter == Character null ])
		ifTrue: [ ^ self scanForTokenX7 ].
	^ self scanForTokenX13
]

{ #category : #generated }
GraciousScanner >> scanForTokenX1X1 [
	currentCharacter == $.
		ifTrue: [ ^ self scan5 ].
	currentCharacter == $:
		ifTrue: [ ^ self scan7 ].
	(currentCharacter isSeparator
		or: [ currentCharacter == Character pageUp ])
		ifTrue: [ ^ self scan3 ].
	((currentCharacter between: $0 and: $9)
		or: [ (currentCharacter between: $A and: $Z)
				or: [ currentCharacter == $_
						or: [ (currentCharacter between: $a and: $z)
								or: [ ('ªµº' includes: currentCharacter)
										or: [ (currentCharacter
												between: (Character value: 192)
												and: (Character value: 214))
												or: [ (currentCharacter
														between: (Character value: 216)
														and: (Character value: 246))
														or: [ currentCharacter >= (Character value: 248) ] ] ] ] ] ] ])
		ifTrue: [ ^ self scan4 ].
	^ self reportLastMatch
]

{ #category : #generated }
GraciousScanner >> scanForTokenX2 [
	self recordMatch: #(26 31).
	self step.
	(currentCharacter between: $0 and: $9)
		ifTrue: [ [ self recordMatch: #(22).
			self step.
			currentCharacter between: $0 and: $9 ] whileTrue.
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
GraciousScanner >> scanForTokenX3 [
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
	self recordMatch: #(10 26 31).
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
	self recordMatch: #(7 26 31).
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
	self recordMatch: #(21 31).
	self step.
	(currentCharacter between: $0 and: $9)
		ifTrue: [ [ self recordMatch: #(21).
			self step.
			currentCharacter between: $0 and: $9 ] whileTrue ].
	^ self reportLastMatch
]

{ #category : #generated }
GraciousScanner >> tokenActions [
	^ #(nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil #whitespace #comment)
]
