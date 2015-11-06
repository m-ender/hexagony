# coding: utf-8

require_relative 'grid'
require_relative 'memory'
require_relative 'coords'
require_relative 'direction'

class Hexagony

    class ProgramError < Exception; end

    def self.run(src, debug_level=0, in_str=$stdin, out_str=$stdout, max_ticks=-1)
        new(src, debug_level, in_str, out_str, max_ticks).run
    end

    def initialize(src, debug_level=false, in_str=$stdin, out_str=$stdout, max_ticks=-1)
        @debug_level = debug_level
        @in_str = in_str
        @out_str = out_str
        @max_ticks = max_ticks
        @debug_tick = false
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
            cmd, dbg = @grid.get coords
            @debug_tick = @debug_level > 1 || (@debug_level > 0 && dbg)
            if @debug_tick
                puts "\nTick #{@tick}:"
                puts "IPs (! indicates active IP):" 
                @ips.each_with_index{|ip,i|
                    puts "#{i == @active_ip ? '!' : ' '} #{i}: #{ip[0]}, #{ip[1]}"
                }
                puts "Command: #{cmd.inspect}"
            end
            if cmd[0] == :terminate
                puts "Memory: #{@memory.inspect}" if @debug_tick
                break
            end
            process cmd
            puts "New direction: #{dir}" if @debug_tick
            puts "Memory: #{@memory.inspect}" if @debug_tick
            @ips[@active_ip][0] += dir.vec
            handle_edges
            @active_ip = @new_ip
            @tick += 1
            break if @max_ticks > -1 && @tick >= @max_ticks
        end

        @max_ticks > -1 && @tick >= @max_ticks
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
        when :mp_rev_left
            @memory.reverse
            @memory.move_right
            @memory.reverse
        when :mp_rev_right
            @memory.reverse
            @memory.move_left
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
            @out_str.print (@memory.get % 256).chr
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
            @out_str.print @memory.get

        # Control flow
        when :jump
            @ips[@active_ip][0] += dir.vec
            handle_edges
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

        abs = [x.abs, y.abs, z.abs]

        if @grid.size == 1
            @ips[@active_ip][0] = PointAxial.new(0,0)
        elsif abs.max >= @grid.size
            # First, determine pivot: if there's only one value at @size, that's the pivot.
            # If there's two, if @memory.get > 0, the pivot is the first coordinate in a
            # cyclically adjacent pair. Otherwise it's the second one.
            # Now undo the last step.
            # Finally, to do the wrapping, negate all three values and swap the non-pivot values.
            max_indices = abs.each_index.select{|i| abs[i] >= @grid.size}

            case max_indices.size
            when 1
                pivot = max_indices[0]
            when 2
                a, b = max_indices
                # We want the first index, if we consider the two as a cyclically adjacent pair.
                # i.e.
                # a b  pivot
                # 0 1  0
                # 1 2  1
                # 2 0  2
                # 1 0  0
                # 2 1  1
                # 0 2  2
                pivot = (a-b)%3 == 1 ? b : a
                # Pick the other one if current cell is non-positive
                pivot = (pivot+1)%3 if @memory.get <= 0
            end # Can't be 3

            i, j = [0, 1, 2].select{|k| k != pivot}

            @ips[@active_ip][0] -= dir.vec

            x = q
            z = r
            y = -x-z

            wrapped = [x,y,z].map{|i| -i}
            wrapped[i], wrapped[j] = wrapped[j], wrapped[i]

            x, _, z = wrapped

            @ips[@active_ip][0].q = x
            @ips[@active_ip][0].r = z
        end
    end

    def read_byte
        result = nil
        if @next_byte
            result = @next_byte
            @next_byte = nil
        else
            result = @in_str.read(1)
        end
        result
    end
end