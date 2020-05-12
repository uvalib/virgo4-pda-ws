class Order < ActiveRecord::Base

  validates_presence_of :catalog_key, :computing_id, :hold_library,
    :fund_code, :loan_type
    #:vendor_order_number

    validate :user_authorized?

    private

    def get_fund_code
      # comes from marc record
      # none?: 'COUTTS1PD'
    end

    # Check user status
    def user_authorized?
     # From Virgo3:
     # account.barred?
     # acct.faculty? || acct.instructor? || acct.staff? ||
     #   acct.graduate? || acct.undergraduate?

      true
    end
end