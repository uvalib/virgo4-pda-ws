module EmailHelpers

  def send_confirmation_email

    mail = Pony.mail(to: "#{@order.computing_id}@virginia.edu",
      subject: "Library Purchase Request (#{@order.catalog_key})",
      body: erb(:email_confirmation)
    )
    $logger.debug "Mailer diagnostic code: #{mail.diagnostic_code}" if mail.diagnostic_code
  end
end