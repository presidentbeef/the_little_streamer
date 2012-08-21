require 'taglib2'
require 'the_little_streamer/song'

module TLS
  class Finder
    def initialize root, path
      @root = root
      @paths = [path] #maybe support multiple paths in future
      @songs = nil
    end

    def each_song &block
      if @songs
        @songs.each(&block)
      else
        get_songs(&block)
      end
    end

    def each_file
      @paths.each do |path|
        Dir.glob "#{path}/**/*.{mp3,ogg}", File::FNM_CASEFOLD do |file|
          yield file
        end
      end
    end

    def get_songs
      puts "Gettings songs"
      @songs = []

      quietly do
        each_file do |file|
          song = get_song file

          if song
            @songs << song
            yield song
          end
        end
      end

      GC.start #Clean up after TagLib2
      @songs
    end

    def get_song file
      song = nil

      begin
        info = TagLib2::File.new(file)

        artist, album, title, track = info.artist, info.album, info.title, info.track

        artist = "Unknown" if artist.nil? or artist.empty?
        album = "Unknown" if album.nil? or album.empty?

        if title
          [artist, album, title].each { |i| i.tr!('/', '-') }

          song = Song.new(artist, album, title, track, Pathname.new(file).relative_path_from(@root).to_s)
        end
      rescue Exception => e
        p e
        #Should probably do something here?
      end

      song
    end

    def quietly
      old_stderr = $stderr.dup

      $stderr.reopen("/dev/null", "w")

      yield

      $stderr = old_stderr
    end
  end
end
