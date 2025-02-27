defmodule Bayaq.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias Bayaq.Invoices.Invoice
  alias Comeonin.Bcrypt
  alias Bayaq.Accounts.Bill
  alias Bayaq.Accounts.Reset



  schema "users" do
    field :email, :string
    field :password, :string
    field :full_name, :string
    field :bank_code, :string
    has_many :invoices, Invoice
    has_many :bills, Bill
    has_many :resets, Reset

    timestamps()
  end

    @doc false
  def bank_code_changeset(user, attrs) do
    user
    |> cast(attrs, [:bank_code])
    |> validate_required([:bank_code])
  end



    @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :password, :full_name])
    |> validate_required([:email, :password, :full_name])
    |> validate_format(:email, ~r/@/)
    |> unique_constraint(:email, [name: :users_email_index])
    |> put_pass_hash()
  end

  defp put_pass_hash(%Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset) do
    change(changeset, password: Bcrypt.hashpwsalt(password))
  end
  defp put_pass_hash(changeset), do: changeset
end

