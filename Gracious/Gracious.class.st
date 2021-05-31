"
!Gracious Language

I'm Gracious, a (WIP) language aiming to provide a more ""naturalistic"" interaction for building simulations, domain models and providing game extending capabilities.

By naturalistic, I mean that I aim to have this features, one syntactic and two semantic:

- Expressions that read like sentences, allowing spaces on identifiers and messages  (as inspired by *Polite>https://zenodo.org/record/61578#.WAdi7x8xD0o*, but closer to Pharo)
- Prototyped object model
- Actor-model based

!! Syntax
To try out the parser:
${example:GraciousExamples>>#parseSimpleMethods}$

Some changes from the standard Pharo syntax:

# Spaces are allowed on local variable names. I use periods to separate variables on declaration:
# Unary messages also allow spaces. I employ commas to separate the target from the message:
# I differentiate between single-keyword messages, and multi-keyword messages. On both, and like on unary messages, I use commas after the target:
# One exception to the target-comma rule is when the target is a predicate, an unary message ending with ""?"":
# On multi-keyword messages, I use semicollons to separate keywords:
# The semicollon also allows me to combine single-keyword messages and multi-keyword ones:
# The last message syntax to have two kinds is binary, with the unicode flavour, with a higher precedence (still bellow unary messages):  


"
Class {
	#name : #Gracious,
	#superclass : #Object,
	#category : #Gracious
}
