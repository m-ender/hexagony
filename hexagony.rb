# coding: utf-8

require_relative 'grid'
require_relative 'memory'
require_relative 'coords'
require_relative 'direction'

class Hexagony

    class ProgramError < Exception; end

    def self.run(src, debug_level=0)
        new(src, debug_level).run
    end

    def initialize(src, debug_level=false)
        @debug_level = debug_level

        @grid = Grid.from_string(src)
        size = @grid.size

        @memory = Memory.new

        @ips = [
            [PointAxial.new(0,-size+1), East.new],
            [PointAxial.new(size-1,-size+1), SouthEast.new],
            [PointAxial.new(size-1,0), SouthWest.new],
            [PointAxial.new(0,size-1), West.new],
            [PointAxial.new(-size+1,size-1), NorthWest.new],
            [PointAxial.new(-size+1,0), NorthEast.new]
        ]
        @active_ip = @new_ip = 0

        @tick = 0
    end

    def dir
        @ips[@active_ip][1]
    end

    def coords
        @ips[@active_ip][0]
    end

    def q
        coords.q
    end

    def r
        coords.r
    end

    def run
        if @grid.size < 1
            return
        end
        loop do
            puts "\nTick #{@tick}:" if @debug_level > 1
            p @ips[@active_ip] if @debug_level > 1
            cmd, dbg = @grid.get coords
            p cmd if @debug_level > 1
            if cmd[0] == :terminate
                break
            end
            process cmd
            p dir if @debug_level > 1
            @ips[@active_ip][0] += dir.vec
            handle_edges
            @active_ip = @new_ip
            @tick += 1
        end
    end

    private

    def process cmd
        # opcode, param = *cmd

        # case opcode
        # # Arithmetic
        # when :push_zero
        #     push_main 0
        # when :digit
        #     val = pop_main
        #     if val < 0
        #         push_main(val*10 - param)
        #     else
        #         push_main(val*10 + param)
        #     end
        # when :inc
        #     push_main(pop_main+1)
        # when :dec
        #     push_main(pop_main-1)
        # when :add
        #     push_main(pop_main+pop_main)
        # when :sub
        #     a = pop_main
        #     b = pop_main
        #     push_main(b-a)
        # when :mul
        #     push_main(pop_main*pop_main)
        # when :div
        #     a = pop_main
        #     b = pop_main
        #     push_main(b/a)
        # when :mod
        #     a = pop_main
        #     b = pop_main
        #     push_main(b%a)
        # when :neg
        #     push_main(-pop_main)
        # when :bit_and
        #     push_main(pop_main&pop_main)
        # when :bit_or
        #     push_main(pop_main|pop_main)
        # when :bit_xor
        #     push_main(pop_main^pop_main)
        # when :bit_not
        #     push_main(~pop_main)

        # # Stack manipulation
        # when :dup
        #     push_main(peek_main)
        # when :pop
        #     pop_main
        # when :move_to_main
        #     push_main(pop_aux)
        # when :move_to_aux
        #     push_aux(pop_main)
        # when :swap_tops
        #     a = pop_aux
        #     m = pop_main
        #     push_aux m
        #     push_main a
        # when :depth
        #     push_main(@main.size)

        # # I/O
        # when :input_char
        #     byte = read_byte
        #     push_main(byte ? byte.ord : -1)
        # when :output_char
        #     $> << pop_main.chr
        # when :input_int
        #     val = 0
        #     sign = 1
        #     loop do
        #         byte = read_byte
        #         case byte
        #         when '+'
        #             sign = 1
        #         when '-'
        #             sign = -1
        #         when '0'..'9', nil
        #             @next_byte = byte
        #         else
        #             next
        #         end
        #         break
        #     end

        #     loop do
        #         byte = read_byte
        #         if byte && byte[/\d/]
        #             val = val*10 + byte.to_i
        #         else
        #             @next_byte = byte
        #             break
        #         end
        #     end

        #     push_main(sign*val)
        # when :output_int
        #     $> << pop_main
        # when :output_newline
        #     puts

        # # Grid manipulation
        # when :rotate_west
        #     offset = pop_main
        #     @grid[(y+offset) % @height].rotate!(1)
            
        #     if offset == 0
        #         @ip += West.new.vec
        #         if x < 0
        #             @ip.x = @width-1
        #         end
        #     end

        #     puts @grid.map{|l| l.map{|c| OPERATORS.invert[c]}*''} if @debug_level > 1
        # when :rotate_east
        #     offset = pop_main
        #     @grid[(y+offset) % @height].rotate!(-1)
            
        #     if offset == 0
        #         @ip += East.new.vec
        #         if x >= @width
        #             @ip.x = 0
        #         end
        #     end

        #     puts @grid.map{|l| l.map{|c| OPERATORS.invert[c]}*''} if @debug_level > 1
        # when :rotate_north
        #     offset = pop_main
        #     grid = @grid.transpose
        #     grid[(x+offset) % @width].rotate!(1)
        #     @grid = grid.transpose
            
        #     if offset == 0
        #         @ip += North.new.vec
        #         if y < 0
        #             @ip.y = @height-1
        #         end
        #     end

        #     puts @grid.map{|l| l.map{|c| OPERATORS.invert[c]}*''} if @debug_level > 1
        # when :rotate_south
        #     offset = pop_main
        #     grid = @grid.transpose
        #     grid[(x+offset) % @width].rotate!(-1)
        #     @grid = grid.transpose
            
        #     if offset == 0
        #         @ip += South.new.vec
        #         if y >= @height
        #             @ip.y = 0
        #         end
        #     end

        #     puts @grid.map{|l| l.map{|c| OPERATORS.invert[c]}*''} if @debug_level > 1

        # # Others
        # when :terminate
        #     raise '[BUG] Received :terminate. This shouldn\'t happen.'
        # when :nop
        #     # Nop(e)
        # when :debug
        #     if @debug_level > 0
        #         puts
        #         puts "Grid:"
        #         puts @grid.map{|l| l.map{|c| OPERATORS.invert[c]}*''}
        #         puts "Position: #{@ip.pretty}"
        #         puts "Direction: #{@dir.class.name}"
        #         puts "Main [ #{@main*' '}  |  #{@aux.reverse*' '} ] Auxiliary"
        #     end
        # end
    end

    def handle_edges
        x = q
        z = r
        y = -x-z

        if [x.abs, y.abs, z.abs].max >= @grid.size
            p [x, y, z]
            p dir
            raise 'NotYetImplemented, duh'
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