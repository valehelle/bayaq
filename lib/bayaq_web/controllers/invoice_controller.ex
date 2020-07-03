defmodule BayaqWeb.InvoiceController do
  use BayaqWeb, :controller

  alias Bayaq.Invoices
  action_fallback BayaqWeb.FallbackController

  def index(conn, _) do
    user = Guardian.Plug.current_resource(conn)
    invoices = Invoices.get_invoices(user.id)
    
    invoices = Enum.map(invoices, &invoice_json/1)
    json(conn, %{invoices: invoices})
  end

  def show(conn, %{"ref_id" => ref_id}) do
    user = Guardian.Plug.current_resource(conn)
    invoice =  Invoices.get_invoice_by_ref(user.id,ref_id)
    invoice = invoice_json(invoice)
    json(conn, %{invoice: invoice})
  end

  def invoice_json(invoice) do
    bills = Enum.map(invoice.bills, &bill_json/1)
    %{ref_id: invoice.stripe_id, bills: bills, paid_at: invoice.updated_at, amount: invoice.amount.amount, service_charge: invoice.service_charge.amount}
  end

  def bill_json(bill) do
    %{id: bill.id,ref1: bill.ref1, ref2: bill.ref2, amount: bill.amount.amount, biller_code: bill.biller_code, company_name: bill.company_name}
  end

end


