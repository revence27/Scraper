#!  /usr/bin/env ruby

require 'luganda_bible'

class LMBTest
    attr_reader :name, :errmsg
    def initialize name, errmsg = nil, &blk
        @name, @errmsg, @tester = name, errmsg, blk
        unless @errmsg then
            if self.class != LMBTest then
                raise ArgumentError.new(%[Pass a test name and its error message.])
            end
            @errmsg = @name.clone
            @name   = self.class.name.gsub(/([a-z0-9])([^a-z])/, '\1 \2')
        end
        if self.class == LMBTest then
            @errmsg = @name if @errmsg == :similar_error
        end
    end

    def run_test bible
        raise NoMethodError.new(%[LMBTest#run_test(Bible) must be over-ridden.]) unless @tester
        @tester.call(bible)
    end
end

LMBTests =
[
    LMBTest.new(%[Genesis (Olubereberye) is in the beginning.], :similar_error) do |bible|
        bible.order.first.downcase == 'olubereberye'
    end,
    LMBTest.new(%[Revelation (Okubikkulirwa) is at the end of the age.], :similar_error) do |bible|
        bible.order.last.downcase == 'okubikkulirwa'
    end,
    LMBTest.new(%[The Bible has 66 books, only.], :similar_error) do |bible|
        bible.books.keys.length == 66
    end,
    LMBTest.new(%[Ad Fontes], %[Romans 8:1 should be concise.]) do |bible|
        romans = bible.books['Abaruumi']
        if romans then
            not romans.chapter(8).verse(1) =~ /tambulira/
        else
            false
        end
    end,
    LMBTest.new(%[John 1:17 rocks.], %[Where is John 1:17?]) do |bible|
        begin
            bible.Yokaana(1, 17) =~ /Musa.+Yesu/
        rescue NoMethodError => e
            false
        end
    end,
    LMBTest.new(%[117 < 119], %[Psalms 119 is longer than Psalms 117]) do |bible|
        begin
            bible.Zabbuli.chapter(119).verses.length > bible.Zabbuli.chapter(117).verses.length
        rescue NoMethodError => e
            false
        end
    end,
    #   TODO:
    #   
    #   Upcoming tests (after pulling general Prot Bible metadata):
    #   
    #   1.  books in the right order
    #   2.  chapter sizes match up.
    #   3.  each chapter's verses match up
    #   4.  chapters follow n = succ(prec(n)) order ...
    #   5.  Psalms 117 has the fewest chapters.
    #   6.  Chapters: Jude == John 2 == John 3
    #   7.  Is there a verse with [A-Z][A-Z]?
    #   8.  Is there a verse with [a-z][A-Z]?
    #   
]

def smain args
    if args.empty? then
        $stderr.puts %[#{$0} arg1 [arg2 ...]]
        return 1
    end
    results = LugandaBible.parse_lutheran_and_test args, LMBTests
    return 0 if results.empty?
    $stderr.puts(%[There were %d errors out of %d tests in the parsing.] % [results.length, LMBTests.length], '====' * 20, '', '____' * 20)
    results.each_with_index do |res, pos|
        $stderr.puts((%[#{sprintf('%3d', pos + 1)}   ] + (('' || '++++') * 20))[0, 80], '      ' + res, '____' * 20)
    end
    1
end

exit(smain(ARGV))
