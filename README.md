# Hexagony

Hexagony is (to the best of the author's knowledge) the first two-dimensional [esoteric programming language](https://esolangs.org/wiki/Main_Page) on a hexagonal grid. Furthermore, the memory layout *also* resembles a (separate) hexagonal grid. The name is a portmanteau of "hexagon" and "agony", because I expect programming in it to be quite painful.

Hexagony is Turing-complete as any Brainfuck program can be translated to Hexagony with some effort.

## Overview

Hexagony has a number of important (and partially unique) concepts which need introduction.

### Source code

The source code consists of printable ASCII characters and line feeds and is interpreted as a [pointy-topped hexagonal grid](http://www.redblobgames.com/grids/hexagons/#basics), where each cell holds a single-character command (similar to how "normal" 2D languages like Befunge or ><> interpret their source as a rectangular grid). The source code must always be a regular hexagon. A convenient way to represent hexagonal layouts in ASCII is to insert a space after each cell and offset every other row. A hexagon of side-length 3 could be represented as

      . . .
     . . . .
    . . . . .
     . . . .
      . . .

where each `.` could be a command (incidentally, `.` is a no-op in Hexagony). The next larger possible source code would be

       . . . .
      . . . . .
     . . . . . .
    . . . . . . .
     . . . . . .
      . . . . .
       . . . .

Because of this restriction, the number of commands in the source code will always be a [centered hexagonal number](https://oeis.org/A003215). For reference, the first 10 centered hexagonal numbers are:

    1, 7, 19, 37, 61, 91, 127, 169, 217, 271
    
When reading a source file, Hexagony first strips all whitespace characters. Then each `` ` `` (backtick) are removed as well, but the characters after those backticks are marked with a "debug flag". Then the remaining source code is padded to the next centered hexagonal number with no-ops and rearranged it into a regular hexagon. This means that the spaces in the examples above were only inserted for cosmetic reasons but don't have to be included in the source code. The following three programs are identical:

  
      a b c
     d e f g
    h . . . .
     . . . .
      . . .

<!-- -->

    abcdefgh...........
    
<!-- -->

    abcdefgh
    
But note that

    abcdefg
    
would instead be the short form of 

     a b
    c d e
     f g

As an example for the debug flag, in the following code, the interpreter would print detailed debug information whenever the `?` is executed:
     
      . . .
     . .`? .
    . . . . . 
     . . . .
      . . .

The exact presentation of the debug information is up to the interpreter, but it should be possible to read off the following information:

- The positions and directions of the instruction pointers.
- Which instruction pointer is active.
- The values and positions of all non-zero memory edges.
- The position and orientation of the memory pointer.

These concepts are explained below.

Interpreters are allowed to omit this feature (and just strip backticks along with whitespace) provided they allow step-by-step debugging with access to the above information.

### Control flow

Hexagony has 6 instruction pointers (IPs). They start out in the corners of the source code, pointing along the edge in the clockwise direction. Only one IP is active at any given time, initially the one in the top left corner (moving to the right). There are commands which let you switch to another IP, in which case the current IP will make another move (but not execute the next command), and then the new IP will start by executing its current command before making its first move. Each IP has an index from `0` to `5`:

        0 . 1
       . . . .
      5 . . . 2
       . . . .
        4 . 3

The direction of an IP can be changed via several commands which resemble mirrors and branches.

The edges of the hexagon wrap around to the opposite edge. In all of the following grids, if an IP starts out on the `a` moving towards the `b`, the letters will be executed in alphabetical order before returning to `a`:

       . . . .          . a . .          . . k .          . g . .   
      a b c d e        . . b . .        . . j . .        . h . . a  
     . . . . . .      g . . c . .      . . i . . e      . i . . b . 
    . . . . . . .    . h . . d . .    . . h . . d .    . j . . c . .
     f g h i j k      . i . . e .      . g . . c .      k . . d . . 
      . . . . .        . j . . f        f . . b .        . . e . .  
       . . . .          . k . .          . . a .          . f . .   
       
If the IP leaves the grid through a corner *in the direction of the corner* there are two possibilities:

    -> . . . .   
      . . . . .  
     . . . . . . 
    . . . . . . . ->
     . . . . . . 
      . . . . .  
    -> . . . .   
    
If the current memory edge (see below) is positive, the IP will continue on the bottom row. If it's zero or negative, the IP will continue on the top row. For the other 5 corners, just rotate the picture. Note that if the IP leaves the grid in a corner but doesn't point at a corner, the wrapping happens normally. This means that there are two paths that lead *to* each corner:

          . . . . ->   
         . . . . .  
        . . . . . . 
    -> . . . . . . .
        . . . . . . 
         . . . . .  
          . . . . ->
          
### Memory model

Picture an infinite hexagonal grid (which is separate from the source code). Each *edge* of the grid has a value (a signed arbitrary-precision integer), which is initially zero. That is, the memory layout is essentially a [line graph](https://en.wikipedia.org/wiki/Line_graph) of a hexagonal grid.

The memory pointer (MP) points at one of the edges and has an orientation along that edge. At any time, there are three relevant edges: the one pointed at (the *current* memory edge), and its left and right neighbours (i.e. the edges connected to the vertex the MP's orientation points to).

It is possible to manipulate the current edge in several ways. The unary operators operate on the current edge only. The binary operators take the left and right neighbours as operands and store their result in the current edge. It is also possible to copy either the left or the right neighbour depending on the value of the current edge (essentially a ternary operator). The MP can reverse its direction or move to the left or right neighbour (without reversing its direction). There is also a conditional move, which chooses the neighbour to move to based on the value of the current edge.

## Command list

The following is a complete reference of all commands available in Hexagony.

### Special characters

- **Letters:** All 52 letter characters are reserved and will set the current memory cell to their ASCII code.
- `.` is a no-op: the IP will simply pass through.
- `@` terminates the program.

### Arithmetic

- `0-9` will multiply the current memory edge by 10 and add the corresponding digit. If the current edge has a negative value, the digit is subtracted instead of added. This allows you to write decimal numbers in the source code despite each digit being processed separately.
- `)` increments the current memory edge.
- `(` decrements the current memory edge.
- `+` sets the current memory edge to the sum of the left and right neighbours.
- `-` sets the current memory edge to the difference of the left and right neighbours (`left - right`).
- `*` sets the current memory edge to the product of the left and right neighbours.
- `:` sets the current memory edge to the quotient of the left and right neighbours (`left / right`, rounded towards negative infinity).
- `%` sets the current memory edge to the modulo of the left and right neighbours (`left % right`, the sign of the result is the same as the sign of `right`).
- `~` multiplies the current memory edge by `-1`.

### I/O

- `,` reads a single byte from STDIN and sets the current memory edge to its value. Returns `-1` once EOF is reached.
- `?` reads and discards from STDIN until a digit, a `-` or a `+` is found. Then reads as many characters as possible to form a valid (signed) decimal integer and sets the current memory edge to its value. Returns `0` once EOF is reached.
- `;` writes the current memory edge's value (modulo 256) to STDOUT as a byte.
- `!` writes the decimal representation of the current memory edge to STDOUT.

### Control flow

- `$` is a jump. When executed, the IP completely ignores the next command in its current direction. This is like Befunge's `#`.
- `_`, `|`, `/`, `\` are mirrors. They reflect the IP in the direction you'd expect. For completeness, the following table shows how they deflect an incoming IP. The top row corresponds to the current direction of the IP, the left column to the mirror, and the table cell shows the outgoing direction of the IP:
 
        cmd   E SE SW  W NW NE

         /   NW  W SW SE  E NE
         \   SW SE  E NE NW  W
         _    E NE NW  W SW SE
         |    W SW SE  E NE NW
 
- `<` and `>` act as either mirrors or branches, depending on the incoming direction:

        cmd   E SE SW  W NW NE

         <   ?? NW  W  E  W SW 
         >    W  E NE ?? SE  E
         
  The cells indicated as `??` are where they act as branches. In these cases, if the current memory edge is positive, the IP takes a 60 degree right turn (e.g. `<` turns `E` into `SE`). If the current memory edge is zero or negative, the IP takes a 60 degree left turn (e.g. `<` turns `E` into `NE`).
- `[` switches to the previous IP (wrapping around from `0` to `5`).
- `]` switches to the next IP (wrapping around from `5` to `0`).
- `#` takes the current memory edge modulo `6` and switches to the IP with that index.

### Memory manipulation

- `{` moves the MP to the left neighbour.
- `}` moves the MP to the right neighbour.
- `"` moves the MP backwards and to the left. This is equivalent to `=}=`.
- `'` moves the MP backwards and to the right. This is equivalent to `={=`.
- `=` reverses the direction of the MP. (This doesn't affect the current memory edge, but changes which edges are considered the left and right neighbour.)
- `^` moves the MP to the left neighbour if the current edge is zero or negative and to the right neighbour if it's positive.
- `&` copies the value of left neighbour into the current edge if the current edge is zero or negative and the value of the right neighbour if it's positive.

## Interpreter features

To run a program, invoke the interpreter with the source code's file name as a command-line argument, e.g.

    $ ruby ./interpreter.rb ./examples/hw.hxg

The `-d` flag to activate `` ` `` annotations can be added in front of the source code, e.g.

    $ ruby ./interpreter.rb -d ./examples/hw.hxg

The interpreter also has a verbose debug mode (like an additional debug level beyond activating `` ` `` annotations) which can be switched on with the command-line flag `-D`. If this flag is set, the interpreter will print detailed diagnostic information after every tick of the program.

It can also be invoked with `-g N` where `N` is a positive integer, in which case it will not run any code but instead print an "empty" source file (i.e. filled with `.`) of side-length `N`, e.g.

    $ ruby ./interpreter.rb -g 5
         . . . . .
        . . . . . .
       . . . . . . .
      . . . . . . . .
     . . . . . . . . .
      . . . . . . . .
       . . . . . . .
        . . . . . .
         . . . . .

This is quite convenient for getting started when writing a larger program.
