module Grape
  module Extensions
    module CrudExtension
      def create(type, options = {})
        instance = type.new
        instance.extend options[:with]
        instance.from_hash options[:from]
        yield instance if block_given?
        instance.save!
        present instance, with: options[:with]
      end

      def update(instance, options = {})
        instance.extend options[:with]
        instance.from_hash options[:from]
        yield instance if block_given?
        instance.save!
        present instance, with: options[:with]
      end

      def delete(instance, options = {})
        yield instance if block_given?
        instance.destroy
        present instance, with: options[:with]
      end

      Grape::Endpoint.send(:include, self)
    end
  end
end
