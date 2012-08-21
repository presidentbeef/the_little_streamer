class TLS::Player
  include TLS::HTML

  def initialize music
    @music = music
  end

  def play_all limit = 100, order = "normal"
    case order
    when "random"
      songs = @music.songs.shuffle
    else
      songs = @music.songs
    end

    player_html songs[0..limit.to_i]
  end

  #HTML for playing all songs by artist
  def play_artist artist, order = "normal"
    if @music.has? artist
      songs = []

      case order
      when "random"
        songs = @music.songs_by(artist).shuffle!
      else
        @music.album_names_by(artist).each do |album|
          @music.get_album(artist, album).values.sort_by { |s| s.track }.each do |song|
            songs << song
          end
        end
      end

      player_html songs
    else
      artist_not_found artist
    end
  end

  #HTML for playing all songs on an album
  def play_album artist, album, order = "normal"
    if @music.has? artist, album
      if order == "random"
        songs = @music.songs_on(artist, album).shuffle!
      else
        songs = @music.songs_on(artist, album).sort_by { |s| s.track }
      end

      player_html songs
    else
      album_not_found artist, album
    end
  end

  def play_song artist, album, title
    song = @music.get_song(artist, album, title)

    if song
      player_html [song]
    else
      song_not_found
    end
  end

  def artist_not_found artist
    page "Could not find <b>#{artist}</b>."
  end

  def song_not_found artist, album, title
    page "Could not find <b>#{title}</b> on <b>#{album}</b> by <b>#{artist}</b>."
  end

  def album_not_found artist, album
    page "Could not find <b>#{album}</b> by <b>#{artist}</b>."
  end

  def list_artists
    path = '/artist/'
    page <<-HTML
    (Random
    #{link("/", "all", "10", :limit => 10, :order => :random)}
    #{link("/", "all", "50", :limit => 50, :order => :random) }
    #{link("/", "all", "100", :limit => 100, :order => :random) })
    <br/><hr/>
    #{@music.artist_names.map { |a| link path, a }.join "<br/>"}
    <br/><br/>
    HTML
  end

  def list_albums_by artist
    if @music.has? artist
      path = "/artist/#{artist}/album/"

      puts "making page"
      x = page <<-HTML
        #{title(artist)}
        #{@music.album_names_by(artist).map { |a| link path, a }.join("<br/>")}
        <br/><br/>
        #{link("/artist/#{artist}/", "play", "Play All")} - 
        #{link("/artist/#{artist}/", "play", "Randomly", :order => :random)}
        HTML
        puts "down"
        x
    else
      artist_not_found artist
    end
  end

  def list_songs_on artist, album
    if @music.has? artist, album
      path = "/artist/#{artist}/album/#{album}/song/"

      page <<-HTML
        #{title(artist, album)}
        #{@music.songs_on(artist, album).sort_by { |s| s.track || 0}.map { |s| link path, s.title }.join("<br/>")}
        <br/><br/>
        #{link "/artist/#{artist}/album/#{album}/", "play", "Play All" } -
        #{link "/artist/#{artist}/album/#{album}/", "play", "Randomly", :order => :random }
        HTML
    else
      album_not_found artist, album
    end
  end
end
