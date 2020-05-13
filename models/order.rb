class Order < ActiveRecord::Base
  require 'httparty'
  include HTTParty
  base_uri ENV['PROQUEST_BASE_URL']
  default_timeout 5

  attr_accessor :user_claims
  validate :user_authorized?
  validates_presence_of :isbn, :catalog_key, :computing_id, :hold_library,
    :fund_code, :loan_type

  validates_uniqueness_of :isbn, message: 'has already been ordered'


  def submit_order
    order_data = {
      apiKey: ENV['PROQUEST_API_KEY'],
      Quantity: 1,
      OrderType: 'CouttsOrder',
      Oemadm: ENV['PROQUEST_ADMIN_EMAIL'],
      ISBN: isbn,
      patronid: computing_id,
      Site: hold_library,
      Budget: fund_code,
      Loantype: loan_type
    }
    order_response = self.class.get('/order', query: order_data)

    if response.success?
      self.vendor_order_number = order_response.parsed_response['OrderNumber']
      logger.info "Successful ProQuest response for order: #{self.as_json}"
      return self.save
    else
      logger.error "ProQuest API failure: #{response.body}"
      errors.add(:base, 'There was a problem creating this order with ProQuest. Please try again later.')
      return false
    end
  end

  private

  # Check user ability to make purchases
  def user_authorized?
    if user_claims.present? && user_claims[:canPurchase]
      self.computing_id = user_claims[:userId]
      return true
    else
      errors.add(:user, 'is not authorized to make purchases')
      return false
    end
  end
end