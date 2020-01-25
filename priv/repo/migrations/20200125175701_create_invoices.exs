defmodule Bayaq.Repo.Migrations.CreateInvoices do
  use Ecto.Migration

  def change do
    create table(:invoices) do
      add :status, :string
      add :stripe_id, :string

      timestamps()
    end

  end
end
