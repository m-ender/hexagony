require_relative 'coords'

class Grid
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
        #'.'  ,
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
            Array.new(2*@size-1 - (@size-1 - j).abs)
        }
        @grid.map{|l|p l}
    end

    def cell coords
        x = coords.q
        z = coords.r
        y = -x-z
        return nil if [x.abs, y.abs, z.abs].max >= @size
        i = x + @size-1
        j = z + [i, @size-1].min

        @grid[i][j]
    end
end