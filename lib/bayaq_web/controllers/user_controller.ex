defmodule BayaqWeb.UserController do
  use BayaqWeb, :controller

  alias Bayaq.Accounts
  alias Bayaq.Accounts.User
  alias Bayaq.Accounts.Guardian

  
  def register_user(conn, params) do
    Accounts.create_user(params)
    |> register_reply(conn)
  end

  defp register_reply({:error, changeset}, conn) do
    send_resp(conn, 400, "")
  end

  defp register_reply({:ok, user}, conn) do
    conn = Guardian.Plug.sign_in(conn, user)
    token = to_string(Guardian.Plug.current_token(conn))
    json(conn, %{token: token})
  end


  def login(conn, %{"email" => email, "password" => password}) do  
    Accounts.authenticate_user(email, password)
    |> login_reply(conn)
  end

  defp login_reply({:error, error}, conn) do
    send_resp(conn, 400, "")
  end


  def index(conn, params) do
    changeset = Accounts.change_user(%User{})
    conn
      |> render("index.html", changeset: changeset, action: Routes.user_path(conn, :login_web), error: "none")
  end

  def login_web(conn, %{"user" => %{"email" => email, "password" => password} = params}) do  
    case email do
    "hazmiirfan92@gmail.com" ->
      Accounts.authenticate_user(email, password)
      |> login_reply_web(conn)
    _ -> redirect(conn, to: Routes.user_path(conn, :index))
    end
  end
  defp login_reply_web({:ok, user}, conn) do
    conn
    |> Guardian.Plug.sign_in(user)
    |> redirect( to: Routes.admin_path(conn, :index))
  end

  defp login_reply({:ok, user}, conn) do
    conn = Guardian.Plug.sign_in(conn, user)
    token = to_string(Guardian.Plug.current_token(conn))
    json(conn, %{token: token})
  end

  def logout(conn, _) do
    conn
    |> Guardian.Plug.sign_out()
    |> redirect(to: Routes.user_path(conn, :login))
  end

  def auth_error(conn, {type, _reason}, _opts) do
    case type do
      :unauthenticated -> 
        send_resp(conn, 401, "")
      :invalid_token -> 
        send_resp(conn, 401, "")
    end
  end

  def create_bill(conn, %{"ref1" => ref1, "ref2" => ref2, "biller_code" => biller_code} = params) do
    user = Guardian.Plug.current_resource(conn)
    user_params = %{
      "user_id" => user.id,
    }
    params = Map.merge(params, user_params)
    if biller_code == "40386" do
      token = "eyJhbGciOiJSUzI1NiIsImp3ayI6eyJrdHkiOiJSU0EiLCJlIjoiQVFBQiIsImtpZCI6ImQ0MTcxODBmLThmNWEtNGFhMC05NDAxLWU2MWMzZDcyZWM1OCIsIm4iOiJBTTBEZDd4QWR2NkgteWdMN3I4cUNMZEUtM0kya2s0NXpnWnREZF9xczhmdm5ZZmRpcVRTVjRfMnQ2T0dHOENWNUNlNDFQTXBJd21MNDEwWDlJWm52aHhvWWlGY01TYU9lSXFvZS1ySkEwdVp1dzJySGhYWjNXVkNlS2V6UlZjQ09Zc1FOLW1RSzBtZno1XzNvLWV2MFVZd1hrU093QkJsMUVocUl3VkR3T2llZzJKTUdsMEVYc1BaZmtOWkktSFU0b01paS1Uck5MelJXa01tTHZtMDloTDV6b3NVTkExNXZlQ0twaDJXcG1TbTJTNjFuRGhIN2dMRW95bURuVEVqUFk1QW9oMmluSS0zNlJHWVZNVVViTzQ2Q3JOVVl1SW9iT2lYbEx6QklodUlDcGZWZHhUX3g3c3RLWDVDOUJmTVRCNEdrT0hQNWNVdjdOejFkRGhJUHU4PSJ9fQ.eyJpc3MiOiJjb20uaWJtLm1mcCIsInN1YiI6ImQ0MTcxODBmLThmNWEtNGFhMC05NDAxLWU2MWMzZDcyZWM1OCIsImF1ZCI6ImNvbS5pYm0ubWZwIiwiZXhwIjoxNTg5NDc2ODQ4MzEwLCJzY29wZSI6IkN1c3RvbWVyU2VjdXJpdHlUZXN0IFJlZ2lzdGVyZWRDbGllbnQifQ.GL8HuXBZbxDeMoBgJNblbFlAv0sStL0FdCFqfVr0yswO6AYxWDXbz-Gek9aUt704-z4cPX9D_AqSlhlTAlgyhNtxsfKDQCcCepjnOJ349ulL37uNIAGOEUh4uSe9IAYvZ4oPMO9yw9ys3P32awwqKhGgkJl6Hcrt-p9n8pUj4j_ABau3l9xkZC1mjXDmqVYXTYAhciUYdYTon5is2sLrGPS5TlUgGKCr2FTHhkKz-09Qhij82ohgR1SrjRLV8mWlR46yWdi554KKzPMIssCEhJcKsz8qOwzPrOJj6UmL2ZGBJJtOb2-IsVIPYwrbswJiDVWj9EqnVm4B_HShyvun8w"
          headers = %{
            "Authorization" => "Bearer #{token}"
          }
          try do
            {:ok, %HTTPoison.Response{status_code: 200, body: body, headers: headers}} = HTTPoison.get! "https://sebcares.sarawakenergy.com.my/SarawakEnergy3/api/adapters/Subscription/addSubscription?params=%5B%7B%22LOCALE%22%3A%22en%22%2C%22CONTRACT_ACC_NO%22%3A%22#{ref1}%22%2C%22CONTRACT_ACC_NAME%22%3A%22#{String.replace(ref2, " ", "%20")}%22%2C%22CONTRACT_ACC_NICK%22%3A%22#{String.replace(ref2, " ", "%20")}%22%2C%22SUBS_TYPE%22%3A%22TENANT%22%7D%5D", headers, ssl: [{:versions, [:'tlsv1.2']}]
          rescue
            e -> IO.inspect e
          end
    end
    

    case Accounts.create_bill(params) do
      {:ok, bill} -> send_resp(conn, 200, "")
      {:error, error} -> send_resp(conn, 400, "")
    end
  end

  def update_bill(conn, %{"id" => bill_id} = params) do
    user = Guardian.Plug.current_resource(conn)
    bill = Accounts.get_bill!(bill_id)
    case bill.user_id == user.id do
      true -> 
        case Accounts.update_bill(bill, params) do
          {:ok, bill} -> send_resp(conn, 200, "")
          {:error, error} -> send_resp(conn, 400, "")
        end
      false -> send_resp(conn, 400, "")
    end
  end

  def get_bills(conn, _) do
    user = Guardian.Plug.current_resource(conn)
    bills = Accounts.get_bills(user.id)
    bills = Enum.map(bills, fn bill -> %{id: bill.id,ref1: bill.ref1, ref2: bill.ref2, amount: bill.amount, biller_code: bill.biller_code, company_name: bill.company_name, type: bill.type} end)
    json(conn, %{bills: bills})
  end


  def delete_bill(conn, %{"id" => bill_id} = params) do
    user = Guardian.Plug.current_resource(conn)
    bill = Accounts.get_bill!(bill_id)
    case bill.user_id == user.id do
      true -> 
        case Accounts.delete_bill(bill) do
          {:ok, bill} -> send_resp(conn, 200, "")
          {:error, error} -> send_resp(conn, 400, "")
        end
      false -> send_resp(conn, 400, "")
    end
  end

  def get_user_info(conn,_params) do
    user = Guardian.Plug.current_resource(conn)
    render(conn, "user.json", user: user)
    
  end
  
  def update_user_bank(conn, %{"bank_code" => bank_code}) do
    user = Guardian.Plug.current_resource(conn)
    {:ok, user} = Accounts.update_user(user, %{bank_code: bank_code})
    render(conn, "user.json", user: user)
    
  end


end
