defmodule Bayaq.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias Bayaq.Invoices.Invoice
  alias Comeonin.Bcrypt


  schema "users" do
    field :email, :string
    field :password, :string
    has_many :invoices, Invoice
    timestamps()
  end


    @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :password])
    |> validate_required([:email, :password])
    |> validate_format(:email, ~r/@/)
    |> unique_constraint(:email, [name: :users_email_index])
    |> put_pass_hash()
  end

  defp put_pass_hash(%Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset) do
    change(changeset, password: Bcrypt.hashpwsalt(password))
  end
  defp put_pass_hash(changeset), do: changeset
end

