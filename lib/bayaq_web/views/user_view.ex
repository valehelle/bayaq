defmodule BayaqWeb.UserView do
  use BayaqWeb, :view
  def render("user.json", %{user: user}) do
    %{email: user.email, name: user.full_name, bank_code: user.bank_code}
  end

end
