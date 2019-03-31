defmodule Commodity.Repo.Migrations.CreateUserAndPermissionTables do
  use Ecto.Migration

  def up do
  	Commodity.Api.Util.Type.Enum.Gender.create_type
  	Commodity.Api.Util.Type.Enum.Nationality.create_type
  	Commodity.Api.Util.Type.Enum.PhoneNumber.create_type
  	Commodity.Api.Util.Type.Enum.Address.create_type
  	Commodity.Api.Util.Type.Enum.State.create_type

  	create table(:users) do
  		add :inserted_at, :naive_datetime_usec, default: fragment("now()")
  	end

  	create table(:user_personal_informations) do
  		add :user_id, references(:users, 
															on_delete: :delete_all,
															on_update: :update_all),
															null: false
      add :source_user_id, references(:users,
        on_delete: :nilify_all,
        on_update: :update_all),
        null: true
  		add :given_name, :string, size: 64, null: false
  		add :family_name, :string, size: 64, null: false
  		add :gender, :gender, default: "not_specified"
  		add :nationality, :nationality, default: "TR"
      add :birthday, :date, null: true
  		add :inserted_at, :naive_datetime_usec, default: fragment("now()")
  	end

  	create index(:user_personal_informations, [:user_id], using: :btree)
    create index(:user_personal_informations, [:source_user_id], using: :btree)
    create index(:user_personal_informations, [:gender], using: :btree)
  	create index(:user_personal_informations, [:nationality], using: :btree)

  	create table(:user_emails) do
  		add :user_id, references(:users,
  														on_delete: :delete_all,
  														on_update: :update_all),
  														null: false
			add :value, :string, size: 64, null: false
			timestamps()
  	end

  	create index(:user_emails, [:user_id], using: :btree)
  	create unique_index(:user_emails, [:value], using: :btree,
      name: :user_emails_value_unique)

    create table(:user_email_logs) do
      add :user_id, references(:users,
        on_delete: :delete_all,
        on_update: :update_all),
        null: false
      add :email_id, references(:user_emails,
        on_delete: :delete_all,
        on_update: :update_all),
        null: false
      add :source_user_id, references(:users,
        on_delete: :nilify_all,
        on_update: :update_all),
        null: true
      add :inserted_at, :naive_datetime_usec, default: fragment("now()")
    end

    create index(:user_email_logs, [:user_id], using: :btree)
    create index(:user_email_logs, [:email_id], using: :btree)
    create index(:user_email_logs, [:source_user_id], using: :btree)

  	create table(:user_email_primaries, primary_key: false) do
  		add :email_id, references(:user_emails,
  														on_delete: :delete_all,
  														on_update: :update_all),
  														null: false,
  														primary_key: true
			add :user_id, references(:users,
															on_delete: :delete_all,
															on_update: :update_all),
															null: false
      add :source_user_id, references(:users,
        on_delete: :nilify_all,
        on_update: :update_all),
        null: true
			add :inserted_at, :naive_datetime_usec, default: fragment("now()")
  	end

  	create index(:user_email_primaries, [:user_id], using: :btree)
    create index(:user_email_primaries, [:source_user_id], using: :btree)

  	create table(:user_phone_numbers) do
  		add :user_id, references(:users,
  														on_delete: :delete_all,
  														on_update: :update_all),
  														null: false
			add :value, :string, size: 24, null: false
			add :type, :phone_number, default: "not_specified"
			timestamps()
  	end

  	create index(:user_phone_numbers, [:user_id], using: :btree)
    create unique_index(:user_phone_numbers, [:value], using: :btree,
      name: :user_phone_numbers_value_unique)

    create table(:user_phone_number_logs) do
      add :user_id, references(:users,
        on_delete: :delete_all,
        on_update: :update_all),
        null: false
      add :number_id, references(:user_phone_numbers,
        on_delete: :delete_all,
        on_update: :update_all),
        null: false
      add :source_user_id, references(:users,
        on_delete: :nilify_all,
        on_update: :update_all),
        null: true
      add :inserted_at, :naive_datetime_usec, default: fragment("now()")
    end

    create index(:user_phone_number_logs, [:user_id], using: :btree)
    create index(:user_phone_number_logs, [:number_id], using: :btree)
    create index(:user_phone_number_logs, [:source_user_id], using: :btree)

  	create table(:user_phone_number_primaries, primary_key: false) do
  		add :number_id, references(:user_phone_numbers,
  																		on_delete: :delete_all,
  																		on_update: :update_all),
  																		null: false,
  																		primary_key: true
			add :user_id, references(:users,
															on_delete: :delete_all,
															on_update: :update_all),
															null: false
      add :source_user_id, references(:users,
        on_delete: :nilify_all,
        on_update: :update_all),
        null: true
			add :inserted_at, :naive_datetime_usec, default: fragment("now()")
  	end

  	create index(:user_phone_number_primaries, [:user_id], using: :btree)
    create index(:user_phone_number_primaries, [:source_user_id], using: :btree)

  	create table(:user_addresses) do
      add :user_id, references(:users,
                              on_delete: :delete_all,
                              on_update: :update_all),
                              null: false
      add :type, :address, default: "home"
      add :name, :string, size: 64
      add :country, :string, size: 24
      add :state, :string, size: 32
      add :city, :string, size: 32
      add :zip_code, :string
      add :address, :text
      timestamps()
    end

    create index(:user_addresses, [:user_id], using: :btree)

  	create table(:user_password_assignments) do
      add :user_id, references(:users, 
                              on_delete: :delete_all, 
                              on_update: :update_all),
                              null: false
      add :password_digest, :string, null: false
      add :inserted_at, :naive_datetime_usec, default: fragment("now()")
    end

    create index(:user_password_assignments, [:user_id], using: :btree)

    create table(:user_passphrases) do
      add :user_id,
          references(:users, on_delete: :delete_all, on_update: :update_all),
          null: false
      add :passphrase, :string, size: 192, null: false
      add :inserted_at, :naive_datetime_usec, default: fragment("now()")
    end

    create index(:user_passphrases, [:user_id], using: :btree)
    create unique_index(:user_passphrases, [:passphrase], using: :btree)
    create index(:user_passphrases, [:inserted_at], using: :btree)

    create table(:user_passphrase_invalidations) do
      add :source_passphrase_id, references(:user_passphrases, 
                                          on_delete: :delete_all, 
                                          on_update: :update_all),
                                          null: false
      add :target_passphrase_id, references(:user_passphrases, 
                                          on_delete: :delete_all, 
                                          on_update: :update_all),
                                          null: false
      add :inserted_at, :naive_datetime_usec, default: fragment("now()")
    end

    create index(:user_passphrase_invalidations, 
    						[:source_passphrase_id], using: :btree)
    create unique_index(:user_passphrase_invalidations, 
    										[:target_passphrase_id], using: :btree)

    create table(:user_states) do
      add :user_id, references(:users,
        on_delete: :delete_all,
        on_update: :update_all),
        null: false
      add :source_user_id, references(:users,
        on_delete: :nilify_all,
        on_update: :update_all),
        null: true
      add :state, :state, default: "active"
      add :note, :string, null: true, size: 255
      add :inserted_at, :naive_datetime_usec, default: fragment("now()")
    end

    create index(:user_states, [:user_id], using: :btree)
    create index(:user_states, [:source_user_id], using: :btree)
    create index(:user_states, [:state], using: :btree)

    create table(:permissions) do
      add :controller_name, :string, size: 100, null: false
      add :controller_action, :string, size: 30, null: false
      add :type, :string, size: 30, null: false
    end

    create unique_index(:permissions,
                        [:controller_name,
                        :controller_action,
                        :type],
                        using: :btree)

    create table(:permission_sets) do
      add :name, :string, size: 50, null: false
      add :description, :string, null: false
      add :user_id,
          references(:users, on_delete: :delete_all, on_update: :update_all)
      add :inserted_at, :naive_datetime_usec, default: fragment("now()")
    end

    create unique_index(:permission_sets, [:name], using: :btree)
    create index(:permission_sets, [:user_id], using: :btree)

    create table(:permission_set_permissions) do
      add :permission_set_id,
          references(:permission_sets, on_delete: :delete_all, on_update: :update_all),
          null: false
      add :permission_id,
          references(:permissions, on_delete: :delete_all, on_update: :update_all),
          null: false
    end

    create unique_index(:permission_set_permissions,
                        [:permission_set_id, :permission_id])

    create table(:permission_set_grants) do
      add :permission_set_id,
          references(:permission_sets, on_delete: :delete_all, on_update: :update_all),
          null: false
      add :user_id,
          references(:users, on_delete: :delete_all, on_update: :update_all),
          null: false
      add :target_user_id,
          references(:users, on_delete: :delete_all, on_update: :update_all),
          null: false
      add :inserted_at, :naive_datetime_usec, default: fragment("now()")
    end

    create index(:permission_set_grants, [:permission_set_id], using: :btree)
    create index(:permission_set_grants, [:user_id], using: :btree)
    create index(:permission_set_grants, [:target_user_id], using: :btree)
  end

  def down do
	  drop table(:permission_set_grants)
  	drop table(:permission_set_permissions)
  	drop table(:permission_sets)
  	drop table(:permissions)
  	drop table(:user_passphrase_invalidations)
  	drop table(:user_passphrases)
  	drop table(:user_password_assignments)
  	drop table(:user_phone_number_primaries)
  	drop table(:user_phone_numbers)
  	drop table(:user_email_primaries)
  	drop table(:user_emails)
  	drop table(:user_personal_informations)
		drop table(:users)

		Commodity.Api.Util.Type.Enum.Gender.drop_type
		Commodity.Api.Util.Type.Enum.Nationality.drop_type 
  	Commodity.Api.Util.Type.Enum.PhoneNumber.create_type 	
  	Commodity.Api.Util.Type.Enum.Address.create_type
  	Commodity.Api.Util.Type.Enum.State.create_type
  end
end
