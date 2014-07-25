module Ahoy
  module Stores
    class ActiveRecordStore < BaseStore

      def track_visit(options, &block)
        visit = visit_model.new(
          {
            id: ahoy.visit_id,
            visitor_id: ahoy.visitor_id,
            user: user,
            started_at: options[:started_at]
          },
          :without_protection => true
        )

        visit_properties.keys.each do |key|
          visit.send(:"#{key}=", visit_properties[key]) if visit.respond_to?(:"#{key}=")
        end

        yield(visit) if block_given?

        begin
          visit.save!
        rescue ActiveRecord::RecordNotUnique
          # do nothing
        end
      end

      def track_event(name, properties, options, &block)
        event =
          event_model.new do |e|
            e.id = options[:id]
            e.visit_id = ahoy.visit_id
            e.user = user
            e.name = name
            e.properties = properties
            e.time = options[:time]
          end

        yield(event) if block_given?

        begin
          event.save!
        rescue ActiveRecord::RecordNotUnique
          # do nothing
        end
      end

      def visit
        @visit ||= visit_model.where(id: ahoy.visit_id).first if ahoy.visit_id
      end

      protected

      def visit_model
        ::Visit
      end

      def event_model
        ::Ahoy::Event
      end

    end
  end
end
