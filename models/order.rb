class Order < ActiveRecord::Base
  include HTTParty
  base_uri ENV['PROQUEST_BASE_URL']
  default_timeout 30

  attr_accessor :user_claims
  validate :user_authorized?
  validates_presence_of :isbn, :catalog_key, :barcode, :hold_library, :fund_code, :loan_type

  attr_accessor :jwt

  # Custom validation messages go in config/locales/en.yml
  validates_uniqueness_of :isbn

  HTTP_ERRORS = [
    EOFError,
    Errno::ECONNRESET,
    Errno::ECONNREFUSED,
    Errno::EINVAL,
    Net::HTTPBadResponse,
    Net::HTTPHeaderSyntaxError,
    Net::ProtocolError,
    Timeout::Error,
  ]


  # Docs from Proquest: https://support.proquest.com/s/article/OASIS-Ordering-API?language=en_US
  def submit_order
    if vendor_order_number.present?
      # order has already been submitted
      errors.add(:isbn, I18n.t('activerecord.errors.models.order.attributes.isbn.taken'))
      return false
    end

    begin
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
      order_response = nil
      time = Benchmark.realtime do
        order_response = self.class.post('/order', query: order_data)
      end
      $logger.info "Proquest Response: #{order_response.body} - #{(time * 1000).round} mS"

      if order_response.success? && order_response.parsed_response['Code'] == 100
        self.vendor_order_number = order_response.parsed_response['OrderNumber']
        $logger.info "Order #{id} sent to Proquest. Vendor number: #{self.vendor_order_number}"
        if !self.save
          $logger.error "ERROR saving after order #{id} was sent to Proquest. #{self.errors.full_messages}"
          return false
        end
        return true
      else
        $logger.error "ERROR ProQuest API failure: #{order_response.inspect}"
        $logger.info "Request was #{order_response.request.inspect}"
        errors.add(:base, 'There was a problem creating this order with ProQuest. Please try again later.')
        return false
      end

    rescue *HTTP_ERRORS => e

      errors.add(:base, 'There was a problem creating your order. Please try again later.')
      $logger.error "HTTP ERROR: #{e}"

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
