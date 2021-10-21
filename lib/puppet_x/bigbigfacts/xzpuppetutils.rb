#!/opt/puppetlabs/puppet/bin/ruby -I ./lib

require_relative '../../facter/util/bigbigpuppetfacts.rb'
# require 'pry-byebug'

cr = File.basename $PROGRAM_NAME
cr = cr.gsub(%r{.rb}, '.sh')
cr = "./#{cr}"

if ARGV.count == 0
  puts <<-helphelp
  #{cr} =  show this help

  #{cr} STDIN =  read input from stdin
  #{cr} STDOUT =  print output


  #{cr} IN <PATH TO THE FILE FOR INPUT> = Read a file as input
  #{cr} OUT <PATH TO THE FILE FOR OUTPUT> = Read a file as output

  #{cr} IN - =  read input from stdin
  #{cr} OUT - =  print output


  #{cr} BASE64_ENC =  Convert to Base64 conversion
  #{cr} BASE64_DEC =  Convert from Base64 conversion
  #{cr} XZ_COMP =  Do XZ compression
  #{cr} XZ_DECOMP =  Do XZ decompression

  #{cr} CAT =  Just CAT the file

  helphelp

  { 'compress' => Facter::Util::Bigbigpuppetfacts.compressmethods.keys,
    'decompress' => Facter::Util::Bigbigpuppetfacts.decompressmethods.keys }.each do |prefix, processor_key_names|
      processor_key_names.each do |commandpostfix|
        puts <<-helphelp
  #{cr} #{prefix}_#{commandpostfix} =  #{prefix} the file using #{commandpostfix} combo-algo from "Facter::Util::Bigbigpuppetfacts"
      helphelp
      end
      puts ''
    end

  puts <<-helphelp



  In the example, all my source file is the ./Gemfile. You can also pipe string in.
  e.g.
  This is will compress the ./Gemfile, base64 encode it and print it.
  #{cr} IN ./Gemfile OUT -  XZ_COMP |#{cr} IN -  OUT - BASE64_ENC

  This is will base64 deencode the ./Gemfile  and print it.
  #{cr} IN ./Gemfile OUT -  BASE64_ENC

  This is will compress the ./Gemfile, base64 encode it, then base64 deencode it, decompress and print it.
  #{cr} IN ./Gemfile OUT -  XZ_COMP |#{cr} IN -  OUT - BASE64_ENC | #{cr} IN -  OUT - BASE64_DEC | #{cr} IN -  OUT - XZ_DECOMP


  This is will compress the ./Gemfile, base64 encode it, then base64 deencode it, decompress and print it.
  #{cr} IN ./Gemfile OUT -  BZ_COMP |#{cr} IN -  OUT - BASE64_ENC | #{cr} IN -  OUT - BASE64_DEC | #{cr} IN -  OUT - BZ_DECOMP



  This is will compress the ./Gemfile save it as  ./Gemfile.xz .
  #{cr} IN ./Gemfile OUT ./Gemfile.xz  XZ_COMP

  Piping Stuff in Instead of using a File, and get a compress file of the output: ./ls.xz .
  ls -l  #{cr} IN - OUT ./ls.xz  XZ_COMP


  In Linux:::::
  For benchmarking, we can use the linux command: time. The BenchMark Gem is not used, as this can separate out the ruby processing from the Benchmarking's,
  Also note that we are piping the data into a null. This will help to give us a better view of the performance, as it removes the I/O's contribution.#{' '}

  > time  #{cr} IN ./Gemfile OUT /dev/null  XZ_COMP

  > time #{cr} IN ./Gemfile OUT -  XZ_COMP |#{cr} IN -  OUT - BASE64_ENC | #{cr} IN -  OUT - BASE64_DEC | #{cr} IN -  OUT /dev/null XZ_DECOMP

  Here is the version with the I/O#{' '}
  > time #{cr} IN ./Gemfile OUT -  XZ_COMP |#{cr} IN -  OUT - BASE64_ENC | #{cr} IN -  OUT - BASE64_DEC | #{cr} IN -  OUT ./Gemfile.xz XZ_DECOMP


  Additional Usage inplace of bzip or xz ..bz2 directly using Facter::Util::Bigbigpuppetfacts
  helphelp
  {
    'decompress' => Facter::Util::Bigbigpuppetfacts.decompressmethods.keys }.each do |prefix, processor_key_names|
    processor_key_names.reject{ |x| /\^/.match?(x) || /base64/.match?(x) }.each do |commandpostfix|
        puts <<-helphelp
   > sudo /opt/puppetlabs/bin/facter -p somedb_instances-dump.#{commandpostfix.gsub(/_/,'.')}.base64 |   #{cr} IN - OUT -  #{prefix}_#{commandpostfix}.base64

   helphelp
      end
      puts ''
    end
  puts <<-helphelp
  In Linux:::::
  For benchmarking, we can use the linux command: time. The BenchMark Gem is not used, as this can separate out the ruby processing from the Benchmarking's,
  Also note that we are piping the data into a null. This will help to give us a better view of the performance, as it removes the I/O's contribution.#{' '}

  helphelp
  {
      'decompress' => Facter::Util::Bigbigpuppetfacts.decompressmethods.keys }.each do |prefix, processor_key_names|
      processor_key_names.reject{ |x| /\^/.match?(x) || /base64/.match?(x) }.each do |commandpostfix|
          puts <<-helphelp
     > sudo /opt/puppetlabs/bin/facter -p somedb_instances-dump.#{commandpostfix.gsub(/_/,'.')}.base64 > /tmp/db.tmp  ; time  #{cr} IN /tmp/db.tmp OUT /dev/null  #{prefix}_#{commandpostfix.gsub(/\./,'_')}_base64

     helphelp
        end
        puts ''
      end
  puts <<-helphelp

