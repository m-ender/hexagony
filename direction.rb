require_relative 'coords'

class NorthEast
    def right() East.new end
    def left() NorthWest.new end
    def reverse() SouthWest.new end
    def vec() PointAxial.new(1,-1) end

    def ==(other) other.is_a?(NorthEast) end
    def coerce(other) return self, other end
end

class NorthWest
    def right() NorthEast.new end
    def left() West.new end
    def reverse() SouthEast.new end
    def vec() PointAxial.new(0,-1) end

    def ==(other) other.is_a?(NorthWest) end
    def coerce(other) return self, other end
end

class West
    def right() NorthWest.new end
    def left() SouthWest.new end
    def reverse() East.new end
    def vec() PointAxial.new(-1,0) end

    def ==(other) other.is_a?(West) end
    def coerce(other) return self, other end
end

class SouthWest
    def right() West.new end
    def left() SouthEast.new end
    def reverse() NorthEast.new end
    def vec() PointAxial.new(-1,1) end

    def ==(other) other.is_a?(SouthWest) end
    def coerce(other) return self, other end
end

class SouthEast
    def right() SouthWest.new end
    def left() East.new end
    def reverse() NorthWest.new end
    def vec() PointAxial.new(0,1) end

    def ==(other) other.is_a?(SouthEast) end
    def coerce(other) return self, other end
end

class East
    def right() SouthEast.new end
    def left() NorthEast.new end
    def reverse() West.new end
    def vec() PointAxial.new(1,0) end

    def ==(other) other.is_a?(East) end
    def coerce(other) return self, other end
end