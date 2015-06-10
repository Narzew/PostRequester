#=======================================================================
#**Post Requester
#**Copyright 10.06.2015 Narzew
#**v 1.1
#=======================================================================

require 'net/http'
require 'uri'

module PostRequester

	$logfile = "postrequester_log.txt"
	$nolog = false
	
	def self.show_help
		print "Usage: postrequester.rb URL field=value field=value !flag=value\n"
		print "Available flags:\n"
		print "sc=pat - Split center - remove all before first and after second pattern\n"
		print "sr=pat - Split right - remove all before pattern\n"
		print "sl=pat - Split left - remove all after pattern\n"
		print "port=nr - Change port number\n"
		print "nolog=1 - Do not log requests\n"
		print "log=file - Change logfile to file\n"
	end
	
	def self.print_error(x)
		print "Error: #{x}\n"
		self.show_help
	end
	
	def self.to2digit(x)
		if(x.to_i<10)
			return "0#{x}"
		else
			return "#{x}"
		end
	end
	
	def self.return_response(x)
		print "#{x}\n"
		if $nolog == false
			begin
				resp = "#{self.to2digit(Time.now.day)}-#{self.to2digit(Time.now.month)}-#{self.to2digit(Time.now.year)} #{self.to2digit(Time.now.hour)}:#{self.to2digit(Time.now.min)}:#{self.to2digit(Time.now.sec)} #{ARGV.join(" ")} => #{x}\n"
				File.open($logfile, "a"){|w| w.write(resp) }
			rescue
				print "Warning: Failed to log response."
			end
		end
	end

	def self.start
		count = 0
		fields = {}
		flags = {}
		ARGV.each{|x|
			if count == 0
				$url = x
				count +=1 
				next
			end
			if x.include?("=")
				data = x.split("=")
				if data.at(0)[0] == "!"
					 # Field is flag
					flags[data.at(0).gsub("!","")] = data.at(1)
				else
					# Field is key=value field
					fields[data.at(0)] = data.at(1)
				end
			else
				if x.include?("!")
					flags[x[0].gsub("!","")] = ""
				else
					self.print_error("Invalid parameter: "+x)
					PostRequester.show_help
				end
			end
			count += 1
		}
		
		# Parse fields
		uri = URI($url)
		if flags.include?("nolog")
			if flags["nolog"] == "0" || flags["nolog"].downcase == "false"
				$nolog = false
			else
				$nolog = true
			end
		end
		if flags.include?("log")
			$logfile = flags["log"]
		end
		if flags.include?("clear")
			File.delete($logfile)
		end
		if flags.include?("port")
			https = Net::HTTP.new(uri.host, flags["port"])
		else
			https = Net::HTTP.new(uri.host, uri.port)
		end
		response = https.post($url, URI.encode_www_form(fields))
		result = response.body
		if flags.include?("sc")
			result2 = result.split(flags["sc"])[1].to_s
			result2 = result2.split(flags["sc"])[0].to_s
			self.return_response(result2)
		elsif flags.include?("sl")
			result2 = result.split(flags["sl"])[0].to_s
			self.return_response(result2)
		elsif flags.include?("sr")
			result2 = result.split(flags["sr"])[1].to_s
			self.return_response(result2)
		else
			self.return_response(result)
		end
	end
		
end

begin
	if ARGV.size > 1
		$url = ARGV[0]
		PostRequester.start
	else
		PostRequester.show_help
	end
rescue => e
	print "Error: #{e}\n"
end
