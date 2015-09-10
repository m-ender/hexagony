# coding: utf-8

require_relative 'grid'
require_relative 'coords'
require_relative 'direction'

class Hexagony

    class ProgramError < Exception; end

    def self.run(src, debug_level=0)
        new(src, debug_level).run
    end

    def initialize(src, debug_level=false)
        @debug_level = debug_level

        @grid = Grid.new(10)

        @tick = 0
    end

    def run
        # if !@ip
        #     return
        # end
        # loop do
        #     puts "\nTick #{@tick}:" if @debug_level > 1
        #     p @ip if @debug_level > 1
        #     cmd = cell @ip
        #     p cmd if @debug_level > 1
        #     if cmd[0] == :terminate
        #         break
        #     end
        #     process cmd
        #     puts @main*' ' + ' | ' + @aux.reverse*' ' if @debug_level > 1
        #     @dir = get_new_dir
        #     p @dir if @debug_level > 1
        #     @ip += @dir.vec

        #     @tick += 1
        # end
    end

    private

    def parse(src)
        lines = src.split($/)

        grid = lines.map{|l| l.chars.map{|c| OPERATORS[c]}}

        width = grid.map(&:size).max

        grid.each{|l| l.fill([:wall], l.length...width)}
    end

    def find_start
        start = nil
        @grid.each_with_index do |l,y|
            l.each_with_index do |c,x|
                if c[0] != :wall
                    start = Point2D.new(x,y)
                    break
                end
            end
            if start
                break
            end
        end

        start
    end

    def x
        @ip.x
    end

    def y
        @ip.y
    end

    def cell coords
        line = coords.y < 0 ? [] : @grid[coords.y] || []
        coords.x < 0 ? [:wall] : line[coords.x] || [:wall]
    end

    def push_main val
        @main << val
    end

    def push_aux val
        @aux << val
    end

    def pop_main
        @main.pop || 0
    end

    def pop_aux
        @aux.pop || 0
    end

    def peek_main
        @main[-1] || 0
    end

    def process cmd
        opcode, param = *cmd

        case opcode
        # Arithmetic
        when :push_zero
            push_main 0
        when :digit
            val = pop_main
            if val < 0
                push_main(val*10 - param)
            else
                push_main(val*10 + param)
            end
        when :inc
            push_main(pop_main+1)
        when :dec
            push_main(pop_main-1)
        when :add
            push_main(pop_main+pop_main)
        when :sub
            a = pop_main
            b = pop_main
            push_main(b-a)
        when :mul
            push_main(pop_main*pop_main)
        when :div
            a = pop_main
            b = pop_main
            push_main(b/a)
        when :mod
            a = pop_main
            b = pop_main
            push_main(b%a)
        when :neg
            push_main(-pop_main)
        when :bit_and
            push_main(pop_main&pop_main)
        when :bit_or
            push_main(pop_main|pop_main)
        when :bit_xor
            push_main(pop_main^pop_main)
        when :bit_not
            push_main(~pop_main)

        # Stack manipulation
        when :dup
            push_main(peek_main)
        when :pop
            pop_main
        when :move_to_main
            push_main(pop_aux)
        when :move_to_aux
            push_aux(pop_main)
        when :swap_tops
            a = pop_aux
            m = pop_main
            push_aux m
            push_main a
        when :depth
            push_main(@main.size)

        # I/O
        when :input_char
            byte = read_byte
            push_main(byte ? byte.ord : -1)
        when :output_char
            $> << pop_main.chr
        when :input_int
            val = 0
            sign = 1
            loop do
                byte = read_byte
                case byte
                when '+'
                    sign = 1
                when '-'
                    sign = -1
                when '0'..'9', nil
                    @next_byte = byte
                else
                    next
                end
                break
            end

            loop do
                byte = read_byte
                if byte && byte[/\d/]
                    val = val*10 + byte.to_i
                else
                    @next_byte = byte
                    break
                end
            end

            push_main(sign*val)
        when :output_int
            $> << pop_main
        when :output_newline
            puts

        # Grid manipulation
        when :rotate_west
            offset = pop_main
            @grid[(y+offset) % @height].rotate!(1)
            
            if offset == 0
                @ip += West.new.vec
                if x < 0
                    @ip.x = @width-1
                end
            end

            puts @grid.map{|l| l.map{|c| OPERATORS.invert[c]}*''} if @debug_level > 1
        when :rotate_east
            offset = pop_main
            @grid[(y+offset) % @height].rotate!(-1)
            
            if offset == 0
                @ip += East.new.vec
                if x >= @width
                    @ip.x = 0
                end
            end

            puts @grid.map{|l| l.map{|c| OPERATORS.invert[c]}*''} if @debug_level > 1
        when :rotate_north
            offset = pop_main
            grid = @grid.transpose
            grid[(x+offset) % @width].rotate!(1)
            @grid = grid.transpose
            
            if offset == 0
                @ip += North.new.vec
                if y < 0
                    @ip.y = @height-1
                end
            end

            puts @grid.map{|l| l.map{|c| OPERATORS.invert[c]}*''} if @debug_level > 1
        when :rotate_south
            offset = pop_main
            grid = @grid.transpose
            grid[(x+offset) % @width].rotate!(-1)
            @grid = grid.transpose
            
            if offset == 0
                @ip += South.new.vec
                if y >= @height
                    @ip.y = 0
                end
            end

            puts @grid.map{|l| l.map{|c| OPERATORS.invert[c]}*''} if @debug_level > 1

        # Others
        when :terminate
            raise '[BUG] Received :terminate. This shouldn\'t happen.'
        when :nop
            # Nop(e)
        when :debug
            if @debug_level > 0
                puts
                puts "Grid:"
                puts @grid.map{|l| l.map{|c| OPERATORS.invert[c]}*''}
                puts "Position: #{@ip.pretty}"
                puts "Direction: #{@dir.class.name}"
                puts "Main [ #{@main*' '}  |  #{@aux.reverse*' '} ] Auxiliary"
            end
        end
    end

    def get_new_dir
        neighbors = []
        [North.new,
         East.new,
         South.new,
         West.new].each do |dir|
            neighbors << dir if cell(@ip + dir.vec)[0] != :wall
        end

        p neighbors if @debug_level > 1

        case neighbors.size
        when 0
            # Remain where you are by moving back one step.
            # This can only happen at the start or due to shifting.
            @ip += @dir.reverse.vec
            @dir
        when 1
            # Move in the only possible direction
            neighbors[0]
        when 2
            neighbors = neighbors.select {|d| d.reverse != @dir}
            # If we came from one of the two directions, pick the other.
            # Otherwise, keep moving straight ahead (this can only happen
            # at the start or due to shifting).
            if neighbors.size == 2
                val = peek_main
                if neighbors.include? @dir
                    @dir
                elsif val < 0
                    @dir.left
                elsif val > 0
                    @dir.right
                else
                    neighbors.sample
                end
            else
                neighbors[0]
            end
        when 3
            val = peek_main
            if val < 0
                dir = @dir.left
            elsif val == 0
                dir = @dir
            else
                dir = @dir.right
            end
            if !neighbors.include? dir
                dir = dir.reverse
            end
            dir
        when 4
            val = peek_main
            if val < 0
                @dir.left
            elsif val == 0
                @dir
            else
                @dir.right
            end
        end
    end

    def read_byte
        result = nil
        if @next_byte
            result = @next_byte
            @next_byte = nil
        else
            result = STDIN.read(1)
        end
        result
    end
end

case ARGV[0]
when "-d"
    debug_level = 1
when "-D"
    debug_level = 2
else
    debug_level = 0
end

if debug_level > 0
    ARGV.shift
end

Hexagony.run(ARGF.read, debug_level)