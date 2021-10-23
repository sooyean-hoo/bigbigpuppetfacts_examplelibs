module Archive # :nodoc:
  #
  # Extraction OOP interface for Archive. See ::new and #extract for more information.
  #
  class Extract

    # The filename of the compressed archive. See ::new.
    attr_reader :filename
    # The extraction directory target. See ::new.
    attr_reader :dir

    #
    # Create a new Extract object. Takes a filename as string containing the
    # archive name, and a directory name as string containing the target path
    # to extract to. The default target is the current directory.
    #
    # If either the filename or directory name do not already exist,
    # ArgumentError will be raised.
    #
    # Extraction tries to preserve timestamps and permissions, but not uid/gid.
    # Note that this is format-dependent -- e.g., .zip files will always be
    # extracted as mode 0777.
    #
    def initialize(filename, dir=Dir.pwd)
      unless File.exist?(filename)
        raise ArgumentError, "File '#{filename}' does not exist!"
      end

      unless File.directory?(dir)
        raise ArgumentError, "Directory '#{dir}' does not exist!"
      end

      @filename = filename
      @dir      = dir

      @extract_flags =
        LibArchive::ARCHIVE_EXTRACT_PERM |
        LibArchive::ARCHIVE_EXTRACT_TIME
    end

    #
    # Perform the extraction. Takes an optional value that when true prints
    # each filename extracted to stdout.
    #
    def extract(verbose=false)
      create_io_objects
      open_file

      header_loop(verbose)

      close
    end

    protected

    def create_io_objects # :nodoc:
      @in = LibArchive.archive_read_new
      @out = LibArchive.archive_write_disk_new
      LibArchive.archive_write_disk_set_options(@out, @extract_flags)
      @entry = FFI::MemoryPointer.new :pointer
      LibArchive.enable_input_formats(@in)
    end

    def open_file # :nodoc:
      LibArchive.archive_read_open_filename(@in, @filename, 10240)
    end

    def header_loop(verbose) # :nodoc:
      while ((result = LibArchive.archive_read_next_header(@in, @entry)) != LibArchive::ARCHIVE_EOF)

        if result != LibArchive::ARCHIVE_OK
          raise LibArchive.archive_error_string(@in)
        end

        entry_pointer = @entry.get_pointer(0)

        full_path = File.join(@dir, LibArchive.archive_entry_pathname(entry_pointer))
        LibArchive.archive_entry_set_pathname(entry_pointer, File.expand_path(full_path))
        puts LibArchive.archive_entry_pathname(entry_pointer) if verbose

        if hardlink_path = LibArchive.archive_entry_hardlink(entry_pointer)
          begin
            File.link(File.expand_path(hardlink_path, @dir), full_path)
          rescue Errno::EEXIST
            File.unlink(full_path)
            retry
          end
        else
          if ((result = LibArchive.archive_write_header(@out, entry_pointer)) != LibArchive::ARCHIVE_OK)
            raise LibArchive.archive_error_string(@out)
          end

          unpack_loop
        end

        LibArchive.archive_write_finish_entry(@out)
      end
    end

    def unpack_loop # :nodoc:
      loop do
        buffer = FFI::MemoryPointer.new :pointer, 1
        size   = FFI::MemoryPointer.new :ulong_long, 1
        offset = FFI::MemoryPointer.new :long_long, 1

        result = LibArchive.archive_read_data_block(@in, buffer, size, offset)

        break if result == LibArchive::ARCHIVE_EOF

        unless result == LibArchive::ARCHIVE_OK
          raise LibArchive.archive_error_string(@in)
        end

        result = LibArchive.archive_write_data_block(@out, buffer.read_pointer, size.read_ulong_long, offset.read_long_long);

        if result != LibArchive::ARCHIVE_OK
          raise LibArchive.archive_error_string(@out)
        end
      end
    end

    def close # :nodoc:
      LibArchive.archive_read_close(@in)
      LibArchive.archive_read_free(@in)
      LibArchive.archive_write_close(@out)
      LibArchive.archive_write_free(@out)
      @in = nil
      @out = nil
      @entry = nil
    end
  end
end
