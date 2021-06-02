"
!Gracious Language

I'm Gracious, a (WIP) language aiming to provide a more ""naturalistic"" interaction for building simulations and domain models, and providing game extending capabilities.

My main design principle are:
 - The code itself that you write is part of the modeling you are writing. If it's not expressive enough, or if you have to mix abstraction levels, those problem affect your modelling.
 - The language and the rest of the development tooling are part of a whole and should be designed together, with Developer Experience as the main focus.
 - You can't have a trully holistic design if you can't extend and mold your tools.
 - To be an expressive tool in the hands of humans, a language should feel naturalistic.

By naturalistic, I mean that I aim to have this features, one syntactic and two semantic:

- Expressions that read like sentences, allowing spaces on identifiers and messages  (as inspired by *Polite>https://zenodo.org/record/61578#.WAdi7x8xD0o*, but closer to Pharo)
- Prototypes-based object model with differential inheritance
- Actor-model based concurrency

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

!!Semantics

!!! Prototyping

!!! Collaborators

!!! Special Messages

!!! Actor-Model
"
Class {
	#name : #Gracious,
	#superclass : #Object,
	#category : #Gracious
}
