require 'archive/version'
require 'archive/libarchive'
require 'archive/extract'
require 'archive/compress'

#
# Archive is a small library to leverage the FreeBSD project's libarchive to
# unpack tarballs and zip files.
#
# See the helper methods in this module, or Archive::Extract and
# Archive::Compress if you want an OOP interface.
#
module Archive

  #
  # Extract a file into a directory. The default directory is the current
  # directory.
  #
  # Format and compression will be auto-detected.
  #
  # See Archive::Extract for more information.
  #
  def self.extract(filename, dir=Dir.pwd)
    Archive::Extract.new(filename, dir).extract
  end

  #
  # Just like ::extract, but prints the filenames extracted to stdout.
  #
  def self.extract_and_print(filename, dir=Dir.pwd)
    Archive::Extract.new(filename, dir).extract(true)
  end

  #
  # Compress a directory's files into the filename provided. The default
  # directory is the current directory.
  #
  # args is a hash that contains two values, :type and :compression.
  #
  # * :type may be :tar or :zip
  # * :compression may be :gzip, :bzip2, or nil (no compression)
  #
  # If the type :zip is selected, no compression will be used. Additionally,
  # files in the .zip will all be stored as binary files.
  #
  # No files in your directory that are not *real files* will be added to the
  # archive.
  #
  # See Archive::Compress for more information, and a way to compress just the
  # files you want.
  #
  def self.compress(filename, dir=Dir.pwd, args={ :type => :tar, :compression => :gzip })
    Archive::Compress.new(filename, args).compress(get_files(dir))
  end

  #
  # Similar to ::compress, but outputs the files it's compressing.
  #
  def self.compress_and_print(filename, dir=Dir.pwd, args={ :type => :tar, :compression => :gzip })
    Archive::Compress.new(filename, args).compress(get_files(dir), true)
  end

  class << self

    protected

    #
    # Finds the files for the dir passed to ::compress.
    #
    def get_files(dir)
      require 'find'

      files = []

      Find.find(dir) do |path|
        files.push(path) if File.file?(path)
      end

      return files
    end

  end
end
