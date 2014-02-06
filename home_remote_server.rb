# home_remote_server.rb

require 'sinatra/base'
require 'sinatra/multi_route'
require 'sonos'
require './itach'

class HomeRemoteServer < Sinatra::Base
	register Sinatra::MultiRoute
	set :sessions, true

	get '/' do
	  @sonos = Sonos::System.new
	  erb :index
	end

	route :get, :post, :put, '/tvOn' do
		%x(wemo switch "Kitchen TV" on)
		speaker = grab_speaker("Kitchen")
		speaker.ungroup
		speaker.mute
		speaker.line_in(speaker)
		speaker.volume = 70
		speaker.unmute
		speaker.play
		200
	end

	route :get, :post, :put, '/tvOff' do
		%x(wemo switch "Kitchen TV" off)
		speaker = grab_speaker("Kitchen")
		speaker.stop
		speaker.volume = 20
		200
	end

	route :get, :post, :put, '/tvInput/:number' do
		hdmi_switch = Itach.new
		command = nil
		case params[:number].to_i
		when 1
			command = hdmi_switch.hdmi_1
		when 2
			command = hdmi_switch.hdmi_2
		when 3
			command = hdmi_switch.hdmi_3
		when 4
			command = hdmi_switch.hdmi_4
		when 5
			command = hdmi_switch.hdmi_5
		end
		hdmi_switch.set_hdmi_port(command, 1) unless command.nil?
		200
	end

	route :get, :post, :put, '/:speaker/:command' do
		send_command(params[:speaker], params[:command])
	end

	route :get, :post, :put, '/:speaker/linein/:source_speaker' do
		send_linein_command(params[:speaker], params[:source_speaker])
	end

	route :get, :post, :put, '/:speaker/volume/:volume_level' do
		set_volume(params[:speaker], params[:volume_level])
	end

	def send_command(speaker_id, command)
		speaker = grab_speaker(speaker_id)
		unless speaker.nil?	
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
			  speaker.next
			  return 200
			when 'prev', 'previous'
			  speaker.previous
			  return 200
			when 'volup'
				speaker.unmute if speaker.muted?
				new_volume = speaker.volume + 5
				new_volume = 100 if new_volume > 100
			  speaker.volume = new_volume
			  return 200
			when 'voldown'
				speaker.unmute if speaker.muted?
				new_volume = speaker.volume - 5
				new_volume = 0 if new_volume < 0
			  speaker.volume = new_volume
			  return 200
			when 'mute'
			  speaker.mute
			  return 200
			when 'unmute'
			  speaker.unmute
			  return 200
			when 'toggleMute'
			  speaker.muted? ? speaker.unmute : speaker.mute
			  return 200
			else
				return send_error_response "The command '#{command}' is not currently supported by this remote."
			end
		end
	end

	def send_linein_command(speaker_id, target_speaker_id)
		speaker = grab_speaker(speaker_id)
		target_speaker = grab_speaker(target_speaker_id)
		speaker.line_in(target_speaker) unless (speaker.nil? or target_speaker.nil?)
	end

	def set_volume(speaker_id, volume)
		volume = 0 if volume < 0
		volume = 100 if volume > 100
		speaker = grab_speaker(speaker_id)
		speaker.volume = volume unless speaker.nil?
	end

	def grab_speaker(speaker_id)
		begin
			system = Sonos::System.new
			speaker = system.find_speaker_by_uid(speaker_id)
			speaker = system.find_speaker_by_name(speaker_id) if speaker.nil?
			send_error_response "Speaker '#{speaker_id}' could not be found." if speaker.nil?
			puts "couldn't find #{speaker_id}" if speaker.nil?
			return speaker
		rescue
			begin
				send_error_response "An unknown error occurred identifying the speaker."
				return nil
			rescue
			end
		end
	end

	def send_error_response(error_msg)
		puts error_msg
		[500, error_msg]
	end
end
