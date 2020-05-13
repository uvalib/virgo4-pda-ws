class Order < ActiveRecord::Base

  validates_presence_of :isbn, :catalog_key, :computing_id, :hold_library,
    :fund_code, :loan_type
    #:vendor_order_number

  validate :user_authorized?
  attr_accessor :user_claims

  def submit_order

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