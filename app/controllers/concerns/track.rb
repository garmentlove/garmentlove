module Track
  extend ActiveSupport::Concern

  class_methods do
    def track(*attributes)
      eventable = attributes.select { |attr|  attr.class.name == "Symbol" || attr.class.name == "String" }
      actions = attributes.select { |attr| attr.class.name == "Hash" }

      after_action(*actions) do
        if eventable.empty?
          create_event
        else
          eventable.each do |evt|
            create_event(eventable: evt)
          end
        end
      end
    end
  end


  private
    def create_event(eventable: nil)
      eventable = self.instance_variable_get("@#{eventable}") \
              if eventable.is_a?(String) || eventable.is_a?(Symbol)
      eventable = eventable if eventable&.persisted? || eventable&.destroyed?

      Event.create! eventable: eventable,
                    creator: Current.identity,
                    controller: controller_name,
                    action: action_name,
                    method: Current.http_method,
                    authentication_type: Current.authentication_type,
                    format: request.format.to_s
    end
end
