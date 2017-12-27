# frozen_string_literal: true

module Inkoc
  class Config
    PROGRAM_NAME = 'inkoc'

    # The name of the directory to store bytecode files in.
    BYTECODE_DIR = 'bytecode'

    # The file extension of bytecode files.
    BYTECODE_EXT = '.inkoc'

    # The file extension of source files.
    SOURCE_EXT = '.inko'

    # The name of the root module for the standard library.
    STD_MODULE = 'std'

    # The path to the bootstrap module.
    BOOTSTRAP_MODULE = 'bootstrap'

    # The path to the prelude module.
    PRELUDE_MODULE = 'prelude'

    # The path to the module that defines the default globals exposed to every
    # module.
    GLOBALS_MODULE = 'globals'

    OBJECT_CONST = 'Object'
    TRAIT_CONST = 'Trait'
    ARRAY_CONST = 'Array'
    HASH_MAP_CONST = 'HashMap'
    BLOCK_CONST = 'Block'
    INTEGER_CONST = 'Integer'
    FLOAT_CONST = 'Float'
    STRING_CONST = 'String'
    TRUE_CONST = 'True'
    FALSE_CONST = 'False'
    BOOLEAN_CONST = 'Boolean'
    NIL_CONST = 'Nil'
    FILE_CONST = 'File'
    ARRAY_TYPE_PARAMETER = 'T'
    HASH_MAP_KEY_TYPE_PARAMETER = 'K'
    HASH_MAP_VALUE_TYPE_PARAMETER = 'K'

    MODULE_TYPE = 'Module'
    SELF_TYPE = 'Self'
    DYNAMIC_TYPE = 'Dynamic'
    MODULES_ATTRIBUTE = 'Modules'

    # The name of the constant to use as the receiver for raw instructions.
    RAW_INSTRUCTION_RECEIVER = '_INKOC'
    NEW_MESSAGE = 'new'
    UNKNOWN_MESSAGE_MESSAGE = 'unknown_message'
    MODULE_GLOBAL = 'ThisModule'
    SELF_LOCAL = 'self'
    CALL_MESSAGE = 'call'
    MODULE_SEPARATOR = '::'
    BLOCK_TYPE_NAME = 'do'
    LAMBDA_TYPE_NAME = 'lambda'
    BLOCK_NAME = '<block>'
    LAMBDA_NAME = '<lambda>'
    TRY_BLOCK_NAME = '<try>'
    ELSE_BLOCK_NAME = '<else>'
    IMPL_NAME = '<impl>'
    IMPLEMENT_TRAIT_MESSAGE = 'implement_trait'
    OBJECT_NAME_INSTANCE_ATTRIBUTE = '@_object_name'
    INIT_MESSAGE = 'init'

    RESERVED_CONSTANTS = Set.new(
      [MODULE_GLOBAL, RAW_INSTRUCTION_RECEIVER, SELF_TYPE]
    ).freeze

    attr_reader :source_directories, :mode, :target

    def initialize
      @source_directories = Set.new
      @mode = :debug
      @target = Pathname
        .new(File.join(SXDG::XDG_CACHE_HOME, PROGRAM_NAME, BYTECODE_DIR))
    end

    def target=(path)
      @target = Pathname.new(path).expand_path
    end

    def release_mode?
      @mode == :release
    end

    def release_mode
      @mode = :release
    end

    def add_source_directories(directories)
      directories.each do |dir|
        @source_directories << Pathname.new(File.expand_path(dir))
      end
    end

    def create_directories
      @target.mkpath
    end
  end
end
