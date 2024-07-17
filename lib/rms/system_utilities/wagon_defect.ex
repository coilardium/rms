defmodule Rms.SystemUtilities.Wagon_defect do
  use Ecto.Schema
  import Ecto.Changeset
  alias Rms.SystemUtilities.TariffLine

  @timestamps_opts [autogenerate: {TariffLine.Localtime, :autogenerate, []}]
  schema "tbl_wagon_defect" do
    field :wagon_id, :id
    field :tracker_id, :id
    field :defect_id, :id
    field :defect_ids, :string
    field :maker_id, :id
    field :checker_id, :id

    timestamps()
  end

  @doc false
  def changeset(wagon_defect, attrs) do
    wagon_defect
    |> cast(attrs, [:defect_id, :maker_id, :wagon_id, :tracker_id, :defect_ids])

    # |> validate_required([])
  end
end
