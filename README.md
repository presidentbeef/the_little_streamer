# The Little Streamer

Extremely simple music streamer using Sinatra.

## Install

    gem install the_little_streamer

## Use

    the_little_streamer /path/to/music

Browse to [http://localhost:4567](http://localhost:4567)

## Dependencies

 * [Sinatra](http://www.sinatrarb.com/)
 * [ruby-taglib2](https://github.com/rumblehq/ruby-taglib2)
 * A browser that supports HTML5, like [Chrome](http://www.google.com/chrome/)

You are strongly encouraged to use [Mongrel](https://github.com/fauna/mongrel) instead of WEBrick, as it will be way faster. Just install it and Sinatra will prefer it over WEBrick.

## License

[MIT](http://www.opensource.org/licenses/mit-license.php)