helphelp
else
  #	binding.pry

  if ARGV.include?('IN')
    infname = ARGV.reduce('') do |x_whichfollow, x|
      x_whichfollow = x if  x_whichfollow == 'IN'
      x_whichfollow = x if  x == 'IN'
      x_whichfollow
    end
    # infname=infname[0] unless infname.nil? || infname.empty?

    unless infname.nil? || infname.empty? || infname == '-'
      file = File.open(infname)
      data = file.read
      file.close
    end
  end
  data = STDIN.read if ARGV.include?('STDIN') || infname == '-'

  if ARGV.include?('OUT')
    outfname = ARGV.reduce('') do |x_whichfollow, x|
      x_whichfollow = x if  x_whichfollow == 'OUT'
      x_whichfollow = x if  x == 'OUT'
      x_whichfollow
    end
    # outfname=outfname[0] unless outfname.nil? || outfname.empty?
  end
  outout_stdout = ARGV.include?('STDOUT') || outfname == '-'

  # when  ARGV.include?('CAT')
  # 	puts(data)
  if ARGV.include?('BASE64_ENC')
    require 'base64'
    data = Base64.encode64(data)
  elsif  ARGV.include?('BASE64_DEC')
    require 'base64'
    data = Base64.decode64(data)

  elsif  ARGV.include?('XZ_COMP')
    require 'xz'
    data = XZ.compress(data)
  elsif  ARGV.include?('XZ_DECOMP')
    require 'xz'
    data = XZ.decompress(data)

  elsif  ARGV.include?('BZ_COMP')
    require 'rbzip2'
    # data = RBzip2.compress(data)
    bz2 = RBzip2.default_adapter::Compressor.new(StringIO.new(data)) # wrap the file into the compressor
    bz2.write data # write the raw data to the compressor
    bz2.close
    data
  elsif  ARGV.include?('BZ_DECOMP')
    require 'rbzip2'
    # data = RBzip2.uncompress(data)
    bz2  = RBzip2.default_adapter::Decompressor.new(StringIO.new(data)) # wrap the file into the decompressor
    data = bz2.read
    bz2.close
    data
  else
    comp_op = %r{compress_.+}.match(ARGV.join(' ')).to_s.sub(%r{compress_}, '')
    decomp_op = %r{decompress_.+}.match(ARGV.join(' ')).to_s.sub(%r{decompress_}, '')
    if decomp_op.empty?
      raise 'Error No Method Provided' if comp_op.empty?
      data = Facter::Util::Bigbigpuppetfacts.compress(data, comp_op)
    else
      data = Facter::Util::Bigbigpuppetfacts.decompress(data, decomp_op)
    end

    # ＃# Using Procs from Facter::Util::Bigbigpuppetfacts
    # { 'compress_' => Facter::Util::Bigbigpuppetfacts.compressmethods,
    #   'decompress_' => Facter::Util::Bigbigpuppetfacts.decompressmethods }.each do |prefix, processorhash|
    #   processor = processorhash.select do |pname, _p|
    #     ARGV.include?(prefix + pname)
    #   end
    #   unless processor.nil? || processor.empty?
    #     processor = processor[ processor.keys[0] ]
    #     data = processor.call(data) unless processor.nil?
    #   end
    # end
  end

  if outout_stdout
    puts(data)
  else
    file = File.open(outfname, 'w')
    file.write(data)
    file.close
  end
end
