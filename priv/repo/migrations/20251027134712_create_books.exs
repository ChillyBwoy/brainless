defmodule Brainless.Repo.Migrations.CreateBooks do
  use Ecto.Migration

  def change do
    create table(:books) do
      add :name, :string
      add :description, :text
      add :price, :integer
      add :is_available, :boolean, default: false, null: false
      add :isbn, :string
      add :author, :string
      add :published_at, :date

      timestamps(type: :utc_datetime)
    end

    create unique_index(:books, [:name, :author])
  end
end
