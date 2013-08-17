require 'taglib'
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
        Dir.glob "#{path}/**/*.{mp3,mP3,Mp3,MP3,ogg,Ogg,OGg,OGG,oGg,oGG,ogG,OgG}" do |file|
          yield file
        end
      end
    end

    def get_songs
      puts "Getting songs"
      @songs = []

      each_file do |file|
        song = get_song file

        if song
          @songs << song
          yield song
        end
      end

      GC.start #Clean up after TagLib2
      @songs
    end

    def get_song file
      song = nil

      begin
        TagLib::FileRef.open(file) do |fileref|
          info = fileref.tag

          artist, album, title, track = info.artist, info.album, info.title, info.track

          artist = "Unknown" if artist.nil? or artist.empty?
          album = "Unknown" if album.nil? or album.empty?
          title = File.basename(file).split('.').first if title.nil? or title.empty?

          if title
            [artist, album, title].each { |i| i.tr!('/', '-') }

            song = Song.new(artist, album, title, track, Pathname.new(file).relative_path_from(@root).to_s)
          end
        end
      rescue Exception => e
        p e
        #Should probably do something here?
      end

      song
    end
  end
end
