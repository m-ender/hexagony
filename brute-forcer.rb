# coding: utf-8

require_relative 'hexagony'
require_relative 'grid'
require 'stringio'

(0..5).each do |in_pos|
    (1..5).each do |out_pos|
        next if in_pos == out_pos
        (1..5).each do |end_pos|
            next if end_pos == in_pos || end_pos == out_pos
            code = ' '*6
            code[in_pos] = ','
            code[out_pos] = ';'
            code[end_pos] = '@'

            $stderr.puts code

            (('"'..'~').to_a-['`','?']).repeated_permutation(3) do |a,b,c|
                this_code = code.clone
                this_code.sub!(' ',a)
                this_code.sub!(' ',b)
                this_code.sub!(' ',c)

                in_stream = StringIO.new('')
                out_stream = StringIO.new
                errored = false
                begin
                    aborted = Hexagony.run(this_code, 0, in_stream, out_stream, 200)
                rescue
                    next
                end

                next if aborted || !(out_stream.string.empty?)

                in_stream = StringIO.new("\x00\x01\x00\x02")
                out_stream = StringIO.new
                errored = false
                begin
                    aborted = Hexagony.run(this_code, 0, in_stream, out_stream, 200)
                rescue
                    next
                end

                next if aborted || !(out_stream.string =~ /^\x00\x01\x00\x02$/)

                in_stream = StringIO.new('c0|#')
                out_stream = StringIO.new

                begin
                    aborted = Hexagony.run(this_code, 0, in_stream, out_stream, 200)
                rescue
                    next
                end

                if !aborted && (out_stream.string =~ /^c0\|\#$/)
                    puts this_code
                    $stderr.puts this_code
                end
            end
        end
    end
end