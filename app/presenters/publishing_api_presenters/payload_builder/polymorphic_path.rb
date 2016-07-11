module PublishingApiPresenters
  module PayloadBuilder
    class PolymorphicPath
      attr_reader :item

      def self.for(item)
        new(item).call
      end

      def initialize(item)
        @item = item
      end

      def call
        { base_path: base_path }.merge(PayloadBuilder::Routes.for(base_path))
      end

    private

      def base_path
        @base_path ||= Whitehall.url_maker.polymorphic_path(item)
      end
    end
  end
end
