defmodule BayaqWeb.BillView do
  use BayaqWeb, :view
  alias BayaqWeb.BillView

  def render("index.json", %{bills: bills}) do
    %{data: render_many(bills, BillView, "bill.json")}
  end

  def render("show.json", %{bill: bill}) do
    bill
  end
  
  def render("show_invoice.json", %{invoice: invoice}) do
    invoice
  end

  def render("bill.json", bill) do
    bill
  end

end
