# https://github.com/spree-contrib/spree_address_book/blob/master/app/models/spree/order_decorator.rb
module Spree
  class Order < Spree::Base
    module AddressBook
      extend ActiveSupport::Concern # FIXME: this module is not required to be a concern

      def clone_shipping_address
        if ship_address
          self.bill_address = ship_address
        end
        true
      end

      def clone_billing_address
        if bill_address
          self.ship_address = bill_address
        end
        true
      end

      def bill_address_id=(id)
        address = Spree::Address.find_by(id: id)
        if address && address.user_id == user_id
          self['bill_address_id'] = address.id
          bill_address.reload
        else
          self['bill_address_id'] = nil
        end
      end

      def bill_address_attributes=(attributes)
        self.bill_address = update_or_create_address(attributes)
        user.update(bill_address: bill_address) if user && user.bill_address.nil?
      end

      def ship_address_id=(id)
        address = Spree::Address.find_by(id: id)
        if address && address.user_id == user_id
          self['ship_address_id'] = address.id
          ship_address.reload
        else
          self['ship_address_id'] = nil
        end
      end

      def ship_address_attributes=(attributes)
        self.ship_address = update_or_create_address(attributes)
        user.update(ship_address: ship_address) if user && user.ship_address.nil?
      end

      private

      def update_or_create_address(attributes = {})
        return if attributes.blank?

        attributes.transform_values!(&:presence)

        address_scope = user ? user.addresses : ::Spree::Address.where(user: nil)
        existing_address = address_scope.find_by(id: attributes[:id])
        new_address = address_scope.new(attributes)
        
        if existing_address && new_address == existing_address
          existing_address
        elsif existing_address&.editable?
          existing_address.update(attributes)
          existing_address
        else
          address_scope.find_or_create_by(attributes.except(:id, :updated_at, :created_at))
        end
      end
    end
  end
end
