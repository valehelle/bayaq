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

  defp get_bank_code(bank_name) do
    case bank_name do
      "MB2U0227" -> "MB2U0227"
      "BCBB0235" -> "BCBB0235"
      "RHB0218" -> "RHB0218"
      "PBB0233" -> "PBB0233"
      "HLB0224" -> "HLB0224"
      "ABB0233" -> "ABB0233"
      "ABMB0212" -> "ABMB0212"
      "AMBB0209" -> "AMBB0209"
      "BIMB0340" -> "BIMB0340"
      "BMMB0341" -> "BMMB0341"
      "BKRM0602" -> "BKRM0602"
      "BSN0601" -> "BSN0601"
      "HSBC0223" -> "HSBC0223"
      "KFH0346" -> "KFH0346"
      "OCBC0229" -> "OCBC0229"
      "SCB0216" -> "SCB0216"
      "UOB0226" -> "UOB0226"
      "MBB0228" -> "MBB0228"
      _ -> "EMPTY"
    end
  end

  def pay_bills(conn, %{"bills" => bills} = params) do
    user = Guardian.Plug.current_resource(conn)
    bank_name = Map.get(params, "bank_code") 
    email = user.email
    name = user.full_name
    bill = Enum.reduce(bills, %{
        "amount" => Money.new(0, :MYR).amount,
        "description" => "Bills:"
    }, fn bill, acc -> 
     
      amount = Map.get(bill, "amount")
      current_amount = Map.get(acc, "amount")
      new_amount = Money.add(Money.new(amount, :MYR), Money.new(current_amount, :MYR)) 
      
      company_name = Map.get(bill, "companyName")
      
      current_description = Map.get(acc, "description")
      new_description = "#{current_description} \n #{company_name} - RM #{Money.to_string(Money.new(amount, :MYR))}"

      new_amount = Money.add(Money.new(amount, :MYR), Money.new(current_amount, :MYR)) 


      bill = %{
        "amount" => new_amount.amount,
        "description" => new_description
      }

  
    end)
    charge_amount = 50 * length(bills)

    description_with_service = "#{Map.get(bill, "description")} \n Service Fee - RM #{Money.to_string(Money.new(charge_amount, :MYR))}"
    bill = %{
        "amount" => Map.get(bill, "amount"),
        "description" => description_with_service
    }
    bill_amount = Money.add(Money.new(charge_amount, :MYR), Money.new(Map.get(bill, "amount"), :MYR)).amount
    bank_code = get_bank_code(bank_code)
    default_map = %{
      "collection_id" => Application.get_env(:bayaq, Bayaq.Repo)[:bayaq_collection],
      "amount" => bill_amount,
      "email" => email,
      "name" => name,
      "description" => Map.get(bill, "description"),
      "redirect_url" => Application.get_env(:bayaq, Bayaq.Repo)[:bayaq_url],
      "callback_url" => Application.get_env(:bayaq, Bayaq.Repo)[:bayaq_backend],
      "reference_1_label" => "Bank Code",
      "reference_1" => bank_code
    }

    body = Poison.encode!(default_map)
    {:ok, %HTTPoison.Response{status_code: 200, body: body}} = HTTPoison.post Application.get_env(:bayaq, Bayaq.Repo)[:bayaq_api_key], body, %{"Content-type" => "application/json"}
    body = Poison.decode!(body)
    stripe_id =  Map.get(body, "id")
    invoice_param = %{"stripe_id" => stripe_id, "bills" => bills, "email" => email, "user_id" => user.id, "amount" => bill_amount}

    {:ok, invoice} = Invoices.create_invoice(invoice_param)
    invoice = %{"id" => invoice.id, "url" => Map.get(body, "url")}
    render(conn, "show_invoice.json", invoice: invoice)
  end

  def get_sesco_balance(conn, %{"account_number" => account_number}) do
      token = "eyJhbGciOiJSUzI1NiIsImp3ayI6eyJrdHkiOiJSU0EiLCJlIjoiQVFBQiIsImtpZCI6ImQ0MTcxODBmLThmNWEtNGFhMC05NDAxLWU2MWMzZDcyZWM1OCIsIm4iOiJBTTBEZDd4QWR2NkgteWdMN3I4cUNMZEUtM0kya2s0NXpnWnREZF9xczhmdm5ZZmRpcVRTVjRfMnQ2T0dHOENWNUNlNDFQTXBJd21MNDEwWDlJWm52aHhvWWlGY01TYU9lSXFvZS1ySkEwdVp1dzJySGhYWjNXVkNlS2V6UlZjQ09Zc1FOLW1RSzBtZno1XzNvLWV2MFVZd1hrU093QkJsMUVocUl3VkR3T2llZzJKTUdsMEVYc1BaZmtOWkktSFU0b01paS1Uck5MelJXa01tTHZtMDloTDV6b3NVTkExNXZlQ0twaDJXcG1TbTJTNjFuRGhIN2dMRW95bURuVEVqUFk1QW9oMmluSS0zNlJHWVZNVVViTzQ2Q3JOVVl1SW9iT2lYbEx6QklodUlDcGZWZHhUX3g3c3RLWDVDOUJmTVRCNEdrT0hQNWNVdjdOejFkRGhJUHU4PSJ9fQ.eyJpc3MiOiJjb20uaWJtLm1mcCIsInN1YiI6ImQ0MTcxODBmLThmNWEtNGFhMC05NDAxLWU2MWMzZDcyZWM1OCIsImF1ZCI6ImNvbS5pYm0ubWZwIiwiZXhwIjoxNTg5NDc2ODQ4MzEwLCJzY29wZSI6IkN1c3RvbWVyU2VjdXJpdHlUZXN0IFJlZ2lzdGVyZWRDbGllbnQifQ.GL8HuXBZbxDeMoBgJNblbFlAv0sStL0FdCFqfVr0yswO6AYxWDXbz-Gek9aUt704-z4cPX9D_AqSlhlTAlgyhNtxsfKDQCcCepjnOJ349ulL37uNIAGOEUh4uSe9IAYvZ4oPMO9yw9ys3P32awwqKhGgkJl6Hcrt-p9n8pUj4j_ABau3l9xkZC1mjXDmqVYXTYAhciUYdYTon5is2sLrGPS5TlUgGKCr2FTHhkKz-09Qhij82ohgR1SrjRLV8mWlR46yWdi554KKzPMIssCEhJcKsz8qOwzPrOJj6UmL2ZGBJJtOb2-IsVIPYwrbswJiDVWj9EqnVm4B_HShyvun8w"
          headers = %{
            "Authorization" => "Bearer #{token}"
          }
          try do
            {:ok, %HTTPoison.Response{status_code: 200, body: body}} = HTTPoison.get "https://sebcares.sarawakenergy.com.my/SarawakEnergy3/api/adapters/Subscription/getSubscriptionDetail?params=%5B%7B%22LOCALE%22%3A%22en%22%2C%22CONTRACT_ACC_NO%22%3A%22#{account_number}%22%7D%5D", headers, ssl: [{:versions, [:'tlsv1.2']}]
                amount = Poison.decode!(body) 
                      |> Map.get("CURRENT_BILL_AMT_DUE")
               {amount, _} = Float.to_string(amount, decimals: 2)
                      |> String.replace(~r/\.|\n|RM|\*/,"", global: true)
                      |> Integer.parse
              if amount != nil do
                bill = %{
                  "description" => "",
                  "amount" => amount,
                }
                render(conn, "show.json", bill: bill)
              else
                {:error}
              end
          rescue
            e -> IO.inspect e
          end    
  end

  def get_bill_amount(conn, %{"billerCode" => biller_code, "account" => account_number}) do
    case biller_code do
      "5454" -> get_tnb_balance(conn, %{"account_number" => account_number})
      "68502" -> get_indah_water_balance(conn, %{"account_number" => account_number})
      "4200" -> get_air_selangor(conn, %{"account_number" => account_number})
    end
  end


  def get_bank_list(conn, _params) do
    credential = Application.get_env(:bayaq, Bayaq.Repo)[:bill_plz_username] |> Base.encode64()
    headers = ["Authorization": "Basic #{credential}"]
    {:ok, %HTTPoison.Response{status_code: 200, body: body}} =  HTTPoison.get Application.get_env(:bayaq, Bayaq.Repo)[:bayaq_api_bank], headers
    banks = Poison.decode!(body) 
    render(conn, "show_banks.json", banks: banks)

  end


end
