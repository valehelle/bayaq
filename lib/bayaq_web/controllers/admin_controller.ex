defmodule BayaqWeb.AdminController do
  use BayaqWeb, :controller

  alias Bayaq.Invoices
  alias Bayaq.Accounts
  action_fallback BayaqWeb.FallbackController

  def index(conn, _) do
    user = Guardian.Plug.current_resource(conn)
    case user.email == "hazmiirfan92@gmail.com" || user.email == "faridzul.ishak@gmail.com" do
      true -> render(conn, "index.html")
      false -> redirect(conn, to: Routes.user_path(conn, :index))
    end
  end
  def users(conn, _) do
    user = Guardian.Plug.current_resource(conn)
    case user.email == "hazmiirfan92@gmail.com" || user.email == "faridzul.ishak@gmail.com" do
      true -> 
      users = Accounts.list_users()
      count = length users
      render(conn, "users.html", users: users, count: count)
      false -> redirect(conn, to: Routes.user_path(conn, :index))
    end
  end
  def bills(conn, _) do
    user = Guardian.Plug.current_resource(conn)
    case user.email == "hazmiirfan92@gmail.com" || user.email == "faridzul.ishak@gmail.com" do
      true -> 
      bills = Accounts.list_bills()
      render(conn, "bills.html", bills: bills)
      false -> redirect(conn, to: Routes.user_path(conn, :index))
    end
  end
  def paid_bills(conn, _) do
    user = Guardian.Plug.current_resource(conn)
    case user.email == "hazmiirfan92@gmail.com" || user.email == "faridzul.ishak@gmail.com" do
      true -> 
      invoices = Invoices.get_invoice_paid()
      render(conn, "invoice.html", invoices: invoices)
      false -> redirect(conn, to: Routes.user_path(conn, :index))
    end
  end

end


