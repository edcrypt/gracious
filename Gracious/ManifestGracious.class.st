"
Please describe the package using the class comment of the included manifest class. The manifest class also includes other additional metadata for the package. These meta data are used by other tools such as the SmalllintManifestChecker and the critics Browser
"
Class {
	#name : #ManifestGracious,
	#superclass : #PackageManifest,
	#category : #'Gracious-Manifest'
}

{ #category : #'code-critics' }
ManifestGracious class >> ruleLiteralArrayContainsCommaRuleV1FalsePositive [
	^ #(#(#(#RGMethodDefinition #(#GrTokenizerTest #testScan #false)) #'2021-09-24T23:17:54.483704-03:00') )
]

{ #category : #'code-critics' }
ManifestGracious class >> ruleLongMethodsRuleV1FalsePositive [
	^ #(#(#(#RGMethodDefinition #(#GrTokenizerTest #testScan #false)) #'2021-09-25T13:00:09.866242-03:00') )
]

{ #category : #'code-critics' }
ManifestGracious class >> ruleReTemporaryVariableCapitalizationRuleV1FalsePositive [
	^ #(#(#(#RGMethodDefinition #(#GrTokenizer #initialize #false)) #'2021-09-22T13:19:40.270485-03:00') )
]
