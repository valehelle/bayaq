defmodule BayaqWeb.InvoiceController do
  use BayaqWeb, :controller

  alias Bayaq.Invoices
  action_fallback BayaqWeb.FallbackController

  def index(conn, _) do
    user = Guardian.Plug.current_resource(conn)
    
    send_resp(conn, 200, "")
  end

end
