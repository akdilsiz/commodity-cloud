defmodule Commodity.Repo.Migrations.CreateCompanyAndBrandTables do
  use Ecto.Migration

  def up do
  	create table(:companies) do
  		add :inserted_at, :naive_datetime_usec, default: fragment("now()")
  	end

  	create table(:company_details) do
      add :company_id, references(:companies,]
        on_delete: :delete_all,
        on_update: :update_all),
        null: false
  		add :name, :string, null: false
  		add :slug, :string, null: false
  		add :source_user_id, references(:users,
  			on_delete: :delete_all,
  			on_update: :update_all),
  			null: false
			add :inserted_at, :naive_datetime_usec, default: fragment("now()")
  	end

    create index(:company_details, [:company_id], using: :btree)
  	create index(:company_details, [:source_user_id], using: :btree)
  	create index(:company_details, [:slug], using: :btree)

  	create table(:brands) do
  		add :inserted_at, :naive_datetime_usec, default: fragment("now()")
  	end

  	create table(:brand_details) do
      add :brand_id, references(:brands,
        on_delete: :delete_all,
        on_update: :update_all),
        null: false
  		add :name, :string, null: false
  		add :slug, :string, null: false
  		add :source_user_id, references(:users,
  			on_delete: :delete_all,
  			on_update: :update_all),
  			null: false
  		add :inserted_at, :naive_datetime_usec, default: fragment("now()")
  	end

    create index(:brand_details, [:brand_id], using: :btree)
  	create index(:brand_details, [:source_user_id], using: :btree)
  	create index(:brand_details, [:slug], using: :btree)
  end

  def down do
  	drop table(:brand_details)
  	drop table(:brands)
  	drop table(:company_details)
  	drop table(:companies)
  end
end
