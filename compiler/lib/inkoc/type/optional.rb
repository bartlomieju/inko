# frozen_string_literal: true

module Inkoc
  module Type
    class Optional
      include Inspect
      include Predicates
      include ObjectOperations

      extend Forwardable

      def_delegator :type, :generic_type?
      def_delegator :type, :type_parameter?
      def_delegator :type, :block?
      def_delegator :type, :regular_object?
      def_delegator :type, :trait?

      attr_reader :type

      def initialize(type)
        @type = type
      end

      def optional?
        true
      end

      def resolve_type(*args)
        self.class.new(type.resolve_type(*args))
      end

      def initialize_as(*args)
        self.class.new(type.initialize_as(*args))
      end

      def type_name
        "?#{type.type_name}"
      end

      # rubocop: disable Style/MethodMissing
      def method_missing(name, *args, &block)
        type.public_send(name, *args, &block)
      end
      # rubocop: enable Style/MethodMissing

      def respond_to_missing?(name, include_private = false)
        type.respond_to?(name, include_private)
      end
    end
  end
end
