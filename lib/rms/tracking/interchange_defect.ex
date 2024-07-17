defmodule Rms.Tracking.InterchangeDefect do
  use Ecto.Schema
  use Endon
  import Ecto.Changeset
  alias Rms.SystemUtilities.TariffLine

  @timestamps_opts [autogenerate: {TariffLine.Localtime, :autogenerate, []}]
  schema "tbl_interchange_defects" do

    field :status, :string, default: "A"
    belongs_to :interchange, Rms.Tracking.Interchange, foreign_key: :interchange_id, type: :id
    belongs_to :wagon, Rms.SystemUtilities.Wagon, foreign_key: :wagon_id, type: :id
    belongs_to :spare, Rms.SystemUtilities.SpareFee, foreign_key: :spare_id, type: :id
    belongs_to :defect_spare, Rms.SystemUtilities.Spare, foreign_key: :defect_spare_id, type: :id
    belongs_to :defect, Rms.SystemUtilities.Defect, foreign_key: :defect_id, type: :id

    timestamps()
  end

  @doc false
  def changeset(interchange_defect, attrs) do
    interchange_defect
    |> cast(attrs, [:interchange_id, :spare_id, :wagon_id, :defect_id, :status, :defect_spare_id])
    |> validate_required([:interchange_id, :defect_id])
  end
end
