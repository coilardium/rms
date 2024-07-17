defmodule Rms.Activity.Sys_exception do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tbl_sys_exception" do
    field :col_ind, :string
    field :error_code, :string
    field :error_msg, :string

    timestamps()
  end

  @doc false
  def changeset(sys_exception, attrs) do
    sys_exception
    |> cast(attrs, [:col_ind, :error_msg, :error_code])
    |> validate_required([:col_ind, :error_msg, :error_code])
  end
end
