module TLS
  class Searcher
    def initialize music
      @music = music
    end

    def find_all search
      search = normalize search

      @music.all_songs.select do |song|
        song.title.downcase.include? search or
        song.album.downcase.include? search or
        song.artist.downcase.include? search
      end
    end

    def normalize search
      search.strip.gsub(/\s{2,}/, ' ').downcase
    end
  end
end
