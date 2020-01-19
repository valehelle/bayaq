defmodule BayaqWeb.PageController do
  use BayaqWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def get_tnb_balance() do
    {:ok, %HTTPoison.Response{status_code: 302, body: body, headers: headers}} = HTTPoison.get "https://myaccount.mytnb.com.my/Payment/QuickPay/Search?caNumber=220153258408", [], [follow_redirect: false]
    {_, location} = Enum.find(headers, fn v -> elem(v,0) == "Location" end)
    {:ok, %HTTPoison.Response{status_code: 200, body: body}} = HTTPoison.get"https://myaccount.mytnb.com.my#{location}", [], [follow_redirect: false]
    {:ok, document} = Floki.parse_fragment(body)

  end

  def get_indah_water_balance() do
    options = [recv_timeout: 10000]
    {:ok, %HTTPoison.Response{status_code: 302, body: body, headers: headers}} = HTTPoison.post "https://www.iwk.com.my/customer/pay-bill", {:form, [{"proceed", "1"}, {"accountno", "98540610"}, {"Submit", "Check+Account+Balance"}]}, %{"Content-type" => "application/x-www-form-urlencoded"}, options
    {_, cookie} = Enum.find(headers, fn v -> elem(v,0) == "Set-Cookie" end)
    {:ok, %HTTPoison.Response{status_code: 200, body: body, headers: headers}} = HTTPoison.get "https://www.iwk.com.my/customer/pay-bill-info", [], hackney: [cookie: [cookie]]
    {:ok, document} = Floki.parse_document(body)
    IO.inspect Floki.find(document, ".col-sm-8") 
               |> Enum.at(2)
               |> Floki.text
  end
end
