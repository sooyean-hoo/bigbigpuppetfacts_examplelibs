require 'pathname'

module Archive # :nodoc:
  #
  # Compression OOP interface for Archive. See ::new and #compress for more information.
  #
  class Compress
    # the filename of the compressed archive
    attr_reader :filename
    # the type of the archive. See ::new.
    attr_reader :type
    # the compression type of the archive. See ::new.
    attr_reader :compression

    # The buffer size for reading content.
    BUFSIZE = 32767

    #
    # Create a new Compress object. Takes a filename as string, and args as
    # hash.
    #
    # args is a hash that contains two values, :type and :compression.
    #
    # * :type may be :tar or :zip
    # * :compression may be :gzip, :bzip2, or nil (no compression)
    #
    # If the type :zip is selected, no compression will be used. Additionally,
    # files in the .zip will all be stored as binary files.
    #
    # The default set of arguments is
    #
    #     { :type => :tar, :compression => :gzip }
    #
    def initialize(filename, args={ :type => :tar, :compression => :gzip })
      @filename     = filename
      @type         = args[:type] || :tar
      @compression  = args[:compression]

      if type == :zip
        @compression = nil
      end
    end

    #
    # Run the compression. Files are an array of filenames. Optional flag for
    # verbosity; if true, will print each file it adds to the archive to
    # stdout.
    #
    # Files must be real files. No symlinks, directories, unix sockets,
    # character devices, etc. This method will raise ArgumentError if you
    # provide any.
    #
    def compress(files, verbose=false)
      if files.any? { |f| !File.file?(f) }
        raise ArgumentError, "Files supplied must all be real, actual files -- not directories or symlinks."
      end

      configure_archive
      compress_files(files, verbose)
      free_archive
    end

    protected

    def configure_archive # :nodoc:
      @archive = LibArchive.archive_write_new
      LibArchive.enable_output_compression(@archive, @compression)
      LibArchive.enable_output_archive(@archive, @type)

      result = LibArchive.archive_write_open_filename(@archive, @filename)
      if result != LibArchive::ARCHIVE_OK
        raise LibArchive.archive_error_string(@archive)
      end

      @disk = LibArchive.archive_read_disk_new
      LibArchive.archive_read_disk_set_standard_lookup(@disk)
    end

    def compress_files(files, verbose) # :nodoc:
      buff = FFI::Buffer.new BUFSIZE

      # truncate our archive, this solves a few issues.
      File.open(filename, 'w').close

      files.reject { |f| Pathname.new(f).realpath == Pathname.new(filename).realpath }.each do |file|
        # TODO return value maybe?
        puts file if verbose

        stat = FFI::MemoryPointer.new Stat, 1, true
        entry = LibArchive.archive_entry_new

        LibArchive.archive_entry_set_pathname(entry, file)
        result = LibArchive.stat(File.join(Dir.pwd, file), stat)

        if result != 0
          raise "Error while calling stat(): #{LibArchive.strerror(FFI.errno)}"
        end

        LibArchive.archive_read_disk_entry_from_file(@disk, entry, -1, stat)

        result = LibArchive.archive_write_header(@archive, entry)

        if result != LibArchive::ARCHIVE_OK
          raise "archive error: #{LibArchive.archive_error_string(@archive)}"
        end

        File.open(file, 'r') do |f|
          loop do
            len = FFI::IO.native_read(f, buff, BUFSIZE)
            LibArchive.archive_write_data(@archive, buff, len)
            break if f.eof?
          end
        end

        LibArchive.archive_entry_free(entry)
      end
    end

    def free_archive # :nodoc:
      LibArchive.archive_read_close(@disk)
      LibArchive.archive_read_free(@disk)
      LibArchive.archive_write_close(@archive)
      LibArchive.archive_write_free(@archive)
    end
  end
end
