begin
  require 'rouge'
rescue LoadError
  Rouge = nil
end

require 'xcpretty/snippet'

module XCPretty
  module Syntax
    def self.highlight(snippet)
      return snippet.contents unless Rouge

      if snippet.file_path.include?(':')
        filename = snippet.file_path.rpartition(':').first
      else
        filename = snippet.file_path
      end

      lexer = find_lexer(filename, snippet.contents)
      if lexer
        formatter = Rouge::Formatters::Terminal256.new
        formatter.format(lexer.lex(snippet.contents))
      else
        snippet.contents
      end
    end

    # @param [String] filename The filename
    # @param [String] contents The contents of the file
    # @return [Rouge::Lexer]
    def self.find_lexer(filename, contents)
      case File.extname(filename)
      when '.cpp', '.cc', '.c++', '.cxx', '.hpp', '.h++', '.hxx'
        Rouge::Lexers::Cpp
      when '.m', '.h' then Rouge::Lexers::ObjectiveC
      when '.swift' then Rouge::Lexers::Swift
      when '.ruby', '.rb' then Rouge::Lexers::Ruby
      else
        options = {
          filename: File.basename(filename),
          source: contents
        }
        Rouge::Lexer.guesses(options).first
      end
    end
  end
end

