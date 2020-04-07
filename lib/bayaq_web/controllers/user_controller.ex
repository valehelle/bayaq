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

end
