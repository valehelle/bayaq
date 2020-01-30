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
    plug CORSPlug, origin: "http://localhost:19006"
    plug :accepts, ["json"]
  end

  scope "/", BayaqWeb do
    pipe_through :browser

    get "/", PageController, :index
    get "/sdfasdfjlkjskasdfsdf", PageController, :invoice
    
  end
  
  scope "/", BayaqWeb do
    pipe_through :api
    get "/tnb/:account_number", BillController, :get_tnb_balance
    post "/pay_bills", BillController, :pay_bills
    options "/pay_bills", BillController, :options
    post "/hooks", PageController, :hooks
    get "/indah_water/:account_number", BillController, :get_indah_water_balance
    get "/bill/amount", BillController, :get_bill_amount
    options "/bill/amount", BillController, :options
  end

  # Other scopes may use custom stacks.
  # scope "/api", BayaqWeb do
  #   pipe_through :api
  # end
end

