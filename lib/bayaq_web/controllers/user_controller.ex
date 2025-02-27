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


  def send_email(email, uuid) do
      headers = %{
            "Authorization" => "Bearer #{Application.get_env(:bayaq, Bayaq.Repo)[:send_grid_token]}",
            "Content-Type" => "application/json"
          }
          body = %{
            "personalizations" => 
              [
                %{"to" => 
                  [
                    %{"email" => email},
                  ]
                  }
              ],
              "from" => 
              %{
                "email" => "customer_support@bayaqapp.com",
              },
              "subject" => "Password Reset",
              "content" => [
                %{"type"=> "text/html", "value" => "<h4>Someone requested to reset the password on your Bayaq account. If you did not request this, please ignore this email.</h4><h4><a href=\"#{Application.get_env(:bayaq, Bayaq.Repo)[:bayaq_url]}?token=#{uuid}\">Reset Password</a></h4>"}
              ]
              
          }
          url = "https://api.sendgrid.com/v3/mail/send"
        HTTPoison.post url, Poison.encode!(body), headers
  end
  def create_reset(conn, %{"email" => email}) do
    case Accounts.get_user_by_email(email) do
      nil -> send_resp(conn, 200, "")
      user -> 
      uuid = UUID.uuid1()
      IO.inspect uuid
      params = %{user_id: user.id, token: uuid, has_expired: false}
      Accounts.invalidate_reset(user.id)
      Accounts.create_reset(params)
      send_email(user.email, uuid)
      send_resp(conn, 200, "")
    end
  end

  def reset_password(conn, %{"token" => token, "password" => password}) do
    case Accounts.get_user_by_token(token) do
      {:ok, user} -> 
        Accounts.update_user_password(user, %{password: password})
        Accounts.invalidate_reset(user.id)
        send_resp(conn, 200, "")
      _ -> send_resp(conn, 400, "")
    end
  end

  def login_web(conn, %{"user" => %{"email" => email, "password" => password} = params}) do  
          
    case email do
    "hazmiirfan92@gmail.com" ->
      Accounts.authenticate_user(email, password)
      |> login_reply_web(conn)
    "faridzul.ishak@gmail.com" ->
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
    

    case Accounts.create_bill(params) do
      {:ok, bill} -> json(conn,%{bill: %{id: bill.id,ref1: bill.ref1, ref2: bill.ref2, amount: bill.amount, biller_code: bill.biller_code, company_name: bill.company_name, type: bill.type}})
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
