defmodule Bayaq.Repo.Migrations.ChangeBankColumn do
  use Ecto.Migration

  def change do
    alter table(:users) do
      modify :bank_code, :string, default: ""
    end
  end
end
