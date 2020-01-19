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
    IO.inspect Floki.find(document, "span.label-16-12") |> Floki.text
    IO.inspect Floki.find(document, "div.label-16-12") |> Floki.text
  end

  @tag wip: true
  def get_indah_water_balance() do
    {:ok, %HTTPoison.Response{status_code: 200, body: body, headers: headers}} = HTTPoison.post "https://www.iwk.com.my/customer/pay-bill", [], [follow_redirect: false]
    {_, cookie} = Enum.find(headers, fn v -> elem(v,0) == "Set-Cookie" end)
    {:ok, %HTTPoison.Response{status_code: 200, body: body, headers: headers}} = HTTPoison.get "https://www.iwk.com.my/customer/pay-bill-info", [], hackney: [cookie: ["PHPSESSID=impafml35la3fi0vmohj6lg9n0"]]
    {:ok, document} = Floki.parse_document(body)
    IO.inspect Floki.find(document, ".col-sm-8") 
               |> Enum.at(2)
               |> Floki.text
  end
end
