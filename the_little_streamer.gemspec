Gem::Specification.new do |s|
  s.name = %q{the_little_streamer}
  s.version = "0.4.2"
  s.authors = ["Justin Collins"]
  s.summary = "Simple Sinatra application for streaming music."
  s.description = "Point the Little Streamer to your music directory and it will serve up the tunes using the HTML5 audio tag."
  s.homepage = "http://github.com/presidentbeef/the_little_streamer"
  s.files = ["bin/the_little_streamer", "README.md"] + Dir["lib/**/*"]
  s.executables = ["the_little_streamer"]
  s.add_dependency "sinatra", "~>1.3"
  s.add_dependency "ruby-taglib2", "~>1.02"
end
