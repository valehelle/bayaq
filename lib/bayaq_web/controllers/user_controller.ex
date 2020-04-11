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

  def create_bill(conn, params) do
    user = Guardian.Plug.current_resource(conn)
    user_params = %{
      "user_id" => user.id,
    }
    params = Map.merge(params, user_params)

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

end
