# home_remote_server.rb

require 'sinatra/base'
require 'sinatra/multi_route'
require 'sonos'

class HomeRemoteServer < Sinatra::Base
	register Sinatra::MultiRoute
	set :sessions, true
	# Daemons.daemonize

	get '/' do
	  @sonos = Sonos::System.new
	  erb :index
	end

	route :get, :post, :put, '/:speaker/:command' do
		sendCommand(params[:speaker], params[:command])
	end

	def sendCommand(speaker_id, command)
		begin
			system = Sonos::System.new
			speaker = system.find_speaker_by_uid(speaker_id)
			speaker = system.find_speaker_by_name(speaker_id) if speaker.nil?
			return send_error_response "Speaker '#{speaker_id}' could not be found." if speaker.nil?
			case command
			when 'play'
			  speaker.play
			  return 200
			when 'pause'
				speaker.pause
			  return 200
			when 'stop'
			  speaker.stop
			  return 200
			when 'next'
			  speaker.stop
			  return 200
			when 'prev'
			  speaker.stop
			  return 200
			when 'volup'
				speaker.unmute if speaker.muted?
			  speaker.volume = speaker.volume + 5
			  return 200
			when 'voldown'
				speaker.unmute if speaker.muted?
			  speaker.volume = speaker.volume - 5
			  return 200
			when 'mute'
			  speaker.muted? ? speaker.unmute : speaker.mute
			  return 200
			else
				return send_error_response "The command '#{command}' is not currently supported by this remote."
			end
		rescue
			begin
				return send_error_response "An unknown error occurred."
			rescue
			end
		end
	end

	def send_error_response(error_msg)
		puts error_msg
		[500, error_msg]
	end
end
