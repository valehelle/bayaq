defmodule Bayaq.Repo.Migrations.AddServiceChargeColumn do
  use Ecto.Migration

  def change do
    alter table(:invoices) do
      add :service_charge, :integer, default: 99
    end
  end
  
end
