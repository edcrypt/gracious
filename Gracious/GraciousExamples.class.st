Class {
	#name : #GraciousExamples,
	#superclass : #Object,
	#category : #'Gracious-Gracious'
}

{ #category : #accessing }
GraciousExamples >> parseSimpleMethods [
	<gtExample>
	^ GraciousParser parseMethod: 'do it with: some argument
		| temporary variable |
		^ temporary variable'
]
