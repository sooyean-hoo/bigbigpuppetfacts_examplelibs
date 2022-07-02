# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2013, Sebastian Staudt

begin
  require 'ffi'
rescue LoadError
end

module RBzip2::FFI

  def self.init
    begin
      extend ::FFI::Library
      ffi_lib ['bz2', 'libbz2.so.1', 'libbz2.dll']   #####  'bz2'        #### Modded by Sooyean.. TODO: Need to be reviewed later... as this is not from default gems
    rescue NameError, LoadError
      @@available = false
    end
  end

  extend RBzip2::Adapter

  autoload :BufferError,  'rbzip2/ffi/errors'
  autoload :Compressor,   'rbzip2/ffi/compressor'
  autoload :ConfigError,  'rbzip2/ffi/errors'
  autoload :CorruptError, 'rbzip2/ffi/errors'
  autoload :Decompressor, 'rbzip2/ffi/decompressor'
  autoload :Error,        'rbzip2/ffi/errors'

end

require 'rbzip2/ffi/constants'
