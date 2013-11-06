require 'socket'
s_port = 20000
s = TCPServer.new s_port
s_welcome_message = %Q{Cliente para envio e recebimento de arquivos\n }

def do_cmd args,c

	if args.start_with? "LS\n"
		c.puts Dir.entries(".").select{ |f| File.file? f and !f.start_with? "." }.join("|").chomp.to_s
	
	elsif args.start_with? "GET"
		f_name = args[4..-1].chomp
		if File.exist?(f_name)
			f_size = File.size(f_name)
			c.puts "#{f_size}\n"
			file = File.open(f_name,"r")
			f_size.times do
				c.write(file.read(1))
			end
			file.close
			puts "SERVIDOR: arquivo #{f_name} (#{f_size} bytes) enviado"
		else
			c.puts "FILE NOT FOUND\n"
		end

	elsif args.start_with? "SEND"
		str = args[5..-1].chomp.split('|')
		f_name = str[0]
		f_size = str[1].to_i
		if File.exist?(f_name)
			c.puts "FILE ALREADY EXIST\n"
			puts "SERVIDOR: arquivo já existe"
		else
			c.puts "OK\n"
			f = File.open(f_name,"w")
			f_size.times do 
				f.write(c.read(1))
			end
			puts "SERVIDOR: arquivo #{f_name} (#{f_size} bytes) recebido"
		end

	elsif args.start_with? "RENAME"
		str = args[7..-1].chomp.split('|')
		f_name = str[0]
		new_f_name = str[1]
		if File.exist?(f_name)
			File.rename(f_name,new_f_name)
			c.puts "OK\n"
			puts "SERVIDOR: arquivo #{f_name} renomado para #{new_f_name}"
		else
			c.puts "FILE NOT FOUND\n"
		end
	
	elsif args.start_with? "SIZE"
		f_name = args[5..-1].chomp
		if File.exist?(f_name)
			f_size = File.size(f_name)
			c.puts "#{f_size}\n"
			puts "SERVIDOR: tamanho do arquivo #{f_name} é #{f_size} bytes"
		else
			c.puts "FILE NOT FOUND\n"
		end
	
	else
		c.puts "SERVIDOR: comando não implementado no protocolo"
	end
end

c = s.accept

loop do
	begin
		c.puts s_welcome_message
		loop do
			cmd = c.readline
			puts "CLIENTE: #{cmd}"
			do_cmd cmd.to_s,c
		end	
		t.join
	rescue Exception => e
		puts "#ERRO #{e}"
	end
end