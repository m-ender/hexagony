# Memory is a pointy-topped hexagonal grid which contains one integer value for
# each edge. That is, the data structure is the line graph of an infinite
# hexagonal grid. Edges are indexed by the axial coordinates of the (westward)
# adjacent hexagon, and a symbol :NE, :E, :SE indicating which of the three
# edges is meant (where the direction is taken from the hexagon to the edge).
# The memory pointer includes another flag which indicates whether the MP
# is currently pointing in the clockwise or counter-clockwise directoin (in
# relation to the hexagon used for indexing).
class Memory
    def initialize
        @memory = Hash.new { 0 }
        @mp = [0, 0, :E]
        @cw = false
    end

    def reverse
        @cw = !@cw
    end

    def move_left
        *@mp, @cw = left_index
    end

    def move_right
        *@mp, @cw = right_index
    end

    def set value
        @memory[@mp] = value
    end

    def get
        @memory[@mp]
    end

    def get_left
        *mp_left, cw = left_index
        @memory[mp_left]
    end

    def get_right
        *mp_right, cw = right_index
        @memory[mp_right]
    end

    def left_index
        q, r, e = @mp
        cw = @cw
        case [e, cw]
        when [:NE, false]
            r -= 1
            e = :SE
            cw = true
        when [:NE, true]
            q += 1
            r -= 1
            e = :SE
            cw = false
        when [:E, false]
            e = :NE
        when [:E, true]
            r += 1
            e = :NE
        when [:SE, false]
            e = :E
        when [:SE, true]
            q -= 1
            r += 1
            e = :E
        end
        [q, r, e, cw]
    end

    def right_index
        q, r, e = @mp
        cw = @cw
        case [e, cw]
        when [:NE, false]
            r -= 1
            e = :E
        when [:NE, true]
            e = :E
        when [:E, false]
            q += 1
            r -= 1
            e = :SE
        when [:E, true]
            e = :SE
        when [:SE, false]
            r += 1
            e = :NE
            cw = true
        when [:SE, true]
            q -= 1
            r += 1
            e = :NE
            cw = false
        end
        [q, r, e, cw]
    end
end