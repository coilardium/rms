defmodule Rms.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias Rms.SystemUtilities.TariffLine

  @timestamps_opts [autogenerate: {TariffLine.Localtime, :autogenerate, []}]
  schema "tbl_users" do
    field :email, :string
    field :first_name, :string
    field :last_name, :string
    field :mobile, :string
    field :password, :string
    field :auto_password, :string, default: "Y"
    field :status, :string, default: "D"
    field :login_attempt, :integer, default: 0
    field :remote_ip, :string
    field :last_login_dt, :naive_datetime
    field :password_expiry_dt, :date, default: Timex.today()
    field :username, :string

    belongs_to :maker, Rms.Accounts.User, foreign_key: :maker_id, type: :id
    belongs_to :checker, Rms.Accounts.User, foreign_key: :checker_id, type: :id
    belongs_to :role, Rms.Accounts.UserRole, foreign_key: :role_id, type: :id
    belongs_to :user_region, Rms.Accounts.UserRegion, foreign_key: :user_region_id, type: :id
    belongs_to :station, Rms.SystemUtilities.Station, foreign_key: :station_id, type: :id

    has_many :tariffs, Rms.SystemUtilities.TariffLine,
      foreign_key: :maker_id,
      on_delete: :nilify_all

    has_many :approved_tariffs, Rms.SystemUtilities.TariffLine,
      foreign_key: :checker_id,
      on_delete: :nilify_all

    has_many :cmdty_groups, Rms.SystemUtilities.CommodityGroup,
      foreign_key: :maker_id,
      on_delete: :nilify_all

    has_many :approved_cmdty_groups, Rms.SystemUtilities.CommodityGroup,
      foreign_key: :checker_id,
      on_delete: :nilify_all

    timestamps()

    @doc false
    def changeset(user, attrs) do
      user
      |> cast(attrs, [
        :first_name,
        :last_name,
        :mobile,
        :email,
        :auto_password,
        :username,
        :password,
        :maker_id,
        :checker_id,
        :status,
        :last_login_dt,
        :role_id,
        :remote_ip,
        :password_expiry_dt,
        :login_attempt,
        :user_region_id,
        :station_id
      ])
      |> validate_required([:first_name, :last_name, :mobile, :email])
      |> validate_format(:email, ~r/@/)
      |> validate_length(:password,
        min: 8,
        max: 40,
        message: " should be atleast 8 to 40 characters"
      )
      # has a number
      |> validate_format(:password, ~r/[0-9]+/, message: "Password must contain a number")
      # has an upper case letter
      |> validate_format(:password, ~r/[A-Z]+/,
        message: "Password must contain an upper-case letter"
      )
      # has a lower case letter
      |> validate_format(:password, ~r/[a-z]+/,
        message: "Password must contain a lower-case letter"
      )
      # |> validate_format(:password, ~r/[#\!\?&@\$%^&*\(\)]+/, message: "Password must contain a special character") # Has a symbol
      |> validate_length(:first_name,
        min: 2,
        max: 100,
        message: "should be between 3 to 100 characters"
      )
      |> validate_length(:last_name,
        min: 2,
        max: 100,
        message: "should be between 3 to 100 characters"
      )
      |> validate_length(:email,
        min: 10,
        max: 150,
        message: "Email Length should be between 10 to 150 characters"
      )
      |> unique_constraint(:email, name: :unique_email, message: "address already exists")
      |> unique_constraint(:mobile, name: :unique_mobile, message: "number already exists")
      |> put_pass_hash
      |> update_change(:email, &String.downcase/1)
      |> update_change(:first_name, &String.capitalize/1)
      |> update_change(:last_name, &String.capitalize/1)
    end

    defp put_pass_hash(%Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset) do
      case password do
        nil ->
          changeset

        _ ->
          Ecto.Changeset.put_change(changeset, :password, encrypt_password(password))
      end
    end

    defp put_pass_hash(changeset), do: changeset

    @spec encrypt_password(
            binary
            | maybe_improper_list(
                binary | maybe_improper_list(any, binary | []) | byte,
                binary | []
              )
          ) :: binary
    def encrypt_password(password), do: Base.encode16(:crypto.hash(:sha512, password))
  end

  def has_role?(%{role: roles}, module, action) when is_atom(action) and is_atom(module),
    do: get_in(roles, [module, action]) == "Y"

  def has_role?(%{role: roles}, modules, actions) when is_list(modules) and is_list(actions) do
    result =
      Enum.reduce(modules, [], fn module, acc ->
        case get_in(roles, [module]) do
          nil ->
            [false | acc]

          module ->
            result = Map.take(module, actions) |> Map.values() |> Enum.any?(&(&1 == "Y"))
            [result | acc]
        end
      end)

    Enum.any?(result, & &1)
  end

  def has_role?(_user, _module, _action), do: false

  # Rms.Accounts.create_user(%{first_name: "Admin", last_name: "Initiator", email: "admin@rms.com", username: "admin@rms.com", password: "Password@06", status: "ACTIVE", user_role: "1", user_id: "1",  mobile: "0976527271", inserted_at: NaiveDateTime.utc_now, updated_at: NaiveDateTime.utc_now})
  # Rms.Accounts.create_user(%{first_name: "Peter", last_name: "Chileshe", email: "peter@.com", username: "peter@.com", Password@06: "password", status: "ACTIVE", user_role: "1", user_id: "1",  mobile: "0976527271", inserted_at: NaiveDateTime.utc_now, updated_at: NaiveDateTime.utc_now})
end
