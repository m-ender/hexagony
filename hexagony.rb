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
            p @memory if @debug_level > 1
            @ips[@active_ip][0] += dir.vec
            handle_edges
            @active_ip = @new_ip
            @tick += 1
        end
    end

    private

    def process cmd
        opcode, param = *cmd

        case opcode

        # Arithmetic
        when :digit
            val = @memory.get
            if val < 0
                @memory.set(val*10 - param)
            else
                @memory.set(val*10 + param)
            end
        when :inc
            @memory.set(@memory.get+1)
        when :dec
            @memory.set(@memory.get-1)
        when :add
            @memory.set(@memory.get_left + @memory.get_right)
        when :sub
            @memory.set(@memory.get_left - @memory.get_right)
        when :mul
            @memory.set(@memory.get_left * @memory.get_right)
        when :div
            @memory.set(@memory.get_left / @memory.get_right)
        when :mod
            @memory.set(@memory.get_left % @memory.get_right)
        when :neg
            @memory.set(-@memory.get)

        # Memory manipulation
        when :mp_left
            @memory.move_left
        when :mp_right
            @memory.move_right
        when :mp_reverse
            @memory.reverse
        when :mp_branch
            if @memory.get > 0
                @memory.move_right
            else
                @memory.move_left
            end
        when :mem_cpy
            if @memory.get > 0
                @memory.set(@memory.get_right)
            else
                @memory.set(@memory.get_left)
            end
        when :mem_set
            @memory.set(param)


        # I/O
        when :input_char
            byte = read_byte
            @memory.set(byte ? byte.ord : -1)
        when :output_char
            $> << @memory.get.chr
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

            @memory.set(sign*val)
        when :output_int
            $> << @memory.get

        # Control flow
        when :mirror_hori
            @ips[@active_ip][1] = dir.reflect_hori
        when :mirror_vert
            @ips[@active_ip][1] = dir.reflect_vert
        when :mirror_diag_up
            @ips[@active_ip][1] = dir.reflect_diag_up
        when :mirror_diag_down
            @ips[@active_ip][1] = dir.reflect_diag_down
        when :branch_left
            @ips[@active_ip][1] = dir.reflect_branch_left(@memory.get > 0)
        when :branch_right
            @ips[@active_ip][1] = dir.reflect_branch_right(@memory.get > 0)
        when :next_ip
            @new_ip = (@active_ip+1) % 6
        when :prev_ip
            @new_ip = (@active_ip-1) % 6
        when :choose_ip
            @new_ip = @memory.get % 6

        # Others
        when :terminate
            raise '[BUG] Received :terminate. This shouldn\'t happen.'
        when :nop
            # Nop(e)
        end
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