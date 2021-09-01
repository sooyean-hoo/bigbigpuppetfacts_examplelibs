#!/opt/puppetlabs/puppet/bin/ruby



#require 'pry-byebug'



cr=File.basename $0
cr=cr.gsub(/.rb/,".sh")
cr="./#{cr}"

if ARGV.count == 0
	puts <<-helphelp
  #{ cr } =  show this help

  #{ cr } STDIN =  read input from stdin
  #{ cr } STDOUT =  print output


  #{ cr } IN <PATH TO THE FILE FOR INPUT> = Read a file as input
  #{ cr } OUT <PATH TO THE FILE FOR OUTPUT> = Read a file as output

  #{ cr } IN - =  read input from stdin
  #{ cr } OUT - =  print output


  #{ cr } BASE64_ENC =  Convert to Base64 conversion
  #{ cr } BASE64_DEC =  Convert from Base64 conversion
  #{ cr } ZX_COMP =  Do ZX compression
  #{ cr } ZX_DECOMP =  Do ZX decompression

  #{ cr } CAT =  Just CAT the file

  In the example, all my source file is the ./Gemfile. You can also pipe string in.
  e.g.
  This is will compress the ./Gemfile, base64 encode it and print it.
  #{ cr } IN ./Gemfile OUT -  ZX_COMP |#{ cr } IN -  OUT - BASE64_ENC

  This is will base64 deencode the ./Gemfile  and print it.
  #{ cr } IN ./Gemfile OUT -  BASE64_ENC

  This is will compress the ./Gemfile, base64 encode it, then base64 deencode it, decompress and print it.
  #{ cr } IN ./Gemfile OUT -  ZX_COMP |#{ cr } IN -  OUT - BASE64_ENC | #{ cr } IN -  OUT - BASE64_DEC | #{ cr } IN -  OUT - ZX_DECOMP



  This is will compress the ./Gemfile save it as  ./Gemfile.xz .
  #{ cr } IN ./Gemfile OUT ./Gemfile.xz  ZX_COMP

  Piping Stuff in Instead of using a File, and get a compress file of the output: ./ls.xz .
  ls -l  #{ cr } IN - OUT ./ls.xz  ZX_COMP


  In Linux:::::
  For benchmarking, we can use the linux command: time. The BenchMark Gem is not used, as this can separate out the ruby processing from the Benchmarking's

  > time  #{ cr } IN ./Gemfile OUT /dev/null  ZX_COMP

  > time #{ cr } IN ./Gemfile OUT -  ZX_COMP |#{ cr } IN -  OUT - BASE64_ENC | #{ cr } IN -  OUT - BASE64_DEC | #{ cr } IN -  OUT /dev/null ZX_DECOMP

helphelp
else
#	binding.pry

	if ARGV.include?('IN')
		infname=ARGV.reduce(''){ |x_whichfollow,x|
			x_whichfollow = x if  x_whichfollow == 'IN'
			x_whichfollow = x if  x == 'IN'
			x_whichfollow
		}
		#infname=infname[0] unless infname.nil? || infname.empty?

		unless infname.nil? || infname.empty? || infname == '-'
			file = File.open(infname)
			data=file.read
			file.close
		end
	end
	data=STDIN.read if ARGV.include?('STDIN') || infname == '-'


	if ARGV.include?('OUT')
		outfname=ARGV.reduce(''){ |x_whichfollow,x|
			x_whichfollow = x if  x_whichfollow == 'OUT'
			x_whichfollow = x if  x == 'OUT'
			x_whichfollow
		}
		#outfname=outfname[0] unless outfname.nil? || outfname.empty?
	end
	outoutSTDOUT = ARGV.include?('STDOUT') || outfname == '-'

	case
	# when  ARGV.include?('CAT')
	# 	puts(data)
	when  ARGV.include?('BASE64_ENC')
		require 'base64'
		data = Base64.encode64(data)
	when  ARGV.include?('BASE64_DEC')
		require 'base64'
		data = Base64.decode64(data)

	when  ARGV.include?('ZX_COMP')
		require 'xz'
		data = XZ.compress(data)
	when  ARGV.include?('ZX_DECOMP')
		require 'xz'
		data = XZ.decompress(data)

	when  ARGV.include?('BZ_COMP')
		require 'bzip2'
		data = Bzip2.compress(data)
	when  ARGV.include?('BZ_DECOMP')
		require 'bzip2'
		data = Bzip2.uncompress(data)
	end

	unless outoutSTDOUT
		file = File.open(outfname, "w")
		file.write(data)
		file.close
	else
		puts(data)
	end
end