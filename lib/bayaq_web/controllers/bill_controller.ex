defmodule BayaqWeb.BillController do
  use BayaqWeb, :controller

  alias Bayaq.Bills
  alias Bayaq.Bills.Bill

  action_fallback BayaqWeb.FallbackController

  def get_tnb_balance(conn, %{"account_number" => account_number}) do
    {:ok, %HTTPoison.Response{status_code: 302, body: body, headers: headers}} = HTTPoison.get "https://myaccount.mytnb.com.my/Payment/QuickPay/Search?caNumber=#{account_number}"
    {_, location} = Enum.find(headers, fn v -> elem(v,0) == "Location" end)
    {:ok, %HTTPoison.Response{status_code: 200, body: body}} = HTTPoison.get"https://myaccount.mytnb.com.my#{location}"
    {:ok, document} = Floki.parse_fragment(body)
    description = Floki.find(document, "span.label-16-12") |> Floki.text
    due_date = Floki.find(document, "div.label-16-12") |> Floki.text
    amount = Floki.find(document, "div.card-text-32-24") |> Floki.text
    bill = %{
      "description" => description,
      "due_date" => due_date,
      "amount" => amount,
    }
    render(conn, "show.json", bill: bill)
  end
  
  def get_indah_water_balance(conn, %{"account_number" => account_number}) do
    options = [recv_timeout: 10000]
    {:ok, %HTTPoison.Response{status_code: 302, body: body, headers: headers}} = HTTPoison.post "https://www.iwk.com.my/customer/pay-bill", {:form, [{"proceed", "1"}, {"accountno", "98540610"}, {"Submit", "Check+Account+Balance"}]}, %{"Content-type" => "application/x-www-form-urlencoded"}, options
    {_, cookie} = Enum.find(headers, fn v -> elem(v,0) == "Set-Cookie" end)
    {:ok, %HTTPoison.Response{status_code: 200, body: body, headers: headers}} = HTTPoison.get "https://www.iwk.com.my/customer/pay-bill-info", [], hackney: [cookie: [cookie]]
    {:ok, document} = Floki.parse_document(body)
    description = Floki.find(document, ".col-sm-8") 
               |> Enum.at(1)
               |> Floki.text
    amount =  Floki.find(document, ".col-sm-8") 
               |> Enum.at(2)
               |> Floki.text

    bill = %{
      "description" => description,
      "amount" => amount,
    }

    render(conn, "show.json", bill: bill)
  end

end
