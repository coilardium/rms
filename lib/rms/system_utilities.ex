defmodule Rms.SystemUtilities do
  @moduledoc """
  The SystemUtilities context.
  """
  # Rms.SystemUtilities.filter_distance_lookup(nil, 1, 10, nil)
  import Ecto.Query, warn: false
  alias Rms.Repo

  alias Rms.SystemUtilities.TariffLine

  @doc """
  Returns the list of tbl_tariff_line.

  ## Examples

      iex> list_tbl_tariff_line()
      [%TariffLine{}, ...]

  """

  def remove_spaces(code) do
    code
    |> String.replace(~r/ +/, " ")
    |> String.trim()
    |> String.downcase()
  end

  def list_tbl_tariff_line do
    TariffLine
    |> preload([
      :maker,
      :checker,
      :commodity,
      :currency,
      :pay_type,
      :surcharge,
      :orig_station,
      :destin_station,
      :client
    ])
    |> Repo.all()
  end

  def tariffline_lookup(client_id, orig_station_id, destin_station_id, commodity, date)
      when client_id == "" or is_nil(client_id) or orig_station_id == "" or
             is_nil(orig_station_id) or destin_station_id == "" or is_nil(destin_station_id) or
             commodity == "" or is_nil(commodity) or date == "" or is_nil(date),
      do: nil

  def tariffline_lookup(client_id, orig_station_id, destin_station_id, commodity, date) do
    from(a in TariffLine, as: :rate)
    |> where(
      [a],
      a.orig_station_id == ^orig_station_id and a.destin_station_id == ^destin_station_id and
        a.client_id == ^client_id and a.commodity_id == ^commodity and a.status == "A" and
        fragment("CAST(? AS DATE) >= ?", ^date, a.start_dt)
    )
    |> join(:left, [a], b in Rms.SystemUtilities.TariffLineRate, on: a.id == b.tariff_id)
    |> join(:left, [a, b], c in Rms.Accounts.RailwayAdministrator, on: b.admin_id == c.id)
    |> join(:left, [a, b, c], d in Rms.SystemUtilities.Country, on: c.country_id == d.id)
    |> join(:left, [a, b, c, d], e in Rms.SystemUtilities.Surchage, on: a.surcharge_id == e.id)
    |> where(
      [a, b, c, d, e],
      a.id in subquery(
        from(
          max_rate in TariffLine,
          where:
            parent_as(:rate).orig_station_id == max_rate.orig_station_id and
              parent_as(:rate).destin_station_id == max_rate.destin_station_id and
              parent_as(:rate).client_id == max_rate.client_id and
              parent_as(:rate).commodity_id == max_rate.commodity_id and max_rate.status == "A" and
              fragment("CAST(? AS DATE) >= ?", ^date, max_rate.start_dt),
          order_by: [desc: max_rate.start_dt],
          limit: 1,
          select: max_rate.id
        )
      )
    )
    |> select([a, b, c, d, e], %{
      rate: b.rate,
      admin: c.description,
      country: d.description,
      date: a.start_dt,
      surcharge: e.surcharge_percent,
      total: 0.00,
      id: a.id
    })
    |> Repo.all()
  end

  def tariffline_lookup(id) do
    TariffLine
    |> where([a], a.id == ^id)
    |> join(:left, [a], b in Rms.SystemUtilities.TariffLineRate, on: a.id == b.tariff_id)
    |> join(:left, [a, b], c in Rms.Accounts.RailwayAdministrator, on: b.admin_id == c.id)
    |> join(:left, [a, b, c], d in Rms.SystemUtilities.Country, on: c.country_id == d.id)
    |> join(:left, [a, b, c, d], e in Rms.SystemUtilities.Surchage, on: a.surcharge_id == e.id)
    |> select([a, b, c, d, e], %{
      rate: b.rate,
      admin: c.description,
      country: d.description,
      date: a.start_dt,
      surcharge: e.surcharge_percent,
      total: 0.00,
      id: a.id
    })
    |> Repo.all()
  end

  @doc """
  Gets a single tariff_line.

  Raises `Ecto.NoResultsError` if the Tariff line does not exist.

  ## Examples

      iex> get_tariff_line!(123)
      %TariffLine{}

      iex> get_tariff_line!(456)
      ** (Ecto.NoResultsError)

  """
  def get_tariff_line!(id), do: Repo.get!(TariffLine, id)

  @doc """
  Creates a tariff_line.

  ## Examples

      iex> create_tariff_line(%{field: value})
      {:ok, %TariffLine{}}

      iex> create_tariff_line(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_tariff_line(attrs \\ %{}) do
    %TariffLine{}
    |> TariffLine.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a tariff_line.

  ## Examples

      iex> update_tariff_line(tariff_line, %{field: new_value})
      {:ok, %TariffLine{}}

      iex> update_tariff_line(tariff_line, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_tariff_line(%TariffLine{} = tariff_line, attrs) do
    tariff_line
    |> TariffLine.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a tariff_line.

  ## Examples

      iex> delete_tariff_line(tariff_line)
      {:ok, %TariffLine{}}

      iex> delete_tariff_line(tariff_line)
      {:error, %Ecto.Changeset{}}

  """
  def delete_tariff_line(%TariffLine{} = tariff_line) do
    Repo.delete(tariff_line)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking tariff_line changes.

  ## Examples

      iex> change_tariff_line(tariff_line)
      %Ecto.Changeset{data: %TariffLine{}}

  """
  def change_tariff_line(%TariffLine{} = tariff_line, attrs \\ %{}) do
    TariffLine.changeset(tariff_line, attrs)
  end

  alias Rms.SystemUtilities.Commodity

  @doc """
  Returns the list of tbl_commodity.

  ## Examples

      iex> list_tbl_commodity()
      [%Commodity{}, ...]

  """
  def list_tbl_commodity do
    Commodity
    |> preload([:maker, :checker, :commodity_group])
    |> Repo.all()
  end

  def search_commoditty(search_term, start) do
    Commodity
    |> where(
      [c],
      fragment("lower(?) like lower(?)", c.description, ^search_term) and c.status == "A"
    )
    |> compose_search_commodity_query(start)
    |> Repo.all()
  end

  def select_commodity(search_term, start) do
    Commodity
    |> where([c], fragment("lower(?) like lower(?)", c.description, ^search_term))
    |> compose_search_commodity_query(start)
    |> Repo.all()
  end

  defp compose_search_commodity_query(query, start) do
    query
    |> order_by([c], c.id)
    |> group_by([c], [c.description, c.id])
    |> limit(50)
    |> offset(^start)
    |> select([c], %{
      total_count: fragment("count(*) AS total_count"),
      id: c.id,
      text: c.description
    })
  end

  @doc """
  Gets a single commodity.

  Raises `Ecto.NoResultsError` if the Commodity does not exist.

  ## Examples

      iex> get_commodity!(123)
      %Commodity{}

      iex> get_commodity!(456)
      ** (Ecto.NoResultsError)

  """
  def get_commodity!(id), do: Repo.get!(Commodity, id)

  @doc """
  Creates a commodity.

  ## Examples

      iex> create_commodity(%{field: value})
      {:ok, %Commodity{}}

      iex> create_commodity(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_commodity(attrs \\ %{}) do
    %Commodity{}
    |> Commodity.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a commodity.

  ## Examples

      iex> update_commodity(commodity, %{field: new_value})
      {:ok, %Commodity{}}

      iex> update_commodity(commodity, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_commodity(%Commodity{} = commodity, attrs) do
    commodity
    |> Commodity.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a commodity.

  ## Examples

      iex> delete_commodity(commodity)
      {:ok, %Commodity{}}

      iex> delete_commodity(commodity)
      {:error, %Ecto.Changeset{}}

  """
  def delete_commodity(%Commodity{} = commodity) do
    Repo.delete(commodity)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking commodity changes.

  ## Examples

      iex> change_commodity(commodity)
      %Ecto.Changeset{data: %Commodity{}}

  """
  def change_commodity(%Commodity{} = commodity, attrs \\ %{}) do
    Commodity.changeset(commodity, attrs)
  end

  def empty_commodity_lookup do
    Commodity
    |> where([a], a.load_status == "E" and a.status == "A")
    |> order_by([a], asc: :id)
    |> limit(1)
    |> Repo.one()
  end

  alias Rms.SystemUtilities.CommodityGroup

  @doc """
  Returns the list of tbl_commodity_group.

  ## Examples

      iex> list_tbl_commodity_group()
      [%CommodityGroup{}, ...]

  """
  def list_tbl_commodity_group do
    CommodityGroup
    |> preload([:maker, :checker])
    |> Repo.all()
  end

  @doc """
  Gets a single commodity_group.

  Raises `Ecto.NoResultsError` if the Commodity group does not exist.

  ## Examples

      iex> get_commodity_group!(123)
      %CommodityGroup{}

      iex> get_commodity_group!(456)
      ** (Ecto.NoResultsError)

  """
  def get_commodity_group!(id), do: Repo.get!(CommodityGroup, id)

  @doc """
  Creates a commodity_group.

  ## Examples

      iex> create_commodity_group(%{field: value})
      {:ok, %CommodityGroup{}}

      iex> create_commodity_group(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_commodity_group(attrs \\ %{}) do
    %CommodityGroup{}
    |> CommodityGroup.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a commodity_group.

  ## Examples

      iex> update_commodity_group(commodity_group, %{field: new_value})
      {:ok, %CommodityGroup{}}

      iex> update_commodity_group(commodity_group, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_commodity_group(%CommodityGroup{} = commodity_group, attrs) do
    commodity_group
    |> CommodityGroup.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a commodity_group.

  ## Examples

      iex> delete_commodity_group(commodity_group)
      {:ok, %CommodityGroup{}}

      iex> delete_commodity_group(commodity_group)
      {:error, %Ecto.Changeset{}}

  """
  def delete_commodity_group(%CommodityGroup{} = commodity_group) do
    Repo.delete(commodity_group)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking commodity_group changes.

  ## Examples

      iex> change_commodity_group(commodity_group)
      %Ecto.Changeset{data: %CommodityGroup{}}

  """
  def change_commodity_group(%CommodityGroup{} = commodity_group, attrs \\ %{}) do
    CommodityGroup.changeset(commodity_group, attrs)
  end

  alias Rms.SystemUtilities.Wagon

  @doc """
  Returns the list of tbl_wagon.

  ## Examples

      iex> list_tbl_wagon()
      [%Wagon{}, ...]

  """
  def list_tbl_wagon do
    Wagon
    |> preload([:maker, :checker, :wagon_type, :wagon_owner, :customer, :station, :condition])
    |> Repo.all()
  end

  @doc """
  Gets a single wagon.

  Raises `Ecto.NoResultsError` if the Wagon does not exist.

  ## Examples

      iex> get_wagon!(123)
      %Wagon{}

      iex> get_wagon!(456)
      ** (Ecto.NoResultsError)

  """
  def get_wagon!(id), do: Repo.get!(Wagon, id)

  @doc """
  Creates a wagon.

  ## Examples

      iex> create_wagon(%{field: value})
      {:ok, %Wagon{}}

      iex> create_wagon(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_wagon(attrs \\ %{}) do
    %Wagon{}
    |> Wagon.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a wagon.

  ## Examples

      iex> update_wagon(wagon, %{field: new_value})
      {:ok, %Wagon{}}

      iex> update_wagon(wagon, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_wagon(%Wagon{} = wagon, attrs) do
    wagon
    |> Wagon.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a wagon.

  ## Examples

      iex> delete_wagon(wagon)
      {:ok, %Wagon{}}

      iex> delete_wagon(wagon)
      {:error, %Ecto.Changeset{}}

  """
  def delete_wagon(%Wagon{} = wagon) do
    Repo.delete(wagon)
  end

  def wagon_lookup(code) do
    Rms.SystemUtilities.Wagon
    |> where([a], a.code == ^code and a.status == "A")
    |> join(:left, [a], b in Rms.SystemUtilities.WagonType, on: a.wagon_type_id == b.id)
    |> join(:left, [a, b], c in Rms.Accounts.RailwayAdministrator, on: a.owner_id == c.id)
    |> select([a, b, c], %{
      id: a.id,
      wagon_owner: c.code,
      wagon_code: a.code,
      wagon_type: b.description,
      capacity: b.weight
    })
    |> Repo.one()
  end

  # def wagon_lookup(code) do
  #   Rms.SystemUtilities.Wagon
  #   |> where([a], a.code == ^code and a.status == "A")
  #   |> limit(1)
  #   |> Repo.exists?()
  # end

  def total_loaded_wagons_lookup() do
    Rms.SystemUtilities.Wagon
    |> where([a], a.load_status == "L")
    |> select([a], %{
      count: count(a.id)
    })
    |> Repo.all()
  end


  def select_wagons_by(wagon_type_id) do
    Wagon
    |> where([a], a.wagon_type_id == ^wagon_type_id)
    |> select([a], %{
        id: a.id
      })
    |> Repo.all()
  end

  def wagon_fleet_lookup(search_params, page, size, _user) do
    Wagon
    |> join(:left, [a], b in Rms.SystemUtilities.WagonType, on: a.wagon_type_id == b.id)
    |> join(:left, [a, _b], c in Rms.Accounts.RailwayAdministrator, on: a.owner_id == c.id)
    |> join(:left, [a, _b, _c], d in Rms.Accounts.Clients, on: a.allocated_cust_id == d.id)
    |> join(:left, [a, _b, _c, _d], e in Rms.Accounts.User, on: a.maker_id == e.id)
    |> join(:left, [a, _b, _c, _d, _e], f in Rms.Accounts.User, on: a.checker_id == f.id)
    |> join(:left, [a, _b, _c, _d, _e, _f], g in Rms.SystemUtilities.Station,
      on: a.station_id == g.id
    )
    |> join(:left, [a, _b, _c, _d, _e, _f, _g], h in Rms.SystemUtilities.Condition,
      on: a.condition_id == h.id
    )
    |> join(:left,  [a, _b, _c, _d, _e, _f, _g, _h], i in Rms.SystemUtilities.WagonType, on: a.wagon_sub_type_id == i.id)
    |> order_by([a, b, c, d, e, f, g, h, i], asc: [a.id])
    |> handle_wagon_report_filter(search_params)
    |> compose_wagon_select()
    |> Repo.paginate(page: page, page_size: size)
  end

  def wagon_fleet_lookup(_source, search_params, _user) do
    Wagon
    |> join(:left, [a], b in Rms.SystemUtilities.WagonType, on: a.wagon_type_id == b.id)
    |> join(:left, [a, _b], c in Rms.Accounts.RailwayAdministrator, on: a.owner_id == c.id)
    |> join(:left, [a, _b, _c], d in Rms.Accounts.Clients, on: a.allocated_cust_id == d.id)
    |> join(:left, [a, _b, _c, _d], e in Rms.Accounts.User, on: a.maker_id == e.id)
    |> join(:left, [a, _b, _c, _d, _e], f in Rms.Accounts.User, on: a.checker_id == f.id)
    |> join(:left, [a, _b, _c, _d, _e, _f], g in Rms.SystemUtilities.Station,
      on: a.station_id == g.id
    )
    |> join(:left, [a, _b, _c, _d, _e, _f, _g], h in Rms.SystemUtilities.Condition,
      on: a.condition_id == h.id
    )
    |> join(:left,  [a, _b, _c, _d, _e, _f, _g, _h], i in Rms.SystemUtilities.WagonType, on: a.wagon_sub_type_id == i.id)
    |> order_by([a, b, c, d, e, f, g, h, i], asc: [a.id])
    |> handle_wagon_report_filter(search_params)
    |> compose_wagon_select()
  end

  defp handle_wagon_report_filter(query, %{"isearch" => search_term} = search_params)
       when search_term == "" or is_nil(search_term) do
    query
    |> handle_wagon_code_filter(search_params)
    |> handle_wagon_type_filter(search_params)
    |> handle_wagon_sub_type_filter(search_params)
    |> handle_wagon_owner_filter(search_params)
    |> handle_wagon_symbol_filter(search_params)
    |> handle_wagon_condition_filter(search_params)
    |> handle_current_station_filter(search_params)
  end

  defp handle_wagon_report_filter(query, %{"isearch" => search_term}) do
    search_term = "%#{search_term}%"
    compose_wagon_isearch_filter(query, search_term)
  end

  defp handle_wagon_code_filter(query, %{"code" => code})
       when code == "" or is_nil(code),
       do: query

  defp handle_wagon_code_filter(query, %{"code" => code}) do
    where(query, [a], fragment("lower(?) LIKE lower(?)", a.code, ^"%#{code}%"))
  end

  defp handle_wagon_type_filter(query, %{"wagon_type" => wagon_type_id})
       when wagon_type_id == "" or is_nil(wagon_type_id),
       do: query

  defp handle_wagon_type_filter(query, %{"wagon_type" => wagon_type_id}) do
    where(query, [a], a.wagon_type_id == ^wagon_type_id)
  end

  defp handle_wagon_sub_type_filter(query, %{"wagon_sub_type" => wagon_sub_type_id})
       when wagon_sub_type_id == "" or is_nil(wagon_sub_type_id),
       do: query

  defp handle_wagon_sub_type_filter(query, %{"wagon_sub_type" => wagon_sub_type_id}) do
    where(query, [a], a.wagon_sub_type_id == ^wagon_sub_type_id)
  end

  defp handle_wagon_owner_filter(query, %{"wagon_owner" => owner_id})
       when owner_id == "" or is_nil(owner_id),
       do: query

  defp handle_wagon_owner_filter(query, %{"wagon_owner" => owner_id}) do
    where(query, [a], a.owner_id == ^owner_id)
  end

  defp handle_wagon_symbol_filter(query, %{"wagon_symbol" => wagon_symbol})
       when wagon_symbol == "" or is_nil(wagon_symbol),
       do: query

  defp handle_wagon_symbol_filter(query, %{"wagon_symbol" => wagon_symbol}) do
    where(query, [a], fragment("lower(?) LIKE lower(?)", a.wagon_symbol, ^"%#{wagon_symbol}%"))
  end

  defp handle_wagon_condition_filter(query, %{"wagon_condition" => wagon_condition})
       when wagon_condition == "" or is_nil(wagon_condition),
       do: query

  defp handle_wagon_condition_filter(query, %{"wagon_condition" => wagon_condition}) do
    where(query, [a], a.condition_id == ^wagon_condition)
  end

  defp handle_current_station_filter(query, %{"current_station" => current_station})
       when current_station == "" or is_nil(current_station),
       do: query

  defp handle_current_station_filter(query, %{"current_station" => current_station}) do
    where(query, [a], a.station_id == ^current_station)
  end

  defp compose_wagon_isearch_filter(query, search_term) do
    query
    |> where(
      [a, b, c, d, e, f],
      fragment("lower(?) LIKE lower(?)", c.description, ^search_term) or
        fragment("lower(?) LIKE lower(?)", a.code, ^search_term) or
        fragment("lower(?) LIKE lower(?)", b.description, ^search_term) or
        fragment("lower(?) LIKE lower(?)", a.wagon_symbol, ^search_term)
    )
  end

  defp compose_wagon_select(query) do
    query
    |> select([a, b, c, d, e, f, g, h, i], %{
      id: a.id,
      wagon_code: a.code,
      description: a.description,
      status: a.status,
      maker_id: a.maker_id,
      checker_id: a.checker_id,
      inserted_at: a.inserted_at,
      updated_at: a.updated_at,
      wagon_type_id: a.wagon_type_id,
      wagon_sub_type_id: a.wagon_sub_type_id,
      owner_id: a.owner_id,
      wagon_symbol: a.wagon_symbol,
      station_id: a.station_id,
      condition_id: a.condition_id,
      load_status: a.load_status,
      mvt_status: a.mvt_status,
      allocated_cust_id: a.allocated_cust_id,
      assigned: a.assigned,
      owner: c.description,
      wagon_type: b.description,
      wagon_sub_type: i.description,
      client_name: d.client_name,
      maker_ft_name: e.first_name,
      maker_lt_name: e.last_name,
      checker_ft_name: f.first_name,
      checker_lt_name: f.last_name,
      station: g.description,
      condition: h.description,
      commodity_id: a.commodity_id,
      wagon_status_id: a.wagon_status_id
    })
  end

  def rms_wagon_lookup_by_symbol(owner_id) do
    Wagon
    |> where([a], a.owner_id == ^owner_id and a.status == "A")
    |> join(:left, [a], b in Rms.SystemUtilities.WagonType, on: a.wagon_type_id == b.id)
    |> join(:left, [a, _b], c in Rms.Accounts.RailwayAdministrator, on: a.owner_id == c.id)
    |> join(:left, [a, _b, _c], d in Rms.Accounts.Clients, on: a.allocated_cust_id == d.id)
    |> join(:left, [a, _b, _c, _d], e in Rms.Accounts.User, on: a.maker_id == e.id)
    |> join(:left, [a, _b, _c, _d, _e], f in Rms.Accounts.User, on: a.checker_id == f.id)
    |> join(:left, [a, _b, _c, _d, _e, _f], g in Rms.SystemUtilities.Station,
      on: a.station_id == g.id
    )
    |> join(:left, [a, _b, _c, _d, _e, _f, _g], h in Rms.SystemUtilities.Condition,
      on: a.condition_id == h.id
    )
    |> order_by([a, b, c, d, e, f, g, h], asc: [a.wagon_symbol])
    |> group_by([a, b, c, d, e, f, g, h], [a.owner_id, a.wagon_symbol, a.load_status])
    |> select([a, b, c, d, e, f, g, h], %{
      ownewr: a.owner_id,
      symbol: a.wagon_symbol,
      load_status: a.load_status,
      wagons: count(a.wagon_symbol)
    })
    |> Repo.all()
  end

  def rms_wagon_lookup_by_domain(owner_id) do
    Wagon
    |> where([a], a.owner_id == ^owner_id and a.status == "A")
    |> join(:left, [a], b in Rms.SystemUtilities.WagonType, on: a.wagon_type_id == b.id)
    |> join(:left, [a, _b], c in Rms.Accounts.RailwayAdministrator, on: a.owner_id == c.id)
    |> join(:left, [a, _b, _c], d in Rms.Accounts.Clients, on: a.allocated_cust_id == d.id)
    |> join(:left, [a, _b, _c, _d], e in Rms.Accounts.User, on: a.maker_id == e.id)
    |> join(:left, [a, _b, _c, _d, _e], f in Rms.Accounts.User, on: a.checker_id == f.id)
    |> join(:left, [a, _b, _c, _d, _e, _f], g in Rms.SystemUtilities.Station,
      on: a.station_id == g.id
    )
    |> join(:left, [a, _b, _c, _d, _e, _f, _g], h in Rms.SystemUtilities.Condition,
      on: a.condition_id == h.id
    )
    |> join(:left, [a, _b, _c, _d, _e, _f, _g, _h], l in Rms.SystemUtilities.Domain,
      on: a.domain_id == l.id
    )
    |> order_by([a, b, c, d, e, f, g, h, l], asc: [l.code])
    |> group_by([a, b, c, d, e, f, g, h, l], [a.owner_id, l.code, a.load_status, h.is_usable])
    |> select([a, b, c, d, e, f, g, h, l], %{
      ownewr: a.owner_id,
      domain: l.code,
      is_usable: h.is_usable,
      load_status: a.load_status,
      wagons: count(a.wagon_symbol)
    })
    |> Repo.all()
  end

  def all_rms_wagon_lookup_by_symbol(owner_id) do
    Wagon
    |> where([a], a.owner_id == ^owner_id and a.status == "A")
    |> join(:left, [a], b in Rms.SystemUtilities.WagonType, on: a.wagon_type_id == b.id)
    |> join(:left, [a, _b], c in Rms.Accounts.RailwayAdministrator, on: a.owner_id == c.id)
    |> join(:left, [a, _b, _c], d in Rms.Accounts.Clients, on: a.allocated_cust_id == d.id)
    |> join(:left, [a, _b, _c, _d], e in Rms.Accounts.User, on: a.maker_id == e.id)
    |> join(:left, [a, _b, _c, _d, _e], f in Rms.Accounts.User, on: a.checker_id == f.id)
    |> join(:left, [a, _b, _c, _d, _e, _f], g in Rms.SystemUtilities.Station,
      on: a.station_id == g.id
    )
    |> join(:left, [a, _b, _c, _d, _e, _f, _g], h in Rms.SystemUtilities.Condition,
      on: a.condition_id == h.id
    )
    |> order_by([a, b, c, d, e, f, g, h], asc: [a.wagon_symbol])
    |> group_by([a, b, c, d, e, f, g, h], [a.owner_id, a.wagon_symbol])
    |> select([a, b, c, d, e, f, g, h], %{
      ownewr: a.owner_id,
      symbol: a.wagon_symbol,
      wagons: count(a.wagon_symbol)
    })
    |> Repo.all()
  end

  def rms_go_wagon_lookup_by_symbol(owner_id) do
    Wagon
    |> where([a], a.owner_id == ^owner_id and a.status == "A")
    |> join(:left, [a], b in Rms.SystemUtilities.WagonType, on: a.wagon_type_id == b.id)
    |> join(:left, [a, _b], c in Rms.Accounts.RailwayAdministrator, on: a.owner_id == c.id)
    |> join(:left, [a, _b, _c], d in Rms.Accounts.Clients, on: a.allocated_cust_id == d.id)
    |> join(:left, [a, _b, _c, _d], e in Rms.Accounts.User, on: a.maker_id == e.id)
    |> join(:left, [a, _b, _c, _d, _e], f in Rms.Accounts.User, on: a.checker_id == f.id)
    |> join(:left, [a, _b, _c, _d, _e, _f], g in Rms.SystemUtilities.Station,
      on: a.station_id == g.id
    )
    |> join(:left, [a, _b, _c, _d, _e, _f, _g], h in Rms.SystemUtilities.Condition,
      on: a.condition_id == h.id
    )
    |> order_by([a, b, c, d, e, f, g, h], asc: [a.wagon_symbol])
    |> group_by([a, b, c, d, e, f, g, h], [a.owner_id, a.wagon_symbol, h.is_usable])
    |> select([a, b, c, d, e, f, g, h], %{
      ownewr: a.owner_id,
      symbol: a.wagon_symbol,
      is_usable: h.is_usable,
      wagons: count(a.wagon_symbol)
    })
    |> Repo.all()
  end

  def all_go_wagon_lookup() do
    Wagon
    |> where([a], a.status == "A")
    |> join(:left, [a], b in Rms.SystemUtilities.WagonType, on: a.wagon_type_id == b.id)
    |> join(:left, [a, _b], c in Rms.Accounts.RailwayAdministrator, on: a.owner_id == c.id)
    |> join(:left, [a, _b, _c], d in Rms.Accounts.Clients, on: a.allocated_cust_id == d.id)
    |> join(:left, [a, _b, _c, _d], e in Rms.Accounts.User, on: a.maker_id == e.id)
    |> join(:left, [a, _b, _c, _d, _e], f in Rms.Accounts.User, on: a.checker_id == f.id)
    |> join(:left, [a, _b, _c, _d, _e, _f], g in Rms.SystemUtilities.Station,
      on: a.station_id == g.id
    )
    |> join(:left, [a, _b, _c, _d, _e, _f, _g], h in Rms.SystemUtilities.Condition,
      on: a.condition_id == h.id
    )
    |> order_by([a, b, c, d, e, f, g, h], asc: [a.owner_id])
    |> group_by([a, b, c, d, e, f, g, h], [a.owner_id, h.is_usable])
    |> select([a, b, c, d, e, f, g, h], %{
      ownewr: a.owner_id,
      is_usable: h.is_usable,
      wagons: count(a.wagon_symbol)
    })
    |> Repo.all()
  end

  def rms_lookup_by_load_status(owner_id) do
    Wagon
    |> where([a], a.owner_id == ^owner_id and a.status == "A")
    |> join(:left, [a], b in Rms.SystemUtilities.WagonType, on: a.wagon_type_id == b.id)
    |> join(:left, [a, _b], c in Rms.Accounts.RailwayAdministrator, on: a.owner_id == c.id)
    |> join(:left, [a, _b, _c], d in Rms.Accounts.Clients, on: a.allocated_cust_id == d.id)
    |> join(:left, [a, _b, _c, _d], e in Rms.Accounts.User, on: a.maker_id == e.id)
    |> join(:left, [a, _b, _c, _d, _e], f in Rms.Accounts.User, on: a.checker_id == f.id)
    |> join(:left, [a, _b, _c, _d, _e, _f], g in Rms.SystemUtilities.Station,
      on: a.station_id == g.id
    )
    |> join(:left, [a, _b, _c, _d, _e, _f, _g], h in Rms.SystemUtilities.Condition,
      on: a.condition_id == h.id
    )
    |> order_by([a, b, c, d, e, f, g, h], asc: [a.mvt_status])
    |> group_by([a, b, c, d, e, f, g, h], [a.owner_id, a.mvt_status])
    |> select([a, b, c, d, e, f, g, h], %{
      ownewr: a.owner_id,
      mvt_status: a.mvt_status,
      wagons: count(a.wagon_symbol)
    })
    |> Repo.all()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking wagon changes.

  ## Examples

      iex> change_wagon(wagon)
      %Ecto.Changeset{data: %Wagon{}}

  """
  def change_wagon(%Wagon{} = wagon, attrs \\ %{}) do
    Wagon.changeset(wagon, attrs)
  end

  alias Rms.SystemUtilities.WagonType

  @doc """
  Returns the list of tbl_wagon_type.

  ## Examples

      iex> list_tbl_wagon_type()
      [%WagonType{}, ...]

  """
  def list_tbl_wagon_type do
    WagonType
    |> preload([:maker, :checker])
    |> Repo.all()
  end

  @doc """
  Gets a single wagon_type.

  Raises `Ecto.NoResultsError` if the Wagon type does not exist.

  ## Examples

      iex> get_wagon_type!(123)
      %WagonType{}

      iex> get_wagon_type!(456)
      ** (Ecto.NoResultsError)

  """
  def get_wagon_type!(id), do: Repo.get!(WagonType, id)

  @doc """
  Creates a wagon_type.

  ## Examples

      iex> create_wagon_type(%{field: value})
      {:ok, %WagonType{}}

      iex> create_wagon_type(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_wagon_type(attrs \\ %{}) do
    %WagonType{}
    |> WagonType.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a wagon_type.

  ## Examples

      iex> update_wagon_type(wagon_type, %{field: new_value})
      {:ok, %WagonType{}}

      iex> update_wagon_type(wagon_type, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_wagon_type(%WagonType{} = wagon_type, attrs) do
    wagon_type
    |> WagonType.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a wagon_type.

  ## Examples

      iex> delete_wagon_type(wagon_type)
      {:ok, %WagonType{}}

      iex> delete_wagon_type(wagon_type)
      {:error, %Ecto.Changeset{}}

  """
  def delete_wagon_type(%WagonType{} = wagon_type) do
    Repo.delete(wagon_type)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking wagon_type changes.

  ## Examples

      iex> change_wagon_type(wagon_type)
      %Ecto.Changeset{data: %WagonType{}}

  """
  def change_wagon_type(%WagonType{} = wagon_type, attrs \\ %{}) do
    WagonType.changeset(wagon_type, attrs)
  end

  alias Rms.SystemUtilities.Surchage

  @doc """
  Returns the list of tbl_surcharge.

  ## Examples

      iex> list_tbl_surcharge()
      [%Surchage{}, ...]

  """
  def list_tbl_surcharge do
    Surchage
    |> preload([:maker, :checker])
    |> Repo.all()
  end

  @doc """
  Gets a single surchage.

  Raises `Ecto.NoResultsError` if the Surchage does not exist.

  ## Examples

      iex> get_surchage!(123)
      %Surchage{}

      iex> get_surchage!(456)
      ** (Ecto.NoResultsError)

  """
  def get_surchage!(id), do: Repo.get!(Surchage, id)

  @doc """
  Creates a surchage.

  ## Examples

      iex> create_surchage(%{field: value})
      {:ok, %Surchage{}}

      iex> create_surchage(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_surchage(attrs \\ %{}) do
    %Surchage{}
    |> Surchage.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a surchage.

  ## Examples

      iex> update_surchage(surchage, %{field: new_value})
      {:ok, %Surchage{}}

      iex> update_surchage(surchage, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_surchage(%Surchage{} = surchage, attrs) do
    surchage
    |> Surchage.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a surchage.

  ## Examples

      iex> delete_surchage(surchage)
      {:ok, %Surchage{}}

      iex> delete_surchage(surchage)
      {:error, %Ecto.Changeset{}}

  """
  def delete_surchage(%Surchage{} = surchage) do
    Repo.delete(surchage)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking surchage changes.

  ## Examples

      iex> change_surchage(surchage)
      %Ecto.Changeset{data: %Surchage{}}

  """
  def change_surchage(%Surchage{} = surchage, attrs \\ %{}) do
    Surchage.changeset(surchage, attrs)
  end

  alias Rms.SystemUtilities.Station

  @doc """
  Returns the list of tbl_station.

  ## Examples

      iex> list_tbl_station()
      [%Station{}, ...]

  """
  def list_tbl_station do
    Station
    |> preload([:maker, :checker, :owner, :domain, :region])
    |> Repo.all()
  end

  def station_owner_lookup(movement_reporting_station_id) do
    Station
    |> where([a], a.id == ^movement_reporting_station_id)
    |> join(:left, [a], b in Rms.Accounts.RailwayAdministrator, on: a.owner_id == b.id)
    |> group_by([a, b], [a.description, b.description])
    |> select([a, b], %{
      description: a.description,
      owner: b.description
    })
    |> Repo.all()
  end

  def station_lookup(id) do
    Station
    |> where(id: ^id)
    |> preload([:maker, :checker, :owner, :domain, :region])
    |> select(
      [a],
      map(a, [
        :acronym,
        :description,
        :station_id,
        :maker_id,
        :checker_id,
        :inserted_at,
        :updated_at,
        :status,
        :owner_id,
        :interchange_point,
        :domain_id,
        :region_id,
        :station_code,
        maker: [:first_name, :last_name],
        checker: [:first_name, :last_name],
        owner: [:code],
        domain: [:description],
        region: [:description]
      ])
    )
    |> Repo.one()
  end

  # def station_owner_lookup(movement_reporting_station_id) do
  #   Station
  #   |> preload([:maker, :checker, :owner, :domain, :region])
  #   |> where([s], s.id == ^movement_reporting_station_id)
  #   |> select([s],
  #     map(
  #       s,
  #       [
  #         :id,
  #         :description,
  #         owner: [:code]
  #       ]
  #     )
  #   )
  #   |> Repo.one()
  # end

  def search_station(search_term, start) do
    Station
    |> where(
      [s],
      fragment("lower(?) like lower(?)", s.description, ^search_term) and s.status == "A"
    )
    |> compose_search_station_query(start)
    |> Repo.all()
  end

  def select_station(search_term, start) do
    Station
    |> where([s], fragment("lower(?) like lower(?)", s.description, ^search_term))
    |> compose_search_station_query(start)
    |> Repo.all()
  end

  defp compose_search_station_query(query, start) do
    query
    |> order_by([s], s.id)
    |> group_by([s], [s.description, s.id])
    |> limit(50)
    |> offset(^start)
    |> select([s], %{
      total_count: fragment("count(*) AS total_count"),
      id: s.id,
      text: s.description
    })
  end

  @doc """
  Gets a single station.

  Raises `Ecto.NoResultsError` if the Station does not exist.

  ## Examples

      iex> get_station!(123)
      %Station{}

      iex> get_station!(456)
      ** (Ecto.NoResultsError)

  """
  def get_station!(id), do: Repo.get!(Station, id)

  @doc """
  Creates a station.

  ## Examples

      iex> create_station(%{field: value})
      {:ok, %Station{}}

      iex> create_station(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_station(attrs \\ %{}) do
    %Station{}
    |> Station.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a station.

  ## Examples

      iex> update_station(station, %{field: new_value})
      {:ok, %Station{}}

      iex> update_station(station, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_station(%Station{} = station, attrs) do
    station
    |> Station.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a station.

  ## Examples

      iex> delete_station(station)
      {:ok, %Station{}}

      iex> delete_station(station)
      {:error, %Ecto.Changeset{}}

  """
  def delete_station(%Station{} = station) do
    Repo.delete(station)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking station changes.

  ## Examples

      iex> change_station(station)
      %Ecto.Changeset{data: %Station{}}

  """
  def change_station(%Station{} = station, attrs \\ %{}) do
    Station.changeset(station, attrs)
  end

  alias Rms.SystemUtilities.PaymentType

  @doc """
  Returns the list of tbl_payment_type.

  ## Examples

      iex> list_tbl_payment_type()
      [%PaymentType{}, ...]

  """
  def list_tbl_payment_type do
    PaymentType
    |> preload([:maker, :checker])
    |> Repo.all()
  end

  @doc """
  Gets a single payment_type.

  Raises `Ecto.NoResultsError` if the Payment type does not exist.

  ## Examples

      iex> get_payment_type!(123)
      %PaymentType{}

      iex> get_payment_type!(456)
      ** (Ecto.NoResultsError)

  """
  def get_payment_type!(id), do: Repo.get!(PaymentType, id)

  @doc """
  Creates a payment_type.

  ## Examples

      iex> create_payment_type(%{field: value})
      {:ok, %PaymentType{}}

      iex> create_payment_type(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_payment_type(attrs \\ %{}) do
    %PaymentType{}
    |> PaymentType.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a payment_type.

  ## Examples

      iex> update_payment_type(payment_type, %{field: new_value})
      {:ok, %PaymentType{}}

      iex> update_payment_type(payment_type, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_payment_type(%PaymentType{} = payment_type, attrs) do
    payment_type
    |> PaymentType.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a payment_type.

  ## Examples

      iex> delete_payment_type(payment_type)
      {:ok, %PaymentType{}}

      iex> delete_payment_type(payment_type)
      {:error, %Ecto.Changeset{}}

  """
  def delete_payment_type(%PaymentType{} = payment_type) do
    Repo.delete(payment_type)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking payment_type changes.

  ## Examples

      iex> change_payment_type(payment_type)
      %Ecto.Changeset{data: %PaymentType{}}

  """
  def change_payment_type(%PaymentType{} = payment_type, attrs \\ %{}) do
    PaymentType.changeset(payment_type, attrs)
  end

  alias Rms.SystemUtilities.Country

  @doc """
  Returns the list of tbl_country.

  ## Examples

      iex> list_tbl_country()
      [%Country{}, ...]

  """
  def list_tbl_country do
    Country
    |> preload([:maker, :checker, :region])
    |> Repo.all()
  end

  @doc """
  Gets a single country.

  Raises `Ecto.NoResultsError` if the Country does not exist.

  ## Examples

      iex> get_country!(123)
      %Country{}

      iex> get_country!(456)
      ** (Ecto.NoResultsError)

  """
  def get_country!(id), do: Repo.get!(Country, id)

  @doc """
  Creates a country.

  ## Examples

      iex> create_country(%{field: value})
      {:ok, %Country{}}

      iex> create_country(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_country(attrs \\ %{}) do
    %Country{}
    |> Country.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a country.

  ## Examples

      iex> update_country(country, %{field: new_value})
      {:ok, %Country{}}

      iex> update_country(country, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_country(%Country{} = country, attrs) do
    country
    |> Country.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a country.

  ## Examples

      iex> delete_country(country)
      {:ok, %Country{}}

      iex> delete_country(country)
      {:error, %Ecto.Changeset{}}

  """
  def delete_country(%Country{} = country) do
    Repo.delete(country)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking country changes.

  ## Examples

      iex> change_country(country)
      %Ecto.Changeset{data: %Country{}}

  """
  def change_country(%Country{} = country, attrs \\ %{}) do
    Country.changeset(country, attrs)
  end

  alias Rms.SystemUtilities.Currency

  @doc """
  Returns the list of tbl_currency.

  ## Examples

      iex> list_tbl_currency()
      [%Currency{}, ...]

  """
  def list_tbl_currency do
    Currency
    |> preload([:maker, :checker])
    |> Repo.all()
  end

  @doc """
  Gets a single currency.

  Raises `Ecto.NoResultsError` if the Currency does not exist.

  ## Examples

      iex> get_currency!(123)
      %Currency{}

      iex> get_currency!(456)
      ** (Ecto.NoResultsError)

  """
  def get_currency!(id), do: Repo.get!(Currency, id)

  @doc """
  Creates a currency.

  ## Examples

      iex> create_currency(%{field: value})
      {:ok, %Currency{}}

      iex> create_currency(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_currency(attrs \\ %{}) do
    %Currency{}
    |> Currency.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a currency.

  ## Examples

      iex> update_currency(currency, %{field: new_value})
      {:ok, %Currency{}}

      iex> update_currency(currency, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_currency(%Currency{} = currency, attrs) do
    currency
    |> Currency.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a currency.

  ## Examples

      iex> delete_currency(currency)
      {:ok, %Currency{}}

      iex> delete_currency(currency)
      {:error, %Ecto.Changeset{}}

  """
  def delete_currency(%Currency{} = currency) do
    Repo.delete(currency)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking currency changes.

  ## Examples

      iex> change_currency(currency)
      %Ecto.Changeset{data: %Currency{}}

  """
  def change_currency(%Currency{} = currency, attrs \\ %{}) do
    Currency.changeset(currency, attrs)
  end

  alias Rms.SystemUtilities.Rates

  @doc """
  Returns the list of tbl_fuel_rates.

  ## Examples

      iex> list_tbl_fuel_rates()
      [%Rates{}, ...]

  """

  # def list_tbl_fuel_rates do
  #   Repo.all(Rates)
  # end

  def list_tbl_fuel_rates do
    Rates
    |> preload([:maker, :checker, :refuel_depo])
    |> Repo.all()
  end

  def lookup_fuel_rate(station_id, date) do
    Rates
    |> where(
      [a],
      a.station_id == ^station_id and fragment("CAST(? AS DATE) >= ?", ^date, a.month)
    )
    |> order_by([a], desc: a.id)
    |> select(
      [a],
      map(a, [
        :fuel_rate,
        :id
      ])
    )
    |> limit(1)
    |> Repo.one()
  end

  # def distance_lookup(station_id) do
  #   Distance
  #   |> where(station_id: ^station_id)
  #   |> select(
  #     [a],
  #     map(a, [
  #       :fuel_rate
  #     ])
  #   )
  #   |> Repo.one()
  # end

  @doc """
  Gets a single rates.

  Raises `Ecto.NoResultsError` if the Rates does not exist.

  ## Examples

      iex> get_rates!(123)
      %Rates{}

      iex> get_rates!(456)
      ** (Ecto.NoResultsError)

  """
  def get_rates!(id), do: Repo.get!(Rates, id)

  @doc """
  Creates a rates.

  ## Examples

      iex> create_rates(%{field: value})
      {:ok, %Rates{}}

      iex> create_rates(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_rates(attrs \\ %{}) do
    %Rates{}
    |> Rates.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a rates.

  ## Examples

      iex> update_rates(rates, %{field: new_value})
      {:ok, %Rates{}}

      iex> update_rates(rates, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_rates(%Rates{} = rates, attrs) do
    rates
    |> Rates.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a rates.

  ## Examples

      iex> delete_rates(rates)
      {:ok, %Rates{}}

      iex> delete_rates(rates)
      {:error, %Ecto.Changeset{}}

  """
  def delete_rates(%Rates{} = rates) do
    Repo.delete(rates)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking rates changes.

  ## Examples

      iex> change_rates(rates)
      %Ecto.Changeset{data: %Rates{}}

  """
  def change_rates(%Rates{} = rates, attrs \\ %{}) do
    Rates.changeset(rates, attrs)
  end

  alias Rms.SystemUtilities.ExchangeRate

  @doc """
  Returns the list of tbl_exchange_rate.

  ## Examples

      iex> list_tbl_exchange_rate()
      [%ExchangeRate{}, ...]

  """

  def verify_user_region_id(query, user) do
    with("M" <- user.role.report.aces_lvl) do
      query
    else
      _ ->
        where(
          query,
          [a],
          a.user_region_id == ^user.user_region_id
        )
    end
  end

  def list_tbl_exchange_rate do
    ExchangeRate
    |> preload([:maker, :checker, :first_ccy, :second_ccy])
    |> Repo.all()
  end

  def exchange_rate_by_date do
    ExchangeRate
    |> order_by([a, b], desc: [a.inserted_at])
    |> group_by([a, b], [
      a.inserted_at,
      a.exchange_rate,
      fragment("FORMAT(?, 'MMMM', 'en-US')", a.inserted_at)
    ])
    |> select([a], %{
      average: avg(a.exchange_rate),
      count: count(a.inserted_at),
      total_fuel_rate: sum(a.exchange_rate),
      start_date: fragment("FORMAT(?, 'MMMM', 'en-US')", a.inserted_at)
    })
    |> Repo.all()
  end

  def get_weekly_fuel_request(month, year) do
    Rates
    |> join(:left, [a], b in Rms.Order.FuelMonitoring,
      on: a.id == b.depo_refueled_id and b.status == "COMPLETE"
    )
    |> distinct(true)
    |> where(
      [a, b],
      fragment("DATEPART(MONTH, ?) = ? and YEAR(?) = ?", b.date, ^month, b.date, ^year)
    )
    # |> verify_user_region_id(user)
    |> order_by([a, b], desc: [b.depo_refueled_id])
    |> group_by([a, b], [
      b.depo_refueled_id,
      fragment(
        """
        CASE

          WHEN DAY(?) BETWEEN 1 and 7 THEN 'Week 1'
          WHEN DAY(?) BETWEEN 7 and 14 THEN 'Week 2'
          WHEN DAY(?) BETWEEN 14 and 21 THEN 'Week 3'
          WHEN DAY(?) BETWEEN 21 and 29 THEN 'Week 4'
          ELSE 'Week 5'
        END
        """,
        b.date,
        b.date,
        b.date,
        b.date
      )
    ])
    |> select([a, b], %{
      depo_refueled_id: b.depo_refueled_id,
      date:
        fragment(
          """
          CASE

            WHEN DAY(?) BETWEEN 1 and 7 THEN 'Week 1'
            WHEN DAY(?) BETWEEN 7 and 14 THEN 'Week 2'
            WHEN DAY(?) BETWEEN 14 and 21 THEN 'Week 3'
            WHEN DAY(?) BETWEEN 21 and 29 THEN 'Week 4'
            ELSE 'Week 5'
          END
          """,
          b.date,
          b.date,
          b.date,
          b.date
        ),
      fuel_avg: avg(b.fuel_rate)
    })
    |> Repo.all()
  end

  def get_fuel_rate_by_date(quarter, year) do
    Rates
    |> join(:left, [a], b in Rms.Order.FuelMonitoring, on: a.id == b.depo_refueled_id)
    |> distinct(true)
    |> where(
      [a, b],
      fragment("DATEPART(QUARTER, ?) = ? and YEAR(?) = ?", b.date, ^quarter, b.date, ^year)
    )
    # |> verify_user_region_id(user)
    |> order_by([a, b], desc: [b.depo_refueled_id])
    |> group_by([a, b], [b.depo_refueled_id, fragment("FORMAT(?, 'MMMM', 'en-US')", b.date)])
    |> select([a, b], %{
      depo_refueled_id: b.depo_refueled_id,
      date: fragment("FORMAT(?, 'MMMM', 'en-US')", b.date),
      fuel_avg: avg(b.fuel_rate)
    })
    |> Repo.all()
  end

  def get_depo_summary(start_end, end_date, user) do
    Rms.Order.FuelMonitoring
    |> where(
      [a],
      a.status == "COMPLETE" and not is_nil(a.total_cost) and
        fragment("CAST(? AS DATE) >= ?", a.inserted_at, ^start_end) and
        fragment("CAST(? AS DATE) <= ?", a.inserted_at, ^end_date)
    )
    |> verify_user_region_id(user)
    |> join(:left, [a], b in Rms.SystemUtilities.Rates, on: a.depo_refueled_id == b.id)
    |> join(:left, [a, b], c in Rms.SystemUtilities.Station, on: a.depo_stn == c.id)
    |> order_by([a, b, c], desc: [a.depo_stn])
    |> group_by([a, b, c], [a.depo_stn, c.description])
    |> select([a, b, c], %{
      qty_refueled: sum(a.quantity_refueled),
      count: count(a.id),
      depo: c.description,
      total_cost: sum(a.total_cost)
    })
    |> Repo.all()
  end

  def get_by_section(start_end, end_date, user) do
    Rms.Order.FuelMonitoring
    |> where(
      [a],
      a.status == "COMPLETE" and not is_nil(a.total_cost) and
        fragment("CAST(? AS DATE) >= ?", a.inserted_at, ^start_end) and
        fragment("CAST(? AS DATE) <= ?", a.inserted_at, ^end_date)
    )
    |> verify_user_region_id(user)
    |> join(:left, [a], b in Rms.SystemUtilities.Rates, on: a.depo_refueled_id == b.id)
    |> join(:left, [a, b], c in Rms.SystemUtilities.Section, on: a.section_id == c.id)
    |> order_by([a, b, c], asc: [a.week_no])
    |> group_by([a, b, c], [a.section_id, a.total_cost, a.week_no, c.code])
    |> select([a, b, c], %{
      count: count(a.id),
      qty_refueled: sum(a.quantity_refueled),
      week: a.week_no,
      section: c.code,
      cost: sum(a.total_cost),
      total_cost: sum(a.total_cost)
    })
    |> Repo.all()
  end

  def monthly_section_summary(start_end, end_date) do
    Rms.Order.FuelMonitoring
    |> where(
      [a],
      a.status == "COMPLETE" and fragment("CAST(? AS DATE) >= ?", a.inserted_at, ^start_end) and
        fragment("CAST(? AS DATE) <= ?", a.inserted_at, ^end_date)
    )
    |> join(:left, [a], b in Rms.SystemUtilities.Rates, on: a.depo_refueled_id == b.id)
    |> join(:left, [a, b], c in Rms.SystemUtilities.Section, on: a.section_id == c.id)
    |> order_by([a, b, c], asc: [a.week_no])
    |> group_by([a, b, c], [a.section_id, a.week_no, c.code])
    |> select([a, b, c], %{
      count: count(a.id),
      qty_refueled: sum(a.quantity_refueled),
      week: a.week_no,
      section: c.code,
      total_cost: sum(a.total_cost)
    })
    |> Repo.all()
  end

  def test do
    Repo.all(
      from(n in Rates,
        group_by: fragment("convert(varchar(7), ?, 126)", n.month),
        select: avg(n.fuel_rate)
      )
    )
  end

  @doc """
  Gets a single exchange_rate.

  Raises `Ecto.NoResultsError` if the Exchange rate does not exist.

  ## Examples

      iex> get_exchange_rate!(123)
      %ExchangeRate{}

      iex> get_exchange_rate!(456)
      ** (Ecto.NoResultsError)

  """
  def get_exchange_rate!(id), do: Repo.get!(ExchangeRate, id)

  @doc """
  Creates a exchange_rate.

  ## Examples

      iex> create_exchange_rate(%{field: value})
      {:ok, %ExchangeRate{}}

      iex> create_exchange_rate(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_exchange_rate(attrs \\ %{}) do
    %ExchangeRate{}
    |> ExchangeRate.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a exchange_rate.

  ## Examples

      iex> update_exchange_rate(exchange_rate, %{field: new_value})
      {:ok, %ExchangeRate{}}

      iex> update_exchange_rate(exchange_rate, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_exchange_rate(%ExchangeRate{} = exchange_rate, attrs) do
    exchange_rate
    |> ExchangeRate.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a exchange_rate.

  ## Examples

      iex> delete_exchange_rate(exchange_rate)
      {:ok, %ExchangeRate{}}

      iex> delete_exchange_rate(exchange_rate)
      {:error, %Ecto.Changeset{}}

  """
  def delete_exchange_rate(%ExchangeRate{} = exchange_rate) do
    Repo.delete(exchange_rate)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking exchange_rate changes.

  ## Examples

      iex> change_exchange_rate(exchange_rate)
      %Ecto.Changeset{data: %ExchangeRate{}}

  """
  def change_exchange_rate(%ExchangeRate{} = exchange_rate, attrs \\ %{}) do
    ExchangeRate.changeset(exchange_rate, attrs)
  end

  alias Rms.SystemUtilities.TrainRoute

  @doc """
  Returns the list of tbl_train_routes.

  ## Examples

      iex> list_tbl_train_routes()
      [%TrainRoute{}, ...]

  """

  def list_tbl_train_routes do
    TrainRoute
    |> preload([:maker, :checker, :destination, :origin, :transport, :admin])
    |> Repo.all()
  end

  def search_for_route(origin, destin) do
    TrainRoute
    |> where(origin_station: ^origin, destination_station: ^destin, status: "A")
    |> limit(1)
    |> Repo.one()
  end

  @doc """
  Gets a single train_route.

  Raises `Ecto.NoResultsError` if the Train route does not exist.

  ## Examples

      iex> get_train_route!(123)
      %TrainRoute{}

      iex> get_train_route!(456)
      ** (Ecto.NoResultsError)

  """
  def get_train_route!(id), do: Repo.get!(TrainRoute, id)

  @doc """
  Creates a train_route.

  ## Examples

      iex> create_train_route(%{field: value})
      {:ok, %TrainRoute{}}

      iex> create_train_route(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_train_route(attrs \\ %{}) do
    %TrainRoute{}
    |> TrainRoute.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a train_route.

  ## Examples

      iex> update_train_route(train_route, %{field: new_value})
      {:ok, %TrainRoute{}}

      iex> update_train_route(train_route, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_train_route(%TrainRoute{} = train_route, attrs) do
    train_route
    |> TrainRoute.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a train_route.

  ## Examples

      iex> delete_train_route(train_route)
      {:ok, %TrainRoute{}}

      iex> delete_train_route(train_route)
      {:error, %Ecto.Changeset{}}

  """
  def delete_train_route(%TrainRoute{} = train_route) do
    Repo.delete(train_route)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking train_route changes.

  ## Examples

      iex> change_train_route(train_route)
      %Ecto.Changeset{data: %TrainRoute{}}

  """
  def train_route_lookup(search_params, page, size, _user) do
    TrainRoute
    |> join(:left, [a], b in Rms.SystemUtilities.Station, on: a.destination_station == b.id)
    |> join(:left, [a, _b], c in Rms.SystemUtilities.Station, on: a.origin_station == c.id)
    |> join(:left, [a, _b, _c], d in Rms.SystemUtilities.TransportType,
      on: a.transport_type == d.id
    )
    |> join(:left, [a, _b, _c, _d], e in Rms.Accounts.RailwayAdministrator, on: a.operator == e.id)
    |> join(:left, [a, _b, _c, _d, _e], f in Rms.Accounts.User, on: a.maker_id == f.id)
    |> join(:left, [a, _b, _c, _d, _e, _f], g in Rms.Accounts.User, on: a.checker_id == g.id)
    |> order_by([a, b, c, d, e, f, g], asc: [a.id])
    |> handle_train_route_filter(search_params)
    |> compose_trainroute_select()
    |> Repo.paginate(page: page, page_size: size)
  end

  def train_route_lookup(_source, search_params, _user) do
    TrainRoute
    |> join(:left, [a], b in Rms.SystemUtilities.Station, on: a.destination_station == b.id)
    |> join(:left, [a, _b], c in Rms.SystemUtilities.Station, on: a.origin_station == c.id)
    |> join(:left, [a, _b, _c], d in Rms.SystemUtilities.TransportType,
      on: a.transport_type == d.id
    )
    |> join(:left, [a, _b, _c, _d], e in Rms.Accounts.RailwayAdministrator, on: a.operator == e.id)
    |> join(:left, [a, _b, _c, _d, _e], f in Rms.Accounts.User, on: a.maker_id == f.id)
    |> join(:left, [a, _b, _c, _d, _e, _f], g in Rms.Accounts.User, on: a.checker_id == g.id)
    |> order_by([a, b, c, d, e, f, g], asc: [a.id])
    |> handle_train_route_filter(search_params)
    |> compose_trainroute_select()
  end

  defp handle_train_route_filter(query, %{"isearch" => search_term} = search_params)
       when search_term == "" or is_nil(search_term) do
    query
    # |> handle_date_filter(search_params)
    |> handle_trainroute_code_filter(search_params)
    |> handle_train_route_dscription_filter(search_params)
    |> handle_route_org_station_filter(search_params)
    |> handle_route_dest_station_filter(search_params)
    |> handle_route_transport_type_filter(search_params)
    |> handle_route_operator_filter(search_params)
  end

  defp handle_train_route_filter(query, %{"isearch" => search_term}) do
    search_term = "%#{search_term}%"
    compose_trainroute_isearch_filter(query, search_term)
  end

  defp handle_trainroute_code_filter(query, %{"code" => code})
       when code == "" or is_nil(code),
       do: query

  defp handle_trainroute_code_filter(query, %{"code" => code}) do
    where(query, [a], fragment("lower(?) LIKE lower(?)", a.code, ^"%#{code}%"))
  end

  defp handle_train_route_dscription_filter(query, %{"description" => description})
       when description == "" or is_nil(description),
       do: query

  defp handle_train_route_dscription_filter(query, %{"description" => description}) do
    where(query, [a], fragment("lower(?) LIKE lower(?)", a.description, ^"%#{description}%"))
  end

  defp handle_route_org_station_filter(query, %{"route_org_station" => origin_station})
       when origin_station == "" or is_nil(origin_station),
       do: query

  defp handle_route_org_station_filter(query, %{"route_org_station" => origin_station}) do
    where(query, [a], a.origin_station == ^origin_station)
  end

  defp handle_route_dest_station_filter(query, %{"route_dest_station" => destination_station})
       when destination_station == "" or is_nil(destination_station),
       do: query

  defp handle_route_dest_station_filter(query, %{"route_dest_station" => destination_station}) do
    where(query, [a], a.destination_station == ^destination_station)
  end

  defp handle_route_transport_type_filter(query, %{"route_transport_type" => transport_type})
       when transport_type == "" or is_nil(transport_type),
       do: query

  defp handle_route_transport_type_filter(query, %{"route_transport_type" => transport_type}) do
    where(query, [a], a.transport_type == ^transport_type)
  end

  defp handle_route_operator_filter(query, %{"route_operator" => operator})
       when operator == "" or is_nil(operator),
       do: query

  defp handle_route_operator_filter(query, %{"route_operator" => operator}) do
    where(query, [a], a.operator == ^operator)
  end

  defp compose_trainroute_isearch_filter(query, search_term) do
    query
    |> where(
      [a, b, c, d, e, f, g],
      fragment("lower(?) LIKE lower(?)", a.code, ^search_term) or
        fragment("lower(?) LIKE lower(?)", a.description, ^search_term) or
        fragment("lower(?) LIKE lower(?)", c.description, ^search_term) or
        fragment("lower(?) LIKE lower(?)", b.description, ^search_term) or
        fragment("lower(?) LIKE lower(?)", d.description, ^search_term) or
        fragment("lower(?) LIKE lower(?)", e.description, ^search_term)
    )
  end

  defp compose_trainroute_select(query) do
    query
    |> select([a, b, c, d, e, f, g], %{
      id: a.id,
      code: a.code,
      description: a.description,
      status: a.status,
      maker_id: a.maker_id,
      checker_id: a.checker_id,
      inserted_at: a.inserted_at,
      updated_at: a.updated_at,
      destination_station: a.destination_station,
      origin_station: a.origin_station,
      operator: a.operator,
      transport_type: a.transport_type,
      distance: a.distance,
      route_org_station: b.description,
      route_dest_station: c.description,
      route_transport_type: d.description,
      route_operator: e.description,
      maker_frt_name: f.first_name,
      maker_lst_name: f.last_name,
      checker_frt_name: g.first_name,
      checker_lst_name: g.last_name
    })
  end

  def change_train_route(%TrainRoute{} = train_route, attrs \\ %{}) do
    TrainRoute.changeset(train_route, attrs)
  end

  alias Rms.SystemUtilities.Model

  @doc """
  Returns the list of tbl_locomotive_models.

  ## Examples

      iex> list_tbl_locomotive_models()
      [%Model{}, ...]

  """
  def list_tbl_locomotive_models do
    Model
    |> preload([:maker, :checker])
    |> Repo.all()
  end

  @doc """
  Gets a single model.

  Raises `Ecto.NoResultsError` if the Model does not exist.

  ## Examples

      iex> get_model!(123)
      %Model{}

      iex> get_model!(456)
      ** (Ecto.NoResultsError)

  """
  def get_model!(id), do: Repo.get!(Model, id)

  @doc """
  Creates a model.

  ## Examples

      iex> create_model(%{field: value})
      {:ok, %Model{}}

      iex> create_model(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_model(attrs \\ %{}) do
    %Model{}
    |> Model.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a model.

  ## Examples

      iex> update_model(model, %{field: new_value})
      {:ok, %Model{}}

      iex> update_model(model, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_model(%Model{} = model, attrs) do
    model
    |> Model.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a model.

  ## Examples

      iex> delete_model(model)
      {:ok, %Model{}}

      iex> delete_model(model)
      {:error, %Ecto.Changeset{}}

  """
  def delete_model(%Model{} = model) do
    Repo.delete(model)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking model changes.

  ## Examples

      iex> change_model(model)
      %Ecto.Changeset{data: %Model{}}

  """
  def change_model(%Model{} = model, attrs \\ %{}) do
    Model.changeset(model, attrs)
  end

  alias Rms.SystemUtilities.Status

  @doc """
  Returns the list of tbl_status.

  ## Examples

      iex> list_tbl_status()
      [%Status{}, ...]

  """
  def list_tbl_status do
    Status
    |> preload([:maker, :checker])
    |> Repo.all()
  end

  @doc """
  Gets a single status.

  Raises `Ecto.NoResultsError` if the Status does not exist.

  ## Examples

      iex> get_status!(123)
      %Status{}

      iex> get_status!(456)
      ** (Ecto.NoResultsError)

  """
  def get_status!(id), do: Repo.get!(Status, id)

  @doc """
  Creates a status.

  ## Examples

      iex> create_status(%{field: value})
      {:ok, %Status{}}

      iex> create_status(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_status(attrs \\ %{}) do
    %Status{}
    |> Status.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a status.

  ## Examples

      iex> update_status(status, %{field: new_value})
      {:ok, %Status{}}

      iex> update_status(status, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_status(%Status{} = status, attrs) do
    status
    |> Status.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a status.

  ## Examples

      iex> delete_status(status)
      {:ok, %Status{}}

      iex> delete_status(status)
      {:error, %Ecto.Changeset{}}

  """
  def delete_status(%Status{} = status) do
    Repo.delete(status)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking status changes.

  ## Examples

      iex> change_status(status)
      %Ecto.Changeset{data: %Status{}}

  """
  def change_status(%Status{} = status, attrs \\ %{}) do
    Status.changeset(status, attrs)
  end

  def wagon_status_lookup(code) do
    Rms.SystemUtilities.Status
    |> where([a], fragment("lower(?) = ?", a.code, ^remove_spaces(code)))
    |> Repo.one()
  end

  alias Rms.SystemUtilities.TransportType

  @doc """
  Returns the list of tbl_transport_type.

  ## Examples

      iex> list_tbl_transport_type()
      [%TransportType{}, ...]

  """
  def list_tbl_transport_type do
    TransportType
    |> preload([:maker, :checker])
    |> Repo.all()
  end

  def search_tranport_type(search_term, start) do
    TransportType
    |> where(
      [t],
      fragment("lower(?) like lower(?)", t.description, ^search_term) and t.status == "A"
    )
    |> compose_search_trans_type_query(start)
    |> Repo.all()
  end

  def select_transport(search_term, start) do
    TransportType
    |> where([t], fragment("lower(?) like lower(?)", t.description, ^search_term))
    |> compose_search_trans_type_query(start)
    |> Repo.all()
  end

  defp compose_search_trans_type_query(query, start) do
    query
    |> order_by([t], t.id)
    |> group_by([t], [t.description, t.id])
    |> limit(50)
    |> offset(^start)
    |> select([t], %{
      total_count: fragment("count(*) AS total_count"),
      id: t.id,
      text: t.description
    })
  end

  @doc """
  Gets a single transport_type.

  Raises `Ecto.NoResultsError` if the Transport type does not exist.

  ## Examples

      iex> get_transport_type!(123)
      %TransportType{}

      iex> get_transport_type!(456)
      ** (Ecto.NoResultsError)

  """
  def get_transport_type!(id), do: Repo.get!(TransportType, id)

  @doc """
  Creates a transport_type.

  ## Examples

      iex> create_transport_type(%{field: value})
      {:ok, %TransportType{}}

      iex> create_transport_type(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_transport_type(attrs \\ %{}) do
    %TransportType{}
    |> TransportType.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a transport_type.

  ## Examples

      iex> update_transport_type(transport_type, %{field: new_value})
      {:ok, %TransportType{}}

      iex> update_transport_type(transport_type, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_transport_type(%TransportType{} = transport_type, attrs) do
    transport_type
    |> TransportType.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a transport_type.

  ## Examples

      iex> delete_transport_type(transport_type)
      {:ok, %TransportType{}}

      iex> delete_transport_type(transport_type)
      {:error, %Ecto.Changeset{}}

  """
  def delete_transport_type(%TransportType{} = transport_type) do
    Repo.delete(transport_type)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking transport_type changes.

  ## Examples

      iex> change_transport_type(transport_type)
      %Ecto.Changeset{data: %TransportType{}}

  """
  def change_transport_type(%TransportType{} = transport_type, attrs \\ %{}) do
    TransportType.changeset(transport_type, attrs)
  end

  alias Rms.SystemUtilities.Condition

  @doc """
  Returns the list of tbl_condition.

  ## Examples

      iex> list_tbl_condition()
      [%Condition{}, ...]

  """
  def list_tbl_condition do
    Condition
    |> preload([:maker, :checker, :condition_cat])
    |> Repo.all()
  end

  @doc """
  Gets a single condition.

  Raises `Ecto.NoResultsError` if the Condition does not exist.

  ## Examples

      iex> get_condition!(123)
      %Condition{}

      iex> get_condition!(456)
      ** (Ecto.NoResultsError)

  """
  def get_condition!(id), do: Repo.get!(Condition, id)

  @doc """
  Creates a condition.

  ## Examples

      iex> create_condition(%{field: value})
      {:ok, %Condition{}}

      iex> create_condition(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_condition(attrs \\ %{}) do
    %Condition{}
    |> Condition.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a condition.

  ## Examples

      iex> update_condition(condition, %{field: new_value})
      {:ok, %Condition{}}

      iex> update_condition(condition, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_condition(%Condition{} = condition, attrs) do
    condition
    |> Condition.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a condition.

  ## Examples

      iex> delete_condition(condition)
      {:ok, %Condition{}}

      iex> delete_condition(condition)
      {:error, %Ecto.Changeset{}}

  """
  def delete_condition(%Condition{} = condition) do
    Repo.delete(condition)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking condition changes.

  ## Examples

      iex> change_condition(condition)
      %Ecto.Changeset{data: %Condition{}}

  """
  def change_condition(%Condition{} = condition, attrs \\ %{}) do
    Condition.changeset(condition, attrs)
  end

  def wagon_condition_lookup(code) do
    Condition
    # |> where([a],  a.code == ^code )
    |> where([a], fragment("lower(?) = ?", a.code, ^remove_spaces(code)) and a.status == "A")
    |> Repo.one()
  end

  alias Rms.SystemUtilities.Spare

  @doc """
  Returns the list of tbl_spares.

  ## Examples

      iex> list_tbl_spares()
      [%Spare{}, ...]

  """
  def list_tbl_spares do
    Spare
    |> preload([:maker, :checker])
    |> Repo.all()
  end

  def search_spare(search_term, start) do
    Spare
    |> where(
      [s],
      fragment("lower(?) like lower(?)", s.description, ^search_term) and s.status == "A"
    )
    |> compose_search_spare_query(start)
    |> Repo.all()
  end

  def select_spare(search_term, start) do
    Spare
    |> where([s], fragment("lower(?) like lower(?)", s.description, ^search_term))
    |> compose_search_spare_query(start)
    |> Repo.all()
  end

  defp compose_search_spare_query(query, start) do
    query
    |> order_by([s], s.id)
    |> group_by([s], [s.description, s.id])
    |> limit(50)
    |> offset(^start)
    |> select([s], %{
      total_count: fragment("count(*) AS total_count"),
      id: s.id,
      text: s.description
    })
  end

  @doc """
  Gets a single spare.

  Raises `Ecto.NoResultsError` if the Spare does not exist.

  ## Examples

      iex> get_spare!(123)
      %Spare{}

      iex> get_spare!(456)
      ** (Ecto.NoResultsError)

  """
  def get_spare!(id), do: Repo.get!(Spare, id)

  @doc """
  Creates a spare.

  ## Examples

      iex> create_spare(%{field: value})
      {:ok, %Spare{}}

      iex> create_spare(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_spare(attrs \\ %{}) do
    %Spare{}
    |> Spare.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a spare.

  ## Examples

      iex> update_spare(spare, %{field: new_value})
      {:ok, %Spare{}}

      iex> update_spare(spare, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_spare(%Spare{} = spare, attrs) do
    spare
    |> Spare.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a spare.

  ## Examples

      iex> delete_spare(spare)
      {:ok, %Spare{}}

      iex> delete_spare(spare)
      {:error, %Ecto.Changeset{}}

  """
  def delete_spare(%Spare{} = spare) do
    Repo.delete(spare)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking spare changes.

  ## Examples

      iex> change_spare(spare)
      %Ecto.Changeset{data: %Spare{}}

  """
  def change_spare(%Spare{} = spare, attrs \\ %{}) do
    Spare.changeset(spare, attrs)
  end

  alias Rms.SystemUtilities.SpareFee

  @doc """
  Returns the list of tbl_spare_fees.

  ## Examples

      iex> list_tbl_spare_fees()
      [%SpareFee{}, ...]

  """
  def list_tbl_spare_fees do
    SpareFee
    |> preload([:maker, :checker, :spare, :currency, :admin])
    |> Repo.all()
  end

  @doc """
  Gets a single spare_fee.

  Raises `Ecto.NoResultsError` if the Spare fee does not exist.

  ## Examples

      iex> get_spare_fee!(123)
      %SpareFee{}

      iex> get_spare_fee!(456)
      ** (Ecto.NoResultsError)

  """
  def get_spare_fee!(id), do: Repo.get!(SpareFee, id)

  @doc """
  Creates a spare_fee.

  ## Examples

      iex> create_spare_fee(%{field: value})
      {:ok, %SpareFee{}}

      iex> create_spare_fee(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_spare_fee(attrs \\ %{}) do
    %SpareFee{}
    |> SpareFee.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a spare_fee.

  ## Examples

      iex> update_spare_fee(spare_fee, %{field: new_value})
      {:ok, %SpareFee{}}

      iex> update_spare_fee(spare_fee, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_spare_fee(%SpareFee{} = spare_fee, attrs) do
    spare_fee
    |> SpareFee.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a spare_fee.

  ## Examples

      iex> delete_spare_fee(spare_fee)
      {:ok, %SpareFee{}}

      iex> delete_spare_fee(spare_fee)
      {:error, %Ecto.Changeset{}}

  """
  def delete_spare_fee(%SpareFee{} = spare_fee) do
    Repo.delete(spare_fee)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking spare_fee changes.

  ## Examples

      iex> change_spare_fee(spare_fee)
      %Ecto.Changeset{data: %SpareFee{}}

  """
  def change_spare_fee(%SpareFee{} = spare_fee, attrs \\ %{}) do
    SpareFee.changeset(spare_fee, attrs)
  end

  def spare_fee_lookup(date, admin_id, spare_id) do
    SpareFee
    |> where(
      [a],
      fragment("CAST(? AS DATE) >= ?", ^date, a.start_date) and a.railway_admin == ^admin_id and
        a.spare_id == ^spare_id and a.status == "A"
    )
    |> order_by([a], desc: [a.id])
    |> select(
      [a],
      map(a, [
        :amount,
        :start_date,
        :spare_id,
        :currency_id,
        :inserted_at,
        :updated_at,
        :maker_id,
        :checker_id,
        :status,
        :railway_admin,
        :id
      ])
    )
    |> limit(1)
    |> Repo.one()
  end

  alias Rms.SystemUtilities.Defect

  @doc """
  Returns the list of tbl_defects.

  ## Examples

      iex> list_tbl_defects()
      [%Defect{}, ...]

  """
  def list_tbl_defects(type) do
    Defect
    |> preload([:maker, :checker, :currency, :surcharge])
    |> where([a], a.type == ^type)
    |> Repo.all()
  end

  @doc """
  Gets a single defect.

  Raises `Ecto.NoResultsError` if the Defect does not exist.

  ## Examples

      iex> get_defect!(123)
      %Defect{}

      iex> get_defect!(456)
      ** (Ecto.NoResultsError)

  """
  def get_defect!(id), do: Repo.get!(Defect, id)

  @doc """
  Creates a defect.

  ## Examples

      iex> create_defect(%{field: value})
      {:ok, %Defect{}}

      iex> create_defect(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_defect(attrs \\ %{}) do
    %Defect{}
    |> Defect.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a defect.

  ## Examples

      iex> update_defect(defect, %{field: new_value})
      {:ok, %Defect{}}

      iex> update_defect(defect, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_defect(%Defect{} = defect, attrs) do
    defect
    |> Defect.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a defect.

  ## Examples

      iex> delete_defect(defect)
      {:ok, %Defect{}}

      iex> delete_defect(defect)
      {:error, %Ecto.Changeset{}}

  """
  def delete_defect(%Defect{} = defect) do
    Repo.delete(defect)
  end

  def get_defects_by_ids(ids) do
    Defect
    |> where([a], a.id in ^ids)
    |> select(
      [a],
      map(a, [
        :id,
        :code,
        :description
      ])
    )
    |> Repo.all()
  end

  def defect_spare_lookup(id, admin, date) do
    Rms.SystemUtilities.DefectSpare
    # |> join(:left, [a], b in Rms.SystemUtilities.DefectSpare, on: b.defect_id == a.id)
    |> where([b], b.defect_id == ^id)
    |> join(:left, [b], c in Rms.SystemUtilities.Spare, on: b.spare_id == c.id)
    |> join(:left, [b, c], d in Rms.SystemUtilities.SpareFee,
      on: d.spare_id == c.id and d.railway_admin == ^admin
    )
    |> join(:left, [b, c, d], e in Rms.SystemUtilities.Currency, on: e.id == d.currency_id)
    |> where(
      [b, c, d, e],
      d.status == "A" and fragment("CAST(? AS DATE) >= ?", ^date, d.start_date)
    )
    # |> where([ b, c, d, e], d.id in subquery(from(f in Rms.SystemUtilities.SpareFee, where: f.railway_admin == ^admin, select: f.id)))
    |> order_by([b, c, d, e], asc: [d.railway_admin])
    |> group_by([b, c, d, e], [d.railway_admin, e.symbol, b.spare_id])
    |> select([b, c, d, e], %{
      count: count(d.id),
      amount: sum(d.amount),
      currency: e.symbol
    })
    |> Repo.all()
  end

  def defect_spare_lookup(id, admin) do
    Rms.SystemUtilities.DefectSpare
    |> where([b], b.defect_id == ^id)
    |> join(:left, [b], c in Rms.SystemUtilities.Spare, on: b.spare_id == c.id)
    |> join(:left, [b, c], d in Rms.SystemUtilities.SpareFee,
      on: d.spare_id == c.id and d.railway_admin == ^admin
    )
    |> join(:left, [b, c, d], e in Rms.SystemUtilities.Currency, on: e.id == d.currency_id)
    |> select([b, c, d, e], %{
      # count: count(d.id),
      amount: d.amount,
      currency: e.symbol,
      spare: c.description,
      code: c.code
    })
    |> Repo.all()
  end

  def interchange_defect_spare_lookup(id, admin) do
    Rms.Tracking.InterchangeDefect
    |> where([a], a.interchange_id == ^id)
    |> join(:left, [a], b in Rms.SystemUtilities.DefectSpare, on: a.defect_id == b.defect_id)
    |> join(:left, [a, b], c in Rms.SystemUtilities.Spare, on: b.spare_id == c.id)
    |> join(:left, [a, b, c], d in Rms.SystemUtilities.SpareFee,
      on: d.spare_id == c.id and d.railway_admin == ^admin
    )
    |> join(:left, [a, b, c, d], e in Rms.SystemUtilities.Currency, on: e.id == d.currency_id)
    |> join(:left, [a, b, c, d, e], f in Rms.SystemUtilities.Defect, on: f.id == a.defect_id)
    |> order_by([a, b, c, d, e, f], asc: [d.railway_admin])
    |> group_by([a, b, c, d, e, f], [
      d.railway_admin,
      e.symbol,
      f.description,
      f.code,
      a.defect_id
    ])
    |> select([a, b, c, d, e, f], %{
      count: count(d.id),
      amount: sum(d.amount),
      currency: e.symbol,
      equipment: f.description,
      code: f.code,
      defect_id: a.defect_id
    })
    |> Repo.all()
  end

  def interchange_defect_spares_lookup(id, admin) do
    Rms.Tracking.InterchangeDefect
    |> where([a], a.interchange_id == ^id)
    |> join(:left, [a], b in Rms.SystemUtilities.DefectSpare, on: a.defect_id == b.defect_id)
    |> join(:left, [a, b], c in Rms.SystemUtilities.Spare, on: b.spare_id == c.id)
    |> join(:left, [a, b, c], d in Rms.SystemUtilities.SpareFee,
      on: d.spare_id == c.id and d.railway_admin == ^admin
    )
    |> join(:left, [a, b, c, d], e in Rms.SystemUtilities.Currency, on: e.id == d.currency_id)
    |> join(:left, [a, b, c, d, e], f in Rms.SystemUtilities.Defect, on: f.id == a.defect_id)
    |> select([a, b, c, d, e, f], %{
      amount: d.amount,
      currency: e.symbol,
      spare: c.description,
      code: c.code
    })
    |> Repo.all()
  end

  def check_defects_by_ids(codes) do
    Defect
    |> where([a], a.code in ^codes)
    |> Repo.exists?()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking defect changes.

  ## Examples

      iex> change_defect(defect)
      %Ecto.Changeset{data: %Defect{}}

  """
  def change_defect(%Defect{} = defect, attrs \\ %{}) do
    Defect.changeset(defect, attrs)
  end

  alias Rms.SystemUtilities.InterchangeFee

  @doc """
  Returns the list of tbl_interchange_fees.

  ## Examples

      iex> list_tbl_interchange_fees()
      [%InterchangeFee{}, ...]

  """
  def list_tbl_interchange_fees do
    InterchangeFee
    |> preload([:maker, :checker, :partner, :currency, :wagon_type])
    |> Repo.all()
  end

  @doc """
  Gets a single interchange_fee.

  Raises `Ecto.NoResultsError` if the Interchange fee does not exist.

  ## Examples

      iex> get_interchange_fee!(123)
      %InterchangeFee{}

      iex> get_interchange_fee!(456)
      ** (Ecto.NoResultsError)

  """
  def get_interchange_fee!(id), do: Repo.get!(InterchangeFee, id)

  @doc """
  Creates a interchange_fee.

  ## Examples

      iex> create_interchange_fee(%{field: value})
      {:ok, %InterchangeFee{}}

      iex> create_interchange_fee(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_interchange_fee(attrs \\ %{}) do
    %InterchangeFee{}
    |> InterchangeFee.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a interchange_fee.

  ## Examples

      iex> update_interchange_fee(interchange_fee, %{field: new_value})
      {:ok, %InterchangeFee{}}

      iex> update_interchange_fee(interchange_fee, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_interchange_fee(%InterchangeFee{} = interchange_fee, attrs) do
    interchange_fee
    |> InterchangeFee.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a interchange_fee.

  ## Examples

      iex> delete_interchange_fee(interchange_fee)
      {:ok, %InterchangeFee{}}

      iex> delete_interchange_fee(interchange_fee)
      {:error, %Ecto.Changeset{}}

  """
  def delete_interchange_fee(%InterchangeFee{} = interchange_fee) do
    Repo.delete(interchange_fee)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking interchange_fee changes.

  ## Examples

      iex> change_interchange_fee(interchange_fee)
      %Ecto.Changeset{data: %InterchangeFee{}}

  """
  def change_interchange_fee(%InterchangeFee{} = interchange_fee, attrs \\ %{}) do
    InterchangeFee.changeset(interchange_fee, attrs)
  end

  def interchange_fee_lookup(year, partner_id, wagon_type_id) do
    InterchangeFee
    |> where(year: ^year, partner_id: ^partner_id, wagon_type_id: ^wagon_type_id, status: "A")
    |> select(
      [a],
      map(a, [
        :amount,
        :year,
        :currency_id,
        :partner_id,
        :inserted_at,
        :updated_at,
        :maker_id,
        :checker_id,
        :status,
        :lease_period,
        :id
      ])
    )
    |> limit(1)
    |> Repo.one()
  end

  def wagon_rate_lookup(effective_date, partner_id, wagon_type_id) do
    InterchangeFee
    |> where(effective_date: ^effective_date, partner_id: ^partner_id, wagon_type_id: ^wagon_type_id)
    |> order_by([a], desc: [a.inserted_at])
    |> limit(1)
    |> Repo.one()
  end



  alias Rms.SystemUtilities.TrainType

  @doc """
  Returns the list of tbl_train_type.

  ## Examples

      iex> list_tbl_train_type()
      [%TrainType{}, ...]

  """
  def list_tbl_train_type do
    TrainType
    |> preload([:maker, :checker])
    |> Repo.all()
  end

  @doc """
  Gets a single train_type.

  Raises `Ecto.NoResultsError` if the Train type does not exist.

  ## Examples

      iex> get_train_type!(123)
      %TrainType{}

      iex> get_train_type!(456)
      ** (Ecto.NoResultsError)

  """
  def get_train_type!(id), do: Repo.get!(TrainType, id)

  @doc """
  Creates a train_type.

  ## Examples

      iex> create_train_type(%{field: value})
      {:ok, %TrainType{}}

      iex> create_train_type(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_train_type(attrs \\ %{}) do
    %TrainType{}
    |> TrainType.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a train_type.

  ## Examples

      iex> update_train_type(train_type, %{field: new_value})
      {:ok, %TrainType{}}

      iex> update_train_type(train_type, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_train_type(%TrainType{} = train_type, attrs) do
    train_type
    |> TrainType.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a train_type.

  ## Examples

      iex> delete_train_type(train_type)
      {:ok, %TrainType{}}

      iex> delete_train_type(train_type)
      {:error, %Ecto.Changeset{}}

  """
  def delete_train_type(%TrainType{} = train_type) do
    Repo.delete(train_type)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking train_type changes.

  ## Examples

      iex> change_train_type(train_type)
      %Ecto.Changeset{data: %TrainType{}}

  """
  def change_train_type(%TrainType{} = train_type, attrs \\ %{}) do
    TrainType.changeset(train_type, attrs)
  end

  alias Rms.SystemUtilities.Region

  @doc """
  Returns the list of tbl_region.

  ## Examples

      iex> list_tbl_region()
      [%Region{}, ...]

  """
  def list_tbl_region do
    Region
    |> preload([:maker, :checker])
    |> Repo.all()
  end

  @doc """
  Gets a single region.

  Raises `Ecto.NoResultsError` if the Region does not exist.

  ## Examples

      iex> get_region!(123)
      %Region{}

      iex> get_region!(456)
      ** (Ecto.NoResultsError)

  """
  def get_region!(id), do: Repo.get!(Region, id)

  @doc """
  Creates a region.

  ## Examples

      iex> create_region(%{field: value})
      {:ok, %Region{}}

      iex> create_region(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_region(attrs \\ %{}) do
    %Region{}
    |> Region.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a region.

  ## Examples

      iex> update_region(region, %{field: new_value})
      {:ok, %Region{}}

      iex> update_region(region, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_region(%Region{} = region, attrs) do
    region
    |> Region.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a region.

  ## Examples

      iex> delete_region(region)
      {:ok, %Region{}}

      iex> delete_region(region)
      {:error, %Ecto.Changeset{}}

  """
  def delete_region(%Region{} = region) do
    Repo.delete(region)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking region changes.

  ## Examples

      iex> change_region(region)
      %Ecto.Changeset{data: %Region{}}

  """
  def change_region(%Region{} = region, attrs \\ %{}) do
    Region.changeset(region, attrs)
  end

  alias Rms.SystemUtilities.Domain

  @doc """
  Returns the list of tbl_domain.

  ## Examples

      iex> list_tbl_domain()
      [%Domain{}, ...]

  """
  def list_tbl_domain do
    Domain
    |> preload([:maker, :checker])
    |> Repo.all()
  end

  @doc """
  Gets a single domain.

  Raises `Ecto.NoResultsError` if the Domain does not exist.

  ## Examples

      iex> get_domain!(123)
      %Domain{}

      iex> get_domain!(456)
      ** (Ecto.NoResultsError)

  """
  def get_domain!(id), do: Repo.get!(Domain, id)

  @doc """
  Creates a domain.

  ## Examples

      iex> create_domain(%{field: value})
      {:ok, %Domain{}}

      iex> create_domain(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """

  def domain_lookup(code) do
    Rms.SystemUtilities.Domain
    # |> where([a],  a.code == ^code )
    |> where([a], fragment("lower(?) = ?", a.code, ^remove_spaces(code)) and a.status == "A")
    |> Repo.one()
  end

  alias Rms.SystemUtilities.CompanyInfo

  def list_company_info do
    Repo.one(CompanyInfo)
  end

  @doc """
  Gets a single company_info.

  Raises `Ecto.NoResultsError` if the Company info does not exist.

  ## Examples

      iex> get_company_info!(123)
      %CompanyInfo{}

      iex> get_company_info!(456)
      ** (Ecto.NoResultsError)

  """
  def get_company_info!(id), do: Repo.get!(CompanyInfo, id)

  @doc """
  Creates a company_info.

  ## Examples

      iex> create_company_info(%{field: value})
      {:ok, %CompanyInfo{}}

      iex> create_company_info(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_company_info(attrs \\ %{}) do
    %CompanyInfo{}
    |> CompanyInfo.changeset(attrs)
    |> Repo.insert()
  end

  def delete_domain(%Domain{} = domain) do
    Repo.delete(domain)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking domain changes.

  ## Examples

      iex> change_domain(domain)
      %Ecto.Changeset{data: %Domain{}}

  """
  def change_domain(%Domain{} = domain, attrs \\ %{}) do
    Domain.changeset(domain, attrs)
  end

  def change_company_info(%CompanyInfo{} = company_info, attrs \\ %{}) do
    CompanyInfo.changeset(company_info, attrs)
  end

  alias Rms.SystemUtilities.Distance

  @doc """
  Returns the list of tbl_distance.

  ## Examples

      iex> list_tbl_distance()
      [%Distance{}, ...]

  """
  def list_tbl_distance do
    Distance
    |> preload([:origin, :destination, :maker, :checker])
    |> Repo.all()
  end

  def distance_lookup(destin, station_orig) do
    Distance
    |> where(destin: ^destin, station_orig: ^station_orig)
    |> select(
      [a],
      map(a, [
        :distance
      ])
    )
    |> limit(1)
    |> Repo.one()
  end

  @doc """
  Gets a single distance.

  Raises `Ecto.NoResultsError` if the Distance does not exist.

  ## Examples

      iex> get_distance!(123)
      %Distance{}

      iex> get_distance!(456)
      ** (Ecto.NoResultsError)

  """
  def get_distance!(id), do: Repo.get!(Distance, id)

  @doc """
  Creates a distance.

  ## Examples

      iex> create_distance(%{field: value})
      {:ok, %Distance{}}

      iex> create_distance(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_distance(attrs \\ %{}) do
    %Distance{}
    |> Distance.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a distance.

  ## Examples

      iex> update_distance(distance, %{field: new_value})
      {:ok, %Distance{}}

      iex> update_distance(distance, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_distance(%Distance{} = distance, attrs) do
    distance
    |> Distance.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a distance.

  ## Examples

      iex> delete_distance(distance)
      {:ok, %Distance{}}

      iex> delete_distance(distance)
      {:error, %Ecto.Changeset{}}

  """
  def delete_distance(%Distance{} = distance) do
    Repo.delete(distance)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking distance changes.

  ## Examples

      iex> change_distance(distance)
      %Ecto.Changeset{data: %Distance{}}

  """
  def change_distance(%Distance{} = distance, attrs \\ %{}) do
    Distance.changeset(distance, attrs)
  end

  def filter_distance_lookup(search_params, page, size, _user) do
    Distance
    |> join(:left, [a], b in Rms.SystemUtilities.Station, on: a.destin == b.id)
    |> join(:left, [a, _b], c in Rms.SystemUtilities.Station, on: a.station_orig == c.id)
    |> join(:left, [a, _b, _c], d in Rms.Accounts.User, on: a.maker_id == d.id)
    |> join(:left, [a, _b, _c, _d], e in Rms.Accounts.User, on: a.checker_id == e.id)
    |> order_by([a, b, c, d, e], asc: [a.id])
    |> handle_distance_report_filter(search_params)
    |> compose_distance_select()
    |> Repo.paginate(page: page, page_size: size)
  end

  def filter_distance_lookup(_source, search_params, _user) do
    Distance
    |> join(:left, [a], b in Rms.SystemUtilities.Station, on: a.destin == b.id)
    |> join(:left, [a, _b], c in Rms.SystemUtilities.Station, on: a.station_orig == c.id)
    |> join(:left, [a, _b, _c], d in Rms.Accounts.User, on: a.maker_id == d.id)
    |> join(:left, [a, _b, _c, _d], e in Rms.Accounts.User, on: a.checker_id == e.id)
    |> order_by([a, b, c, d, e], asc: [a.id])
    |> handle_distance_report_filter(search_params)
    |> compose_distance_select()
  end

  defp handle_distance_report_filter(query, %{"isearch" => search_term} = search_params)
       when search_term == "" or is_nil(search_term) do
    query
    |> handle_distance_orig_station_filter(search_params)
    |> handle_distance_destin_station_filter(search_params)
  end

  defp handle_distance_report_filter(query, %{"isearch" => search_term}) do
    search_term = "%#{search_term}%"
    compose_distance_isearch_filter(query, search_term)
  end

  defp handle_distance_orig_station_filter(query, %{"station_origin_name" => station_orig})
       when station_orig == "" or is_nil(station_orig),
       do: query

  defp handle_distance_orig_station_filter(query, %{"station_origin_name" => station_orig}) do
    where(query, [a], a.station_orig == ^station_orig)
  end

  defp handle_distance_destin_station_filter(query, %{"station_destin_name" => destin})
       when destin == "" or is_nil(destin),
       do: query

  defp handle_distance_destin_station_filter(query, %{"station_destin_name" => destin}) do
    where(query, [a], a.destin == ^destin)
  end

  defp compose_distance_isearch_filter(query, search_term) do
    query
    |> where(
      [a, b, c, d, e],
      fragment("lower(?) LIKE lower(?)", c.description, ^search_term) or
        fragment("lower(?) LIKE lower(?)", b.description, ^search_term)
    )
  end

  defp compose_distance_select(query) do
    query
    |> select([a, b, c, d, e], %{
      id: a.id,
      distance: a.distance,
      inserted_at: a.inserted_at,
      updated_at: a.updated_at,
      status: a.status,
      destin: a.destin,
      station_orig: a.station_orig,
      station_origin_name: c.description,
      station_destin_name: b.description,
      description: b.description,
      maker_first_name: d.first_name,
      maker_lastname: d.last_name,
      checker_first_name: e.first_name,
      checker_lastname: e.last_name
    })
  end

  alias Rms.SystemUtilities.TariffLineRate

  @doc """
  Returns the list of tbl_tariff_line_rates.

  ## Examples

      iex> list_tbl_tariff_line_rates()
      [%TariffLineRate{}, ...]

  """
  def list_tbl_tariff_line_rates do
    Repo.all(TariffLineRate)
  end

  @doc """
  Gets a single tariff_line_rate.

  Raises `Ecto.NoResultsError` if the Tariff line rate does not exist.

  ## Examples

      iex> get_tariff_line_rate!(123)
      %TariffLineRate{}

      iex> get_tariff_line_rate!(456)
      ** (Ecto.NoResultsError)

  """
  def get_tariff_line_rate!(id), do: Repo.get!(TariffLineRate, id)

  @doc """
  Creates a tariff_line_rate.

  ## Examples

      iex> create_tariff_line_rate(%{field: value})
      {:ok, %TariffLineRate{}}

      iex> create_tariff_line_rate(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_tariff_line_rate(attrs \\ %{}) do
    %TariffLineRate{}
    |> TariffLineRate.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a tariff_line_rate.

  ## Examples

      iex> update_tariff_line_rate(tariff_line_rate, %{field: new_value})
      {:ok, %TariffLineRate{}}

      iex> update_tariff_line_rate(tariff_line_rate, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_tariff_line_rate(%TariffLineRate{} = tariff_line_rate, attrs) do
    tariff_line_rate
    |> TariffLineRate.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a tariff_line_rate.

  ## Examples

      iex> delete_tariff_line_rate(tariff_line_rate)
      {:ok, %TariffLineRate{}}

      iex> delete_tariff_line_rate(tariff_line_rate)
      {:error, %Ecto.Changeset{}}

  """
  def delete_tariff_line_rate(%TariffLineRate{} = tariff_line_rate) do
    Repo.delete(tariff_line_rate)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking tariff_line_rate changes.

  ## Examples

      iex> change_tariff_line_rate(tariff_line_rate)
      %Ecto.Changeset{data: %TariffLineRate{}}

  """
  def change_tariff_line_rate(%TariffLineRate{} = tariff_line_rate, attrs \\ %{}) do
    TariffLineRate.changeset(tariff_line_rate, attrs)
  end

  def tariff_line_rate_lookup(id) do
    TariffLineRate
    |> where([a], a.tariff_id == ^id)
    |> join(:left, [a], b in Rms.Accounts.RailwayAdministrator, on: a.admin_id == b.id)
    |> select([a, b], %{
      rate: a.rate,
      id: a.id,
      admin: b.description
    })
    |> Repo.all()
  end

  def tariff_line_item_look(id) do
    TariffLine
    |> where(id: ^id)
    |> preload([
      :maker,
      :checker,
      :commodity,
      :currency,
      :pay_type,
      :surcharge,
      :orig_station,
      :destin_station,
      :client,
    ])
    |> tarriff_fields()
    |> Repo.one()
  end

  defp tarriff_fields(query) do
    select(
      query,
      [u],
      map(
        u,
        [
          :id,
          :maker_id,
          :checker_id,
          :inserted_at,
          :updated_at,
          :commodity_id,
          :client_id,
          :orig_station_id,
          :destin_station_id,
          :pay_type_id,
          :currency_id,
          :surcharge_id,
          :start_dt,
          :status,
          :category,
          maker: [:first_name, :last_name],
          checker: [:first_name, :last_name],
          commodity: [:id, :description],
          currency: [:id, :description],
          pay_type: [:id, :description],
          surcharge: [:id, :description],
          orig_station: [:id, :description],
          destin_station: [:id, :description],
          client: [:id, :client_name]
        ]
      )
    )
  end

  def tariff_line_rates_lookup(search_params, page, size, _user) do
    TariffLine
    |> join(:left, [a], b in Rms.SystemUtilities.Commodity, on: a.commodity_id == b.id)
    |> join(:left, [a, _b], c in Rms.SystemUtilities.Currency, on: a.currency_id == c.id)
    |> join(:left, [a, _b, _c], d in Rms.SystemUtilities.PaymentType, on: a.pay_type_id == d.id)
    |> join(:left, [a, _b, _c, _d], e in Rms.SystemUtilities.Surchage, on: a.surcharge_id == e.id)
    |> join(:left, [a, _b, _c, _d, _e], f in Rms.SystemUtilities.Station,
      on: a.orig_station_id == f.id
    )
    |> join(:left, [a, _b, _c, _d, _e, _f], g in Rms.SystemUtilities.Station,
      on: a.destin_station_id == g.id
    )
    |> join(:left, [a, _b, _c, _d, _e, _f, _g], h in Rms.Accounts.Clients, on: a.client_id == h.id)
    |> join(:left, [a, _b, _c, _d, _e, _f, _g, _h], i in Rms.Accounts.User, on: a.maker_id == i.id)
    |> join(:left, [a, _b, _c, _d, _e, _f, _g, _h, _i], j in Rms.Accounts.User,
      on: a.checker_id == j.id
    )
    |> order_by([a, b, c, d, e, f, g, h, i, j], asc: [a.id])
    |> handle_tariff_report_filter(search_params)
    |> compose_tariff_line_select()
    |> Repo.paginate(page: page, page_size: size)
  end

  def tariff_line_rates_lookup(_source, search_params, _user) do
    TariffLine
    |> join(:left, [a], b in Rms.SystemUtilities.Commodity, on: a.commodity_id == b.id)
    |> join(:left, [a, _b], c in Rms.SystemUtilities.Currency, on: a.currency_id == c.id)
    |> join(:left, [a, _b, _c], d in Rms.SystemUtilities.PaymentType, on: a.pay_type_id == d.id)
    |> join(:left, [a, _b, _c, _d], e in Rms.SystemUtilities.Surchage, on: a.surcharge_id == e.id)
    |> join(:left, [a, _b, _c, _d, _e], f in Rms.SystemUtilities.Station,
      on: a.orig_station_id == f.id
    )
    |> join(:left, [a, _b, _c, _d, _e, _f], g in Rms.SystemUtilities.Station,
      on: a.destin_station_id == g.id
    )
    |> join(:left, [a, _b, _c, _d, _e, _f, _g], h in Rms.Accounts.Clients, on: a.client_id == h.id)
    |> join(:left, [a, _b, _c, _d, _e, _f, _g, _h], i in Rms.Accounts.User, on: a.maker_id == i.id)
    |> join(:left, [a, _b, _c, _d, _e, _f, _g, _h, _i], j in Rms.Accounts.User,
      on: a.checker_id == j.id
    )
    |> order_by([a, b, c, d, e, f, g, h, i, j], asc: [a.id])
    |> handle_tariff_report_filter(search_params)
    |> compose_tariff_line_select()
  end

  defp handle_tariff_report_filter(query, %{"isearch" => search_term} = search_params)
       when search_term == "" or is_nil(search_term) do
    query
    |> handle_tariff_client_filter(search_params)
    |> handle_tariff_orig_station_filter(search_params)
    |> handle_tariff_destin_station_filter(search_params)
    |> handle_tariff_currency_filter(search_params)
    |> handle_tariff_pay_type_filter(search_params)
    |> handle_tariff_commodity_filter(search_params)
    |> handle_tariff_surcharge_filter(search_params)
    |> handle_tariff_start_date_filter(search_params)
    |> handle_tariff_category_filter(search_params)
  end

  defp handle_tariff_report_filter(query, %{"isearch" => search_term}) do
    search_term = "%#{search_term}%"
    compose_tarriff_isearch_filter(query, search_term)
  end

  defp handle_tariff_client_filter(query, %{"client_id" => client_id})
       when client_id == "" or is_nil(client_id),
       do: query

  defp handle_tariff_client_filter(query, %{"client_id" => client_id}) do
    where(query, [a], a.client_id == ^client_id)
  end

  defp handle_tariff_orig_station_filter(query, %{"orig_station_id" => orig_station_id})
       when orig_station_id == "" or is_nil(orig_station_id),
       do: query

  defp handle_tariff_orig_station_filter(query, %{"orig_station_id" => orig_station_id}) do
    where(query, [a], a.orig_station_id == ^orig_station_id)
  end

  defp handle_tariff_destin_station_filter(query, %{"destin_station_id" => destin_station_id})
       when destin_station_id == "" or is_nil(destin_station_id),
       do: query

  defp handle_tariff_destin_station_filter(query, %{"destin_station_id" => destin_station_id}) do
    where(query, [a], a.destin_station_id == ^destin_station_id)
  end

  defp handle_tariff_currency_filter(query, %{"currency_id" => currency_id})
       when currency_id == "" or is_nil(currency_id),
       do: query

  defp handle_tariff_currency_filter(query, %{"currency_id" => currency_id}) do
    where(query, [a], a.currency_id == ^currency_id)
  end

  defp handle_tariff_category_filter(query, %{"category" => category})
  when category == "" or is_nil(category),
  do: query

  defp handle_tariff_category_filter(query, %{"category" => category}) do
     where(query, [a], a.category == ^category)
  end

  defp handle_tariff_pay_type_filter(query, %{"pay_type_id" => pay_type_id})
       when pay_type_id == "" or is_nil(pay_type_id),
       do: query

  defp handle_tariff_pay_type_filter(query, %{"pay_type_id" => pay_type_id}) do
    where(query, [a], a.pay_type_id == ^pay_type_id)
  end

  defp handle_tariff_commodity_filter(query, %{"commodity_id" => commodity_id})
       when commodity_id == "" or is_nil(commodity_id),
       do: query

  defp handle_tariff_commodity_filter(query, %{"commodity_id" => commodity_id}) do
    where(query, [a], a.commodity_id == ^commodity_id)
  end

  defp handle_tariff_surcharge_filter(query, %{"surcharge_id" => surcharge_id})
       when surcharge_id == "" or is_nil(surcharge_id),
       do: query

  defp handle_tariff_surcharge_filter(query, %{"surcharge_id" => surcharge_id}) do
    where(query, [a], a.surcharge_id == ^surcharge_id)
  end

  defp handle_tariff_start_date_filter(query, %{"start_dt" => start_dt})
       when start_dt == "" or is_nil(start_dt),
       do: query

  defp handle_tariff_start_date_filter(query, %{"start_dt" => start_dt}) do
    query
    |> where(
      [a],
      fragment("CAST(? AS DATE) >= ?", a.start_dt, ^start_dt)
    )
  end

  defp compose_tarriff_isearch_filter(query, search_term) do
    query
    |> where(
      [a, b, c, d, e, f, g, h, i, j],
      fragment("lower(?) LIKE lower(?)", b.description, ^search_term) or
        fragment("lower(?) LIKE lower(?)", c.description, ^search_term) or
        fragment("lower(?) LIKE lower(?)", d.description, ^search_term) or
        fragment("lower(?) LIKE lower(?)", h.client_name, ^search_term) or
        fragment("lower(?) LIKE lower(?)", f.description, ^search_term) or
        fragment("lower(?) LIKE lower(?)", g.description, ^search_term) or
        fragment("lower(?) LIKE lower(?)", a.category, ^search_term)
    )
  end

  defp compose_tariff_line_select(query) do
    query
    |> select([a, b, c, d, e, f, g, h, i, j], %{
      id: a.id,
      maker_id: a.maker_id,
      checker_id: a.checker_id,
      inserted_at: a.inserted_at,
      updated_at: a.updated_at,
      commodity_id: a.commodity_id,
      client_id: a.client_id,
      orig_station_id: a.orig_station_id,
      destin_station_id: a.destin_station_id,
      pay_type_id: a.pay_type_id,
      currency_id: a.currency_id,
      surcharge_id: a.surcharge_id,
      start_dt: a.start_dt,
      status: a.status,
      maker_ft_name: i.first_name,
      maker_lt_name: i.last_name,
      checker_ft_name: j.first_name,
      checker_lt_name: j.last_name,
      commodity: b.description,
      currency: c.description,
      payment_type: d.description,
      surcharge: e.description,
      origin_station: f.description,
      destin_station: g.description,
      client_name: h.client_name,
      category: a.category
    })
  end

  alias Rms.SystemUtilities.Refueling

  @doc """
  Returns the list of tbl_refueling_type.

  ## Examples

      iex> list_tbl_refueling_type()
      [%Refueling{}, ...]

  """

  # def list_tbl_refueling_type do
  #   Repo.all(Refueling)
  # end

  def list_tbl_refueling_type do
    Refueling
    |> preload([:maker, :checker])
    |> Repo.all()
  end

  @doc """
  Gets a single refueling.

  Raises `Ecto.NoResultsError` if the Refueling does not exist.

  ## Examples

      iex> get_refueling!(123)
      %Refueling{}

      iex> get_refueling!(456)
      ** (Ecto.NoResultsError)

  """
  def get_refueling!(id), do: Repo.get!(Refueling, id)

  @doc """
  Creates a refueling.

  ## Examples

      iex> create_refueling(%{field: value})
      {:ok, %Refueling{}}

      iex> create_refueling(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_refueling(attrs \\ %{}) do
    %Refueling{}
    |> Refueling.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a refueling.

  ## Examples

      iex> update_refueling(refueling, %{field: new_value})
      {:ok, %Refueling{}}

      iex> update_refueling(refueling, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_refueling(%Refueling{} = refueling, attrs) do
    refueling
    |> Refueling.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a refueling.

  ## Examples

      iex> delete_refueling(refueling)
      {:ok, %Refueling{}}

      iex> delete_refueling(refueling)
      {:error, %Ecto.Changeset{}}

  """
  def delete_refueling(%Refueling{} = refueling) do
    Repo.delete(refueling)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking refueling changes.

  ## Examples

      iex> change_refueling(refueling)
      %Ecto.Changeset{data: %Refueling{}}

  """
  def change_refueling(%Refueling{} = refueling, attrs \\ %{}) do
    Refueling.changeset(refueling, attrs)
  end

  alias Rms.SystemUtilities.Section

  @doc """
  Returns the list of tbl_section.

  ## Examples

      iex> list_tbl_section()
      [%Section{}, ...]

  """

  def list_tbl_section do
    Section
    |> preload([:maker, :checker])
    |> Repo.all()
  end

  @doc """
  Gets a single section.

  Raises `Ecto.NoResultsError` if the Section does not exist.

  ## Examples

      iex> get_section!(123)
      %Section{}

      iex> get_section!(456)
      ** (Ecto.NoResultsError)

  """
  def get_section!(id), do: Repo.get!(Section, id)

  alias Rms.SystemUtilities.Wagon_defect

  @doc """
  Returns the list of tbl_wagon_defect.

  ## Examples

      iex> list_tbl_wagon_defect()
      [%Wagon_defect{}, ...]

  """
  def list_tbl_wagon_defect do
    Repo.all(Wagon_defect)
  end

  @doc """
  Gets a single wagon_defect.

  Raises `Ecto.NoResultsError` if the Wagon defect does not exist.

  ## Examples

      iex> get_wagon_defect!(123)
      %Wagon_defect{}

      iex> get_wagon_defect!(456)
      ** (Ecto.NoResultsError)

  """
  def get_wagon_defect!(id), do: Repo.get!(Wagon_defect, id)

  @doc """
  Creates a wagon_defect.

  ## Examples

      iex> create_wagon_defect(%{field: value})
      {:ok, %Wagon_defect{}}

      iex> create_wagon_defect(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_wagon_defect(attrs \\ %{}) do
    %Wagon_defect{}
    |> Wagon_defect.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a wagon_defect.

  ## Examples

      iex> update_wagon_defect(wagon_defect, %{field: new_value})
      {:ok, %Wagon_defect{}}

      iex> update_wagon_defect(wagon_defect, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_wagon_defect(%Wagon_defect{} = wagon_defect, attrs) do
    wagon_defect
    |> Wagon_defect.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a wagon_defect.

  ## Examples

      iex> delete_wagon_defect(wagon_defect)
      {:ok, %Wagon_defect{}}

      iex> delete_wagon_defect(wagon_defect)
      {:error, %Ecto.Changeset{}}

  """
  def delete_wagon_defect(%Wagon_defect{} = wagon_defect) do
    Repo.delete(wagon_defect)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking wagon_defect changes.

  ## Examples

      iex> change_wagon_defect(wagon_defect)
      %Ecto.Changeset{data: %Wagon_defect{}}

  """
  def change_wagon_defect(%Wagon_defect{} = wagon_defect, attrs \\ %{}) do
    Wagon_defect.changeset(wagon_defect, attrs)
  end

  def tracker_entry_lookup(tracker_id, wagon_id) do
    Rms.SystemUtilities.Wagon_defect
    |> where([a], a.tracker_id == ^tracker_id and a.wagon_id == ^wagon_id)
    |> limit(1)
    |> Repo.one()
  end

  alias Rms.SystemUtilities.ConditionCategory

  @doc """
  Returns the list of tbl_condition_category.

  ## Examples

      iex> list_tbl_condition_category()
      [%ConditionCategory{}, ...]

  """
  def list_tbl_condition_category do
    ConditionCategory
    |> preload([:maker, :checker])
    |> Repo.all()
  end

  @doc """
  Gets a single condition_category.

  Raises `Ecto.NoResultsError` if the Condition category does not exist.

  ## Examples

      iex> get_condition_category!(123)
      %ConditionCategory{}

      iex> get_condition_category!(456)
      ** (Ecto.NoResultsError)

  """
  def get_condition_category!(id), do: Repo.get!(ConditionCategory, id)

  @doc """
  Creates a condition_category.

  ## Examples

      iex> create_condition_category(%{field: value})
      {:ok, %ConditionCategory{}}

      iex> create_condition_category(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_condition_category(attrs \\ %{}) do
    %ConditionCategory{}
    |> ConditionCategory.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a condition_category.

  ## Examples

      iex> update_condition_category(condition_category, %{field: new_value})
      {:ok, %ConditionCategory{}}

      iex> update_condition_category(condition_category, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_condition_category(%ConditionCategory{} = condition_category, attrs) do
    condition_category
    |> ConditionCategory.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a condition_category.

  ## Examples

      iex> delete_condition_category(condition_category)
      {:ok, %ConditionCategory{}}

      iex> delete_condition_category(condition_category)
      {:error, %Ecto.Changeset{}}

  """
  def delete_condition_category(%ConditionCategory{} = condition_category) do
    Repo.delete(condition_category)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking condition_category changes.

  ## Examples

      iex> change_condition_category(condition_category)
      %Ecto.Changeset{data: %ConditionCategory{}}

  """
  def change_condition_category(%ConditionCategory{} = condition_category, attrs \\ %{}) do
    ConditionCategory.changeset(condition_category, attrs)
  end

  alias Rms.SystemUtilities.FileUploadError

  @doc """
  Returns the list of tbl_upload_file_errors.

  ## Examples

      iex> list_tbl_upload_file_errors()
      [%FileUploadError{}, ...]

  """
  def list_tbl_upload_file_errors(user) do
    FileUploadError
    |> handle_date_filter(user)
    |> Repo.all()
  end

  @doc """
  Gets a single file_upload_error.

  Raises `Ecto.NoResultsError` if the File upload error does not exist.

  ## Examples

      iex> get_file_upload_error!(123)
      %FileUploadError{}

      iex> get_file_upload_error!(456)
      ** (Ecto.NoResultsError)

  """
  def get_file_upload_error!(id), do: Repo.get!(FileUploadError, id)

  @doc """
  Creates a file_upload_error.

  ## Examples

      iex> create_file_upload_error(%{field: value})
      {:ok, %FileUploadError{}}

      iex> create_file_upload_error(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_file_upload_error(attrs \\ %{}) do
    %FileUploadError{}
    |> FileUploadError.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a file_upload_error.

  ## Examples

      iex> update_file_upload_error(file_upload_error, %{field: new_value})
      {:ok, %FileUploadError{}}

      iex> update_file_upload_error(file_upload_error, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_file_upload_error(%FileUploadError{} = file_upload_error, attrs) do
    file_upload_error
    |> FileUploadError.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a file_upload_error.

  ## Examples

      iex> delete_file_upload_error(file_upload_error)
      {:ok, %FileUploadError{}}

      iex> delete_file_upload_error(file_upload_error)
      {:error, %Ecto.Changeset{}}

  """
  def delete_file_upload_error(%FileUploadError{} = file_upload_error) do
    Repo.delete(file_upload_error)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking file_upload_error changes.

  ## Examples

      iex> change_file_upload_error(file_upload_error)
      %Ecto.Changeset{data: %FileUploadError{}}

  """
  def change_file_upload_error(%FileUploadError{} = file_upload_error, attrs \\ %{}) do
    FileUploadError.changeset(file_upload_error, attrs)
  end

  defp handle_date_filter(query, user) do
    where(
      query,
      [a],
      fragment("CAST(? AS DATE) >= ?", a.inserted_at, ^to_string(Timex.today())) and
        a.user_id == ^user.id
    )
  end

  def exceptions_lookup(%{"type" => type} = search_params, page, size, _user) do
    FileUploadError
    |> where([a], a.type == ^type)
    |> join(:left, [a], b in Rms.Accounts.User, on: a.user_id == b.id)
    |> handle_exception_report_filter(search_params)
    |> compose_haulage_report_select()
    |> Repo.paginate(page: page, page_size: size)
  end

  def exceptions_lookup(_source, %{"type" => type} = search_params, _user) do
    FileUploadError
    |> where([a], a.type == ^type)
    |> join(:left, [a], b in Rms.Accounts.User, on: a.user_id == b.id)
    |> handle_exception_report_filter(search_params)
    |> compose_haulage_report_select()
  end

  defp handle_exception_report_filter(query, %{"isearch" => search_term} = search_params)
       when search_term == "" or is_nil(search_term) do
    query
    |> handle_exception_date_filter(search_params)
    |> handle_exception_filename_filter(search_params)
  end

  defp handle_exception_report_filter(query, %{"isearch" => search_term, "type" => type}) do
    search_term = "%#{search_term}%"
    compose_exception_isearch_filter(query, search_term, type)
  end

  defp handle_exception_date_filter(query, %{"from" => from, "to" => to})
       when from == "" or is_nil(from) or to == "" or is_nil(to),
       do: query

  defp handle_exception_date_filter(query, %{"from" => from, "to" => to}) do
    query
    |> where(
      [a],
      fragment("CAST(? AS DATE) >= ?", a.inserted_at, ^from) and
        fragment("CAST(? AS DATE) <= ?", a.inserted_at, ^to)
    )
  end

  defp handle_exception_filename_filter(query, %{"filename" => filename})
       when filename == "" or is_nil(filename),
       do: query

  defp handle_exception_filename_filter(query, %{"filename" => filename}) do
    where(
      query,
      [a],
      fragment("lower(?) LIKE lower(?)", a.filename, ^"%#{filename}%")
    )
  end

  defp compose_exception_isearch_filter(query, search_term, type) do
    query
    |> where([a, b], a.type == ^type)
    |> where(
      [a, b],
      fragment("lower(?) LIKE lower(?)", a.filename, ^search_term) or
        fragment("lower(?) LIKE lower(?)", b.first_name, ^search_term) or
        fragment("lower(?) LIKE lower(?)", b.last_name, ^search_term)
    )
  end

  defp compose_haulage_report_select(query) do
    query
    |> order_by([a, b], desc: a.inserted_at)
    |> select([a, b], %{
      id: a.id,
      col_index: a.col_index,
      error_msg: a.error_msg,
      filename: a.filename,
      inserted_at: a.inserted_at,
      updated_at: a.updated_at,
      user_id: a.user_id,
      new_filename: a.new_filename,
      upload_date: a.upload_date,
      type: a.type,
      first_name: b.first_name,
      last_name: b.last_name
    })
  end

  alias Rms.SystemUtilities.DefectSpare

  @doc """
  Returns the list of tbl_defect_spares.

  ## Examples

      iex> list_tbl_defect_spares()
      [%DefectSpare{}, ...]

  """
  def list_tbl_defect_spares do
    Repo.all(DefectSpare)
  end

  @doc """
  Gets a single defect_spare.

  Raises `Ecto.NoResultsError` if the Defect spare does not exist.

  ## Examples

      iex> get_defect_spare!(123)
      %DefectSpare{}

      iex> get_defect_spare!(456)
      ** (Ecto.NoResultsError)

  """
  def get_defect_spare!(id), do: Repo.get!(DefectSpare, id)

  @doc """
  Creates a defect_spare.

  ## Examples

      iex> create_defect_spare(%{field: value})
      {:ok, %DefectSpare{}}

      iex> create_defect_spare(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_defect_spare(attrs \\ %{}) do
    %DefectSpare{}
    |> DefectSpare.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a defect_spare.

  ## Examples

      iex> update_defect_spare(defect_spare, %{field: new_value})
      {:ok, %DefectSpare{}}

      iex> update_defect_spare(defect_spare, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_defect_spare(%DefectSpare{} = defect_spare, attrs) do
    defect_spare
    |> DefectSpare.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a defect_spare.

  ## Examples

      iex> delete_defect_spare(defect_spare)
      {:ok, %DefectSpare{}}

      iex> delete_defect_spare(defect_spare)
      {:error, %Ecto.Changeset{}}

  """
  def delete_defect_spare(%DefectSpare{} = defect_spare) do
    Repo.delete(defect_spare)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking defect_spare changes.

  ## Examples

      iex> change_defect_spare(defect_spare)
      %Ecto.Changeset{data: %DefectSpare{}}

  """
  def change_defect_spare(%DefectSpare{} = defect_spare, attrs \\ %{}) do
    DefectSpare.changeset(defect_spare, attrs)
  end

  def defect_spare_lookup(id) do
    DefectSpare
    |> where([a], a.defect_id == ^id)
    # |> join(:left, [a], b in Defect, on: a.defect_id == b.id)
    |> join(:left, [a], b in Spare, on: a.spare_id == b.id)
    |> select([a, b], %{
      id: a.id,
      spare_id: a.spare_id,
      defect_id: a.defect_id,
      code: b.code,
      spare: b.description
    })
    |> Repo.all()
  end

  alias Rms.SystemUtilities.CollectionType

  @doc """
  Returns the list of tbl_collection_types.

  ## Examples

      iex> list_tbl_collection_types()
      [%CollectionType{}, ...]

  """
  def list_tbl_collection_types do
    Repo.all(CollectionType)
  end

  @doc """
  Gets a single collection_type.

  Raises `Ecto.NoResultsError` if the Collection type does not exist.

  ## Examples

      iex> get_collection_type!(123)
      %CollectionType{}

      iex> get_collection_type!(456)
      ** (Ecto.NoResultsError)

  """
  def get_collection_type!(id), do: Repo.get!(CollectionType, id)

  @doc """
  Creates a collection_type.

  ## Examples

      iex> create_collection_type(%{field: value})
      {:ok, %CollectionType{}}

      iex> create_collection_type(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_collection_type(attrs \\ %{}) do
    %CollectionType{}
    |> CollectionType.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a collection_type.

  ## Examples

      iex> update_collection_type(collection_type, %{field: new_value})
      {:ok, %CollectionType{}}

      iex> update_collection_type(collection_type, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_collection_type(%CollectionType{} = collection_type, attrs) do
    collection_type
    |> CollectionType.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a collection_type.

  ## Examples

      iex> delete_collection_type(collection_type)
      {:ok, %CollectionType{}}

      iex> delete_collection_type(collection_type)
      {:error, %Ecto.Changeset{}}

  """
  def delete_collection_type(%CollectionType{} = collection_type) do
    Repo.delete(collection_type)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking collection_type changes.

  ## Examples

      iex> change_collection_type(collection_type)
      %Ecto.Changeset{data: %CollectionType{}}

  """
  def change_collection_type(%CollectionType{} = collection_type, attrs \\ %{}) do
    CollectionType.changeset(collection_type, attrs)
  end

  alias Rms.SystemUtilities.Equipment

  @doc """
  Returns the list of tbl_equipments.

  ## Examples

      iex> list_tbl_equipments()
      [%Equipment{}, ...]

  """
  def list_tbl_equipments do
    Equipment
    |> preload([:maker, :checker])
    |> Repo.all()
  end

  @doc """
  Gets a single equipment.

  Raises `Ecto.NoResultsError` if the Equipment does not exist.

  ## Examples

      iex> get_equipment!(123)
      %Equipment{}

      iex> get_equipment!(456)
      ** (Ecto.NoResultsError)

  """
  def get_equipment!(id), do: Repo.get!(Equipment, id)

  @doc """
  Creates a equipment.

  ## Examples

      iex> create_equipment(%{field: value})
      {:ok, %Equipment{}}

      iex> create_equipment(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_equipment(attrs \\ %{}) do
    %Equipment{}
    |> Equipment.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a equipment.

  ## Examples

      iex> update_equipment(equipment, %{field: new_value})
      {:ok, %Equipment{}}

      iex> update_equipment(equipment, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_equipment(%Equipment{} = equipment, attrs) do
    equipment
    |> Equipment.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a equipment.

  ## Examples

      iex> delete_equipment(equipment)
      {:ok, %Equipment{}}

      iex> delete_equipment(equipment)
      {:error, %Ecto.Changeset{}}

  """
  def delete_equipment(%Equipment{} = equipment) do
    Repo.delete(equipment)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking equipment changes.

  ## Examples

      iex> change_equipment(equipment)
      %Ecto.Changeset{data: %Equipment{}}

  """
  def change_equipment(%Equipment{} = equipment, attrs \\ %{}) do
    Equipment.changeset(equipment, attrs)
  end

  alias Rms.SystemUtilities.EquipmentRate

  @doc """
  Returns the list of tbl_equipment_rates.

  ## Examples

      iex> list_tbl_equipment_rates()
      [%EquipmentRate{}, ...]

  """
  def list_tbl_equipment_rates do
    EquipmentRate
    |> preload([:maker, :checker, :partner, :currency, :equipment])
    |> Repo.all()
  end

  @doc """
  Gets a single equipment_rate.

  Raises `Ecto.NoResultsError` if the Equipment rate does not exist.

  ## Examples

      iex> get_equipment_rate!(123)
      %EquipmentRate{}

      iex> get_equipment_rate!(456)
      ** (Ecto.NoResultsError)

  """
  def get_equipment_rate!(id), do: Repo.get!(EquipmentRate, id)

  @doc """
  Creates a equipment_rate.

  ## Examples

      iex> create_equipment_rate(%{field: value})
      {:ok, %EquipmentRate{}}

      iex> create_equipment_rate(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_equipment_rate(attrs \\ %{}) do
    %EquipmentRate{}
    |> EquipmentRate.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a equipment_rate.

  ## Examples

      iex> update_equipment_rate(equipment_rate, %{field: new_value})
      {:ok, %EquipmentRate{}}

      iex> update_equipment_rate(equipment_rate, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_equipment_rate(%EquipmentRate{} = equipment_rate, attrs) do
    equipment_rate
    |> EquipmentRate.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a equipment_rate.

  ## Examples

      iex> delete_equipment_rate(equipment_rate)
      {:ok, %EquipmentRate{}}

      iex> delete_equipment_rate(equipment_rate)
      {:error, %Ecto.Changeset{}}

  """
  def delete_equipment_rate(%EquipmentRate{} = equipment_rate) do
    Repo.delete(equipment_rate)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking equipment_rate changes.

  ## Examples

      iex> change_equipment_rate(equipment_rate)
      %Ecto.Changeset{data: %EquipmentRate{}}

  """
  def change_equipment_rate(%EquipmentRate{} = equipment_rate, attrs \\ %{}) do
    EquipmentRate.changeset(equipment_rate, attrs)
  end

  def material_fee_lookup(date, admin_id, equipment_id) do
    EquipmentRate
    # |> where(fragment("CAST(? AS DATE) >= ?", ^date, start_dt), partner_id: ^admin_id, equipment_id: ^equipment_id, status: "A")
    |> where(
      [a],
      a.partner_id == ^admin_id and a.equipment_id == ^equipment_id and a.status == "A" and
        fragment("CAST(? AS DATE) >= ?", ^date, a.start_date)
    )
    |> order_by([a], desc: [a.id])
    |> select(
      [a],
      map(a, [
        :rate,
        :start_date,
        :currency_id,
        :partner_id,
        :inserted_at,
        :updated_at,
        :equipment_id,
        :maker_id,
        :checker_id,
        :id
      ])
    )
    |> limit(1)
    |> Repo.one()
  end

  alias Rms.SystemUtilities.LocoDetentionRate

  @doc """
  Returns the list of tbl_loco_dentention_rates.

  ## Examples

      iex> list_tbl_loco_dentention_rates()
      [%LocoDetentionRate{}, ...]

  """
  def list_tbl_loco_dentention_rates do
    LocoDetentionRate
    |> preload([:maker, :checker, :admin, :currency])
    |> Repo.all()
  end

  @doc """
  Gets a single loco_detention_rate.

  Raises `Ecto.NoResultsError` if the Loco detention rate does not exist.

  ## Examples

      iex> get_loco_detention_rate!(123)
      %LocoDetentionRate{}

      iex> get_loco_detention_rate!(456)
      ** (Ecto.NoResultsError)

  """
  def get_loco_detention_rate!(id), do: Repo.get!(LocoDetentionRate, id)

  @doc """
  Creates a loco_detention_rate.

  ## Examples

      iex> create_loco_detention_rate(%{field: value})
      {:ok, %LocoDetentionRate{}}

      iex> create_loco_detention_rate(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_loco_detention_rate(attrs \\ %{}) do
    %LocoDetentionRate{}
    |> LocoDetentionRate.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a loco_detention_rate.

  ## Examples

      iex> update_loco_detention_rate(loco_detention_rate, %{field: new_value})
      {:ok, %LocoDetentionRate{}}

      iex> update_loco_detention_rate(loco_detention_rate, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_loco_detention_rate(%LocoDetentionRate{} = loco_detention_rate, attrs) do
    loco_detention_rate
    |> LocoDetentionRate.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a loco_detention_rate.

  ## Examples

      iex> delete_loco_detention_rate(loco_detention_rate)
      {:ok, %LocoDetentionRate{}}

      iex> delete_loco_detention_rate(loco_detention_rate)
      {:error, %Ecto.Changeset{}}

  """
  def delete_loco_detention_rate(%LocoDetentionRate{} = loco_detention_rate) do
    Repo.delete(loco_detention_rate)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking loco_detention_rate changes.

  ## Examples

      iex> change_loco_detention_rate(loco_detention_rate)
      %Ecto.Changeset{data: %LocoDetentionRate{}}

  """
  def change_loco_detention_rate(%LocoDetentionRate{} = loco_detention_rate, attrs \\ %{}) do
    LocoDetentionRate.changeset(loco_detention_rate, attrs)
  end

  def loco_detention_rate_lookup(date, admin_id) do
    LocoDetentionRate
    |> where(
      [a],
      a.admin_id == ^admin_id and a.status == "A" and
        fragment("CAST(? AS DATE) >= ?", ^date, a.start_date)
    )
    |> order_by([a], desc: [a.id])
    |> limit(1)
    |> Repo.one()
  end

  alias Rms.SystemUtilities.HaulageRate

  @doc """
  Returns the list of tbl_haulage_rates.

  ## Examples

      iex> list_tbl_haulage_rates()
      [%HaulageRate{}, ...]

  """
  def list_tbl_haulage_rates do
    HaulageRate
    |> preload([:maker, :checker, :admin, :currency])
    |> Repo.all()
  end

  @doc """
  Gets a single haulage_rate.

  Raises `Ecto.NoResultsError` if the Haulage rate does not exist.

  ## Examples

      iex> get_haulage_rate!(123)
      %HaulageRate{}

      iex> get_haulage_rate!(456)
      ** (Ecto.NoResultsError)

  """
  def get_haulage_rate!(id), do: Repo.get!(HaulageRate, id)

  @doc """
  Creates a haulage_rate.

  ## Examples

      iex> create_haulage_rate(%{field: value})
      {:ok, %HaulageRate{}}

      iex> create_haulage_rate(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_haulage_rate(attrs \\ %{}) do
    %HaulageRate{}
    |> HaulageRate.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a haulage_rate.

  ## Examples

      iex> update_haulage_rate(haulage_rate, %{field: new_value})
      {:ok, %HaulageRate{}}

      iex> update_haulage_rate(haulage_rate, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_haulage_rate(%HaulageRate{} = haulage_rate, attrs) do
    haulage_rate
    |> HaulageRate.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a haulage_rate.

  ## Examples

      iex> delete_haulage_rate(haulage_rate)
      {:ok, %HaulageRate{}}

      iex> delete_haulage_rate(haulage_rate)
      {:error, %Ecto.Changeset{}}

  """
  def delete_haulage_rate(%HaulageRate{} = haulage_rate) do
    Repo.delete(haulage_rate)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking haulage_rate changes.

  ## Examples

      iex> change_haulage_rate(haulage_rate)
      %Ecto.Changeset{data: %HaulageRate{}}

  """
  def change_haulage_rate(%HaulageRate{} = haulage_rate, attrs \\ %{}) do
    HaulageRate.changeset(haulage_rate, attrs)
  end

  def haulage_fee_lookup(admin, direction, date) do
    HaulageRate
    |> where(
      [a],
      a.admin_id == ^admin and a.status == "A" and
        fragment("CAST(? AS DATE) >= ?", ^date, a.start_date) and
        (a.rate_type == "RATIO" or (a.rate_type == "PER_KM" and a.category == ^direction))
    )
    |> order_by([a], desc: [a.id])
    |> limit(1)
    |> Repo.one()
  end
end
