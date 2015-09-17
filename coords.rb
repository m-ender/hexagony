class PointAxial
    attr_accessor :q, :r

    def initialize(q, r)
        @q = q
        @r = r
    end

    def self.from_string(string)
        coords = string.split.map(&:to_i)
        PointAxial.new(coords[0], coords[1])
    end

    def to_cube
        PointCube.new(@q, -@q-@r, @r)
    end

    def +(other)
        if other.is_a?(PointAxial)
            return PointAxial.new(@q+other.q, @r+other.r)
        end
    end

    def -(other)
        if other.is_a?(PointAxial)
            return PointAxial.new(@q-other.q, @r-other.r)
        end
    end

    def coerce(other)
        return self, other
    end

    def to_s
        "(%d,%d)" % [@q, @r]
    end
end

class PointCube
    attr_accessor :x, :y, :z

    def initialize(x, y, z)
        @x = x
        @y = y
        @z = z
    end

    def self.from_string(string)
        coords = string.split.map(&:to_i)
        PointCube.new(coords[0], coords[1], coords[2])
    end

    def to_axial
        PointAxial.new(@x, @z)
    end

    def +(other)
        if other.is_a?(PointCube)
            return PointCube.new(@x+other.x, @y+other.y, @z+other.z)
        end
    end

    def -(other)
        if other.is_a?(PointCube)
            return PointCube.new(@x-other.x, @y-other.y, @z-other.z)
        end
    end

    def coerce(other)
        return self, other
    end

    def to_s
        "(%d,%d,%d)" % [@x, @y, @z]
    end
end