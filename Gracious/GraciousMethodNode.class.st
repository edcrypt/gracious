Class {
	#name : #GraciousMethodNode,
	#superclass : #RBMethodNode,
	#category : #Gracious
}

{ #category : #accessing }
GraciousMethodNode class >> formatterClass [
	^ FormatterClass ifNil: [FormatterClass := GraciousFormatter]
]

{ #category : #accessing }
GraciousMethodNode >> gtGraciousMethodTableFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Method details' translated;
		priority: 1;
		items: [ #(1 2 3) ];
		column: 'foo' text: [ :n | n ];
		column: 'bar' text: [ :n | n * 2 ];
		column: 'baz' text: [ :n | n + 2 ]
]
