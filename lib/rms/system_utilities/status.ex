defmodule Rms.SystemUtilities.Status do
  use Ecto.Schema
  import Ecto.Changeset

  alias Rms.SystemUtilities.TariffLine

  @timestamps_opts [autogenerate: {TariffLine.Localtime, :autogenerate, []}]
  schema "tbl_wagon_status" do
    field :code, :string
    field :description, :string
    field :rec_status, :string, default: "D"
    field :status, :string
    field :pur_code, :string
    # field :checker_id, :id

    belongs_to :maker, Rms.Accounts.User, foreign_key: :maker_id, type: :id
    belongs_to :checker, Rms.Accounts.User, foreign_key: :checker_id, type: :id

    timestamps()
  end

  @doc false
  def changeset(status, attrs) do
    status
    |> cast(attrs, [:code, :rec_status, :description, :status, :pur_code])
    |> validate_required([:status, :description])
    |> validate_length(:description, min: 1, max: 50, message: " should be 1 - 50 character(s)")
    |> unique_constraint(:code, name: :unique_code, message: "already exists")
    |> unique_constraint(:status, name: :unique_status, message: "already exists")
  end
end
