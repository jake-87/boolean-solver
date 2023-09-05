# boolean-solver
A tiny little boolean solver.

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
