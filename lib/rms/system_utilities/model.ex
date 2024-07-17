defmodule Rms.SystemUtilities.Model do
  use Ecto.Schema
  import Ecto.Changeset
  alias Rms.SystemUtilities.TariffLine

  @timestamps_opts [autogenerate: {TariffLine.Localtime, :autogenerate, []}]
  schema "tbl_locomotive_models" do
    field :model, :string
    field :self_weight, :string
    field :status, :string, default: "D"
    # field :maker_id, :id
    # field :checker_id, :id

    belongs_to :maker, Rms.Accounts.User, foreign_key: :maker_id, type: :id
    belongs_to :checker, Rms.Accounts.User, foreign_key: :checker_id, type: :id

    timestamps()
  end

  @doc false
  def changeset(model, attrs) do
    model
    |> cast(attrs, [:model, :self_weight, :status])
    |> validate_required([:model, :self_weight, :status])
    |> validate_inclusion(:status, ~w(A D))
  end
end
