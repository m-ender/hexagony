require_relative 'coords'

class Grid
    attr_reader :size

    OPERATORS = {
        '!' => [:output_int],
        '"' => [:mp_rev_left],
        '#' => [:choose_ip],
        '$' => [:jump],
        '%' => [:mod],
        '&' => [:mem_cpy],
        '\'' => [:mp_rev_right],
        '(' => [:dec],
        ')' => [:inc],
        '*' => [:mul],
        '+' => [:add],
        ',' => [:input_char],
        '-' => [:sub],
        '.' => [:nop],
        '/' => [:mirror_diag_up],
        '0'  => [:digit, 0], '1'  => [:digit, 1], '2'  => [:digit, 2], '3'  => [:digit, 3], '4'  => [:digit, 4], '5'  => [:digit, 5], '6'  => [:digit, 6], '7'  => [:digit, 7], '8'  => [:digit, 8], '9'  => [:digit, 9],
        ':' => [:div],
        ';' => [:output_char],
        '<' => [:branch_left],
        '=' => [:mp_reverse],
        '>' => [:branch_right],
        '?' => [:input_int],
        '@' => [:terminate],
        #'A'  ,
        # ... These will not be assigned and will set their ASCII value to the current memory cell.
        #'Z'  ,
        '[' => [:prev_ip],
        '\\' => [:mirror_diag_down],
        ']' => [:next_ip],
        '^' => [:mp_branch],
        '_' => [:mirror_hori],
        #'`'  , This will not be assigned as it's used for debug annotations. 
        #'a'  ,
        # ... These will not be assigned and will set their ASCII value to the current memory cell.
        #'z'  ,
        '{' => [:mp_left],
        '|' => [:mirror_vert],
        '}' => [:mp_right],
        '~' => [:neg],
    }

    OPERATORS.default_proc = proc do |hash, key|
        [:mem_set, key.ord]
    end

    def initialize size
        @size = size
        @grid = Array.new(2*@size-1) {|j|
            [[[:nop]]]*(2*@size-1 - (@size-1 - j).abs)
        }
    end

    def self.from_string(string)
        src_dbg = string.gsub(/\s/,'')
        src = src_dbg.gsub(/`/,'')


        # Find size of the grid as the smallest regular hexagon which
        # is not smaller than the source code.
        size = 1
        size += 1 while 3*size*(size-1) + 1 < src.size

        src_dbg += '.'*(3*size*(size-1) + 1 - src.size)

        grid = Grid.new(size)

        debug = false
        ops = []

        src_dbg.each_char {|c|
            if c == '`'
                debug = true
            else
                ops << [OPERATORS[c], debug]
                debug = false
            end
        }

        grid.fill! ops

        grid
    end

    def fill! data
        i = -1
        @grid.map! { |line|
            line.map! {
                data[i+=1]
            }
        }
    end

    def get coords
        i, j = axial_to_index coords

        if i && j
            @grid[i][j]
        else
            nil
        end
    end

    def set coords, value
        i, j = axial_to_index coords

        @grid[i][j] = value if i && j
    end

    def axial_to_index coords
        x = coords.q
        z = coords.r
        y = -x-z
        return nil if [x.abs, y.abs, z.abs].max >= @size

        i = z + @size-1
        j = x + [i, @size-1].min
        return [i, j]
    end

    def to_s
        @grid.map{|line|
            ' '*(2*@size-1 - line.size) + line.map{|c,d| (d ? '`' : ' ') + (OPERATORS.invert[c]||c[1].chr)}*''
        }*$/
    end
end