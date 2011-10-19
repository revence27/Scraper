require 'open-uri'

class TestFailed < Exception
    def initialize book, chap, verse, errmsg
        super errmsg
        @book, @chapter, @verse  = book, chap, verse
    end

    def message
        super + (%[ (%s %d:%d)] % [@book, @chapter, @verse])
    end
end

class Chapter
    attr_reader :verses, :chapter

    def initialize chp
        @verses  = []
        @chapter = chp
    end

    def << verse
        @verses << verse
    end

    def verse v
        @verses[v - 1]
    end

    def inspect
        %[[%d] %s ...] % [@verses.length, @chapter[0 .. 100]]
    end
end

class Book
    attr_reader :name

    def initialize name
        @chaps = []
        @name  = name
    end

    def << chap
        @chaps << chap
    end

    def [] c, v
        chapter(c).verse(v)
    end
    
    def chapters
        @chaps
    end

    def chapter n
        @chaps[n - 1]
    end

    def inspect
        %[[%d] %s] % [@chaps.length, @name]
    end
end

class Bible
    attr_reader :books, :order

    def initialize
        @order = []
        @books = {}
    end

    def method_missing meth, *args
        book = self[meth.to_s]
        super unless book
        if args.empty? then
            book
        else
            book[*args]
        end
    end

    def [] book
        @books[book]
    end

    def << book
        @books[book.name] ||= book
        @order << book.name unless @order.member? book.name
    end

    def inspect br = ' '
        %[[%d]%s%s] % [@books.keys.length, br, @books.map {|x| %[#{x.last.name}(#{x.last.chapters.length})]}.join((br == ' ' ? ',' + br : br))]
    end
end

class LugandaBible < Bible
    def self.parse_lutheran_ministry files
        bible, book = Bible.new, nil
        files.each do |arg|
            open(arg) do |fch|
                ans = fch.read
                until ans.empty?
                    mtc  = ans.match /<P  align="RIGHT"><A  name="([^"]+)"/
                    book ||= Book.new(mtc[1]) if mtc
                    unless mtc and book and book.name == mtc[1] then
                        if mtc then
                            ans = mtc.post_match
                            book = Book.new(mtc[1])
                        end
                    end
                    mtc  = ans.match /Essuula\s+(\d+)<\/FONT>/
                    unless mtc then
                        mtc = ans.match /Essuula .*<\/A>(\d+)<\/FONT>/
                        break unless mtc
                    end
                    chap = Chapter.new(mtc[1])
                    lst  = mtc.post_match.match /<\/TABLE>/
                    wrap = lst.pre_match
                    until wrap.empty?
                        gat  = wrap.match /<TD[^>]*><FONT  size="4">(.+)<\/FONT><\/TD>/
                        if gat then
                            wrap = gat.post_match
                            next if gat[1] =~ /^<B>/i
                            chap << gat[1].strip unless not_a_verse gat[1].strip
                        else
                            break
                        end
                    end
                    ans = lst.post_match
                    book << chap
                    bible << book
                end
            end
        end
        bible
    end

    def self.test_parsed_bible bible, tests = []
        ans = []
        tests.each_with_index do |test, pos|
            begin
                unless test.run_test bible then
                    raise TestFailed.new(test.name, pos + 1, 0, test.errmsg)
                end
            rescue TestFailed => e
                ans << e.message
            end
        end
        ans
    end

    def self.parse_lutheran_and_test files, tests
        test_parsed_bible(parse_lutheran_ministry(files), tests)
    end

    def self.not_a_verse vrs
        ['&nbsp;', ''].member? vrs
    end
end
