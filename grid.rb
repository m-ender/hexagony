require_relative 'coords'

class Grid
    attr_reader :size

    OPERATORS = {
        #'!'  ,
        #'"'  ,
        #'#'  ,
        #'$'  ,
        #'%'  ,
        #'&'  ,
        #'\'' ,
        #'('  ,
        #')'  ,
        #'*'  ,
        #'+'  ,
        #','  ,
        #'-'  ,
        '.' => :nop,
        #'/'  ,
        #'0'  ,
        #':'  ,
        #';'  ,
        #'<'  ,
        #'='  ,
        #'>'  ,
        #'?'  ,
        #'@'  ,
        ##'A'  ,
        # ...
        ##'Z'  ,
        ##'['  ,
        #'\\'  ,
        ##']'  ,
        #'^'  ,
        #'_'  ,
        #'`'  ,
        ##'a'  ,
        # ...
        ##'u'  ,
        #'v'  ,
        ##'w'  ,
        # ...
        ##'z'  ,
        #'{'  ,
        #'|'  ,
        #'}'  ,
        #'~'  ,
    }

    OPERATORS.default = [:nop]

    def initialize size
        @size = size
        @grid = Array.new(2*@size-1) {|j|
            [:nop]*(2*@size-1 - (@size-1 - j).abs)
        }
    end

    def self.from_string(string)
        src = string.gsub(/\s/,'')

        # Find size of the grid as the smallest regular hexagon which
        # is not smaller than the source code.
        size = 1
        size += 1 while 3*size*(size-1) + 1 < src.size

        src = src.ljust(3*size*(size-1) + 1, '.')

        grid = Grid.new(size)

        grid.fill!(src.chars.map{|c| OPERATORS[c]})

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

        return [x + @size-1, z + [i, @size-1].min]
    end

    def to_s
        @grid.map{|line|
            ' '*(2*@size-1 - line.size) + line.map{|c| OPERATORS.invert[c]}*' '
        }*$/
    end
end