# Sonos

Control [Sonos](https://www.sonos.com) speakers over the web.

Huge thanks to [Rahim Sonawalla](https://github.com/rahims) for making [SoCo](https://github.com/rahims/SoCo) and [Sam Soffes](https://github.com/soffes) for making the [Ruby Sonos Gem](https://github.com/soffes/sonos). This gem would not be possible without their work.

## Installation and Starting the Server

Download or clone into this repository.

To ensure you have all dependencies, run:

``` $ bundle ```

Start the server using one of the following:

``` $ rackup ```

``` rackup -p 50405 ``` to use WEBrick on port 50405

``` rackup -p 50405 -s thin ``` to use Thin (**recommended**)

## Web Interface

Once the server is running, you can see the web interface at:

``` http://yourdomain.com:50405 ```

## Supported Commands

You can also send GET, POST, or PUT commands to control features in the following format:

``` http://yourdomain.com:50405/:speaker_id/:command ```

For example,

``` http://yourdomain.com:50405/Kitchen/play ```

``` http://yourdomain.com:50405/Master%20Bedroom/pause ```

``` http://yourdomain.com:50405/RINCON_000E5833F9A201400/stop ```

Supported speaker IDs are:

* UID (without the leading 'uuid:' prefix)
* Friendly Name (i.e. Kitchen) - Note, this only returns the first match.

Supported commands are:

* play
* pause
* stop
* next
* prev
* volup
* voldown
* mute 

## To Do

There is a lot to do.  The current index page was designed for a specific use case rather than to replace a general controller.

* Authentication
* Alternate view better mirror Sonos Controller / App functionality.
* Queue management
* Browse music sources and select songs to play

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request