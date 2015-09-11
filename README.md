# Hexagony

Hexagony is (to the best of the author's knowledge) the first two-dimensional [esoteric programming language](https://esolangs.org/wiki/Main_Page) on a hexagonal grid. Furthermore, the memory layout *also* resembles a (separate) hexagonal grid.

Labyrinth is Turing-complete as any Brainfuck program can be translated to Hexagony with some effort.

## Overview

Hexagony has a number of important (and partially unique) concepts which need introduction.

### Source code

The source code is interpreted as a [pointy-topped hexagonal grid](http://www.redblobgames.com/grids/hexagons/#basics), where each cell holds a single-character command (similar to how "normal" 2D languages like Befunge or ><> interpret their source as a rectangular grid). The source code must always be a regular hexagon. A convenient way to represent hexagonal layouts in ASCII is to insert a space after each cell and offset every other row. A hexagon of side-length 3 could be represented as

      . . .
     . . . .
    . . . . .
     . . . .
      . . .

where each `.` could be a command (`.`, incidentally is a no-op in Hexagony). The next larger possible source code would be

       . . . .
      . . . . .
     . . . . . .
    . . . . . . .
     . . . . . .
      . . . . .
       . . . .

Because of this restriction, the number of commands in the source code will always be a [centred hexagonal number](https://oeis.org/A003215). For reference, the first 10 centred hexagonal numbers are:

    1, 7, 19, 37, 61, 91, 127, 169, 217, 271
    
When reading a source file, Hexagony strips all the whitespace from it, pads it to the next centre hexagonal number with no-ops and then rearranges it into a hexagon. This means that the spaces in the examples above were only inserted for cosmetic reasons but don't have to be included in the source code. The following three programs are identical:

  
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
     
### Control flow

Hexagony has 6 instruction pointers (IPs). They start out in the corners of the source code, pointing along the edge in the clockwise direction. Only one IP is active at any given time, initially the one in the top left corner (moving to the right). There are commands which let you switch to another IP, in which case the current IP will make another move (but not execute the next command), and then the new IP will start by executing its current command before making its first move.

The direction of an IP can be changed via several commands which resemble mirrors and branches.

The edges of the hexagon wrap around to the opposite edge. All of the following grids, if an IP starts out on the `a` moving towards the `b`, the letters will be executed in order before returning to `a`:

       . . . .          . a . .          . . k .          . g . .   
      a b c d e        . . b . .        . . j . .        . h . . a  
     . . . . . .      g . . c . .      . . i . . e      . i . . b . 
    . . . . . . .    . h . . d . .    . . h . . d .    . j . . c . .
     f g h i j k      . i . . e .      . g . . c .      k . . d . . 
      . . . . .        . j . . f        f . . b .        . . e . .  
       . . . .          . k . .          . . a .          . f . .   
       
If the IP leaves the grid through corner *in the direction of the corner* there are two possibilities:

    -> . . . .   
      . . . . .  
     . . . . . . 
    . . . . . . . ->
     . . . . . . 
      . . . . .  
    -> . . . .   
    
If the current memory cell (see below) is positive, the IP will continue on the bottom row. If it's zero or negative, the IP will continue on the top row. For the other 5 corners, just rotate the picture. Note that if the IP leaves the grid in a corner but doesn't point at a corner, the wrapping happens normally. This means that there are two paths that lead *to* each corner:

          . . . . ->   
         . . . . .  
        . . . . . . 
    -> . . . . . . .
        . . . . . . 
         . . . . .  
          . . . . ->
          
### Memory model

Picture an infinite hexagonal grid (which is separate from the source code). Each *edge* of the grid has a value (a signed arbitrary-precision integer), which is initially zero. That is, the memory layout is essentially [line graph](https://en.wikipedia.org/wiki/Line_graph) of a hexagonal grid.

The memory pointer (MP) points at one of the edges and has a direction along that edge. At any time, there are three relevant edges: the one pointed at (the *current* memory edge), and the left and right neighbours (i.e. the edges connected to the vertex the MP's direction points to).

It is be possible to manipulate the current edge, either directly via unary operators or as the result of an operation applied to the two neighbours via binary operators. It is also possible to copy either the left or the right neighbour depending on the current edge (essentially a ternary operator). The MP can reverse its direction or move to the left or a right neighbour (without reversing its direction). There is also a conditional move, which moves chooses the neighbour to move to based on the value of the current edge.

## Command list

The following is a complete reference of all commands available in Hexagony.

### Special characters

- `` ` `` is stripped from the source code together with all whitespace. However, it sets a debug flag on the *following* command. When the interpreter is invoked with the `-d` flag, it will print useful debug information whenever a marked command is executed. E.g. in the following code, the debug flag is set on the `?` command:

         . . . .
        . . . . . 
