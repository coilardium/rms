defmodule Rms.Accounts.RailwayAdministrator do
  use Ecto.Schema
  use Endon
  import Ecto.Changeset
  alias Rms.SystemUtilities.TariffLine

  @timestamps_opts [autogenerate: {TariffLine.Localtime, :autogenerate, []}]
  schema "tbl_railway_administrator" do
    field :code, :string
    # field :country, :string
    field :description, :string
    field :status, :string, default: "D"
    # field :maker_id, :id
    # field :checker_id, :id

    belongs_to :maker, Rms.Accounts.User, foreign_key: :maker_id, type: :id
    belongs_to :checker, Rms.Accounts.User, foreign_key: :checker_id, type: :id
    belongs_to :country, Rms.SystemUtilities.Country, foreign_key: :country_id, type: :id

    timestamps()
  end

  @doc false
  def changeset(railway_administrator, attrs) do
    railway_administrator
    |> cast(attrs, [:code, :description, :status, :country_id, :maker_id, :checker_id])
    |> validate_required([:description, :status])
    |> validate_inclusion(:status, ~w(A D))
    |> validate_length(:code, min: 1, max: 10, message: " should be 1 - 10 character(s)")
    |> validate_length(:description, min: 1, max: 100, message: " should be 1 - 50 character(s)")
    |> unique_constraint(:code, name: :unique_operator_code, message: "already exists")
  end
end
