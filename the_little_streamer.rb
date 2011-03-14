#This is a simple Sinatra application to play mp3/ogg files through a browser
#using the HTML5 audio tag

require 'rubygems'
require 'taglib2'
require 'sinatra'
require 'cgi'
require 'pathname'

#Supply a directory with all the music in it
abort "Need a path to the music!" unless ARGV[0]

#Wrap up in HTML
def html body
	<<-HTML
		<html>
			<body>
				#{body}
			</body>
		</html>
	HTML
end

#Create a link
def link root, path, text = path
	"<a href='#{root}#{CGI.escape path}'>#{text}</a>"
end

#Storing all music information in here
Music = {}

#Song information
Song = Struct.new :artist, :album, :title, :track, :path

#Used to figure out path to music files
root = Pathname.new ARGV[0]

#Make song files public
set :public, ARGV[0]

#Grab information from all the song files
Dir.glob "#{ARGV[0]}/**/*.{mp3,ogg}" do |file|
	begin
		info = TagLib2::File.new(file)

		artist, album, title, track = info.artist, info.album, info.title, info.track
		artist ||= "Unknown"
		album ||= "Unknown"
		info = nil

		if title
			[artist, album, title].each { |i| i.tr!('/', '-') }
			Music[artist] ||= {}
			Music[artist][album] ||= {}
			Music[artist][album][title] = Song.new(artist, album, title, track, Pathname.new(file).relative_path_from(root).to_s)
		end
	rescue Exception => e
		$stderr.puts e if $DEBUG
	end
end

GC.start

#List artists
get '/' do
	path = '/artist/'
	html Music.keys.sort.map { |a| link path, a }.join "<br/>"
end

#List albums by given artist
get '/artist/:artist/?' do |artist|
	if Music[artist]
		path = "/artist/#{artist}/album/"
		html Music[artist].keys.sort.map { |a| link path, a }.join "<br/>"
	else
		html "Could not find #{artist}."
	end
end

#List songs on given album
get '/artist/:artist/album/:album/?' do |artist, album|
	if Music[artist] and Music[artist][album]
		path = "/artist/#{artist}/album/#{album}/song/"
		html Music[artist][album].values.sort_by { |s| s.track || 0}.map { |s| link path, s.title }.join "<br/>"
	else
		html "Could not find #{album} for #{artist}."
	end
end

#Play song!
get '/artist/:artist/album/:album/song/:song/?' do |artist, album, song|
	if Music[artist] and Music[artist][album] and Music[artist][album][song]
		html <<-HTML
			<span id="song_title">#{song}</span> by <span id="artist">#{artist}</span> (<span>#{album}</span>)<br/>
			<audio src='/#{CGI.escapeHTML Music[artist][album][song].path}' autobuffer controls >
		HTML
	else
		html "Could not find #{song} on #{album} for #{artist}."
	end
end
