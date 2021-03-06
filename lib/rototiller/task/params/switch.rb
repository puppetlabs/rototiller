require "rototiller/task/collections/env_collection"

module Rototiller
  module Task
    # The Switch class to implement rototiller command switch handling
    #   via a RototillerTask's #add_command and Command's #add_switch
    #   contains information about a Switch's state, as influenced by environment variables,
    #     for instance
    # @since v1.0.0
    # @attr [String] name The name of the switch to add to a command string
    class Switch < RototillerParam
      # @return [String] the command to be used, could be considered a default
      # FIXME: this really needs a test, or to not have accessors
      attr_accessor :name

      # Creates a new instance of Switch
      # @param [Hash,Array<Hash>] args hashes of information about the switch
      # for block { |b| ... }
      # @yield Switch object with attributes matching method calls supported by Switch
      # @return Switch object
      def initialize(args = {})
        # the env_vars that override the name
        @env_vars = EnvCollection.new
        block_given? ? (yield self) : send_hash_keys_as_methods_to_self(args)
        # do this after we have done the rest of init, so @name can be re-set
        set_command_name_from_our_env_vars
      end

      # adds environment variables to be tracked, messaged.
      #   In the Switch context this env_var overrides the switch "name"
      # @param [Hash] args hashes of information about the environment variable
      # @option args [String] :name The environment variable
      # @option args [String] :default The default value for the environment variable
      # @option args [String] :message A message describing the use of this variable
      #
      # for block {|a| ... }
      # @yield [a] Optional block syntax allows you to specify information about the
      #   environment variable, available methods match hash keys
      def add_env(*args, &block)
        raise ArgumentError, "#{__method__} takes a block or a hash" if !args.empty? && block_given?
        # this is kinda annoying we have to do this for all params? (not DRY)
        #   have to do it this way so EnvVar doesn't become a collection
        #   but if this gets moved to a mixin, it might be more tolerable
        if block_given?
          # send in the name of this Param, so it can be used when no default is given to add_env
          @env_vars.push(EnvVar.new({ parent_name: @name }, &block))
        else
          # TODO: test this with array and non-array single hash
          add_hash_env(args)
        end
        #   do this every time a new env_var is created (thus here)
        set_command_name_from_our_env_vars
      end

      # Does this param require the task to stop
      # Determined by the interactions between @name and @env_vars
      # @return [true|nil] if this param requires a stop
      def stop
        true unless @name
      end

      # @return [String] formatted messages from all of Switch's pieces
      #   itself, env_vars
      def message(indent = 0)
        [@env_vars.messages(indent)].join ""
      end

      # The string representation of this Switch; the value sent by author, or
      #   overridden by any env_vars
      # @return [String] the Switch's value
      def to_str
        @name.to_s
      end
      alias to_s to_str

      private

      # @api private
      # our name/value is the value of the last env_var set, if any
      # FIXME: this should be abstracted into a parent class above RototillerParam
      #   this is used only, but in both of command and switch.
      def set_command_name_from_our_env_vars
        @name = @env_vars.last if @env_vars.last
      end

      # @api private
      def add_hash_env(args)
        args.each do |arg| # we can accept an array of hashes, each of which defines a param
          validate_hash_param_arg(arg)
          # send in the name of this Param, so it can be used when no default is given to add_env
          arg[:parent_name] = @name
          @env_vars.push(EnvVar.new(arg))
        end
      end
    end
  end
end
