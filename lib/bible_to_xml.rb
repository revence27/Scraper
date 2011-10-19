#!  /usr/bin/env ruby

require 'rubygems'
require 'haml'
require 'luganda_bible'

def rmain args
    if args.empty? then
        $stderr.puts %[#{$0} arg1 [arg2 ...]]
        return 1
    end
    bible   = LugandaBible.parse_lutheran_ministry args
    genr    = Haml::Engine.new(DATA.read)
    $stdout.puts(genr.render(binding))
    0
end

exit(rmain(ARGV))

__END__
!!! XML UTF-8
%XMLBIBLE{'xmlns:xsi' => "http://www.w3.org/2001/XMLSchema-instance", :biblename => "EkitaboEkitukuvu"}
    - bible.order.each_with_index do |bk, pos|
        %BIBLEBOOK{:bnumber => pos + 1, :bname => bk.gsub(/^(\d)/, '\1 ')}
            - bible.books[bk].chapters.each_with_index do |chp, cpos|
                %CHAPTER{:cnumber => cpos + 1}
                    - chp.verses.each_with_index do |vrs, vpos|
                        %VERS{:vnumber => vpos + 1}= vrs.gsub(/<[^>]*>/, '')
