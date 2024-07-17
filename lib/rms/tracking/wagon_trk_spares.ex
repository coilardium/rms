defmodule Rms.Tracking.WagonTrkSpares do
  use Ecto.Schema
  import Ecto.Changeset
  alias Rms.SystemUtilities.TariffLine

  @timestamps_opts [autogenerate: {TariffLine.Localtime, :autogenerate, []}]
  schema "tbl_wagon_tracking_defect_spares" do
    # field :wagon_id, :id
    # field :spare_id, :id
    # field :tracker_id, :id
    field :quantity, :integer

    belongs_to :spare, Rms.SystemUtilities.SpareFee, foreign_key: :spare_id, type: :id
    belongs_to :wagon, Rms.SystemUtilities.Wagon, foreign_key: :wagon_id, type: :id
    belongs_to :tracker, Rms.Tracking.WagonTracking, foreign_key: :tracker_id, type: :id

    timestamps()
  end

  @doc false
  def changeset(wagon_trk_spares, attrs) do
    wagon_trk_spares
    |> cast(attrs, [:wagon_id, :spare_id, :tracker_id, :quantity])
    |> validate_required([:spare_id, :quantity, :tracker_id, :wagon_id])
  end
end
