defmodule Bayaq.Accounts.Pipeline do
  use Guardian.Plug.Pipeline,
    otp_app: :bayaq,
    error_handler: BayaqWeb.UserController,
    module: Bayaq.Accounts.Guardian

  # If there is a session token, validate it
  plug Guardian.Plug.VerifySession, claims: %{"typ" => "access"}

  # If there is an authorization header, validate it
  plug Guardian.Plug.VerifyHeader, claims: %{"typ" => "access"}

  # Load the user if either of the verifications worked
  plug Guardian.Plug.LoadResource, allow_blank: true
end