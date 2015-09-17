require_relative 'coords'

class NorthEast
    def right() East.new end
    def left() NorthWest.new end

    def reflect_diag_up() NorthEast.new end
    def reflect_diag_down() West.new end
    def reflect_hori() SouthEast.new end
    def reflect_vert() NorthWest.new end
    def reflect_branch_left(right) SouthWest.new end
    def reflect_branch_right(right) East.new end

    def reverse() SouthWest.new end
    def vec() PointAxial.new(1,-1) end

    def ==(other) other.is_a?(NorthEast) end
    def coerce(other) return self, other end

    def to_s() "North East" end
end

class NorthWest
    def right() NorthEast.new end
    def left() West.new end

    def reflect_diag_up() East.new end
    def reflect_diag_down() NorthWest.new end
    def reflect_hori() SouthWest.new end
    def reflect_vert() NorthEast.new end
    def reflect_branch_left(right) West.new end
    def reflect_branch_right(right) SouthEast.new end

    def reverse() SouthEast.new end
    def vec() PointAxial.new(0,-1) end

    def ==(other) other.is_a?(NorthWest) end
    def coerce(other) return self, other end

    def to_s() "North West" end
end

class West
    def right() NorthWest.new end
    def left() SouthWest.new end

    def reflect_diag_up() SouthEast.new end
    def reflect_diag_down() NorthEast.new end
    def reflect_hori() West.new end
    def reflect_vert() East.new end
    def reflect_branch_left(right) East.new end
    def reflect_branch_right(right) right ? NorthWest.new : SouthWest.new end

    def reverse() East.new end
    def vec() PointAxial.new(-1,0) end

    def ==(other) other.is_a?(West) end
    def coerce(other) return self, other end

    def to_s() "West" end
end

class SouthWest
    def right() West.new end
    def left() SouthEast.new end

    def reflect_diag_up() SouthWest.new end
    def reflect_diag_down() East.new end
    def reflect_hori() NorthWest.new end
    def reflect_vert() SouthEast.new end
    def reflect_branch_left(right) West.new end
    def reflect_branch_right(right) NorthEast.new end

    def reverse() NorthEast.new end
    def vec() PointAxial.new(-1,1) end

    def ==(other) other.is_a?(SouthWest) end
    def coerce(other) return self, other end

    def to_s() "South West" end
end

class SouthEast
    def right() SouthWest.new end
    def left() East.new end

    def reflect_diag_up() West.new end
    def reflect_diag_down() SouthEast.new end
    def reflect_hori() NorthEast.new end
    def reflect_vert() SouthWest.new end
    def reflect_branch_left(right) NorthWest.new end
    def reflect_branch_right(right) East.new end

    def reverse() NorthWest.new end
    def vec() PointAxial.new(0,1) end

    def ==(other) other.is_a?(SouthEast) end
    def coerce(other) return self, other end

    def to_s() "South East" end
end

class East
    def right() SouthEast.new end
    def left() NorthEast.new end

    def reflect_diag_up() NorthWest.new end
    def reflect_diag_down() SouthWest.new end
    def reflect_hori() East.new end
    def reflect_vert() West.new end
    def reflect_branch_left(right) right ? SouthEast.new : NorthEast.new end
    def reflect_branch_right(right) West.new end

    def reverse() West.new end
    def vec() PointAxial.new(1,0) end

    def ==(other) other.is_a?(East) end
    def coerce(other) return self, other end

    def to_s() "East" end
end