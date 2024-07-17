defmodule Rms.Locomotives.LocomotiveType do
  use Ecto.Schema
  import Ecto.Changeset
  alias Rms.SystemUtilities.TariffLine

  @timestamps_opts [autogenerate: {TariffLine.Localtime, :autogenerate, []}]

  schema "tbl_locomotive_type" do
    field :code, :string
    field :description, :string
    field :status, :string, default: "D"

    belongs_to :maker, Rms.Accounts.User, foreign_key: :maker_id, type: :id
    belongs_to :checker, Rms.Accounts.User, foreign_key: :checker_id, type: :id

    timestamps()
  end

  @doc false
  def changeset(locomotive_type, attrs) do
    locomotive_type
    |> cast(attrs, [:code, :description, :status, :maker_id, :checker_id])
    |> validate_required([:code, :description, :status])
    |> unique_constraint(:code, name: :unique_code, message: "already exists")
  end
end
