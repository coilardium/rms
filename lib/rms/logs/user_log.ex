defmodule Rms.Logs.UserLog do
  use Ecto.Schema
  import Ecto.Changeset
  alias Rms.SystemUtilities.TariffLine

  @timestamps_opts [autogenerate: {TariffLine.Localtime, :autogenerate, []}]
  schema "tbl_user_log" do
    field :activity, :string
    field :user_id, :integer

    timestamps()
  end

  @doc false
  def changeset(user_log, attrs) do
    user_log
    |> cast(attrs, [:activity, :user_id])
    |> validate_required([:activity, :user_id])
  end
end
