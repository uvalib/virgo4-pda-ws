module EmailHelpers

  def send_confirmation_email

    Pony.mail(to: "#{@order.computing_id}@virginia.edu",
      subject: "Library Purchase Request (#{@order.catalog_key})",
      body: erb(:email_confirmation),
      via: :test
    )
  end
end