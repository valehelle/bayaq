defmodule BayaqWeb.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.

  See `Phoenix.Controller.action_fallback/1` for more details.
  """
  use BayaqWeb, :controller

  def call(conn, {:error}) do
    bill = %{
      "description" => "",
      "amount" => 0,
    }
    conn
    |> render("show.json", bill: bill)
  end
end
