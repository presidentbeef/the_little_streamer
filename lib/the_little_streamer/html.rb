module TLS::HTML
  #Wrap up in HTML
  def page body = nil
    if block_given?
      body = yield
    end

    <<-HTML
    <html>
      <head>
        <style type="text/css">
    #{css}
        </style>
        <title>The Little Streamer</title>
      </head>
      <body>
    #{body}
      </body>
      <script>
      if(document.getElementById('artist')) {
        window.onload = function() {
         var artist = document.getElementById('artist').firstChild.text;
         var title = document.getElementById('title').textContent;
         document.title = title + " by " + artist;
        }
      }
      </script>
    </html>
    HTML
  end

  def css
    @css ||= <<-CSS
  body {
    font-family: Helvetica,Verdana,Arial,sans-serif;
    font-size: 13pt;
  }

  span#title {
    font-size: 14pt;
    font-weight: bold;
  }

  span#artist {
    font-size: 14pt;
    font-weight: bold;
  }

  span#artist a {
    text-decoration: none;
    color: black;
   }

  span#artist a:hover {
    text-decoration: underline;
  }

  span#album {
    font-style: italic;
  }

  span#album a {
    text-decoration: none;
    color: black;
  }

  span#album a:hover {
    text-decoration: underline;
  }

  div#playlist {
    float: left;
    margin-top: 15px;
    height: 80%;
    overflow: auto;
    text-align: left;
  }

  div#playerbox {
    float: left;
    text-align: center;
  }
    CSS

    @css
  end

  #Create a link
  def link root, path, text = path, params = {}
    full_path = root.split('/').map! {|r| URI.escape r }.join('/') << "/" << URI.escape(path)
    params = params.map { |k, v| "#{k}=#{v}" }.join "&"
    "<a href=\"#{full_path}?#{params}\">#{text}</a>"
  end

  #Some navigation
  def title artist, album = nil
    if album
      "<h3>#{link "/", "", "Music"} : #{link "/artist/", artist, artist} : #{album}</h3>"
    else
      "<h3>#{link "/", "", "Music"} : #{artist}</h3>"
    end
  end

  #Audio tag
  def audio path
    <<-HTML
  <audio id='player' onEnded='javascript:play_next()' src=#{("/" << URI.escape(path)).inspect} autobuffer controls autoplay >
    You need the power of HTML5!
  </audio>
  <script type="text/javascript">
    document.getElementById('player').volume = 0.3;
  </script>
    HTML
  end

  #HTML for displaying playlist
  def playlist_html songs
    list = []

    songs.each_with_index do |song, i|
      list << "<li><a href=\"javascript:play_index(#{i})\">#{song.artist} - #{song.title}</a></li>"
    end

    <<-HTML
    <div style="clear:both">&nbsp;</div>
    <div id="playlist">
      <ol>
    #{list.join}
      </ol>
    </div>
    HTML
  end

  #Javascript for playlist
  def playlist_js songs
    <<-JAVASCRIPT
  <script type="text/javascript">
    var player = document.getElementById('player');
    var artist = document.getElementById('artist');
    var album = document.getElementById('album');
    var title = document.getElementById('title');
    var playlist = [#{songs.map { |s| song_to_js s }.join "," }]
    var current_song = 0;

    play_next = function(reverse) {
      if(reverse && current_song > 0)
        current_song--;
      else if(!reverse && current_song < playlist.length)
        current_song++;
      else
        return;

      play_current();
    }

    play_current = function() {
      var song = playlist[current_song];
      player.src = song.path;
      artist.innerHTML = song.artist
      album.innerHTML = song.album
      title.innerHTML = song.title
      document.title = song.title + " by " + document.getElementById('artist').firstChild.text;
      player.play();
    }

    play_index = function(index) {
      current_song = index;
      play_current();
    }
  </script>
    JAVASCRIPT
  end

  #Javascript for a song
  def song_to_js song
    <<-JAVASCRIPT
  { artist: #{link("/artist", song.artist, song.artist).inspect},
    album: #{link("/artist/#{song.artist}/album/", song.album, song.album).inspect},
    title: #{song.title.inspect},
    path: #{(CGI.escapeHTML "/" << CGI.escape(song.path)).inspect} }
    JAVASCRIPT
  end

  #HTML for song information header
  def song_info song
    "<span id='title'>#{song.title}</span> by <span id='artist'>#{link "/artist/", song.artist}</span><br/><span id='album'>#{link "/artist/#{song.artist}/album", song.album}</span>"
  end

  #Back/forward links
  def prev_and_next
    @prev_and_next ||= "<a href='javascript:play_next(true)'>Prev</a>&nbsp;&nbsp;&nbsp;<a href='javascript:play_next()'>Next</a>"
    @prev_and_next
  end

  #Output HTML for player
  def player_html songs
    page <<-HTML
    <div id="playerbox">
    #{song_info songs.first}<br/>
    #{audio songs.first.path}<br/>
    #{prev_and_next if songs.length > 1}
    #{playlist_js songs}
    #{playlist_html songs if songs.length > 1}
      <div style="clear:both">#{link "/", "", "Back to All Music"}</div>
    </div>
    HTML
  end
end
