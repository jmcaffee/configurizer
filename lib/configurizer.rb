require "configurizer/version"
require "pathname"
require 'yaml'

module Configurizer

  class Configuration

    ##
    # Add an instance variable to the list of non-emittable variables.
    #
    # args:: 1 or more variable names separated by commas
    #
    # Example:
    #
    #   do_not_save "var_a", "var_b", "var_c"
    #

    def self.do_not_save *args
      self._no_emit_vars = self._no_emit_vars | args
    end

    ##
    # Control which instance vars are emitted when dumped to YAML.
    #

    def encode_with(coder)
      vars = instance_variables.map { |x| x.to_s }
      no_emit = Configurizer::Configuration._no_emit_vars.reject { |x| x.nil? or x.empty? }
      no_emit = no_emit | ["_no_emit_vars"]

      vars = vars - no_emit.collect { |x| "@" + x }

      vars.each do |var|
        var_val = eval(var)
        coder[var.gsub('@', '')] = var_val
      end
    end

    private

    def self._no_emit_vars
      @_no_emit_vars ||= Array.new
    end

    def self._no_emit_vars= ary
      @_no_emit_vars = Array(ary)
    end

  end

  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods

    attr_accessor :configuration

    ##
    # Set the configuration filename to use.
    #
    # The filename should not include any part of a path
    #
    def config_filename= filename
      @cfg_filename = filename
    end

    def config_filename
      raise "config_filename not set!" if @cfg_filename.nil? or @cfg_filename.empty?
      @cfg_filename
    end

    def do_not_save *args
      Configurizer::Configuration.do_not_save *args
    end

    ##
    # Setup a configuration
    #
    # Attempts to find and load a configuration file the first time
    # it's requested. If a config file cannot be found on in the current
    # directory tree (moving towards trunk, not the leaves), a default
    # configuration object is created.
    #
    # If a block is provided, the configuration object is yielded to the block
    # after the configuration is loaded/created.
    #

    def configure
      if self.configuration.nil?
        unless self.load_configuration
          self.configuration = Configuration.new
        end
      end
      yield(configuration) if block_given?
    end

    ##
    # Walk up the directory tree from current working dir (pwd) till a file
    # named .portal_module is found
    #
    # Returns file path if found, nil if not.
    #

    def find_config_path
      path = Pathname(Pathname.pwd).ascend{|d| h=d+config_filename; break h if h.file?}
    end

    ##
    # Write configuration to disk
    #
    # Writes to current working dir (pwd) if path is nil
    #
    # Returns path of emitted file
    #

    def save_configuration(path = nil)
      # If no path provided, see if we can find one in the dir tree.
      if path.nil?
        path = find_config_path
      end

      # Still no path? Use the current working dir.
      if path.nil?
        path = Pathname.pwd
      end

      unless path.to_s.end_with?('/' + config_filename)
        path = Pathname(path) + config_filename
      end

      path = Pathname(path).expand_path
      File.write(path, YAML.dump(configuration))

      path
    end

    ##
    # Load the configuration from disk
    #
    # Returns true if config file found and loaded, false otherwise.
    #

    def load_configuration(path = nil)
      # If no path provided, see if we can find one in the dir tree.
      if path.nil?
        path = find_config_path
      end

      return false if path.nil?
      return false unless Pathname(path).exist?

      unless path.to_s.end_with?('/' + config_filename)
        path = Pathname(path) + config_filename
      end

      File.open(path, 'r') do |f|
        self.configuration = YAML.load(f)
        puts "configuration loaded from #{path}" if $debug
      end

      true
    end
  end # ClassMethods
end
