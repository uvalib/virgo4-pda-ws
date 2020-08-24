class Order < ActiveRecord::Base
  include HTTParty
  base_uri ENV['PROQUEST_BASE_URL']
  default_timeout 8

  attr_accessor :user_claims
  validate :user_authorized?
  validates_presence_of :isbn, :catalog_key, :barcode, :hold_library, :fund_code, :loan_type

  attr_accessor :jwt

  # Custom validation messages go in config/locales/en.yml
  validates_uniqueness_of :isbn


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

    if order_response.success?
      self.vendor_order_number = order_response.parsed_response['OrderNumber']
      $logger.info "Order #{id} sent to Proquest"
      if saved = self.save
        create_sirsi_hold
      else
        $logger.warn "Problem saving after order #{id} sent to Proquest. #{self.errors.full_messages}"
      end
      return saved
    else
      $logger.error "ProQuest API failure: #{response.body}"
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

  def create_sirsi_hold
    sirsi_data = {
      titleKey: catalog_key,
      itemBarcode: barcode,
      pickupLibrary: 'CLEMONS'
    }
    sirsi_response = self.class.post('/v4/requests/hold',
      base_uri: ENV['ILS_CONNECTOR_BASE_URL'],
      body: sirsi_data,
      headers: {Authorization: jwt}
    )
    if !sirsi_response.success?
      $logger.error "ERROR during Sirsi Hold (Order: #{self.as_json}): #{sirsi_response.body}"
    end
  end

end
