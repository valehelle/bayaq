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
    plug CORSPlug, origin: ["http://localhost:19006", "https://bayaq.netlify.com", "http://192.168.0.153:19006", "https://bayaqapp.com", "http://bayaqapp.com", "https://www.bayaqapp.com", "http://www.bayaqapp.com"]
    plug :accepts, ["json"]
  end

  scope "/", BayaqWeb do
    pipe_through :browser

    get "/", PageController, :index
    get "/sdfasdfjlkjskasdfsdf", PageController, :invoice
    
  end

  pipeline :auth do
    plug Bayaq.Accounts.Pipeline
  end

  pipeline :ensure_auth do
    plug Guardian.Plug.EnsureAuthenticated, error_handler: BayaqWeb.UserController
  end
  
  scope "/", BayaqWeb do
    pipe_through :api
    get "/tnb/:account_number", BillController, :get_tnb_balance
    options "/hooks", BillController, :options
    post "/hooks", PageController, :hooks
    get "/indah_water/:account_number", BillController, :get_indah_water_balance
    get "/bill/amount", BillController, :get_bill_amount
    options "/bill/amount", BillController, :options
    get "/wakeup", BillController, :wakeup
    options "/wakeup", BillController, :options
    post "/users/sign_up", UserController, :register_user
    options "/users/sign_up", UserController, :options
    post "/users/sign_in", UserController, :login
    options "/users/sign_in", UserController, :options
  end

    scope "/", BayaqWeb do
    pipe_through [:api, :auth, :ensure_auth]
    get "/invoice", InvoiceController, :index
    options "/invoice", InvoiceController, :options
    post "/pay_bills", BillController, :pay_bills
    options "/pay_bills", BillController, :options
    post "/bills", UserController, :create_bill
    get "/bills", UserController, :get_bills
    put "/bills", UserController, :update_bill
    delete "/bills", UserController, :delete_bill
    options "/bills", UserController, :options

  end

  # Other scopes may use custom stacks.
  # scope "/api", BayaqWeb do
  #   pipe_through :api
  # end
end

