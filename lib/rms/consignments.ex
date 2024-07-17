defmodule Rms.Consignments do
  @moduledoc """
  The Consignments context.
  """

  import Ecto.Query, warn: false
  alias Rms.Repo

  alias Rms.Order.Consignment

  @doc """
  Returns the list of tbl_consignments.
  
  ## Examples
  
      iex> list_tbl_consignments()
      [%Consignment{}, ...]
  
  """
  def list_tbl_consignments do
    Repo.all(Consignment)
  end

  # def pending_consign_lookup() do
  #   Consignment
  #   |> where([status: ^"PENDING"])
  #   # |> preload([:consignment])
  #   |> select(
  #   [a],
  #   map(a, [
  #     :capture_date,
  #     :code,
  #     :customer_ref,
  #     :document_date,
  #     :sale_order,
  #     :station_code,
  #     :status,
  #     :vat_amount,
  #     :invoice_no,
  #     :rsz,
  #     :nlpi,
  #     :nll_2005,
  #     :tfr,
  #     :tzr,
  #     :tzr_project,
  #     :additional_chg,
  #     :final_destination_id,
  #     :origin_station_id,
  #     :reporting_station_id,
  #     :commodity_id,
  #     :consignee_id,
  #     :consigner_id,
  #     :customer_id,
  #     :payer_id,
  #     :tarrif_id,
  #     :maker_id,
  #     :wagon_id,
  #     :checker_id,
  #     :comment,
  #     :capacity_tonnes,
  #     :actual_tonnes,
  #     :tariff_tonnage,
  #     :container_no,
  #     consignment: [:consignment_id]

  #     ])
  #   )
  #   |> Repo.all()
  # end

  @doc """
  Gets a single consignment.
  
  Raises `Ecto.NoResultsError` if the Consignment does not exist.
  
  ## Examples
  
      iex> get_consignment!(123)
      %Consignment{}
  
      iex> get_consignment!(456)
      ** (Ecto.NoResultsError)
  
  """
  def get_consignment!(id), do: Repo.get!(Consignment, id)

  @doc """
  Creates a consignment.
  
  ## Examples
  
      iex> create_consignment(%{field: value})
      {:ok, %Consignment{}}
  
      iex> create_consignment(%{field: bad_value})
      {:error, %Ecto.Changeset{}}
  
  """
  def create_consignment(attrs \\ %{}) do
    %Consignment{}
    |> Consignment.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a consignment.
  
  ## Examples
  
      iex> update_consignment(consignment, %{field: new_value})
      {:ok, %Consignment{}}
  
      iex> update_consignment(consignment, %{field: bad_value})
      {:error, %Ecto.Changeset{}}
  
  """
  def update_consignment(%Consignment{} = consignment, attrs) do
    consignment
    |> Consignment.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a consignment.
  
  ## Examples
  
      iex> delete_consignment(consignment)
      {:ok, %Consignment{}}
  
      iex> delete_consignment(consignment)
      {:error, %Ecto.Changeset{}}
  
  """
  def delete_consignment(%Consignment{} = consignment) do
    Repo.delete(consignment)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking consignment changes.
  
  ## Examples
  
      iex> change_consignment(consignment)
      %Ecto.Changeset{data: %Consignment{}}
  
  """
  def change_consignment(%Consignment{} = consignment, attrs \\ %{}) do
    Consignment.changeset(consignment, attrs)
  end

  def pending_consign_lookup() do
    Consignment
    |> join(:left, [c], w in "tbl_wagon", on: c.wagon_id == w.id)
    |> join(:left, [c, w], cl in "tbl_clients", on: c.consignee_id == cl.id)
    |> join(:left, [c, w, cl], com in "tbl_commodity", on: c.commodity_id == com.id)
    |> join(:left, [c, w, cl, com], st in "tbl_stations", on: c.origin_station_id == st.id)
    |> where([c, w], c.status == "PENDING")
    |> select([c, w, cl, com, st], %{
      id: c.id,
      wagon: w.code,
      consignee: cl.client_name,
      consigner: cl.client_name,
      description: com.description,
      container_no: c.container_no,
      sale_order: c.sale_order,
      station_code: c.station_code,
      payer: cl.client_name,
      status: c.status,
      capture_date: c.capture_date,
      origin_station: st.acronym,
      final_destination: st.acronym
    })
    |> Repo.all()
  end
end
