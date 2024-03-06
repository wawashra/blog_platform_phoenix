defmodule BlogPlatform.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :first_name, :string
      add :last_name, :string
      add :user_name, :string
      add :password_hash, :string
      add :email, :string
      add :role, :"ENUM('ADMIN', 'USER')", null: false

      timestamps()
    end

    create unique_index(:users, [:email])
    create unique_index(:users, [:user_name])
  end

end
