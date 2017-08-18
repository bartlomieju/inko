# frozen_string_literal: true

module Inkoc
  module AST
    class Implement
      include Inspect

      attr_reader :name, :renames, :location

      # name - The trait to implement.
      # renames - The methods to rename in the implementation.
      # location - The SourceLocation of the implementation.
      def initialize(name, renames, location)
        @name = name
        @renames = renames
        @location = location
      end

      def tir_process_node_method
        :on_implement
      end
    end
  end
end