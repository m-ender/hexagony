#!/usr/bin/env ruby
# coding: utf-8

require_relative 'hexagony'
require_relative 'grid'

case ARGV[0]
when "-d"
    debug_level = 1
when "-D"
    debug_level = 2
when "-g"
    size = ARGV[1].to_i
    puts Grid.new(size)
    exit
else
    debug_level = 0
end

if debug_level > 0
    ARGV.shift
end

Hexagony.run(ARGF.read, debug_level)
