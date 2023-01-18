#lang scribble/rhombus/manual
@(import: 
    "common.rhm" open
    "macro.rhm")

@(def dots: @rhombus(..., ~bind))
@(fun list(x, ...): [x, ...])

@title{Syntax Classes}

@doc(
  defn.macro 'syntax.class $name $maybe_args
              | $pattern_case
              | ...'
  defn.macro 'syntax.class $name $maybe_args:
                $class_clause
                ...'

  grammar maybe_args:
    ($identifier_binding, ...)
    ($identifier_binding, ..., & $rest_identifier)
    #,(epsilon)

  grammar class_clause:
    #,(@rhombus(pattern, ~syntax_class_clause)) $pattern_cases
    #,(@rhombus(description, ~syntax_class_clause)) $desc_rhs
    #,(@rhombus(error_mode, ~syntax_class_clause)) $error_mode_rhs
    #,(@rhombus(kind, ~syntax_class_clause)) $kind_rhs
    #,(@rhombus(fields, ~syntax_class_clause)): $identifier ...; ...

  grammar pattern_cases:
    $pattern_case
    Z| $pattern_case
     | ...

  grammar pattern_case:
    $syntax_pattern
    $syntax_pattern: $pattern_body; ...

  grammar pattern_body:
    #,(@rhombus(field, ~pattern_clause)) $field_decl
    #,(@rhombus(match_def, ~pattern_clause)) $also_decl
    #,(@rhombus(match_when, ~pattern_clause)) $when_rhs
    #,(@rhombus(match_unless, ~pattern_clause)) $unless_rhs
    $body
){

 Defines a @deftech{syntax class} that can be used in syntax patterns with
 @rhombus(::, ~unquote_bind). A syntax class can optionally have arguments, in which
 case every use of the syntax class with @rhombus(::, ~unquote_bind) must supply
 arguments; an @rhombus(identifier_binding) is like a @rhombus(kwopt_binding, ~var) for
 @rhombus(fun), but each binding must be a plain @rhombus(identifier) (i.e., annotations
 and general pattern matching are not supported). Identifiers bound as arguments
 are visible in @rhombus(clause) bodies.

 Syntax forms matched by the syntax class are described by
 @rhombus(pattern_case) alternatives. The
 @rhombus(pattern, ~syntax_class_clause) clause is optional in the sense
 that pattern alternatives can be inlined directly in the
 @rhombus(syntax.class) form, but the @rhombus(pattern, ~syntax_class_clause)
 clause form makes room for additional options as clauses. Each kind of
 @rhombus(class_clause) alternative can be supplied at most once, and
 @rhombus(pattern, ~syntax_class_clause) is required.

 An optional @rhombus(description,  ~syntax_class_clause) clause
 provides a description of the syntax class which is used to produce
 clearer error messages when a term is rejected by the syntax class. The
 result of the @rhombus(block) block must be a string or
 @rhombus(#false), where @rhombus(#false) is equivalent to not specifying
 a @rhombus(description, ~syntax_class_clause). When
 @rhombus(error_mode, ~syntax_class_clause) is declared as
 @rhombus(~opaque), then parsing error messages will not refer to the
 interior details of the pattern cases; insteda, messages will use the
 decsription string.

 An optional @rhombus(kind, ~syntax_class_clause) declaration indicates
 the context within a
 pattern where a syntax class can be used, and it determines the kind
 of match that each pattern specifies. See @rhombus(kind, ~syntax_class_clause)
 for details. The default is inferred from the shapes for @rhombus(pattern_case)s.

 A @rhombus(fields, ~syntax_class_clause) declaration limits the set of pattern variables that
 are accessible from the class, where variables used in all
 @rhombus(pattern_case)s are otherwise available (as described next).
 Each identifier in @rhombus(fields, ~syntax_class_clause) must be a field name that would be
 made available.

 The @rhombus(pattern_case) alternatives are the main content
 of a syntax class.
 After the class @rhombus(name) is defined, then when a
 variable @rhombus(id, ~var) is bound through a
 @seclink("stxobj"){syntax pattern} with
 @rhombus($(#,(@rhombus(id, ~var)) :: #,(@rhombus(name, ~var)))),
 it matches a syntax object that matches any of the
 @rhombus(pattern_case)s in the definition of
 @rhombus(stx_class_id ,~var), where the @rhombus(pattern_case)s are tried
 first to last. A pattern variable that is included in all of the
 @rhombus(pattern_case)s is a field of the syntax class, which is
 accessed from a binding @rhombus(id, ~var) using dot notation. For
 example, if the pattern variable is @rhombus(var, ~var), its value is
 accessed from @rhombus(id, ~var) using
 @list(@rhombus(id, ~var), @rhombus(.), @rhombus(var, ~var)).

 A @rhombus(pattern_case) matches when

@itemlist(

 @item{the @rhombus(syntax_pattern) at the start of the
  @rhombus(pattern_case) matches;}

 @item{every @rhombus(match_def, ~pattern_clause) clause within the
  @rhombus(pattern_case) body also matches;}

 @item{every @rhombus(match_when, ~pattern_clause) clause within the
  @rhombus(pattern_case) body has a true value for its right-hand side;
  and}

 @item{every @rhombus(match_unless, ~pattern_clause) clause within
  the @rhombus(pattern_case) body has a false value for its right-hand
  side.}

)

 Every pattern variable in the initial @rhombus(syntax_pattern) of a
 @rhombus(pattern_case) as well as evey variable in every
 @rhombus(match_def, ~pattern_clause) is a candiate field name, as
 long as it is also a candiate in all other @rhombus(syntax_pattern)s
 within the syntax class. In addition, names declared with
 @rhombus(field, ~pattern_clause) are also candidates. A field must have
 the same repetition depth across all pattern cases, unless it is
 excluded from the syntax class's result through a
 @rhombus(fields, ~syntax_class_clause) declaration that does not list
 the field.

 The body of a @rhombus(pattern_case) can include other definitions and
 expressions. Those definitions and expressions can use pattern variables
 bound in the main @rhombus(syntax_pattern) of the case as well as any
 preceding @rhombus(match_def, ~pattern_clause) clause or a field
 declared by a preceding @rhombus(field, ~pattern_clause). Consecutive
 definitions and expressions within a @rhombus(pattern_case) form a
 definition context, but separated sets of definitions and expressions
 can refer only to definitions in earlier sets.

 A variable bound with a syntax class (within a syntax pattern) can be
 used without dot notation. In that case, the result for
 @rhombus(~sequence) mode is a sequence of syntax objects
 corresponding to the entire match of a @rhombus(syntax_pattern); use
 @rhombus(...) after a @rhombus($)-escaped reference to the variable
 in a syntax template. For other modes, the variable represents a
 single syntax object representing matched syntax.

@examples(
  ~eval: macro.make_for_meta_eval()
  meta:
    syntax.class Arithmetic
    | '$x + $y'
    | '$x - $y'
  expr.macro 'doubled_operands $(e :: Arithmetic)':
    values('$(e.x) * 2 + $(e.y) * 2', '')
  doubled_operands 3 + 5
  expr.macro 'add_one_to_expression $(e :: Arithmetic)':
    values('$e ... + 1', '')
  add_one_to_expression 2 + 2
  meta:
    syntax.class NTerms
    | '~one $a':
        field b = '0'
        field average = '$(Syntax.unwrap(a) / 2)'
    | '~two $a $b':
        def sum:
          Syntax.unwrap(a) + Syntax.unwrap(b)
        field average = '$(sum / 2)'
  expr.macro 'second_term $(e :: NTerms)':
    values(e.b, '')
  second_term ~two 1 2
  second_term ~one 3
  expr.macro 'average $(e :: NTerms)':
    values(e.average, '')
  average ~two 24 42
)

}


@doc(
  syntax_class_clause.macro 'pattern $pattern_cases'
  bind.macro 'pattern $pattern_cases'

  grammar pattern_cases:
    $pattern_case
    Z| $pattern_case
     | ...

  grammar pattern_case:
    $syntax_pattern
    $syntax_pattern: $pattern_body; ...
){

 The @rhombus(pattern, ~syntax_class_clause) clause form in
 @rhombus(syntax.class) describes the patterns that the class matches;
 see @rhombus(syntax.class) for more information. A
 @rhombus(pattern, ~syntax_class_clause) class with only a
 @rhombus(pattern_case) is a shorthand for writing the
 @rhombus(pattern_case) in a single @litchar{|} alternative.

 The binding variant of @rhombus(pattern , ~syntax_class_clause) (for
 direct use in a binding context) has the same syntax and matching rules
 as a @rhombus(pattern, ~syntax_class_clause) form in
 @rhombus(syntax.class), but with all fields exposed. In particular, a
 @rhombus(pattern_case) can have a block with
 @rhombus(match_def, ~pattern_clause),
 @rhombus(match_when, ~pattern_clause), and
 @rhombus(match_unless, ~pattern_clause) clauses that refine the match.

@examples(
  ~defn:
    fun simplify(e):
      match e
      | '($e)': simplify(e)
      | '0 + $e': simplify(e)
      | '$e + 0': simplify(e)
      | (pattern '$a + $b - $c':
           match_when same(simplify(b), simplify(c))):
          simplify(a)
      | (pattern '$a - $b + $c':
           match_when same(simplify(b), simplify(c))):
          simplify(a)
      | ~else: e
  ~defn:
    fun same(b, c):
      b.unwrap() == c.unwrap()
  ~repl:
    simplify('(1 + (2 + 0) - 2)')
    simplify('1 + 2 + 2')
)

}

@doc(
  syntax_class_clause.macro 'fields:
                               $identifier ...
                               ...'
){

 Limits the set of fields that are provided by a syntax class to the
 listed @rhombus(identifier)s. See @rhombus(syntax.class).

}


@doc(
  syntax_class_clause.macro 'description:
                               $body;
                               ...'
  syntax_class_clause.macro 'description: $expr'
){

 Configures a syntax class's description for error reporting. See
 @rhombus(syntax.class).

}


@doc(
  syntax_class_clause.macro 'error_mode: $error_mode_keyword'
  syntax_class_clause.macro 'error_mode $error_mode_keyword'
  grammar error_mode_keyword:
    ~opaque
    ~transparent
){

 Configures the way that failures to match a syntax class are reported.
 See @rhombus(syntax.class).

}


@doc(
  syntax_class_clause.macro 'kind: $kind_keyword'
  syntax_class_clause.macro 'kind $kind_keyword'

  grammar kind_keyword:
    ~term
    ~sequence
    ~group
    ~multi
    ~block
){

 Determines the contexts where a syntax class can be used and the kinds
 of matches that it produces:

@itemlist(

 @item{@rhombus(~term): each pattern case represents a single term, and
  the syntax class can be used in the same way at the
  @rhombus(Term, ~stxclass) syntax class.}

 @item{@rhombus(~sequence): each pattern case represents a sequence of
  terms that is spliced within a group. This is the default mode of a
  syntax class when no @rhombus(kind) is specified.}

 @item{@rhombus(~group): each pattern case represents a @tech{group},
  and the syntax class can be used in the same places as
  @rhombus(Group, ~stxclass) (i.e., alone within its group).}

 @item{@rhombus(~multi): each pattern case represents multiple groups, and the
  syntax class can be used in the same way at the
   @rhombus(Multi, ~stxclass) syntax class.}

 @item{@rhombus(~block): each pattern case represents a block, and the
  syntax class can be used in the same way at the
  @rhombus(Block, ~stxclass) syntax class}
)

 With @rhombus(~term), each pattern case must match only a single term,
 and with @rhombus(~block), each pattern case must be a block pattern.

 See also @rhombus(syntax.class).

}


@doc(
  pattern_clause.macro 'field $identifier_maybe_rep:
                          $body
                          ...'
  pattern_clause.macro 'field $identifier_maybe_rep = $expr'
  
  grammar identifier_maybe_rep:
    $identifier
    [$identifier_maybe_rep, $ellipsis]

  grammar ellipsis:
    #,(dots)
){

 Similar to @rhombus(def), but restricted to defining a plain identifier
 or a simple list repetition within a @rhombus(syntax.class) pattern
 case, and adds a field (or, at least, a cadndidate field) to the pattern
 case.

 The result of the right-hand @rhombus(body) sequence or @rhombus(expr)
 is not required to be a syntax object or have syntax objects in nested
 lists. If the field is referenced so that it's value is included in a
 syntax template, a non-sytax value is converted to syntax at that point.
 Otherwise, the field can be used directly to access non-syntax values.

 See also @rhombus(syntax.class).

}

@doc(
  pattern_clause.macro '«match_def '$pattern':
                           $body
                           ...»'
  pattern_clause.macro '«match_def '$pattern' = $expr»'
){

 Constrains a pattern case to match only when the right-hand
 @rhombus(body) or @rhombus(expr) matches @rhombus(pattern), and adds the
 pattern variables of @rhombus(pattern) to the set of (candidate) syntax
 class fields.

 See @rhombus(syntax.class).

}

@doc(
  pattern_clause.macro 'match_when:
                          $body
                          ...'
  pattern_clause.macro 'match_when $expr'

  pattern_clause.macro 'match_unless:
                          $body
                          ...'
  pattern_clause.macro 'match_unless $expr'
){

 Constrains a pattern case to match only when a @rhombus(body) or
 @rhombus(expr) produces a true value in the case of
 @rhombus(match_when, ~pattern_clause) or a false value in the case of
 @rhombus(match_unless, ~pattern_clause).

 See @rhombus(syntax.class).

}

