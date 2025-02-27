defmodule BayaqWeb.PageController do
  use BayaqWeb, :controller
  alias Bayaq.Invoices
  def index(conn, _params) do
    render(conn, "index.html")
  end

  def invoice(conn, _params) do
    invoices = Invoices.get_invoice_paid()
    render(conn, "invoice.html", invoices: invoices)
  end

  def get_tnb_balance() do
    {:ok, %HTTPoison.Response{status_code: 302, body: body, headers: headers}} = HTTPoison.get "https://myaccount.mytnb.com.my/Payment/QuickPay/Search?caNumber=220153258408", [], [follow_redirect: false]
    {_, location} = Enum.find(headers, fn v -> elem(v,0) == "Location" end)
    {:ok, %HTTPoison.Response{status_code: 200, body: body}} = HTTPoison.get"https://myaccount.mytnb.com.my#{location}", [], [follow_redirect: false]
    {:ok, document} = Floki.parse_fragment(body)

  end

  def hooks(conn, params) do
    bill_state = Map.get(params, "paid")
    case bill_state do
      "true" -> 
        {bill_plz_signature, bill_plz_params} = Map.pop(params, "x_signature")
        params_string = Enum.map(bill_plz_params, fn {k, v} -> "#{k}#{v}" end) 
          |> Enum.sort 
          |> Enum.reduce(fn x, acc -> "#{acc}|#{x}" end)

        expected_signature =  :crypto.hmac(:sha256, Application.get_env(:bayaq, Bayaq.Repo)[:signature], params_string)
          |> Base.encode16(case: :lower)
        
        case SecureCompare.compare(bill_plz_signature, expected_signature) do
          true ->
          invoice = Invoices.invoice_paid(params)
          send_push_notification(invoice.id)
          send_resp(conn, 200, "")
          false -> 
          send_resp(conn, 200, "")
        end
      "false" -> send_resp(conn, 200, "")
    end
  end

  def payment_succeed_stripe(conn, params) do
    stripe_signature = conn |> get_req_header("stripe-signature") |> List.first |> String.split(",")
    [timestamp | tail] = stripe_signature
    timestamp = String.split(timestamp, "=") |> List.last
    [signature | tail] = tail
    signature = String.split(signature, "=") |> List.last
    signed_payload = "#{timestamp}.#{conn.private[:raw_body]}"

    expected_signature =  :crypto.hmac(:sha256, Application.get_env(:bayaq, Bayaq.Repo)[:stripe_key], signed_payload)
    |> Base.encode16(case: :lower)
    case SecureCompare.compare(signature, expected_signature) do
      true -> 
      invoice = Invoices.invoice_paid(params)
      send_push_notification(invoice.id)
      send_resp(conn, 200, "")
      false -> send_resp(conn, 300, "")
    end
  end

  def send_push_notification(id) do
    HTTPoison.post "https://exp.host/--/api/v2/push/send", "{\"to\": \"ExponentPushToken[I3QjOoCnnBIqTYbIgR1x3K]\", \"title\":\"User paid Bayaq\", \"body\": \"#{id}\"}", %{"Content-type" => "application/json"}
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
