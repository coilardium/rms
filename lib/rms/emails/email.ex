defmodule Rms.Emails.Email do
  import Bamboo.Email
  use Bamboo.Phoenix, view: RmsWeb.InterchangeView
  alias Rms.Emails.Mailer

  def send_login_details(recipient, password) do
    new_email()
    |> from("RMS")
    |> to(recipient)
    |> subject("Account Creation")
    |> text_body("""
    Dear User,

    You been created on RMS.
    Use the following Credentials to Login into your Account
          Email :#{recipient}
          Password:  #{password}
    Please Note:
          Your credentials must be kept secured
    """)
    |> Mailer.deliver_later()
  end

  def confirm_password_reset(token, recipient) do
    new_email()
    |> from("RMS")
    |> to(recipient)
    |> subject("Password Reset")
    |> text_body("""
       Dear User,
        have received a password reset request for your account. If you recognise this activity follow the instructions below.
        http://41.175.6.106:5502/reset/password?token=#{token} to reset your password.

    """)
    |> Mailer.deliver_later()
  end

  def password_alert(recipient, password) do
    new_email()
    |> from("RMS")
    |> to(recipient)
    |> subject("Password Reset")
    |> text_body("""
    Your password reset was successful. Use the following Credentials to Login into your Account
          Email :#{recipient}
          Password:  #{password}

    Please Note:
          Your credentials must be kept secured
    """)
    |> Mailer.deliver_later()
  end

  def send_consignment_initized(client, sales_order) do
    client = Rms.Accounts.get_clients!(client)

    new_email()
    |> from("ZRL")
    |> to(client.email)
    |> subject("Your consignment has been created")
    |> text_body("""
     Dear #{client.client_name},
      Your consignment has been created on sales order #{sales_order}. You will be noted when it has been approved.
    """)
    |> Mailer.deliver_later()
  end

  def send_consignment_approved(client, sales_order) do
    client = Rms.Accounts.get_clients!(client)

    new_email()
    |> from("ZRL")
    |> to(client.email)
    |> subject("Consignment approval")
    |> text_body("""
     Dear #{client.client_name},
      Your consignment on sales order #{sales_order} has been Successfully approved.
    """)
    |> Mailer.deliver_later()
  end

  def rejected_consignment(batch_id) do
    entry = Rms.Order.get_consignment_item_by_batch_id(batch_id)
    user = Rms.Accounts.get_user!(entry.maker_id)

    new_email()
    |> from("ZRL")
    |> to(user.email)
    |> subject("Rejected Consignment")
    |> text_body("""
     Dear #{user.first_name} #{user.last_name},
      Your consignment on sales order #{entry.sale_order} has been rejected.
    """)
    |> Mailer.deliver_later()
  end

  def rejected_movement(batch_id) do
    entry = Rms.Order.list_movement_batch_items(batch_id)
    user = Rms.Accounts.get_user!(entry.maker_id)

    new_email()
    |> from("ZRL")
    |> to(user.email)
    |> subject("Movement Consignment")
    |> text_body("""
     Dear #{user.first_name} #{user.last_name},
      Your movement on batch #{entry.train_list_no} and train no #{entry.train_no} has been rejected.
    """)
    |> Mailer.deliver_later()
  end

  def wagons_alert(email, interchange, type) do
    max_period = Rms.SystemUtilities.list_company_info().on_hire_max_period

    new_email()
    |> from("coilardium@gmail.com")
    |> to("#{email}")
    |> put_html_layout({RmsWeb.LayoutView, "email.html"})
    |> subject("Interchange wagons on hire")
    |> assign(:interchange, interchange)
    |> assign(:type, type)
    |> assign(:days, max_period)
    |> render("interchange_emailing.html")
    |> Mailer.deliver_later()
  end
end
