require 'socket'
h_name = 'localhost'
s_port = 20000

S = TCPSocket.new h_name,s_port

C_uioptions = %Q{Opções:
1 - Lista arquivos disponíveis para download
2 - Baixa arquivo do servidor
3 - Envia arquivo para o servidor
4 - Renomeia arquivo no servidor
5 - Tamanho de um arquivo no servidor
6 - Sair
}

puts S.readline
puts C_uioptions
# hack!
S.readline

def send_cmd args
	case args
		
		when "1"
			S.puts "LS\n"
			S.gets.split('|').each do |str|
				puts str
			end

		when "2"
			puts "digite o nome do arquivo"
			f_name = gets.chomp
			S.puts "GET #{f_name}\n"
			ret = S.gets
			if ret == "FILE NOT FOUND\n"
				puts "arquivo não encontrado"
			else
				f_size = ret.chomp.to_s.to_i
				f = File.open(f_name,"w+")
				f_size.times do |x|
					b = S.read(1)
					f.write(b)
				end
				f.close
				puts "#{f_size} bytes recebidos com êxito"
			end

		when "3"
			puts "digite o nome do arquivo p/ ser enviado"
			f_name = gets.chomp
			f_size = File.size(f_name)
			S.puts "SEND #{f_name}|#{f_size}\n"
			ret = S.readline
			if ret == "FILE ALREADY EXIST\n"
				puts "arquivo já existe"
			elsif ret.to_s == "OK\n"
				file = File.open(f_name,"r")
				f_size.times do 
					S.write(file.read(1))
				end
				puts "#{f_size} enviados com êxito"
			else			
				puts "?"
			end

		when "4"
			puts "digite o nome do arquivo p/ ser renomeado"
			o_fname = gets.chomp
			puts "digite o novo nome do arquivo"
			n_fname = gets.chomp
			S.puts "RENAME #{o_fname}|#{n_fname}\n"
			ret = S.gets
			if ret == "OK\n"
				puts "arquivo renomeado com êxito"
			elsif ret == "FILE NOT FOUND\n"
				puts "arquivo não encontrado"
			end

		when "5"
			puts "digite o novo nome do arquivo"
			f_name = gets.chomp
			S.puts "SIZE #{f_name}\n"
			ret = S.gets
			if ret == "FILE NOT FOUND\n"
				puts "arquivo não encontrado"
			else
				puts "arquivo #{f_name} possui #{ret.chomp} bytes"
			end
		when "6"
			S.close
			puts "FIM."
		else 
			puts C_uioptions
	end
end

loop do
	x = gets.chomp
	begin
		send_cmd x
	rescue Exception => e
		puts "#ERRO #{e}"
	end
	break if x == "6"
end