#=======================================================================
#**Post Requester
#**Copyright 09.06.2015 Narzew
#**v 1.00
#=======================================================================

require 'net/http'
require 'uri'

module PostRequester

	def self.show_help
		print "Usage: postrequester.rb URL field=value field=value !flag=value\n"
		print "Available flags:\n"
		print "sc - Split center - remove all before first and after second pattern\n"
		print "sr - Split right - remove all before pattern\n"
		print "sl - Split left - remove all after pattern\n"
	end
	
	def self.print_error(x)
		print "Error: #{x}\n"
		self.show_help
	end
	
	def self.return_response(x)
		print "#{x}\n"
		begin
			File.open("postrequester_log.txt", "a"){|w| w.write(x+"\n") }
		rescue
			print "Warning: Failed to log response."
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
				self.print_error("Invalid parameter: "+x)
				PostRequester.show_help
			end
			count += 1
		}
		
		# Parse fields
		uri = URI($url)
		https = Net::HTTP.new(uri.host, uri.port)
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
	print "Error #{e}\n"
end
