#!  /usr/bin/env ruby

require 'rubygems'
require 'luganda_bible'

def rmain args
    if args.empty? then
        $stderr.puts %[#{$0} arg1 [arg2 ...]]
        return 1
    end
    bible   = LugandaBible.parse_lutheran_ministry args
    puts bible.inspect "\n"
    puts bible.Okuva(20, 1)
    #   puts bible.Zabbuli(117, 1)

    #   TODO:
    #   Register Bible into database.
    0
end

exit(rmain(ARGV))
