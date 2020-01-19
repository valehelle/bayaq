defmodule BayaqWeb.Router do
  use BayaqWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", BayaqWeb do
    pipe_through :browser

    get "/", PageController, :index
    get "/tnb/:account_number", BillController, :get_tnb_balance
    get "/indah_water/:account_number", BillController, :get_indah_water_balance
  end

  # Other scopes may use custom stacks.
  # scope "/api", BayaqWeb do
  #   pipe_through :api
  # end
end
