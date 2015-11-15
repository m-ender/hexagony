# coding: utf-8

require_relative 'hexagony'
require_relative 'grid'
require 'stringio'

[')', '('].each do |count_char|
    (0..5).each do |inc_pos|
        ([*1..5]-[inc_pos]).each do |out_pos|
            ([*1..5]-[inc_pos,out_pos]).each do |out2_pos|
                code = ' '*6
                code[inc_pos] = count_char
                code[out_pos] = '!'
                code[out2_pos] = ';'

                $stderr.puts code

                (('"'..'~').to_a-"`?,@".chars).repeated_permutation(3) do |pos|
                    this_code = code.clone
                    pos.each do |c| this_code.sub!(' ',c) end

                    in_stream = StringIO.new('')
                    out_stream = StringIO.new
                    errored = false
                    begin
                        aborted = Hexagony.run(this_code, 0, in_stream, out_stream, 35)
                    rescue
                        next
                    end

                    if aborted && (out_stream.string =~ /^1([ \n\t,])2(\1)3/)
                        puts this_code
                        $stderr.puts this_code
                    end
                end
            end
        end
    end
end