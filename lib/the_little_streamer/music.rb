class TLS::Music
  def initialize finder
    #Hash three levels deep for artist, album, and song
    @music = Hash.new do |h,k|
      h[k] = Hash.new do |hash, key|
        hash[key] = Hash.new
      end
    end

    @songs = []

    finder.each_song do |song|
      add_song song
    end
  end

  def add_song song
    @music[song.artist][song.album][song.title] = song
    @songs << song
  end

  def [] artist, album = nil, title = nil
    if title
      get_song artist, album, title
    elsif album
      get_album artist, album
    elsif artist
      get_artist artist
    end
  end

  def has? artist, album = nil, title = nil
    not self[artist, album, title].empty?
  end

  def get_artist artist
    @music[artist]
  end

  def get_album artist, album
    @music[artist][album]
  end

  def get_song artist, album, title
    @music[artist][album][title]
  end

  def artist_names
    @music.keys.sort!
  end

  def album_names_by artist
    get_artist(artist).keys.sort!
  end

  def song_names_on artist, album
    get_album(artist, album).keys.sort!
  end

  def songs_on artist, album
    get_album(artist, album).values
  end

  def songs_by artist
    songs = []

    get_artist(artist).each_value do |album|
      album.each_value do |song|
        songs << song
      end
    end

    songs
  end

  def albums_by artist
    get_artist(artist).values
  end
end
