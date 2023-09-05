# boolean-solver
A tiny little boolean solver.

## Running:

If you have the ocaml compiler installed, it should just be a matter of 
```
$ ocamlc sve.ml
$ ./a.out
```
or use ocamlopt if you want, I don't make the rules :P

It's probably also small enough to copy paste into an online ocaml runner like `try.ocamlpro.com` if you wanted

## The language:

Input is in the form of a simple little language. The program gives you an example, but for clarity here's a quick description:
```
& = and
| = or
^ = xor
~ = not
parens = grouping
```

Simple as.
Here's a few examples:
```
a & ~b
b & (a | b)
a ^ (a ^ b)
(~a) & b | (c ^ a)
```
All variables with the same name are assumed to be the same. You can use any single char variables a-zA-Z.

## How it works:

As hinted at by the filename `sve.ml`, it's based off SVE or successive variable elimination, which follows the concept that because booleans only have two possible states, then if you have
```
(a | b) & ~a
```
then one of replacing all instances of `a` with false and all instances of `a` with true must be valid, ie:
```
either:
(T | b) & ~T
or
(F | b) & ~F
```
you can keep appling this till there are no more variables left, then find the one that's valid (ie evals to true), then you have:
```
(a | b) & ~a
(F | T) & ~F
```
and it's just a matter of walking both trees and assigning generating the `a = F` and `b = T` to print out.
