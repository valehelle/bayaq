defmodule Bayaq.Repo.Migrations.AddBankColumn do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :bank_code, :integer, default: 0
    end
  end
end
