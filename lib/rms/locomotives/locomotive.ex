defmodule Rms.Locomotives.Locomotive do
  use Ecto.Schema
  import Ecto.Changeset
  alias Rms.SystemUtilities.TariffLine

  @timestamps_opts [autogenerate: {TariffLine.Localtime, :autogenerate, []}]
  schema "tbl_locomotive" do
    field :description, :string
    field :loco_number, :string
    # field :model, :string
    # field :type_id, :string
    # field :weight, :float
    field :status, :string, default: "D"
    field :loco_engine_capacity, :decimal

    belongs_to :owner, Rms.Accounts.RailwayAdministrator, foreign_key: :owner_id, type: :id
    belongs_to :model, Rms.SystemUtilities.Model, foreign_key: :model_id, type: :id
    belongs_to :type, Rms.Locomotives.LocomotiveType, foreign_key: :type_id, type: :id
    belongs_to :maker, Rms.Accounts.User, foreign_key: :maker_id, type: :id
    belongs_to :checker, Rms.Accounts.User, foreign_key: :checker_id, type: :id

    timestamps()
  end

  @doc false
  def changeset(locomotive, attrs) do
    locomotive
    |> cast(attrs, [
      :description,
      :loco_number,
      :model_id,
      :status,
      :type_id,
      :maker_id,
      :checker_id,
      :owner_id,
      :loco_engine_capacity
    ])
    |> validate_required([:loco_number, :status, :type_id])
  end
end
