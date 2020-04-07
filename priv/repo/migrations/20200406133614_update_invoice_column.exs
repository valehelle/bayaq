defmodule Bayaq.Repo.Migrations.UpdateInvoiceColumn do
  use Ecto.Migration

  def change do
    alter table(:invoices) do
      add :user_id, references(:users, on_delete: :delete_all)
    end
  end
end
