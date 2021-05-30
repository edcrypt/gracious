"
I store metadata for this package. These meta data are used by other tools such as the SmalllintManifestChecker and the critics Browser
"
Class {
	#name : #ManifestGracious,
	#superclass : #PackageManifest,
	#category : #'Gracious-Manifest'
}

{ #category : #'code-critics' }
ManifestGracious class >> ruleGRTemporaryNeitherReadNorWrittenRuleV1FalsePositive [
	^ #(#(#(#RGMethodDefinition #(#GraciousParserTests #testSimpleElementsMethodWithMultipleVars #false)) #'2021-05-30T11:33:11.600446-03:00') )
]

{ #category : #'code-critics' }
ManifestGracious class >> ruleRBBadMessageRuleV1FalsePositive [
	^ #(#(#(#RGMethodDefinition #(#Object #graciousPerform: #false)) #'2021-05-27T17:18:57.020864-03:00') )
]

{ #category : #'code-critics' }
ManifestGracious class >> ruleRBTempsReadBeforeWrittenRuleV1FalsePositive [
	^ #(#(#(#RGMethodDefinition #(#GraciousParserTests #testsimpleElementsMultiKeywordMethod #false)) #'2021-05-30T11:31:40.571527-03:00') #(#(#RGMethodDefinition #(#GraciousParserTests #testSimpleElementsMethodWithMultipleVars #false)) #'2021-05-30T11:35:17.879406-03:00') #(#(#RGMethodDefinition #(#GraciousParserTests #testSimpleElementsMethod #false)) #'2021-05-30T13:12:12.534437-03:00') #(#(#RGMethodDefinition #(#GraciousParserTests #testSimpleElementsKeywordMethod #false)) #'2021-05-30T13:15:21.778901-03:00') )
]
