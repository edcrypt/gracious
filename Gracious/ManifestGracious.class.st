"
I store metadata for this package. These meta data are used by other tools such as the SmalllintManifestChecker and the critics Browser
"
Class {
	#name : #ManifestGracious,
	#superclass : #PackageManifest,
	#category : #'Gracious-Manifest'
}

{ #category : #'code-critics' }
ManifestGracious class >> ruleRBBadMessageRuleV1FalsePositive [
	^ #(#(#(#RGMethodDefinition #(#Object #graciousPerform: #false)) #'2021-05-27T17:18:57.020864-03:00') )
]
