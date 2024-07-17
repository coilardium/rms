defmodule Rms.Vats.Vat do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tbl_vat" do
    field :rate, :decimal
    field :status, :string
    field :maker_id, :id
    field :checker_id, :id

    timestamps()
  end

  @doc false
  def changeset(vat, attrs) do
    vat
    |> cast(attrs, [:rate, :status])
    |> validate_required([:rate, :status])
  end
end
