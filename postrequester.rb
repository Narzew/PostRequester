#=======================================================================
#**Post Requester
#**Copyright 10.06.2015 Narzew
#**v 1.4
#=======================================================================

$version = "1.4 (10.06.2015)"

require 'net/http'
require 'uri'
require 'digest/md5'
require 'digest/sha1'
require 'zlib'

module PostRequester

	$logfile = "postrequester_log.txt"
	$respfile = "postrequester_response.txt"
	$resplogfile = "postrequester_response_log.txt"
	$binarymode = false
	$nolog = false
	
	def self.show_help
		print "HTTP Post Requester - Tool to send HTTP POST requests\n"
		print "Usage: postrequester.rb URL field=value field=value @flag=value\n"
		print "Available flags:\n"
		print "***Connection options***\n"
		print "@port=nr - Change port number\n"
		print "***Splitting response***\n"
		print "@sc=pattern - Split center - remove all before first and after second pattern\n"
		print "@sr=pattern - Split right - remove all before pattern\n"
		print "@sl=pattern - Split left - remove all after pattern\n"
		print "***Logging options***\n"
		print "@nolog=1 - Do not log requests\n"
		print "@log=file - Change logfile to file\n"
		print "@respsave=filename - Change response save filename (Clear content)\n"
		print "@resplog=filename - Change response log filename (Keep content)\n"
		print "@binary=1 - Save responses in binary mode\n"
		print "***Converting values***\n"
		print "@sha1=field=value - Hash value with SHA1\n"
		print "@md5=field=value - Hash value with MD5\n"
		print "@b64=field=value - Encode value with Base64\n"
		print "@uue=field=value - Encode value with UUEncode\n"
		print "@db64=field=value - Decode value with Base64\n"
		print "@duue=field=value - Decode value with UUEncode\n"
		print "***Working with files***\n"
		print "@file=field=value - Replace value with file data\n"
		print "@sha1file=field=value - Replace value with SHA1 file hash\n"
		print "@md5file=field=value - Replace value with MD5 file hash\n"
		print "@b64file=field=value - Replace value with Base64 encoded file data\n"
		print "@uuefile=field=value - Replace value with UUEncode encoded file data\n"
		print "@db64file=field=value - Replace value with Base64 decoded file data\n"
		print "@duuefile=field=value - Replace value with UUEncode decoded file data\n"
		print "@zlibfile=field=value - Replace value with Zlib encoded file data\n"
		print "@dzlibfile=field=value - Replace value with Zlib decoded file data\n"
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
				if $binarymode == false
					File.open($logfile, "a"){|w| w.write(resp) }
					File.open($respfile, "w"){|w| w.write(x) }
					File.open($resplogfile, "a"){|w| w.write(x+"\n")}
				else
					File.open($logfile, "ab"){|w| w.write(resp) }
					File.open($respfile, "wb"){|w| w.write(x) }
					File.open($resplogfile, "ab"){|w| w.write(x+"\n")}
				end
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
				if data.at(0)[0] == "@"
					# Field is flag
			
					# Special flag treatmnet
					if data.at(0) == "@sha1"
						fields[data.at(1)] = Digest::SHA1.hexdigest(data.at(2))
					elsif data.at(0) == "@md5"
						fields[data.at(1)] = Digest::MD5.hexdigest(data.at(2))
					elsif data.at(0) == "@b64"
						fields[data.at(1)] = [data.at(2)].pack('m0').to_s
					elsif data.at(0) == "@uue"
						fields[data.at(1)] = [data.at(2)].pack('u').to_s
					elsif data.at(0) == "@db64"
						fields[data.at(1)] = data.at(2).unpack('m0').first.to_s
					elsif data.at(0) == "@duue"
						fields[data.at(1)] = data.at(2).unpack('u').first.to_s
					elsif data.at(0) == "@file"
						if File.exist?(data.at(2))
							fields[data.at(1)] = File.read(data.at(2))
						else
							print_error("File #{data.at(2)} don't exist!")
						end
					elsif data.at(0) == "@sha1file"
						if File.exist?(data.at(2))
							fields[data.at(1)] = Digest::SHA1.hexdigest(File.read(data.at(2)))
						else
							print_error("File #{data.at(2)} don't exist!")
						end
					elsif data.at(0) == "@md5file"
						if File.exist?(data.at(2))
							fields[data.at(1)] = Digest::MD5.hexdigest(File.read(data.at(2)))
						else
							print_error("File #{data.at(2)} don't exist!")
						end
					elsif data.at(0) == "@b64file"
						if File.exist?(data.at(2))
							fields[data.at(1)] = [File.read(data.at(2))].pack('m0').to_s
						else
							print_error("File #{data.at(2)} don't exist!")
						end
					elsif data.at(0) == "@uuefile"
						if File.exist?(data.at(2))
							fields[data.at(1)] = [File.read(data.at(2))].pack('u').to_s
						else
							print_error("File #{data.at(2)} don't exist!")
						end
					elsif data.at(0) == "@db64file"
						if File.exist?(data.at(2))
							fields[data.at(1)] = File.read(data.at(2)).unpack('m0').first
						else
							print_error("File #{data.at(2)} don't exist!")
						end
					elsif data.at(0) == "@duuefile"
						if File.exist?(data.at(2))
							fields[data.at(1)] = File.read(data.at(2)).unpack('u').first
						else
							print_error("File #{data.at(2)} don't exist!")
						end
					elsif data.at(0) == "@zlibfile"
						if File.exist?(data.at(2))
							fields[data.at(1)] = Zlib::Deflate.deflate(data.at(2),Zlib::BEST_COMPRESSION)
						else
							print_error("File #{data.at(2)} don't exist!")
						end
					elsif data.at(0) == "@dzlibfile"
						if File.exist?(data.at(2))
							fields[data.at(1)] = Zlib::Inflate.inflate(data.at(2))
						else
							print_error("File #{data.at(2)} don't exist!")
						end
					else
						#Normal flag treatment
						flags[data.at(0).gsub("@","")] = data.at(1)
					end
				else
					# Field is key=value field
					fields[data.at(0)] = data.at(1)
				end
			else
				if x.include?("@")
					flags[x[0].gsub("@","")] = ""
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
		if flags.include?("binary")
			if flags["binary"] == "0" || flags["nolog"].downcase == "false"
				$binarymode = false
			else
				$binarymode = true
			end
		end
		if $nolog == false
			if flags.include?("log")
				$logfile = flags["log"]
			end
			if flags.include?("respsave")
				$respfile=flags["respsave"]
			end
			if flags.include?("resplog")
				$resplogfile = flags["resplog"]
			end
		end
		if flags.include?("clear")
			File.delete($logfile)
			File.delete($respfile)
			File.delete($resplogfile)
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
	print "HTTP Post Requester v#{$version} by Narzew\n"
	if ARGV.size > 1
		$url = ARGV[0]
		PostRequester.start
	else
		PostRequester.show_help
	end
rescue => e
	print "Error: #{e}\n"
end
