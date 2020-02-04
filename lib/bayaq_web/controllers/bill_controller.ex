defmodule BayaqWeb.BillController do
  use BayaqWeb, :controller

  alias Bayaq.Invoices
  action_fallback BayaqWeb.FallbackController

  def get_tnb_balance(conn, %{"account_number" => account_number}) do
    try do
      {:ok, %HTTPoison.Response{status_code: 302, body: body, headers: headers}} = HTTPoison.get "https://myaccount.mytnb.com.my/Payment/QuickPay/Search?caNumber=#{account_number}"
      {_, location} = Enum.find(headers, fn v -> elem(v,0) == "Location" end)
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} = HTTPoison.get"https://myaccount.mytnb.com.my#{location}"
      {:ok, document} = Floki.parse_fragment(body)
      description = Floki.find(document, "span.label-16-12") |> Floki.text
      due_date = Floki.find(document, "div.label-16-12") |> Floki.text
      {amount, _} = Floki.find(document, "div.card-text-32-24") 
                |> Floki.text
                |> String.replace(~r/\.|\n|RM|\*/,"", global: true)
                |> Integer.parse
      bill = %{
        "description" => description,
        "due_date" => due_date,
        "amount" => amount,
      }
      render(conn, "show.json", bill: bill)
      rescue 
        e -> {:error}
    end
  end
  
  def get_indah_water_balance(conn, %{"account_number" => account_number}) do
    try do
      options = [recv_timeout: 20000]
      {:ok, %HTTPoison.Response{status_code: 302, body: body, headers: headers}} = HTTPoison.post "https://www.iwk.com.my/customer/pay-bill", {:form, [{"proceed", "1"}, {"accountno", account_number}, {"Submit", "Check+Account+Balance"}]}, %{"Content-type" => "application/x-www-form-urlencoded"}, options
      {_, cookie} = Enum.find(headers, fn v -> elem(v,0) == "Set-Cookie" end)
      {:ok, %HTTPoison.Response{status_code: 200, body: body, headers: headers}} = HTTPoison.get "https://www.iwk.com.my/customer/pay-bill-info", [], hackney: [cookie: [cookie]]
      {:ok, document} = Floki.parse_document(body)
      description = Floki.find(document, ".col-sm-8") 
                |> Enum.at(1)
                |> Floki.text
      {amount, _} =  Floki.find(document, ".col-sm-8") 
                |> Enum.at(2)
                |> Floki.text
                |> String.replace(~r/\.|\n|RM|\*/,"", global: true)
                |> Integer.parse

      bill = %{
        "description" => description,
        "amount" => amount,
      }

      render(conn, "show.json", bill: bill)
    rescue
      e -> {:error}
    end
  end

  def get_air_selangor(conn, %{"account_number" => account_number}) do

    try do
      headers = %{
        "Content-type" => "application/json",
        "Client-Service" => " Syabas-Portal-Service",
        "X-Powered-By" => " Syabas-Air-Selangor",
        "Accept" => "application/vnd.airselangor.portal.api+json;channel=apiv2"
      }
      body = "{\"device_name\":\"Firefox\",\"os_version\":\"72\",\"device_id\":\"KJFAWOX4-C3T78EO1-6HJ3GZQG-UNF08O9E\"}"
      {:ok, %HTTPoison.Response{status_code: 200, body: body, headers: headers}} = HTTPoison.post "https://crismobile2.airselangor.com/api/portal/token", body, headers, ssl: [{:versions, [:'tlsv1.2']}]
      token = Poison.decode!(body) |> Map.get("data") |> Map.get("token")

      headers = %{
        "Accept" => " application/vnd.airselangor.portal.api+json;channel=apiv2",
        "Client-Service" => " Syabas-Portal-Service",
        "X-Powered-By" => " Syabas-Air-Selangor",
        "Authorization" => "Bearer #{token}"
      }
      {:ok, %HTTPoison.Response{status_code: 200, body: body, headers: headers}} = HTTPoison.get "https://crismobile2.airselangor.com/api/portal/cris/account/v2/#{account_number}/info", headers, ssl: [{:versions, [:'tlsv1.2']}]
      amount = Poison.decode!(body) |> Map.get("data") |> Map.get("amount_due")
      {amount, _} =  Float.to_string(amount, decimals: 2) |> String.replace(~r/\.|\n|RM|\*/,"", global: true) |> Integer.parse
      bill = %{
        "description" => "",
        "amount" => amount,
      }
      render(conn, "show.json", bill: bill)
    rescue
      e -> {:error}
    end

  end


  def wakeup(conn, _params) do
    {:error}
  end

  def pay_bills(conn, %{"bills" => bills, "email" => email}) do
    {index, bills_map} = Enum.reduce(bills, %{"index" => 0}, fn bill, acc -> 
      
      index = Map.get(acc, "index")
      amount = Map.get(bill, "amount")
      money = Money.new(amount, :MYR)


      bill = %{
        "name" => Map.get(bill, "companyName"),
        "description" => "Account Number : #{Map.get(bill, "ref1")}",
        "amount" => money.amount,
        "currency" => "myr",
        "quantity" => 1,
      }

      add_bill = Map.put_new(acc, index, bill) 
      new_index = index + 1
      Map.put(add_bill, "index", new_index) 
    end) |> Map.pop("index")

    charge_amount = 50 * length(bills)
    bill_charge = %{
        "name" => "Bayaq",
        "description" => "Service Fee",
        "amount" => Money.new(charge_amount, :MYR).amount,
        "currency" => "myr",
        "quantity" => 1,
    }
    bills_map = Map.put_new(bills_map, index, bill_charge) 

    default_map = %{
      "customer_email" => email,
      "payment_method_types" => ["card"],
      "success_url" => "https://bayaq.netlify.com?success=true",
      "cancel_url" => "https://bayaq.netlify.com"
    }

    stripe_param = Map.merge(default_map, %{"line_items" => bills_map})
    req_body = Plug.Conn.Query.encode(stripe_param)
    {:ok, %HTTPoison.Response{status_code: 200, body: body}} = HTTPoison.post "https://api.stripe.com/v1/checkout/sessions", req_body, %{"Content-type" => "application/x-www-form-urlencoded", "Authorization" => "Bearer #{Application.get_env(:bayaq, Bayaq.Repo)[:stripe_api_key]}"}
    body = Poison.decode!(body)
    stripe_id =  Map.get(body, "id")
    invoice_param = %{"stripe_id" => stripe_id, "bills" => bills, "email" => email}
    {:ok, invoice} = Invoices.create_invoice(invoice_param)
    invoice = %{"id" => invoice.id, "stripe_id" => invoice.stripe_id}
    render(conn, "show_invoice.json", invoice: invoice)
  end

  def get_bill_amount(conn, %{"billerCode" => biller_code, "account" => account_number}) do
    case biller_code do
      "5454" -> get_tnb_balance(conn, %{"account_number" => account_number})
      "68502" -> get_indah_water_balance(conn, %{"account_number" => account_number})
      "4200" -> get_air_selangor(conn, %{"account_number" => account_number})
    end
  end

end
