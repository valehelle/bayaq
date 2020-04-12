defmodule Bayaq.Repo.Migrations.CreateUserBills do
  use Ecto.Migration

  def change do
    create table(:user_bills) do
      add :ref1, :string
      add :ref2, :string
      add :biller_code, :string
      add :amount, :integer
      add :company_name, :string
      add :type, :string
      add :user_id, references(:users, on_delete: :delete_all)

      timestamps()
    end

  end
end
