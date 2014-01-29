# home_remote_server.rb

require 'sinatra/base'
require 'sonos'

class HomeRemoteServer < Sinatra::Base
	set :sessions, true
	# Daemons.daemonize

	get '/' do
	  @sonos = Sonos::System.new
	  erb :index
	end

	get '/:speaker/:command' do
		sendCommand(params[:speaker], params[:command])
	end

	def sendCommand(speaker, command)
		begin
			system = Sonos::System.new
			speaker = system.find_speaker_by_uid(speaker)
			case command
			when 'play'
			  speaker.play
			when 'pause'
				speaker.pause
			when 'stop'
			  speaker.stop
			when 'next'
			  speaker.stop
			when 'prev'
			  speaker.stop
			when 'volup'
				speaker.unmute if speaker.muted?
			  speaker.volume = speaker.volume + 5
			when 'voldown'
				speaker.unmute if speaker.muted?
			  speaker.volume = speaker.volume - 5
			when 'mute'
			  speaker.muted? ? speaker.unmute : speaker.mute
			end
		rescue
			"#{speaker.name} had an error when trying to process the #{command} command." 
		end
	end
end
