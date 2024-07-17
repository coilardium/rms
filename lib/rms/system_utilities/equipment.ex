defmodule Rms.SystemUtilities.Equipment do
  use Ecto.Schema
  import Ecto.Changeset
  alias Rms.SystemUtilities.TariffLine

  @timestamps_opts [autogenerate: {TariffLine.Localtime, :autogenerate, []}]
  schema "tbl_equipments" do
    field :code, :string
    field :description, :string
    field :status, :string, default: "D"

    belongs_to :maker, Rms.Accounts.User, foreign_key: :maker_id, type: :id
    belongs_to :checker, Rms.Accounts.User, foreign_key: :checker_id, type: :id

    timestamps()
  end

  @doc false
  def changeset(equipment, attrs) do
    equipment
    |> cast(attrs, [:code, :description, :maker_id, :checker_id, :status])
    |> validate_required([:description])
    |> unique_constraint(:description, name: :unique_description, message: "already exists")
    |> unique_constraint(:code, name: :unique_code, message: "already exists")
  end
end
