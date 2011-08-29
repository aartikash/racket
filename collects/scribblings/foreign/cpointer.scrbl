#lang scribble/doc
@(require "utils.rkt")

@title[#:tag "foreign:tagged-pointers"]{Tagged C Pointer Types}

The unsafe @racket[cpointer-has-tag?] and @racket[cpointer-push-tag!]
operations manage tags to distinguish pointer types.

@defproc*[([(_cpointer [tag any/c]
                       [ptr-type ctype? _pointer]
                       [scheme-to-c (any/c . -> . any/c) values]
                       [c-to-scheme (any/c . -> . any/c) values])
            ctype]
           [(_cpointer/null [tag any/c]
                            [ptr-type ctype? _pointer]
                            [scheme-to-c (any/c . -> . any/c) values]
                            [c-to-scheme (any/c . -> . any/c) values])
            ctype])]{

Construct a kind of a pointer that gets a specific tag when converted
to Racket, and accept only such tagged pointers when going to C.  An
optional @racket[ptr-type] can be given to be used as the base pointer
type, instead of @racket[_pointer].

By convention, tags should be symbols named after the
type they point to.  For example, the cpointer @racket[_car] should
be created using @racket['car] as the key.
Pointer tags are checked with @racket[cpointer-has-tag?] and changed
with @racket[cpointer-push-tag!] which means that other tags are
preserved.  Specifically, if a base @racket[ptr-type] is given and is
itself a @racket[_cpointer], then the new type will handle pointers
that have the new tag in addition to @racket[ptr-type]'s tag(s).  When
the tag is a pair, its first value is used for printing, so the most
recently pushed tag which corresponds to the inheriting type will be
displayed.

@racket[_cpointer/null] is similar to @racket[_cpointer] except that
it tolerates @cpp{NULL} pointers both going to C and back.  Note that
@cpp{NULL} pointers are represented as @racket[#f] in Racket, so they
are not tagged.}


@defform*[[(define-cpointer-type _id)
           (define-cpointer-type _id ptr-type-expr)
           (define-cpointer-type _id ptr-type-expr 
                                 scheme-to-c-expr c-to-scheme-expr)]]{

A macro version of @racket[_cpointer] and @racket[_cpointer/null],
using the defined name for a tag string, and defining a predicate
too. The @racket[_id] must start with @litchar{_}.

The optional expressions produce optional arguments to @racket[_cpointer].

In addition to defining @racket[_id] to a type generated by
@racket[_cpointer], @racket[_id]@racketidfont{/null} is bound to a
type produced by @racket[_cpointer/null] type. Finally,
@racketvarfont{id}@racketidfont{?}  is defined as a predicate, and
@racketvarfont{id}@racketidfont{-tag} is defined as an accessor to
obtain a tag. The tag is the string form of @racketvarfont{id}.}

@defproc*[([(cpointer-has-tag? [cptr any/c] [tag any/c]) boolean?]
           [(cpointer-push-tag! [cptr any/c] [tag any/c]) void])]{

These two functions treat pointer tags as lists of tags.  As described
in @secref["foreign:pointer-funcs"], a pointer tag does not have any
role, except for Racket code that uses it to distinguish pointers;
these functions treat the tag value as a list of tags, which makes it
possible to construct pointer types that can be treated as other
pointer types, mainly for implementing inheritance via upcasts (when a
struct contains a super struct as its first element).

The @racket[cpointer-has-tag?] function checks whether if the given
@racket[cptr] has the @racket[tag]. A pointer has a tag @racket[tag]
when its tag is either @racket[eq?] to @racket[tag] or a list that
contains (in the sense of @racket[memq]) @racket[tag].

The @racket[cpointer-push-tag!] function pushes the given @racket[tag]
value on @racket[cptr]'s tags.  The main properties of this operation
are: (a) pushing any tag will make later calls to
@racket[cpointer-has-tag?] succeed with this tag, and (b) the pushed tag
will be used when printing the pointer (until a new value is pushed).
Technically, pushing a tag will simply set it if there is no tag set,
otherwise push it on an existing list or an existing value (treated as
a single-element list).}
