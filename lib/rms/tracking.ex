defmodule Rms.Tracking do
  @moduledoc """
  The Tracking context.
  """

  import Ecto.Query, warn: false
  alias Rms.Repo

  alias Rms.Tracking.WagonTracking
  alias Rms.SystemUtilities.Region
  alias Rms.SystemUtilities.Wagon

  @doc """
  Returns the list of tbl_wagon_tracking.

  ## Examples

      iex> list_tbl_wagon_tracking()
      [%WagonTracking{}, ...]

  """
  def list_tbl_wagon_tracking do
    Repo.all(WagonTracking)
  end

  @doc """
  Gets a single wagon_tracking.

  Raises `Ecto.NoResultsError` if the Wagon tracking does not exist.

  ## Examples

      iex> get_wagon_tracking!(123)
      %WagonTracking{}

      iex> get_wagon_tracking!(456)
      ** (Ecto.NoResultsError)

  """
  def get_wagon_tracking!(id), do: Repo.get!(WagonTracking, id)

  @doc """
  Creates a wagon_tracking.

  ## Examples

      iex> create_wagon_tracking(%{field: value})
      {:ok, %WagonTracking{}}

      iex> create_wagon_tracking(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_wagon_tracking(attrs \\ %{}) do
    %WagonTracking{}
    |> WagonTracking.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a wagon_tracking.

  ## Examples

      iex> update_wagon_tracking(wagon_tracking, %{field: new_value})
      {:ok, %WagonTracking{}}

      iex> update_wagon_tracking(wagon_tracking, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_wagon_tracking(%WagonTracking{} = wagon_tracking, attrs) do
    wagon_tracking
    |> WagonTracking.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a wagon_tracking.

  ## Examples

      iex> delete_wagon_tracking(wagon_tracking)
      {:ok, %WagonTracking{}}

      iex> delete_wagon_tracking(wagon_tracking)
      {:error, %Ecto.Changeset{}}

  """
  def delete_wagon_tracking(%WagonTracking{} = wagon_tracking) do
    Repo.delete(wagon_tracking)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking wagon_tracking changes.

  ## Examples

      iex> change_wagon_tracking(wagon_tracking)
      %Ecto.Changeset{data: %WagonTracking{}}

  """
  def change_wagon_tracking(%WagonTracking{} = wagon_tracking, attrs \\ %{}) do
    WagonTracking.changeset(wagon_tracking, attrs)
  end

  alias Rms.Tracking.Interchange

  @doc """
  Returns the list of tbl_interchange.

  ## Examples

      iex> list_tbl_interchange()
      [%Interchange{}, ...]

  """
  def list_tbl_interchange do
    Repo.all(Interchange)
  end

  @doc """
  Gets a single interchange.

  Raises `Ecto.NoResultsError` if the Interchange does not exist.

  ## Examples

      iex> get_interchange!(123)
      %Interchange{}

      iex> get_interchange!(456)
      ** (Ecto.NoResultsError)

  """
  def get_interchange!(id), do: Repo.get!(Interchange, id)

  @doc """
  Creates a interchange.

  ## Examples

      iex> create_interchange(%{field: value})
      {:ok, %Interchange{}}

      iex> create_interchange(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_interchange(attrs \\ %{}) do
    %Interchange{}
    |> Interchange.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a interchange.

  ## Examples

      iex> update_interchange(interchange, %{field: new_value})
      {:ok, %Interchange{}}

      iex> update_interchange(interchange, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_interchange(%Interchange{} = interchange, attrs) do
    interchange
    |> Interchange.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a interchange.

  ## Examples

      iex> delete_interchange(interchange)
      {:ok, %Interchange{}}

      iex> delete_interchange(interchange)
      {:error, %Ecto.Changeset{}}


  """
  def delete_interchange(%Interchange{} = interchange) do
    Repo.delete(interchange)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking interchange changes.

  ## Examples

      iex> change_interchange(interchange)
      %Ecto.Changeset{data: %Interchange{}}

  """
  def change_interchange(%Interchange{} = interchange, attrs \\ %{}) do
    Interchange.changeset(interchange, attrs)
  end

  def list_region_with_country_details do
    Region
    # |> where([a], a.id == ^id)
    |> join(:left, [a], c in Rms.SystemUtilities.Country, on: a.id == c.region_id)
    |> select([a, c], %{
      region_id: c.region_id,
      code: c.code,
      region_description: a.description
    })
    |> order_by(desc: :id)
    |> Repo.all()
  end

  def list_wagon_tracker_with_id(id) do
    WagonTracking
    |> where([a], a.id == ^id)
    |> join(:left, [a], b in Rms.SystemUtilities.Wagon, on: a.wagon_id == b.id)
    |> join(:left, [a, b], c in Rms.SystemUtilities.WagonType, on: b.wagon_type_id == c.id)
    |> join(:left, [a, b, _c], d in Rms.Accounts.RailwayAdministrator, on: b.owner_id == d.id)
    |> join(:left, [a, b, _c, _d], e in Rms.SystemUtilities.Station, on: a.destination_id == e.id)
    |> join(:left, [a, b, _c, _d, _e], f in Rms.SystemUtilities.Station, on: a.origin_id == f.id)
    |> join(:left, [a, b, _c, _d, _e, _f], g in Rms.SystemUtilities.Station,
      on: a.current_location_id == g.id
    )
    |> join(:left, [a, b, _c, _d, _e, _f, _g], k in Rms.SystemUtilities.Commodity,
      on: a.commodity_id == k.id
    )
    |> join(:left, [a, b, _c, _d, _e, _f, _g, _k], l in Rms.Accounts.Clients,
      on: a.customer_id == l.id
    )
    |> join(:left, [a, b, _c, _d, _e, _f, _g, _k, _l], m in Rms.SystemUtilities.Condition,
      on: a.condition_id == m.id
    )
    |> join(:left, [a, b, _c, _d, _e, _f, _g, _k, _l, _m], n in Rms.SystemUtilities.Status,
      on: a.departure == n.id
    )
    |> join(:left, [a, b, _c, _d, _e, _f, _g, _k, _l, _m, n], j in Rms.SystemUtilities.Defect,
      on: a.defect_id == j.id
    )
    |> join(:left, [a, b, _c, d, _e, _f, _g, _k, _l, _m, n, j], o in Rms.SystemUtilities.Country,
      on: d.country == o.code
    )
    |> join(
      :left,
      [a, b, _c, d, _e, _f, _g, _k, _l, _m, n, j, o],
      q in Rms.SystemUtilities.Region,
      on: o.region_id == q.id
    )
    |> join(
      :left,
      [a, b, _c, d, _e, _f, _g, k, _l, _m, n, j, o, q],
      r in Rms.SystemUtilities.CommodityGroup,
      on: k.com_group_id == r.id
    )
    |> join(
      :left,
      [a, b, _c, d, _e, _f, _g, k, _l, _m, n, j, o, q, r],
      s in Rms.SystemUtilities.Domain,
      on: a.domain_id == s.id
    )
    |> select([a, b, c, d, e, f, g, k, l, m, n, j, o, q, r, s], %{
      #  |> select([a, b, c, d, e, f, g, k, l, m, n, j, o], %{
      id: a.id,
      region_id: o.region_id,
      region_description: q.description,
      domain_description: s.description,
      update_date: a.update_date,
      departure: a.departure,
      arrival: a.arrival,
      train_no: a.train_no,
      yard_siding: a.yard_siding,
      sub_category: a.sub_category,
      comment: a.comment,
      net_ton: a.net_ton,
      bound: a.bound,
      allocated_to_customer: a.allocated_to_customer,
      wagon_id: a.wagon_id,
      wagon_status_description: n.description,
      current_location_id: a.current_location_id,
      commodity_id: a.commodity_id,
      commodity_description: k.description,
      current_location: g.description,
      condition_description: m.description,
      customer_id: a.customer_id,
      client_name: l.client_name,
      origin_id: a.origin_id,
      origin_station: e.description,
      destination_id: a.destination_id,
      destination_station: e.description,
      maker_id: a.maker_id,
      checker_id: a.checker_id,
      inserted_at: a.inserted_at,
      updated_at: a.updated_at,
      month: a.month,
      origin_station: f.description,
      commodity: k.description,
      commodity_group: r.description,
      dest_station: e.description,
      wagon_status: a.id,
      year: a.year,
      wagon_code: b.code,
      wagon_type: c.description,
      wagon_defect: j.description,
      wagon: b.id,
      wagon_symbol: b.wagon_symbol,
      days_at: a.days_at,
      on_hire: a.on_hire,
      country_code: o.code,
      wagon_owner: d.description,
      total_accum_days: a.total_accum_days,
      wagon_type: c.description
    })
    |> Repo.one()
  end

  def list_wagon_tracker_lookup_by_train(train_no) do
    WagonTracking
    |> where([a], a.train_no == ^train_no)
    |> join(:left, [a], b in Rms.SystemUtilities.Wagon, on: a.wagon_id == b.id)
    |> join(:left, [a, b], c in Rms.SystemUtilities.WagonType, on: b.wagon_type_id == c.id)
    |> join(:left, [a, b, _c], d in Rms.Accounts.RailwayAdministrator, on: b.owner_id == d.id)
    |> join(:left, [a, b, _c, _d], e in Rms.SystemUtilities.Station, on: a.destination_id == e.id)
    |> join(:left, [a, b, _c, _d, _e], f in Rms.SystemUtilities.Station, on: a.origin_id == f.id)
    |> join(:left, [a, b, _c, _d, _e, _f], g in Rms.SystemUtilities.Station,
      on: a.current_location_id == g.id
    )
    |> join(:left, [a, b, _c, _d, _e, _f, _g], k in Rms.SystemUtilities.Commodity,
      on: a.commodity_id == k.id
    )
    |> join(:left, [a, b, _c, _d, _e, _f, _g, _k], l in Rms.Accounts.Clients,
      on: a.customer_id == l.id
    )
    |> join(:left, [a, b, _c, _d, _e, _f, _g, _k, _l], m in Rms.SystemUtilities.Condition,
      on: a.condition_id == m.id
    )
    |> join(:left, [a, b, _c, _d, _e, _f, _g, _k, _l, _m], n in Rms.SystemUtilities.Status,
      on: a.departure == n.id
    )
    |> join(:left, [a, b, _c, _d, _e, _f, _g, _k, _l, _m, n], j in Rms.SystemUtilities.Defect,
      on: a.defect_id == j.id
    )
    |> join(:left, [a, b, _c, d, _e, _f, _g, _k, _l, _m, n, j], o in Rms.SystemUtilities.Country,
      on: d.country == o.code
    )
    |> join(
      :left,
      [a, b, _c, d, _e, _f, _g, _k, _l, _m, n, j, o],
      q in Rms.SystemUtilities.Region,
      on: o.region_id == q.id
    )
    |> join(
      :left,
      [a, b, _c, d, _e, _f, _g, k, _l, _m, n, j, o, q],
      r in Rms.SystemUtilities.CommodityGroup,
      on: k.com_group_id == r.id
    )
    |> join(
      :left,
      [a, b, _c, d, _e, _f, _g, k, _l, _m, n, j, o, q, r],
      s in Rms.SystemUtilities.Domain,
      on: a.domain_id == s.id
    )
    |> where(
      [a, b, c, d, e, f, g, k, l, m, n, j, o, q, r, s],
      a.id in subquery(
        from(t in WagonTracking,
          where: not is_nil(t.train_no),
          group_by: [t.train_no, t.wagon_id],
          select: max(t.id)
        )
      )
    )
    |> order_by([a, b, c, d, e, f, g, k, l, m, n, j, o, q, r, s], desc: a.inserted_at)
    |> select([a, b, c, d, e, f, g, k, l, m, n, j, o, q, r, s], %{
      id: a.id,
      region_id: o.region_id,
      region_description: q.description,
      domain_description: s.description,
      update_date: a.update_date,
      departure: a.departure,
      arrival: a.arrival,
      train_no: a.train_no,
      yard_siding: a.yard_siding,
      sub_category: a.sub_category,
      comment: a.comment,
      net_ton: a.net_ton,
      bound: a.bound,
      allocated_to_customer: a.allocated_to_customer,
      wagon_id: a.wagon_id,
      wagon_status_description: n.description,
      wagon_curent_stat_pur_code: n.pur_code,
      current_location_id: a.current_location_id,
      commodity_id: a.commodity_id,
      commodity_name: k.description,
      current_location: g.description,
      condition_description: m.description,
      customer_id: a.customer_id,
      customer_name: l.client_name,
      origin_id: a.origin_id,
      origin_name: f.description,
      destination_id: a.destination_id,
      origin_station_id: a.origin_id,
      destination_station_id: a.destination_id,
      destination_name: e.description,
      maker_id: a.maker_id,
      month: a.month,
      domain_id: a.domain_id,
      wagon_status: a.id,
      year: a.year,
      wagon_code: b.code,
      wagon_type: c.description,
      wagon_defect: j.description,
      wagon: b.id,
      wagon_symbol: b.wagon_symbol,
      days_at: a.days_at,
      on_hire: a.on_hire,
      country_code: o.code,
      wagon_owner: d.code,
      wagon_type: c.description,
      condition_id: a.condition_id
    })
    |> Repo.all()
  end

  def wagon_tracker_lookup_by_train(train_no) do
    WagonTracking
    |> where([a], a.train_no == ^train_no)
    |> join(:left, [a], b in Rms.SystemUtilities.Wagon, on: a.wagon_id == b.id)
    |> join(:left, [a, b], c in Rms.SystemUtilities.WagonType, on: b.wagon_type_id == c.id)
    |> join(:left, [a, b, _c], d in Rms.Accounts.RailwayAdministrator, on: b.owner_id == d.id)
    |> join(:left, [a, b, _c, _d], e in Rms.SystemUtilities.Station, on: a.destination_id == e.id)
    |> join(:left, [a, b, _c, _d, _e], f in Rms.SystemUtilities.Station, on: a.origin_id == f.id)
    |> join(:left, [a, b, _c, _d, _e, _f], g in Rms.SystemUtilities.Station,
      on: a.current_location_id == g.id
    )
    |> join(:left, [a, b, _c, _d, _e, _f, _g], k in Rms.SystemUtilities.Commodity,
      on: a.commodity_id == k.id
    )
    |> join(:left, [a, b, _c, _d, _e, _f, _g, _k], l in Rms.Accounts.Clients,
      on: a.customer_id == l.id
    )
    |> join(:left, [a, b, _c, _d, _e, _f, _g, _k, _l], m in Rms.SystemUtilities.Condition,
      on: a.condition_id == m.id
    )
    |> join(:left, [a, b, _c, _d, _e, _f, _g, _k, _l, _m], n in Rms.SystemUtilities.Status,
      on: a.departure == n.id
    )
    |> join(:left, [a, b, _c, _d, _e, _f, _g, _k, _l, _m, n], j in Rms.SystemUtilities.Defect,
      on: a.defect_id == j.id
    )
    |> join(:left, [a, b, _c, d, _e, _f, _g, _k, _l, _m, n, j], o in Rms.SystemUtilities.Country,
      on: d.country == o.code
    )
    |> join(
      :left,
      [a, b, _c, d, _e, _f, _g, _k, _l, _m, n, j, o],
      q in Rms.SystemUtilities.Region,
      on: o.region_id == q.id
    )
    |> join(
      :left,
      [a, b, _c, d, _e, _f, _g, k, _l, _m, n, j, o, q],
      r in Rms.SystemUtilities.CommodityGroup,
      on: k.com_group_id == r.id
    )
    |> join(
      :left,
      [a, b, _c, d, _e, _f, _g, k, _l, _m, n, j, o, q, r],
      s in Rms.SystemUtilities.Domain,
      on: a.domain_id == s.id
    )
    |> where(
      [a, b, c, d, e, f, g, k, l, m, n, j, o, q, r, s],
      a.id in subquery(
        from(t in WagonTracking,
          where: not is_nil(t.train_no),
          group_by: [t.train_no, t.wagon_id],
          select: max(t.id)
        )
      )
    )
    |> order_by([a, b, c, d, e, f, g, k, l, m, n, j, o, q, r, s], desc: a.inserted_at)
    |> select([a, b, c, d, e, f, g, k, l, m, n, j, o, q, r, s], %{
      id: a.id,
      region_id: o.region_id,
      region_description: q.description,
      domain_description: s.description,
      update_date: a.update_date,
      departure: a.departure,
      arrival: a.arrival,
      train_no: a.train_no,
      yard_siding: a.yard_siding,
      sub_category: a.sub_category,
      bound: a.bound,
      allocated_to_customer: a.allocated_to_customer,
      wagon_id: a.wagon_id,
      wagon_status_description: n.description,
      wagon_curent_stat_pur_code: n.pur_code,
      current_location_id: a.current_location_id,
      commodity_id: a.commodity_id,
      commodity_name: k.description,
      current_location: g.description,
      condition_description: m.description,
      customer_id: a.customer_id,
      customer_name: l.client_name,
      origin_id: a.origin_id,
      origin_name: f.description,
      destination_id: a.destination_id,
      origin_station_id: a.origin_id,
      destination_station_id: a.destination_id,
      destination_name: e.description,
      maker_id: a.maker_id,
      domain_id: a.domain_id,
      wagon_status: a.id,
      wagon_code: b.code,
      wagon_type: c.description,
      wagon_defect: j.description,
      wagon: b.id,
      wagon_symbol: b.wagon_symbol,
      days_at: a.days_at,
      on_hire: a.on_hire,
      country_code: o.code,
      wagon_owner: d.code,
      wagon_type: c.description,
      condition_id: a.condition_id
    })
    |> Repo.all()
  end

  def get_all_wagon_position(search_params, page, size, _user) do
    Rms.SystemUtilities.Wagon
    |> where([a], not is_nil(a.wagon_status_id) and not is_nil(a.domain_id))
    |> join(:left, [a], b in Rms.SystemUtilities.Status, on: a.wagon_status_id == b.id)
    |> join(:left, [a, b], c in Rms.SystemUtilities.Domain, on: a.domain_id == c.id)
    |> order_by([a, b, c], desc: [c.description, b.code])
    |> handle_position_report_filter(search_params)
    |> get_wagon_tracker_grouped_by_domain()
    |> Repo.paginate(page: page, page_size: size)
  end

  def get_all_wagon_position(_source, search_params, _user) do
    Rms.SystemUtilities.Wagon
    |> where([a], not is_nil(a.wagon_status_id) and not is_nil(a.domain_id))
    |> join(:left, [a], b in Rms.SystemUtilities.Status, on: a.wagon_status_id == b.id)
    |> join(:left, [a, b], c in Rms.SystemUtilities.Domain, on: a.domain_id == c.id)
    |> order_by([a, b, c], desc: [c.description, b.code])
    |> handle_position_report_filter(search_params)
    |> get_wagon_tracker_grouped_by_domain()
  end

  defp handle_position_report_filter(query, %{"isearch" => search_term} = search_params)
       when search_term == "" or is_nil(search_term) do
    query
    |> handle_domain_filter(search_params)
    |> handle_wagon_status_filter(search_params)
    |> handle_postion_date_filter(search_params)
  end

  defp handle_position_report_filter(query, %{"isearch" => search_term}) do
    search_term = "%#{search_term}%"
    compose_position_isearch_filter(query, search_term)
  end

  defp handle_domain_filter(query, %{"domain_ids" => domain_ids})
       when domain_ids == "" or is_nil(domain_ids),
       do: query

  defp handle_domain_filter(query, %{"domain_ids" => domain_ids}) do
    where(query, [a, b, c], a.domain_id == ^domain_ids)
  end

  defp handle_wagon_status_filter(query, %{"wagon_status_ids" => wagon_status_ids})
       when wagon_status_ids == "" or is_nil(wagon_status_ids),
       do: query

  defp handle_wagon_status_filter(query, %{"wagon_status_ids" => wagon_status_ids}) do
    where(query, [a, b, c], a.wagon_status_id == ^wagon_status_ids)
  end

  defp handle_postion_date_filter(query, %{"from" => from, "to" => to})
       when byte_size(from) > 0 and byte_size(to) > 0 do
    query
    |> where(
      [a],
      fragment("CAST(? AS DATE) >= ?", a.inserted_at, ^from) and
        fragment("CAST(? AS DATE) <= ?", a.inserted_at, ^to)
    )
  end

  defp handle_postion_date_filter(query, _params), do: query

  defp compose_position_isearch_filter(query, search_term) do
    query
    |> where(
      [a, b, c, d],
      fragment("lower(?) LIKE lower(?)", c.description, ^search_term) or
        fragment("lower(?) LIKE lower(?)", b.description, ^search_term)
    )
  end

  def get_wagon_tracker_grouped_by_domain(query) do
    query
    |> group_by([a, b, c], [a.wagon_symbol, b.code, c.description])
    |> select([a, b, c], %{
      count: count(a.id),
      status: b.code,
      domain: c.description,
      wagon_symbol: a.wagon_symbol
    })
  end

  def ready() do
    Wagon
    |> where([uA], uA.status == "A" and uA.wagon_symbol == "i")
    |> select([uA], %{
      id: uA.id,
      wagon_symbol: uA.wagon_symbol
    })
    |> limit(1)
    |> Repo.one()
  end

  def period_days(days_at) when days_at < 1, do: "Less than 1 day"

  def period_days(days_at) do
    Timex.Duration.from_days(days_at) |> Timex.Format.Duration.Formatters.Humanized.format()
  end

  def list_wagon_tracker_with_wagon_id do
    WagonTracking
    |> group_by([a], a.wagon_id)
    |> select([a], max(a.id))
    |> Repo.all()
  end

  alias Rms.Tracking.Interchange

  def get_interchange_batch_by_uuid(uuid, status) do
    Interchange
    |> where([a], a.uuid == ^uuid and a.auth_status == ^status)
    |> join(:left, [a], b in Rms.SystemUtilities.Wagon, on: a.wagon_id == b.id)
    |> join(:left, [a, b], c in Rms.SystemUtilities.WagonType, on: b.wagon_type_id == c.id)
    |> join(:left, [a, b, _c], d in Rms.Accounts.RailwayAdministrator, on: b.owner_id == d.id)
    |> join(:left, [a, b, _c, _d], e in Rms.Accounts.RailwayAdministrator,
      on: a.adminstrator_id == e.id
    )
    |> join(:left, [a, _b, _c, _d, _e], f in Rms.SystemUtilities.Station,
      on: a.interchange_point == f.id
    )
    |> join(:left, [a, _b, _c, _d, _e, _f], g in Rms.Locomotives.Locomotive,
      on: a.locomotive_id == g.id
    )
    |> join(:left, [a, _b, _c, _d, _e, _f, _g], h in Rms.SystemUtilities.Status,
      on: a.wagon_status_id == h.id
    )
    |> join(:left, [a, _b, _c, _d, _e, _f, _g, _h], i in Rms.SystemUtilities.InterchangeFee,
      on: a.interchange_fee_id == i.id
    )
    |> join(:left, [a, _b, _c, _d, _e, _f, _g, _h, _i], j in Rms.SystemUtilities.Commodity,
      on: a.commodity_id == j.id
    )
    |> select([a, b, c, d, e, f, g, h, i, j], %{
      id: a.id,
      uuid: a.uuid,
      wagon_id: a.wagon_id,
      commodity_id: a.commodity_id,
      wagon_owner: d.description,
      wagon_code: d.description,
      wagon_type: c.description,
      maker_id: a.maker_id,
      checker_id: a.checker_id,
      inserted_at: a.inserted_at,
      updated_at: a.updated_at,
      commodity: j.code,
      comment: a.comment,
      direction: a.direction,
      status: a.status,
      entry_date: a.entry_date,
      exit_date: a.exit_date,
      accumulative_days: a.accumulative_days,
      accumulative_amount: a.accumulative_amount,
      interchange_fee: a.interchange_fee,
      wagon_id: a.wagon_id,
      wagon: b.description,
      wagon_status_id: a.wagon_status_id,
      wagon_status: h.description,
      commodity_id: a.commodity_id,
      adminstrator_id: a.adminstrator_id,
      administrator: e.description,
      interchange_point: a.interchange_point,
      interchange_pt: f.description,
      interchange_fee_id: a.interchange_fee_id,
      locomotive_id: a.locomotive_id,
      total_accum_days: a.total_accum_days,
      rate: a.rate,
      locomotive: g.description
    })
    |> Repo.all()
  end

  def on_hire_interchange_entries_lookup(train_no, auth_status, direction) do
    Interchange
    |> where(
      [a],
      a.train_no == ^train_no and a.auth_status == ^auth_status and a.direction == ^direction
    )
    |> join(:left, [a], b in Rms.SystemUtilities.Wagon, on: a.wagon_id == b.id)
    |> join(:left, [a, b], c in Rms.SystemUtilities.WagonType, on: b.wagon_type_id == c.id)
    |> join(:left, [a, b, c], d in Rms.Accounts.RailwayAdministrator, on: b.owner_id == d.id)
    |> join(:left, [a, b, c, d], e in Rms.Accounts.RailwayAdministrator,
      on: a.adminstrator_id == e.id
    )
    |> join(:left, [a, b, c, d, e], f in Rms.SystemUtilities.Station,
      on: a.interchange_point == f.id
    )
    |> join(:left, [a, b, c, d, e, f], g in Rms.SystemUtilities.Station,
      on: a.origin_station_id == g.id
    )
    |> join(:left, [a, b, c, d, e, f, g], h in Rms.SystemUtilities.Station,
      on: a.destination_station_id == h.id
    )
    |> join(:left, [a, b, c, d, e, f, g, h], i in Rms.SystemUtilities.Commodity,
      on: a.commodity_id == i.id
    )
    |> where(
      [a, b, c, d, e, f, g, h, i],
      a.id in subquery(
        from(t in Interchange,
          where: not is_nil(t.train_no),
          group_by: [t.train_no, t.wagon_id],
          select: max(t.id)
        )
      )
    )
    |> select([a, b, c, d, e, f, g, h, i], %{
      id: a.id,
      origin_station_id: a.origin_station_id,
      origin_name: g.description,
      commodity_id: a.commodity_id,
      commodity_name: i.description,
      destination_name: h.description,
      wagon_id: a.wagon_id,
      checker_id: a.checker_id,
      comment: a.comment,
      wagon_owner: d.code,
      wagon_type: c.description,
      wagon_code: b.code,
      interchange_point: a.interchange_point,
      interchange_pt: f.description,
      adminstrator_id: a.adminstrator_id,
      administrator: e.code,
      admin_id: a.adminstrator_id,
      lease_period: a.lease_period,
      off_hire_date: a.off_hire_date,
      accumulative_amount: a.accumulative_amount,
      accumulative_days: a.accumulative_days,
      direction: a.direction,
      auth_status: a.auth_status,
      entry_date: a.entry_date,
      exit_date: a.exit_date,
      interchange_fee: a.interchange_fee,
      destination_station_id: a.destination_station_id,
      train_no: a.train_no,
      total_accum_days: a.total_accum_days,
      rate: a.rate,
      on_hire_date: a.on_hire_date
    })
    |> Repo.all()
  end

  def interchange_entry_lookup(train_no, auth_status, status) do
    Interchange
    |> where(
      [a],
      a.train_no == ^train_no and a.auth_status == ^auth_status and a.status == ^status
    )
    |> join(:left, [a], b in Rms.SystemUtilities.Wagon, on: a.wagon_id == b.id)
    |> join(:left, [a, b], c in Rms.SystemUtilities.WagonType, on: b.wagon_type_id == c.id)
    |> join(:left, [a, b, _c], d in Rms.Accounts.RailwayAdministrator, on: b.owner_id == d.id)
    |> join(:left, [a, b, _c, _d], e in Rms.Accounts.RailwayAdministrator,
      on: a.adminstrator_id == e.id
    )
    |> join(:left, [a, _b, _c, _d, _e], f in Rms.SystemUtilities.Station,
      on: a.interchange_point == f.id
    )
    |> join(:left, [a, _b, _c, _d, _e, _f], g in Rms.Locomotives.Locomotive,
      on: a.locomotive_id == g.id
    )
    |> join(:left, [a, _b, _c, _d, _e, _f, _g], h in Rms.SystemUtilities.Status,
      on: a.wagon_status_id == h.id
    )
    |> join(:left, [a, _b, _c, _d, _e, _f, _g, _h], i in Rms.SystemUtilities.InterchangeFee,
      on: a.interchange_fee_id == i.id
    )
    |> join(:left, [a, _b, _c, _d, _e, _f, _g, _h, _i], j in Rms.SystemUtilities.Commodity,
      on: a.commodity_id == j.id
    )
    |> where(
      [a, b, c, d, e, f, g, h, i, j],
      a.id in subquery(
        from(t in Interchange,
          where: not is_nil(t.train_no),
          group_by: [t.train_no, t.wagon_id],
          select: max(t.id)
        )
      )
    )
    |> select([a, b, c, d, e, f, g, h, i, j], %{
      id: a.id,
      uuid: a.uuid,
      wagon_id: a.wagon_id,
      auth_status: a.auth_status,
      commodity_id: a.commodity_id,
      wagon_owner: d.description,
      wagon_code: d.description,
      wagon_type: c.description,
      maker_id: a.maker_id,
      checker_id: a.checker_id,
      inserted_at: a.inserted_at,
      updated_at: a.updated_at,
      commodity: j.code,
      comment: a.comment,
      direction: a.direction,
      status: a.status,
      entry_date: a.entry_date,
      exit_date: a.exit_date,
      accumulative_days: a.accumulative_days,
      accumulative_amount: a.accumulative_amount,
      interchange_fee: a.interchange_fee,
      wagon_id: a.wagon_id,
      wagon: b.description,
      wagon_status_id: a.wagon_status_id,
      wagon_status: h.description,
      adminstrator_id: a.adminstrator_id,
      on_hire_date: a.on_hire_date,
      train_no: a.train_no,
      administrator: e.description,
      interchange_point: a.interchange_point,
      interchange_pt: f.description,
      interchange_fee_id: a.interchange_fee_id,
      locomotive_id: a.locomotive_id,
      total_accum_days: a.total_accum_days,
      rate: a.rate,
      locomotive: g.description
    })
    |> limit(1)
    |> Repo.one()
  end

  def get_interchange_by_uuid(uuid) do
    Interchange
    |> where([a], a.uuid == ^uuid)
    |> Repo.all()
  end

  def interchange_on_hire_batch(direction) do
    Interchange
    |> where(
      [a],
      a.auth_status == "APPROVED" and a.status == "ON_HIRE" and a.direction == ^direction
    )
    |> join(:left, [a], b in Rms.SystemUtilities.Wagon, on: a.wagon_id == b.id)
    |> join(:left, [a, b], c in Rms.SystemUtilities.WagonType, on: b.wagon_type_id == c.id)
    |> join(:left, [a, b, _c], d in Rms.Accounts.RailwayAdministrator, on: b.owner_id == d.id)
    |> join(:left, [a, b, _c, _d], e in Rms.Accounts.RailwayAdministrator,
      on: a.adminstrator_id == e.id
    )
    |> join(:left, [a, _b, _c, _d, _e], f in Rms.SystemUtilities.Station,
      on: a.interchange_point == f.id
    )
    |> join(:left, [a, _b, _c, _d, _e, _f], g in Rms.Locomotives.Locomotive,
      on: a.locomotive_id == g.id
    )
    |> join(:left, [a, _b, _c, _d, _e, _f, _g], h in Rms.SystemUtilities.Status,
      on: a.wagon_status_id == h.id
    )
    |> join(:left, [a, _b, _c, _d, _e, _f, _g, _h], i in Rms.SystemUtilities.InterchangeFee,
      on: a.interchange_fee_id == i.id
    )
    |> join(:left, [a, _b, _c, _d, _e, _f, _g, _h, _i], j in Rms.SystemUtilities.Commodity,
      on: a.commodity_id == j.id
    )
    |> order_by([a, _b, _c, _d, _e, _f, _g, _h, _i, _j],
      desc: a.adminstrator_id,
      desc: a.entry_date,
      desc: a.exit_date,
      desc: a.direction,
      desc: a.commodity_id,
      desc: a.interchange_point
    )
    |> where(
      [a, b, c, d, e, f, g, h, i, j],
      a.id in subquery(
        from(t in Interchange,
          where: not is_nil(t.train_no),
          group_by: [t.train_no],
          select: max(t.id)
        )
      )
    )
    |> select([a, b, c, d, e, f, g, h, i, j], %{
      id: a.id,
      uuid: a.uuid,
      wagon_id: a.wagon_id,
      commodity_id: a.commodity_id,
      wagon_owner: d.description,
      wagon_code: d.description,
      wagon_type: c.description,
      maker_id: a.maker_id,
      checker_id: a.checker_id,
      inserted_at: a.inserted_at,
      updated_at: a.updated_at,
      commodity: j.code,
      auth_status: a.auth_status,
      comment: a.comment,
      direction: a.direction,
      status: a.status,
      entry_date: a.entry_date,
      exit_date: a.exit_date,
      accumulative_days: a.accumulative_days,
      accumulative_amount: a.accumulative_amount,
      interchange_fee: a.interchange_fee,
      wagon_id: a.wagon_id,
      wagon: b.description,
      wagon_status_id: a.wagon_status_id,
      wagon_status: h.description,
      commodity_id: a.commodity_id,
      adminstrator_id: a.adminstrator_id,
      administrator: e.description,
      interchange_point: a.interchange_point,
      interchange_pt: f.description,
      interchange_fee_id: a.interchange_fee_id,
      locomotive_id: a.locomotive_id,
      locomotive: g.description,
      total_accum_days: a.total_accum_days,
      rate: a.rate,
      train_no: a.train_no
    })
    |> Repo.all()
  end

  def get_interchange_on_hire_by_uuid(uuid) do
    Interchange
    |> where([a], a.uuid == ^uuid and a.status == "ON_HIRE" and a.auth_status == "APPROVED")
    |> Repo.all()
  end

  def list_interchange_on_hire() do
    Interchange
    |> where(
      [a],
      a.status in ["ON_HIRE"] and a.auth_status == "APPROVED" and
        not is_nil(a.train_no)
    )
    |> where(
      [a],
      a.id in subquery(
        from(t in Interchange,
          where: not is_nil(t.train_no),
          group_by: [t.train_no, t.wagon_id],
          select: max(t.id)
        )
      )
    )
    |> Repo.all()
  end

  def list_interchange_on_hire_emailing() do
    Interchange
    |> where(
      [a],
      a.status in ["ON_HIRE"] and a.auth_status == "APPROVED" and not is_nil(a.train_no)
    )
    |> join(:left, [a], b in Rms.SystemUtilities.Wagon, on: a.wagon_id == b.id)
    |> join(:left, [a, b], c in Rms.SystemUtilities.WagonType, on: b.wagon_type_id == c.id)
    |> join(:left, [a, b, _c], d in Rms.Accounts.RailwayAdministrator, on: b.owner_id == d.id)
    |> join(:left, [a, b, _c, _d], e in Rms.Accounts.RailwayAdministrator,
      on: a.adminstrator_id == e.id
    )
    |> join(:left, [a, _b, _c, _d, _e], f in Rms.SystemUtilities.Station,
      on: a.interchange_point == f.id
    )
    |> join(:left, [a, _b, _c, _d, _e, _f], g in Rms.Locomotives.Locomotive,
      on: a.locomotive_id == g.id
    )
    |> join(:left, [a, _b, _c, _d, _e, _f, _g], h in Rms.SystemUtilities.Status,
      on: a.wagon_status_id == h.id
    )
    |> join(:left, [a, _b, _c, _d, _e, _f, _g, _h], i in Rms.SystemUtilities.InterchangeFee,
      on: a.interchange_fee_id == i.id
    )
    |> join(:left, [a, _b, _c, _d, _e, _f, _g, _h, _i], j in Rms.SystemUtilities.Commodity,
      on: a.commodity_id == j.id
    )
    |> join(:left, [a, _b, _c, _d, _e, _f, _g, _h, _i, _j], k in Rms.SystemUtilities.Station,
      on: a.origin_station_id == k.id
    )
    |> join(:left, [a, _b, _c, _d, _e, _f, _g, _h, _i, _j, _k], l in Rms.SystemUtilities.Station,
      on: a.destination_station_id == l.id
    )
    |> where(
      [a, _b, _c, _d, _e, _f, _g, _h, _i, _j, _k, _l],
      a.id in subquery(
        from(t in Interchange,
          where: not is_nil(t.train_no),
          group_by: [t.train_no, t.wagon_id],
          select: max(t.id)
        )
      )
    )
    |> select([a, b, c, d, e, f, g, h, i, j, k, l], %{
      id: a.id,
      wagon_id: a.wagon_id,
      checker_id: a.checker_id,
      comment: a.comment,
      wagon_owner: d.code,
      wagon_type: c.description,
      wagon_code: b.code,
      interchange_point: a.interchange_point,
      interchange_pt: f.description,
      adminstrator_id: a.adminstrator_id,
      administrator: e.code,
      commodity_id: a.commodity_id,
      uuid: a.uuid,
      train_no: a.train_no,
      admin_id: a.adminstrator_id,
      lease_period: a.lease_period,
      off_hire_date: a.off_hire_date,
      on_hire_date: a.on_hire_date,
      accumulative_amount: a.accumulative_amount,
      accumulative_days: a.accumulative_days,
      entry_date: a.entry_date,
      exit_date: a.exit_date,
      direction: a.direction,
      origin_station_id: a.origin_station_id,
      destination_station_id: a.origin_station_id,
      origin: k.description,
      rate: a.rate,
      destination: l.description,
      total_accum_days: a.total_accum_days,
      commodity: j.description
    })
    |> Repo.all()
  end

  def interchange_off_hire_report_lookup(search_params, page, size, _user) do
    Interchange
    |> where([a], a.auth_status == "COMPLETE" and a.status in ["OFF_HIRE", "ON_HIRE"])
    |> join(:left, [a], b in Rms.SystemUtilities.Wagon, on: a.wagon_id == b.id)
    |> join(:left, [a, b], c in Rms.SystemUtilities.WagonType, on: b.wagon_type_id == c.id)
    |> join(:left, [a, b, _c], d in Rms.Accounts.RailwayAdministrator, on: b.owner_id == d.id)
    |> join(:left, [a, b, _c, _d], e in Rms.Accounts.RailwayAdministrator,
      on: a.adminstrator_id == e.id
    )
    |> join(:left, [a, _b, _c, _d, _e], f in Rms.SystemUtilities.Station,
      on: a.interchange_point == f.id
    )
    |> join(:left, [a, _b, _c, _d, _e, _f], g in Rms.Locomotives.Locomotive,
      on: a.locomotive_id == g.id
    )
    |> join(:left, [a, _b, _c, _d, _e, _f, _g], h in Rms.SystemUtilities.Status,
      on: a.wagon_status_id == h.id
    )
    |> join(:left, [a, _b, _c, _d, _e, _f, _g, _h], i in Rms.SystemUtilities.InterchangeFee,
      on: a.interchange_fee_id == i.id
    )
    |> join(:left, [a, _b, _c, _d, _e, _f, _g, _h, _i], j in Rms.SystemUtilities.Commodity,
      on: a.commodity_id == j.id
    )
    |> join(:left, [a, _b, _c, _d, _e, _f, _g, _h, _i, _j], k in Rms.SystemUtilities.Station,
      on: a.origin_station_id == k.id
    )
    |> join(:left, [a, _b, _c, _d, _e, _f, _g, _h, _i, _j, _k], l in Rms.SystemUtilities.Station,
      on: a.destination_station_id == l.id
    )
    |> join(
      :left,
      [a, _b, _c, _d, _e, _f, _g, _h, _i, _j, _k, _l],
      n in Rms.SystemUtilities.Region,
      on: a.region_id == n.id
    )
    |> join(
      :left,
      [a, _b, _c, _d, _e, _f, _g, _h, _i, _j, _k, _l, _n],
      o in Rms.SystemUtilities.Condition,
      on: a.wagon_condition_id == o.id
    )
    |> join(
      :left,
      [a, _b, _c, _d, _e, _f, _g, _h, _i, _j, _k, _l, _n, _o],
      q in Rms.SystemUtilities.Domain,
      on: a.domain_id == q.id
    )
    |> join(
      :left,
      [a, _b, _c, _d, _e, _f, _g, _h, _i, _j, _k, _l, _n, _o, _q],
      s in Rms.SystemUtilities.Station,
      on: a.current_station_id == s.id
    )
    |> handle_interchange_off_hire_report_filter(search_params)
    |> compose_interchange_off_hire_report_select()
    |> Repo.paginate(page: page, page_size: size)
  end

  def interchange_train_no_lookup(train_no) do
    Interchange
    |> where(
      [a],
      a.train_no == ^train_no and a.auth_status != "COMPLETE"
    )
    |> join(:left, [a], b in Rms.SystemUtilities.Wagon, on: a.wagon_id == b.id)
    |> join(:left, [a, b], c in Rms.SystemUtilities.WagonType, on: b.wagon_type_id == c.id)
    |> join(:left, [a, b, c], d in Rms.Accounts.RailwayAdministrator, on: b.owner_id == d.id)
    |> join(:left, [a, b, c, d], e in Rms.Accounts.RailwayAdministrator,
      on: a.adminstrator_id == e.id
    )
    |> join(:left, [a, b, c, d, e], f in Rms.SystemUtilities.Station,
      on: a.interchange_point == f.id
    )
    |> join(:left, [a, b, c, d, e, f], g in Rms.SystemUtilities.Station,
      on: a.origin_station_id == g.id
    )
    |> join(:left, [a, b, c, d, e, f, g], h in Rms.SystemUtilities.Station,
      on: a.destination_station_id == h.id
    )
    |> join(:left, [a, b, c, d, e, f, g, h], i in Rms.SystemUtilities.Commodity,
      on: a.commodity_id == i.id
    )
    |> join(:left, [a, b, c, d, e, f, g, h, i], j in Rms.SystemUtilities.Station,
      on: a.current_station_id == j.id
    )
    |> join(:left, [a, b, c, d, e, f, g, h, i, j], k in Rms.SystemUtilities.Condition,
      on: a.wagon_condition_id == k.id
    )
    |> join(:left, [a, b, c, d, e, f, g, h, i, j, k], l in Rms.SystemUtilities.Status,
      on: a.wagon_status_id == l.id
    )
    |> where(
      [a, b, c, d, e, f, g, h, i, j, k, l],
      a.id in subquery(
        from(t in Interchange,
          where: not is_nil(t.train_no) and t.auth_status != "COMPLETE",
          group_by: [t.train_no, t.wagon_id],
          select: max(t.id)
        )
      )
    )
    |> select([a, b, c, d, e, f, g, h, i, j, k, l], %{
      id: a.id,
      origin_station_id: a.origin_station_id,
      wagon_curent_stat_pur_code: l.pur_code,
      origin_name: g.description,
      commodity_id: a.commodity_id,
      commodity_name: i.description,
      destination_name: h.description,
      wagon_id: a.wagon_id,
      checker_id: a.checker_id,
      comment: a.comment,
      wagon_owner: d.code,
      wagon_type: c.description,
      wagon_code: b.code,
      interchange_point: a.interchange_point,
      interchange_pt: f.description,
      adminstrator_id: a.adminstrator_id,
      administrator: e.code,
      admin_id: a.adminstrator_id,
      lease_period: a.lease_period,
      off_hire_date: a.off_hire_date,
      accumulative_amount: a.accumulative_amount,
      accumulative_days: a.accumulative_days,
      direction: a.direction,
      auth_status: a.auth_status,
      entry_date: a.entry_date,
      exit_date: a.exit_date,
      interchange_fee: a.interchange_fee,
      destination_station_id: a.destination_station_id,
      train_no: a.train_no,
      current_station_id: a.current_station_id,
      current_location: j.description,
      on_hire_date: a.on_hire_date,
      wagon_condition_id: a.wagon_condition_id,
      total_accum_days: a.total_accum_days,
      rate: a.rate,
      wagon_status_id: a.wagon_status_id
    })
    |> Repo.all()
  end

  def interchange_off_hire_report_lookup(_source, search_params, _user) do
    Interchange
    |> where([a], a.auth_status == "COMPLETE" and a.status in ["OFF_HIRE", "ON_HIRE"])
    |> join(:left, [a], b in Rms.SystemUtilities.Wagon, on: a.wagon_id == b.id)
    |> join(:left, [a, b], c in Rms.SystemUtilities.WagonType, on: b.wagon_type_id == c.id)
    |> join(:left, [a, b, _c], d in Rms.Accounts.RailwayAdministrator, on: b.owner_id == d.id)
    |> join(:left, [a, b, _c, _d], e in Rms.Accounts.RailwayAdministrator,
      on: a.adminstrator_id == e.id
    )
    |> join(:left, [a, _b, _c, _d, _e], f in Rms.SystemUtilities.Station,
      on: a.interchange_point == f.id
    )
    |> join(:left, [a, _b, _c, _d, _e, _f], g in Rms.Locomotives.Locomotive,
      on: a.locomotive_id == g.id
    )
    |> join(:left, [a, _b, _c, _d, _e, _f, _g], h in Rms.SystemUtilities.Status,
      on: a.wagon_status_id == h.id
    )
    |> join(:left, [a, _b, _c, _d, _e, _f, _g, _h], i in Rms.SystemUtilities.InterchangeFee,
      on: a.interchange_fee_id == i.id
    )
    |> join(:left, [a, _b, _c, _d, _e, _f, _g, _h, _i], j in Rms.SystemUtilities.Commodity,
      on: a.commodity_id == j.id
    )
    |> join(:left, [a, _b, _c, _d, _e, _f, _g, _h, _i, _j], k in Rms.SystemUtilities.Station,
      on: a.origin_station_id == k.id
    )
    |> join(:left, [a, _b, _c, _d, _e, _f, _g, _h, _i, _j, _k], l in Rms.SystemUtilities.Station,
      on: a.destination_station_id == l.id
    )
    |> join(
      :left,
      [a, _b, _c, _d, _e, _f, _g, _h, _i, _j, _k, _l],
      n in Rms.SystemUtilities.Region,
      on: a.region_id == n.id
    )
    |> join(
      :left,
      [a, _b, _c, _d, _e, _f, _g, _h, _i, _j, _k, _l, _n],
      o in Rms.SystemUtilities.Condition,
      on: a.wagon_condition_id == o.id
    )
    |> join(
      :left,
      [a, _b, _c, _d, _e, _f, _g, _h, _i, _j, _k, _l, _n, _o],
      q in Rms.SystemUtilities.Domain,
      on: a.domain_id == q.id
    )
    |> join(
      :left,
      [a, _b, _c, _d, _e, _f, _g, _h, _i, _j, _k, _l, _n, _o, _q],
      s in Rms.SystemUtilities.Station,
      on: a.current_station_id == s.id
    )
    |> handle_interchange_off_hire_report_filter(search_params)
    |> compose_interchange_off_hire_report_excel_select()
  end

  defp handle_interchange_off_hire_report_filter(
         query,
         %{"isearch" => search_term} = search_params
       )
       when search_term == "" or is_nil(search_term) do
    query
    |> handle_date_filter(search_params)
    |> handle_interchange_exit_date_filter(search_params)
    |> handle_interchange_exit_date_filter(search_params)
    |> handle_interchange_entry_date_filter(search_params)
    |> handle_interchange_train_no_filter(search_params)
    |> handle_interchange_adminstrator_filter(search_params)
    |> handle_interchange_point_filter(search_params)
    |> handle_interchange_onhire_date_filter(search_params)
    |> handle_interchange_direction_filter(search_params)
  end

  defp handle_interchange_off_hire_report_filter(
         query,
         %{"isearch" => search_term, "interchange_direction" => direction}
       ) do
    search_term = "%#{search_term}%"
    compose_Inchangechange_isearch_filter(query, search_term, direction)
  end

  defp handle_interchange_exit_date_filter(query, %{
         "interchange_exit_date_from" => from,
         "interchange_exit_date_to" => to
       })
       when from == "" or is_nil(from) or to == "" or is_nil(to),
       do: query

  defp handle_interchange_exit_date_filter(query, %{
         "interchange_exit_date_from" => from,
         "interchange_exit_date_to" => to
       }) do
    query
    |> where(
      [a],
      fragment("CAST(? AS DATE) >= ?", a.exit_date, ^from) and
        fragment("CAST(? AS DATE) <= ?", a.exit_date, ^to)
    )
  end

  defp handle_interchange_entry_date_filter(query, %{
         "interchange_entry_date_from" => from,
         "interchange_entry_date_to" => to
       })
       when from == "" or is_nil(from) or to == "" or is_nil(to),
       do: query

  defp handle_interchange_entry_date_filter(query, %{
         "interchange_entry_date_from" => from,
         "interchange_entry_date_to" => to
       }) do
    query
    |> where(
      [a],
      fragment("CAST(? AS DATE) >= ?", a.entry_date, ^from) and
        fragment("CAST(? AS DATE) <= ?", a.entry_date, ^to)
    )
  end

  defp handle_interchange_onhire_date_filter(query, %{
         "interchange_on_hire_date_from" => from,
         "interchange_on_hire_date_to" => to
       })
       when from == "" or is_nil(from) or to == "" or is_nil(to),
       do: query

  defp handle_interchange_onhire_date_filter(query, %{
         "interchange_on_hire_date_from" => from,
         "interchange_on_hire_date_to" => to
       }) do
    query
    |> where(
      [a],
      fragment("CAST(? AS DATE) >= ?", a.on_hire_date, ^from) and
        fragment("CAST(? AS DATE) <= ?", a.on_hire_date, ^to)
    )
  end

  defp handle_interchange_update_date_filter(query, %{
         "interchange_update_dt_from" => from,
         "interchange_update_dt_to" => to
       })
       when from == "" or is_nil(from) or to == "" or is_nil(to),
       do: query

  defp handle_interchange_update_date_filter(query, %{
         "interchange_update_dt_from" => from,
         "interchange_update_dt_to" => to
       }) do
    query
    |> where(
      [a],
      fragment("CAST(? AS DATE) >= ?", a.update_date, ^from) and
        fragment("CAST(? AS DATE) <= ?", a.update_date, ^to)
    )
  end

  defp handle_interchange_adminstrator_filter(query, %{
         "interchange_administrator" => adminstrator_id
       })
       when adminstrator_id == "" or is_nil(adminstrator_id),
       do: query

  defp handle_interchange_adminstrator_filter(query, %{
         "interchange_administrator" => adminstrator_id
       }) do
    where(
      query,
      [a],
      a.adminstrator_id == ^adminstrator_id
    )
  end

  defp handle_interchange_region_filter(query, %{
         "interchange_region" => interchange_region
       })
       when interchange_region == "" or is_nil(interchange_region),
       do: query

  defp handle_interchange_region_filter(query, %{
         "interchange_region" => interchange_region
       }) do
    where(
      query,
      [a],
      a.region_id == ^interchange_region
    )
  end

  defp handle_interchange_train_no_filter(query, %{
         "interchange_train_no" => train_no
       })
       when train_no == "" or is_nil(train_no),
       do: query

  defp handle_interchange_train_no_filter(query, %{
         "interchange_train_no" => train_no
       }) do
    where(
      query,
      [a],
      fragment("lower(?) LIKE lower(?)", a.train_no, ^"%#{train_no}%")
    )
  end

  defp handle_interchange_point_filter(query, %{
         "interchange_interchange_point" => interchange_point
       })
       when interchange_point == "" or is_nil(interchange_point),
       do: query

  defp handle_interchange_point_filter(query, %{
         "interchange_interchange_point" => interchange_point
       }) do
    where(
      query,
      [a],
      fragment("lower(?) LIKE lower(?)", a.interchange_point, ^"%#{interchange_point}%")
    )
  end

  defp handle_interchange_direction_filter(query, %{"interchange_direction" => direction})
       when direction == "" or is_nil(direction),
       do: query

  defp handle_interchange_direction_filter(query, %{"interchange_direction" => direction}) do
    where(query, [a], fragment("lower(?) LIKE lower(?)", a.direction, ^"%#{direction}%"))
  end

  defp compose_Inchangechange_isearch_filter(query, search_term, direction) do
    query
    |> where([a, b, c, d, e, f, g, h, i, j, k, l, n, o, q, s], a.direction == ^direction)
    |> where(
      [a, b, c, d, e, f, g, h, i, j, k, l, n, o, q, s],
      fragment("lower(?) LIKE lower(?)", f.description, ^search_term) or
        fragment("lower(?) LIKE lower(?)", e.description, ^search_term) or
        fragment("lower(?) LIKE lower(?)", j.description, ^search_term) or
        fragment("lower(?) LIKE lower(?)", k.description, ^search_term) or
        fragment("lower(?) LIKE lower(?)", l.description, ^search_term) or
        fragment("lower(?) LIKE lower(?)", a.direction, ^search_term) or
        fragment("lower(?) LIKE lower(?)", a.status, ^search_term) or
        fragment("lower(?) LIKE lower(?)", a.interchange_point, ^search_term) or
        fragment("lower(?) LIKE lower(?)", a.entry_date, ^search_term) or
        fragment("lower(?) LIKE lower(?)", b.code, ^search_term) or
        fragment("lower(?) LIKE lower(?)", a.train_no, ^search_term) or
        fragment("lower(?) LIKE lower(?)", a.exit_date, ^search_term)
    )
  end

  defp compose_interchange_off_hire_report_select(query) do
    query
    |> order_by([a, _b, _c, _d, _e, _f, _g, _h, _i, _j, _k, _l, _n, _o, _q, _s],
      desc: a.inserted_at
    )
    |> select([a, b, c, d, e, f, g, h, i, j, k, l, n, o, q, s], %{
      id: a.id,
      uuid: a.uuid,
      train_no: a.train_no,
      wagon_id: a.wagon_id,
      wagon_owner: d.code,
      wagon_code: b.code,
      wagon_type: c.description,
      maker_id: a.maker_id,
      checker_id: a.checker_id,
      inserted_at: a.inserted_at,
      updated_at: a.updated_at,
      commodity: j.description,
      auth_status: a.auth_status,
      comment: a.comment,
      direction: a.direction,
      status: a.status,
      entry_date: a.entry_date,
      exit_date: a.exit_date,
      accumulative_days: a.accumulative_days,
      accumulative_amount: a.accumulative_amount,
      interchange_fee: a.interchange_fee,
      wagon_id: a.wagon_id,
      wagon: b.code,
      rate: a.rate,
      wagon_status_id: a.wagon_status_id,
      wagon_status: h.description,
      commodity_id: a.commodity_id,
      adminstrator_id: a.adminstrator_id,
      administrator: e.code,
      interchange_point: a.interchange_point,
      interchange_pt: f.description,
      interchange_fee_id: a.interchange_fee_id,
      locomotive_id: a.locomotive_id,
      locomotive: g.description,
      status: a.status,
      origin: k.description,
      destination: l.description,
      on_hire_date: a.on_hire_date,
      total_accum_days: a.total_accum_days,
      region: n.description,
      wagon_condition: o.description,
      domain: q.description,
      current_station: s.description,
      off_hire_date: a.off_hire_date
    })
  end

  defp compose_interchange_off_hire_report_excel_select(query) do
    query
    |> order_by([a, _b, _c, _d, _e, _f, _g, _h, _i, _j, _k, _l, _n, _o, _q, _s],
      desc: a.inserted_at
    )
    |> select([a, b, c, d, e, f, g, h, i, j, k, l, n, o, q, s], %{
      id: a.id,
      uuid: a.uuid,
      train_no: a.train_no,
      wagon_id: a.wagon_id,
      wagon_owner: d.code,
      wagon_code: b.code,
      wagon_type: c.description,
      maker_id: a.maker_id,
      checker_id: a.checker_id,
      inserted_at: a.inserted_at,
      updated_at: a.updated_at,
      commodity: j.description,
      auth_status: a.auth_status,
      comment: a.comment,
      direction: a.direction,
      status: a.status,
      entry_date: a.entry_date,
      exit_date: a.exit_date,
      accumulative_days: a.accumulative_days,
      accumulative_amount: a.accumulative_amount,
      interchange_fee: a.interchange_fee,
      wagon_id: a.wagon_id,
      lease_period: a.lease_period,
      wagon: b.code,
      wagon_status_id: a.wagon_status_id,
      wagon_status: h.description,
      commodity_id: a.commodity_id,
      adminstrator_id: a.adminstrator_id,
      administrator: e.code,
      interchange_point: a.interchange_point,
      interchange_pt: f.description,
      interchange_fee_id: a.interchange_fee_id,
      locomotive_id: a.locomotive_id,
      locomotive: g.description,
      status: a.status,
      origin: k.description,
      destination: l.description,
      on_hire_date: a.on_hire_date,
      total_accum_days: a.total_accum_days,
      region: n.description,
      wagon_condition: o.description,
      domain: q.description,
      rate: a.rate,
      current_station: s.description,
      off_hire_date: a.off_hire_date
    })
  end

  def interchange_off_hire_report_list_lookup(search_params, page, size, _user) do
    Interchange
    |> where([a], a.status in ["OFF_HIRE", "ON_HIRE"])
    |> join(:left, [a], b in Rms.SystemUtilities.Wagon, on: a.wagon_id == b.id)
    |> join(:left, [a, b], c in Rms.SystemUtilities.WagonType, on: b.wagon_type_id == c.id)
    |> join(:left, [a, b, _c], d in Rms.Accounts.RailwayAdministrator, on: b.owner_id == d.id)
    |> join(:left, [a, b, _c, _d], e in Rms.Accounts.RailwayAdministrator,
      on: a.adminstrator_id == e.id
    )
    |> join(:left, [a, _b, _c, _d, _e], f in Rms.SystemUtilities.Station,
      on: a.interchange_point == f.id
    )
    |> join(:left, [a, _b, _c, _d, _e, _f], g in Rms.Locomotives.Locomotive,
      on: a.locomotive_id == g.id
    )
    |> join(:left, [a, _b, _c, _d, _e, _f, _g], h in Rms.SystemUtilities.Status,
      on: a.wagon_status_id == h.id
    )
    |> join(:left, [a, _b, _c, _d, _e, _f, _g, _h], i in Rms.SystemUtilities.InterchangeFee,
      on: a.interchange_fee_id == i.id
    )
    |> join(:left, [a, _b, _c, _d, _e, _f, _g, _h, _i], j in Rms.SystemUtilities.Commodity,
      on: a.commodity_id == j.id
    )
    |> join(:left, [a, _b, _c, _d, _e, _f], g in Rms.SystemUtilities.Station,
      on: a.origin_station_id == g.id
    )
    |> join(:left, [a, _b, _c, _d, _e, _f, _g], k in Rms.SystemUtilities.Station,
      on: a.destination_station_id == k.id
    )
    |> join(
      :left,
      [a, _b, _c, _d, _e, _f, _g, _h, _i, _j, _k, _l],
      n in Rms.SystemUtilities.Region,
      on: a.region_id == n.id
    )
    |> join(
      :left,
      [a, _b, _c, _d, _e, _f, _g, _h, _i, _j, _k, _l, _n],
      o in Rms.SystemUtilities.Condition,
      on: a.wagon_condition_id == o.id
    )
    |> join(
      :left,
      [a, _b, _c, _d, _e, _f, _g, _h, _i, _j, _k, _l, _n, _o],
      p in Rms.SystemUtilities.Status,
      on: a.wagon_status_id == p.id
    )
    |> join(
      :left,
      [a, _b, _c, _d, _e, _f, _g, _h, _i, _j, _k, _l, _n, _o, _p],
      q in Rms.SystemUtilities.Domain,
      on: a.domain_id == q.id
    )
    |> join(
      :left,
      [a, _b, _c, _d, _e, _f, _g, _h, _i, _j, _k, _l, _n, _o, _p, _q],
      s in Rms.SystemUtilities.Station,
      on: a.current_station_id == s.id
    )
    |> handle_interchange_report_filter(search_params)
    |> compose_interchange_report_select()
    |> Repo.paginate(page: page, page_size: size)
  end

  def interchange_off_hire_report_list_lookup(_source, search_params, _user) do
    Interchange
    |> where([a], a.status in ["OFF_HIRE", "ON_HIRE"])
    |> join(:left, [a], b in Rms.SystemUtilities.Wagon, on: a.wagon_id == b.id)
    |> join(:left, [a, b], c in Rms.SystemUtilities.WagonType, on: b.wagon_type_id == c.id)
    |> join(:left, [a, b, _c], d in Rms.Accounts.RailwayAdministrator, on: b.owner_id == d.id)
    |> join(:left, [a, b, _c, _d], e in Rms.Accounts.RailwayAdministrator,
      on: a.adminstrator_id == e.id
    )
    |> join(:left, [a, _b, _c, _d, _e], f in Rms.SystemUtilities.Station,
      on: a.interchange_point == f.id
    )
    |> join(:left, [a, _b, _c, _d, _e, _f], g in Rms.Locomotives.Locomotive,
      on: a.locomotive_id == g.id
    )
    |> join(:left, [a, _b, _c, _d, _e, _f, _g], h in Rms.SystemUtilities.Status,
      on: a.wagon_status_id == h.id
    )
    |> join(:left, [a, _b, _c, _d, _e, _f, _g, _h], i in Rms.SystemUtilities.InterchangeFee,
      on: a.interchange_fee_id == i.id
    )
    |> join(:left, [a, _b, _c, _d, _e, _f, _g, _h, _i], j in Rms.SystemUtilities.Commodity,
      on: a.commodity_id == j.id
    )
    |> join(:left, [a, _b, _c, _d, _e, _f, _g, _h, _i, _j], k in Rms.SystemUtilities.Station,
      on: a.origin_station_id == k.id
    )
    |> join(:left, [a, _b, _c, _d, _e, _f, _g, _h, _i, _j, _k], l in Rms.SystemUtilities.Station,
      on: a.destination_station_id == l.id
    )
    |> join(
      :left,
      [a, _b, _c, _d, _e, _f, _g, _h, _i, _j, _k, _l],
      n in Rms.SystemUtilities.Region,
      on: a.region_id == n.id
    )
    |> join(
      :left,
      [a, _b, _c, _d, _e, _f, _g, _h, _i, _j, _k, _l, _n],
      o in Rms.SystemUtilities.Condition,
      on: a.wagon_condition_id == o.id
    )
    |> join(
      :left,
      [a, _b, _c, _d, _e, _f, _g, _h, _i, _j, _k, _l, _n, _o],
      p in Rms.SystemUtilities.Status,
      on: a.wagon_status_id == p.id
    )
    |> join(
      :left,
      [a, _b, _c, _d, _e, _f, _g, _h, _i, _j, _k, _l, _n, _o, _p],
      q in Rms.SystemUtilities.Domain,
      on: a.domain_id == q.id
    )
    |> join(
      :left,
      [a, _b, _c, _d, _e, _f, _g, _h, _i, _j, _k, _l, _n, _o, _p, _q],
      s in Rms.SystemUtilities.Station,
      on: a.current_station_id == s.id
    )
    |> handle_interchange_report_filter(search_params)
    |> compose_interchange_report_select()
  end

  defp handle_interchange_report_filter(
         query,
         %{"isearch" => search_term} = search_params
       )
       when search_term == "" or is_nil(search_term) do
    query
    |> handle_date_filter(search_params)
    |> handle_interchange_train_no_filter(search_params)
    |> handle_interchange_adminstrator_filter(search_params)
    |> handle_interchanging_point_filter(search_params)
    |> handle_interchange_onhire_date_filter(search_params)
    |> handle_interchange_direction_filter(search_params)
    |> handle_interchange_wagon_code_filter(search_params)
    |> handle_interchange_commdity_filter(search_params)
    |> handle_interchange_direction_side_filter(search_params)
    |> handle_interchange_train_no_filter(search_params)
    |> handle_interchange_origin_filter(search_params)
    |> handle_interchange_destin_filter(search_params)
    |> handle_interchange_update_date_filter(search_params)
    |> handle_interchange_region_filter(search_params)
  end

  defp handle_interchange_report_filter(
         query,
         %{"isearch" => search_term}
       ) do
    search_term = "%#{search_term}%"
    compose_Inchangechange_rate_isearch_filter(query, search_term)
  end

  defp handle_interchanging_point_filter(query, %{
         "interchange_point" => interchange_point
       })
       when interchange_point == "" or is_nil(interchange_point),
       do: query

  defp handle_interchanging_point_filter(query, %{
         "interchange_point" => interchange_point
       }) do
    where(
      query,
      [a],
      a.interchange_point == ^interchange_point
    )
  end

  defp handle_interchange_wagon_code_filter(query, %{
         "interchange_wagon_no" => interchange_wagon_no
       })
       when interchange_wagon_no == "" or is_nil(interchange_wagon_no),
       do: query

  defp handle_interchange_wagon_code_filter(query, %{
         "interchange_wagon_no" => interchange_wagon_no
       }) do
    where(
      query,
      [a, b, _c, _d, _e, _f, _g, _h, _i, _j, _k, _l],
      fragment("lower(?) LIKE lower(?)", b.code, ^"%#{interchange_wagon_no}%")
    )
  end

  defp handle_interchange_commdity_filter(query, %{
         "interchange_commdity" => interchange_commdity
       })
       when interchange_commdity == "" or is_nil(interchange_commdity),
       do: query

  defp handle_interchange_commdity_filter(query, %{
         "interchange_commdity" => interchange_commdity
       }) do
    where(
      query,
      [a],
      a.commodity_id == ^interchange_commdity
    )
  end

  defp handle_interchange_direction_side_filter(query, %{
         "interchange_direction" => interchange_direction
       })
       when interchange_direction == "" or is_nil(interchange_direction),
       do: query

  defp handle_interchange_direction_side_filter(query, %{
         "interchange_direction" => interchange_direction
       }) do
    where(
      query,
      [a],
      fragment("lower(?) LIKE lower(?)", a.direction, ^"%#{interchange_direction}%")
    )
  end

  defp handle_interchange_destin_filter(query, %{
         "interchange_destin" => interchange_destin
       })
       when interchange_destin == "" or is_nil(interchange_destin),
       do: query

  defp handle_interchange_destin_filter(query, %{
         "interchange_destin" => interchange_destin
       }) do
    where(
      query,
      [a],
      a.destination_station_id == ^interchange_destin
    )
  end

  defp handle_interchange_origin_filter(query, %{
         "interchange_origin" => interchange_origin
       })
       when interchange_origin == "" or is_nil(interchange_origin),
       do: query

  defp handle_interchange_origin_filter(query, %{
         "interchange_origin" => interchange_origin
       }) do
    where(
      query,
      [a],
      a.origin_station_id == ^interchange_origin
    )
  end

  def interchange_hired_report_list_lookup(
        %{"interchange_direction" => direction, "interchange_status" => status} = search_params,
        page,
        size,
        _user
      ) do
    Interchange
    |> where(
      [a],
      a.auth_status == "APPROVED" and a.status == ^status and a.direction == ^direction
    )
    |> join(:left, [a], b in Rms.SystemUtilities.Wagon, on: a.wagon_id == b.id)
    |> join(:left, [a, b], c in Rms.SystemUtilities.WagonType, on: b.wagon_type_id == c.id)
    |> join(:left, [a, b, _c], d in Rms.Accounts.RailwayAdministrator, on: b.owner_id == d.id)
    |> join(:left, [a, b, _c, _d], e in Rms.Accounts.RailwayAdministrator,
      on: a.adminstrator_id == e.id
    )
    |> join(:left, [a, _b, _c, _d, _e], f in Rms.SystemUtilities.Station,
      on: a.interchange_point == f.id
    )
    |> join(:left, [a, _b, _c, _d, _e, _f], g in Rms.Locomotives.Locomotive,
      on: a.locomotive_id == g.id
    )
    |> join(:left, [a, _b, _c, _d, _e, _f, _g], h in Rms.SystemUtilities.Status,
      on: a.wagon_status_id == h.id
    )
    |> join(:left, [a, _b, _c, _d, _e, _f, _g, _h], i in Rms.SystemUtilities.InterchangeFee,
      on: a.interchange_fee_id == i.id
    )
    |> join(:left, [a, _b, _c, _d, _e, _f, _g, _h, _i], j in Rms.SystemUtilities.Commodity,
      on: a.commodity_id == j.id
    )
    |> join(:left, [a, _b, _c, _d, _e, _f, _g, _h, _i, _j], k in Rms.SystemUtilities.Station,
      on: a.origin_station_id == k.id
    )
    |> join(:left, [a, _b, _c, _d, _e, _f, _g, _h, _i, _j, _k], l in Rms.SystemUtilities.Station,
      on: a.destination_station_id == l.id
    )
    |> join(
      :left,
      [a, _b, _c, _d, _e, _f, _g, _h, _i, _j, _k, _l],
      n in Rms.SystemUtilities.Region,
      on: a.region_id == n.id
    )
    |> join(
      :left,
      [a, _b, _c, _d, _e, _f, _g, _h, _i, _j, _k, _l, _n],
      o in Rms.SystemUtilities.Condition,
      on: a.wagon_condition_id == o.id
    )
    |> join(
      :left,
      [a, _b, _c, _d, _e, _f, _g, _h, _i, _j, _k, _l, _n, _o],
      p in Rms.SystemUtilities.Status,
      on: a.wagon_status_id == p.id
    )
    |> join(
      :left,
      [a, _b, _c, _d, _e, _f, _g, _h, _i, _j, _k, _l, _n, _o, _p],
      q in Rms.SystemUtilities.Domain,
      on: a.domain_id == q.id
    )
    |> join(
      :left,
      [a, _b, _c, _d, _e, _f, _g, _h, _i, _j, _k, _l, _n, _o, _p, _q],
      s in Rms.SystemUtilities.Station,
      on: a.current_station_id == s.id
    )
    |> where(
      [a, _b, _c, _d, _e, _f, _g, _k, _l, _n, _o, _p, _q, _s],
      a.id in subquery(
        from(t in Interchange,
          where: not is_nil(t.train_no),
          group_by: [t.train_no, t.wagon_id],
          select: max(t.id)
        )
      )
    )
    |> handle_interchange_report_filter(search_params)
    |> compose_interchange_report_select()
    |> Repo.paginate(page: page, page_size: size)
  end

  def interchange_hired_report_list_lookup(
        _source,
        %{"interchange_direction" => direction, "interchange_status" => status} = search_params,
        _user
      ) do
    Interchange
    |> where(
      [a],
      a.auth_status == "APPROVED" and a.status == ^status and a.direction == ^direction
    )
    |> join(:left, [a], b in Rms.SystemUtilities.Wagon, on: a.wagon_id == b.id)
    |> join(:left, [a, b], c in Rms.SystemUtilities.WagonType, on: b.wagon_type_id == c.id)
    |> join(:left, [a, b, _c], d in Rms.Accounts.RailwayAdministrator, on: b.owner_id == d.id)
    |> join(:left, [a, b, _c, _d], e in Rms.Accounts.RailwayAdministrator,
      on: a.adminstrator_id == e.id
    )
    |> join(:left, [a, _b, _c, _d, _e], f in Rms.SystemUtilities.Station,
      on: a.interchange_point == f.id
    )
    |> join(:left, [a, _b, _c, _d, _e, _f], g in Rms.Locomotives.Locomotive,
      on: a.locomotive_id == g.id
    )
    |> join(:left, [a, _b, _c, _d, _e, _f, _g], h in Rms.SystemUtilities.Status,
      on: a.wagon_status_id == h.id
    )
    |> join(:left, [a, _b, _c, _d, _e, _f, _g, _h], i in Rms.SystemUtilities.InterchangeFee,
      on: a.interchange_fee_id == i.id
    )
    |> join(:left, [a, _b, _c, _d, _e, _f, _g, _h, _i], j in Rms.SystemUtilities.Commodity,
      on: a.commodity_id == j.id
    )
    |> join(:left, [a, _b, _c, _d, _e, _f, _g, _h, _i, _j], k in Rms.SystemUtilities.Station,
      on: a.origin_station_id == k.id
    )
    |> join(:left, [a, _b, _c, _d, _e, _f, _g, _h, _i, _j, _k], l in Rms.SystemUtilities.Station,
      on: a.destination_station_id == l.id
    )
    |> join(
      :left,
      [a, _b, _c, _d, _e, _f, _g, _h, _i, _j, _k, _l],
      n in Rms.SystemUtilities.Region,
      on: a.region_id == n.id
    )
    |> join(
      :left,
      [a, _b, _c, _d, _e, _f, _g, _h, _i, _j, _k, _l, _n],
      o in Rms.SystemUtilities.Condition,
      on: a.wagon_condition_id == o.id
    )
    |> join(
      :left,
      [a, _b, _c, _d, _e, _f, _g, _h, _i, _j, _k, _l, _n, _o],
      p in Rms.SystemUtilities.Status,
      on: a.wagon_status_id == p.id
    )
    |> join(
      :left,
      [a, _b, _c, _d, _e, _f, _g, _h, _i, _j, _k, _l, _n, _o, _p],
      q in Rms.SystemUtilities.Domain,
      on: a.domain_id == q.id
    )
    |> join(
      :left,
      [a, _b, _c, _d, _e, _f, _g, _h, _i, _j, _k, _l, _n, _o, _p, _q],
      s in Rms.SystemUtilities.Station,
      on: a.current_station_id == s.id
    )
    |> where(
      [a, _b, _c, _d, _e, _f, _g, _k, _l, _n, _o, _p, _q, _s],
      a.id in subquery(
        from(t in Interchange,
          where: not is_nil(t.train_no),
          group_by: [t.train_no, t.wagon_id],
          select: max(t.id)
        )
      )
    )
    |> handle_interchange_report_filter(search_params)
    |> compose_interchange_report_select()
  end

  defp compose_Inchangechange_rate_isearch_filter(query, search_term) do
    query
    |> where(
      [a, b, c, d, e, f, g, h, i, j, k, l],
      fragment("lower(?) LIKE lower(?)", f.description, ^search_term) or
        fragment("lower(?) LIKE lower(?)", e.description, ^search_term) or
        fragment("lower(?) LIKE lower(?)", a.direction, ^search_term) or
        fragment("lower(?) LIKE lower(?)", a.interchange_point, ^search_term) or
        fragment("lower(?) LIKE lower(?)", d.code, ^search_term) or
        fragment("lower(?) LIKE lower(?)", b.code, ^search_term) or
        fragment("lower(?) LIKE lower(?)", a.train_no, ^search_term) or
        fragment("lower(?) LIKE lower(?)", f.description, ^search_term) or
        fragment("lower(?) LIKE lower(?)", k.description, ^search_term) or
        fragment("lower(?) LIKE lower(?)", l.description, ^search_term) or
        fragment("lower(?) LIKE lower(?)", j.description, ^search_term) or
        fragment("lower(?) LIKE lower(?)", a.on_hire_date, ^search_term)
    )
  end

  defp compose_interchange_report_select(query) do
    query
    |> order_by([a, _b, _c, _d, _e, _f, _g, _h, _i, _j, _k, _l, _n, _o, _p, _q],
      desc: a.inserted_at
    )
    |> select([a, b, c, d, e, f, g, h, i, j, k, l, n, o, p, q, s], %{
      id: a.id,
      wagon_id: a.wagon_id,
      checker_id: a.checker_id,
      comment: a.comment,
      wagon_owner: d.code,
      wagon_type: c.description,
      wagon_code: b.code,
      interchange_point: a.interchange_point,
      interchange_pt: f.description,
      adminstrator_id: a.adminstrator_id,
      administrator: e.code,
      uuid: a.uuid,
      status: a.status,
      train_no: a.train_no,
      admin_id: a.adminstrator_id,
      lease_period: a.lease_period,
      off_hire_date: a.off_hire_date,
      on_hire_date: a.on_hire_date,
      accumulative_amount: a.accumulative_amount,
      accumulative_days: a.accumulative_days,
      wagon_condition_id: a.wagon_condition_id,
      wagon_condition: o.description,
      wagon_status_id: a.wagon_status_id,
      wagon_status: p.description,
      region_id: a.region_id,
      region: n.description,
      domain_id: a.domain_id,
      domain: q.description,
      current_station_id: a.current_station_id,
      current_station: s.description,
      entry_date: a.entry_date,
      exit_date: a.exit_date,
      direction: a.direction,
      origin_station_id: a.origin_station_id,
      destination_station_id: a.origin_station_id,
      origin: k.description,
      rate: a.rate,
      destination: l.description,
      commodity: j.description,
      total_accum_days: a.total_accum_days,
      update_date: a.update_date
    })
  end

  def interchange_hired_report_list_lookup(id) do
    Interchange
    |> where([a], a.id == ^id)
    |> join(:left, [a], b in Rms.SystemUtilities.Wagon, on: a.wagon_id == b.id)
    |> join(:left, [a, b], c in Rms.SystemUtilities.WagonType, on: b.wagon_type_id == c.id)
    |> join(:left, [a, b, _c], d in Rms.Accounts.RailwayAdministrator, on: b.owner_id == d.id)
    |> join(:left, [a, b, _c, _d], e in Rms.Accounts.RailwayAdministrator,
      on: a.adminstrator_id == e.id
    )
    |> join(:left, [a, _b, _c, _d, _e], f in Rms.SystemUtilities.Station,
      on: a.interchange_point == f.id
    )
    |> join(:left, [a, _b, _c, _d, _e, _f], g in Rms.Locomotives.Locomotive,
      on: a.locomotive_id == g.id
    )
    |> join(:left, [a, _b, _c, _d, _e, _f, _g], h in Rms.SystemUtilities.Status,
      on: a.wagon_status_id == h.id
    )
    |> join(:left, [a, _b, _c, _d, _e, _f, _g, _h], i in Rms.SystemUtilities.InterchangeFee,
      on: a.interchange_fee_id == i.id
    )
    |> join(:left, [a, _b, _c, _d, _e, _f, _g, _h, _i], j in Rms.SystemUtilities.Commodity,
      on: a.commodity_id == j.id
    )
    |> join(:left, [a, _b, _c, _d, _e, _f, _g, _h, _i, _j], k in Rms.SystemUtilities.Station,
      on: a.origin_station_id == k.id
    )
    |> join(:left, [a, _b, _c, _d, _e, _f, _g, _h, _i, _j, _k], l in Rms.SystemUtilities.Station,
      on: a.destination_station_id == l.id
    )
    |> join(
      :left,
      [a, _b, _c, _d, _e, _f, _g, _h, _i, _j, _k, _l],
      n in Rms.SystemUtilities.Region,
      on: a.region_id == n.id
    )
    |> join(
      :left,
      [a, _b, _c, _d, _e, _f, _g, _h, _i, _j, _k, _l, _n],
      o in Rms.SystemUtilities.Condition,
      on: a.wagon_condition_id == o.id
    )
    |> join(
      :left,
      [a, _b, _c, _d, _e, _f, _g, _h, _i, _j, _k, _l, _n, _o],
      p in Rms.SystemUtilities.Status,
      on: a.wagon_status_id == p.id
    )
    |> join(
      :left,
      [a, _b, _c, _d, _e, _f, _g, _h, _i, _j, _k, _l, _n, _o, _p],
      q in Rms.SystemUtilities.Domain,
      on: a.domain_id == q.id
    )
    |> join(
      :left,
      [a, _b, _c, _d, _e, _f, _g, _h, _i, _j, _k, _l, _n, _o, _p, _q],
      s in Rms.SystemUtilities.Station,
      on: a.current_station_id == s.id
    )
    |> select([a, b, c, d, e, f, g, h, i, j, k, l, n, o, p, q, s], %{
      id: a.id,
      wagon_id: a.wagon_id,
      checker_id: a.checker_id,
      comment: a.comment,
      wagon_owner: d.code,
      wagon_type: c.description,
      wagon_code: b.code,
      interchange_point: a.interchange_point,
      interchange_pt: f.description,
      adminstrator_id: a.adminstrator_id,
      administrator: e.code,
      commodity_id: a.commodity_id,
      uuid: a.uuid,
      train_no: a.train_no,
      admin_id: a.adminstrator_id,
      lease_period: a.lease_period,
      off_hire_date: a.off_hire_date,
      on_hire_date: a.on_hire_date,
      accumulative_amount: a.accumulative_amount,
      accumulative_days: a.accumulative_days,
      entry_date: a.entry_date,
      exit_date: a.exit_date,
      direction: a.direction,
      origin_station_id: a.origin_station_id,
      destination_station_id: a.origin_station_id,
      origin: k.description,
      destination: l.description,
      commodity: j.description,
      current_station_id: a.current_station_id,
      wagon_condition_id: a.wagon_condition_id,
      wagon_condition: o.description,
      wagon_status_id: a.wagon_status_id,
      wagon_status: p.description,
      region_id: a.region_id,
      region: n.description,
      domain_id: a.domain_id,
      domain: q.description,
      rate: a.rate,
      current_station_id: a.current_station_id,
      total_accum_days: a.total_accum_days,
      current_station: s.description,
      modification_reason: a.modification_reason
    })
    |> Repo.one()
  end

  def get_int_wagon(id) do
    Interchange
    |> where([a], a.id == ^id)
    |> select([a], %{
      id: a.id,
      direction: a.direction,
      status: a.status,
      entry_date: a.entry_date,
      exit_date: a.exit_date,
      accumulative_days: a.accumulative_days,
      accumulative_amount: a.accumulative_amount,
      interchange_fee: a.interchange_fee,
      maker_id: a.maker_id,
      checker_id: a.checker_id,
      wagon_id: a.wagon_id,
      wagon_status_id: a.wagon_status_id,
      commodity_id: a.commodity_id,
      adminstrator_id: a.adminstrator_id,
      interchange_point: a.interchange_point,
      interchange_fee_id: a.interchange_fee_id,
      uuid: a.uuid,
      rate: a.rate,
      auth_status: a.auth_status,
      off_hire_date: a.off_hire_date,
      lease_period: a.lease_period,
      origin_station_id: a.origin_station_id,
      destination_station_id: a.destination_station_id,
      train_no: a.train_no,
      on_hire_date: a.on_hire_date,
      on_hire_date: a.hire_status,
      current_station_id: a.current_station_id,
      total_accum_days: a.total_accum_days,
      wagon_condition_id: a.wagon_condition_id
    })
    |> Repo.one()
  end

  alias Rms.Tracking.InterchangeDefect

  @doc """
  Returns the list of tbl_interchange_defects.

  ## Examples

      iex> list_tbl_interchange_defects()
      [%InterchangeDefect{}, ...]

  """
  def list_tbl_interchange_defects do
    Repo.all(InterchangeDefect)
  end

  @doc """
  Gets a single interchange_defect.

  Raises `Ecto.NoResultsError` if the Interchange defect does not exist.

  ## Examples

      iex> get_interchange_defect!(123)
      %InterchangeDefect{}

      iex> get_interchange_defect!(456)
      ** (Ecto.NoResultsError)

  """
  def get_interchange_defect!(id), do: Repo.get!(InterchangeDefect, id)

  @doc """
  Creates a interchange_defect.

  ## Examples

      iex> create_interchange_defect(%{field: value})
      {:ok, %InterchangeDefect{}}

      iex> create_interchange_defect(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_interchange_defect(attrs \\ %{}) do
    %InterchangeDefect{}
    |> InterchangeDefect.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a interchange_defect.

  ## Examples

      iex> update_interchange_defect(interchange_defect, %{field: new_value})
      {:ok, %InterchangeDefect{}}

      iex> update_interchange_defect(interchange_defect, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_interchange_defect(%InterchangeDefect{} = interchange_defect, attrs) do
    interchange_defect
    |> InterchangeDefect.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a interchange_defect.

  ## Examples

      iex> delete_interchange_defect(interchange_defect)
      {:ok, %InterchangeDefect{}}

      iex> delete_interchange_defect(interchange_defect)
      {:error, %Ecto.Changeset{}}

  """
  def delete_interchange_defect(%InterchangeDefect{} = interchange_defect) do
    Repo.delete(interchange_defect)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking interchange_defect changes.

  ## Examples

      iex> change_interchange_defect(interchange_defect)
      %Ecto.Changeset{data: %InterchangeDefect{}}

  """
  def change_interchange_defect(%InterchangeDefect{} = interchange_defect, attrs \\ %{}) do
    InterchangeDefect.changeset(interchange_defect, attrs)
  end

  def interchange_defect_lookup(id) do
    InterchangeDefect
    |> where([a], a.interchange_id == ^id)
    |> join(:left, [a], b in Rms.SystemUtilities.SpareFee, on: a.spare_id == b.id)
    |> join(:left, [a, b], c in Rms.SystemUtilities.Spare, on: b.spare_id == c.id)
    |> join(:left, [a, b, c], d in Rms.SystemUtilities.Currency, on: b.currency_id == d.id)
    |> select([a, b, c, d], %{
      id: a.id,
      code: c.code,
      equipment: c.description,
      amount: b.amount,
      currency: d.code
    })
    |> Repo.all()
  end

  def get_all_wagon_tracker(search_params, page, size, _user) do
    WagonTracking
    |> join(:left, [a], b in Rms.SystemUtilities.Wagon, on: a.wagon_id == b.id)
    |> join(:left, [a, b], c in Rms.SystemUtilities.WagonType, on: b.wagon_type_id == c.id)
    |> join(:left, [a, b, _c], d in Rms.Accounts.RailwayAdministrator, on: b.owner_id == d.id)
    |> join(:left, [a, b, _c, _d], e in Rms.SystemUtilities.Station, on: a.destination_id == e.id)
    |> join(:left, [a, b, _c, _d, _e], f in Rms.SystemUtilities.Station, on: a.origin_id == f.id)
    |> join(:left, [a, b, _c, _d, _e, _f], g in Rms.SystemUtilities.Station,
      on: a.current_location_id == g.id
    )
    |> join(:left, [a, b, _c, _d, _e, _f, _g], k in Rms.SystemUtilities.Commodity,
      on: a.commodity_id == k.id
    )
    |> join(:left, [a, b, _c, _d, _e, _f, _g, _k], l in Rms.Accounts.Clients,
      on: a.customer_id == l.id
    )
    |> join(:left, [a, b, _c, _d, _e, _f, _g, _k, _l], m in Rms.SystemUtilities.Condition,
      on: a.condition_id == m.id
    )
    |> join(:left, [a, b, _c, d, _e, _f, _g, _k, _l, _m], n in Rms.SystemUtilities.Country,
      on: d.country == n.code
    )
    |> join(:left, [a, b, _c, d, _e, _f, _g, _k, _l, _m, n], o in Rms.SystemUtilities.Region,
      on: n.region_id == o.id
    )
    |> join(:left, [a, b, _c, d, _e, _f, _g, _k, _l, _m, n, o], p in Rms.SystemUtilities.Domain,
      on: a.domain_id == p.id
    )
    |> handle_report_filter(search_params)
    |> order_by(desc: :inserted_at)
    |> compose_report_select()
    |> Repo.paginate(page: page, page_size: size)
  end

  # CSV Report
  def get_all_wagon_tracker(_source, search_params, _user) do
    WagonTracking
    |> join(:left, [a], b in Rms.SystemUtilities.Wagon, on: a.wagon_id == b.id)
    |> join(:left, [a, b], c in Rms.SystemUtilities.WagonType, on: b.wagon_type_id == c.id)
    |> join(:left, [a, b, _c], d in Rms.Accounts.RailwayAdministrator, on: b.owner_id == d.id)
    |> join(:left, [a, b, _c, _d], e in Rms.SystemUtilities.Station, on: a.destination_id == e.id)
    |> join(:left, [a, b, _c, _d, _e], f in Rms.SystemUtilities.Station, on: a.origin_id == f.id)
    |> join(:left, [a, b, _c, _d, _e, _f], g in Rms.SystemUtilities.Station,
      on: a.current_location_id == g.id
    )
    |> join(:left, [a, b, _c, _d, _e, _f, _g], k in Rms.SystemUtilities.Commodity,
      on: a.commodity_id == k.id
    )
    |> join(:left, [a, b, _c, _d, _e, _f, _g, _k], l in Rms.Accounts.Clients,
      on: a.customer_id == l.id
    )
    |> join(:left, [a, b, _c, _d, _e, _f, _g, _k, _l], m in Rms.SystemUtilities.Condition,
      on: a.condition_id == m.id
    )
    |> join(:left, [a, b, _c, d, _e, _f, _g, _k, _l, _m], n in Rms.SystemUtilities.Country,
      on: d.country == n.code
    )
    |> join(:left, [a, b, _c, d, _e, _f, _g, _k, _l, _m, n], o in Rms.SystemUtilities.Region,
      on: n.region_id == o.id
    )
    |> join(:left, [a, b, _c, d, _e, _f, _g, _k, _l, _m, n, o], p in Rms.SystemUtilities.Domain,
      on: a.domain_id == p.id
    )
    |> handle_report_filter(search_params)
    |> order_by(desc: :inserted_at)
    |> compose_report_select()
  end

  defp handle_report_filter(query, %{"isearch" => search_term} = search_params)
       when search_term == "" or is_nil(search_term) do
    query
    # |> handle_date_filter(search_params)
    |> handle_wagon_id_filter(search_params)
    |> handle_customer_id_filter(search_params)
    |> handle_update_date_filter(search_params)
    |> handle_current_location_id_filter(search_params)
    |> handle_yard_siding_filter(search_params)
    |> handle_commodity_id_filter(search_params)
    |> handle_origin_id_filter(search_params)
    |> handle_destination_id_filter(search_params)
    |> handle_train_no_filter(search_params)
  end

  defp handle_report_filter(query, %{"isearch" => search_term}) do
    search_term = "%#{search_term}%"
    compose_isearch_filter(query, search_term)
  end

  defp handle_date_filter(query, %{"from" => from, "to" => to})
       when from == "" or is_nil(from) or to == "" or is_nil(to),
       do: query

  defp handle_date_filter(query, %{"from" => from, "to" => to}) do
    query
    |> where(
      [a],
      fragment("CAST(? AS DATE) >= ?", a.inserted_at, ^from) and
        fragment("CAST(? AS DATE) <= ?", a.inserted_at, ^to)
    )
  end

  defp handle_update_date_filter(query, %{
         "update_date_from" => update_date_from,
         "update_date_to" => update_date_to
       })
       when update_date_from == "" or is_nil(update_date_from) or update_date_to == "" or
              is_nil(update_date_to),
       do: query

  defp handle_update_date_filter(query, %{
         "update_date_from" => update_date_from,
         "update_date_to" => update_date_to
       }) do
    query
    |> where(
      [a],
      fragment("CAST(? AS DATE) >= ?", a.update_date, ^update_date_from) and
        fragment("CAST(? AS DATE) <= ?", a.update_date, ^update_date_to)
    )
  end

  # defp handle_update_date_filter(query, %{"update_date" => update_date})
  #      when update_date == "" or is_nil(update_date),
  #      do: query

  # defp handle_update_date_filter(query, %{"update_date" => update_date}) do
  #   query
  #   |> where(
  #     [a],
  #     fragment("CAST(? AS DATE) = ?", a.update_date, ^update_date)
  #   )
  # end

  defp handle_wagon_id_filter(query, %{"wagon_id" => wagon_id})
       when wagon_id == "" or is_nil(wagon_id),
       do: query

  defp handle_wagon_id_filter(query, %{"wagon_id" => wagon_id}) do
    where(query, [a, b], fragment("lower(?) LIKE lower(?)", b.code, ^"%#{wagon_id}%"))
  end

  defp handle_customer_id_filter(query, %{"customer_id" => customer_id})
       when customer_id == "" or is_nil(customer_id),
       do: query

  defp handle_customer_id_filter(query, %{"customer_id" => customer_id}) do
    where(query, [a], fragment("lower(?) LIKE lower(?)", a.customer_id, ^"%#{customer_id}%"))
  end

  defp handle_current_location_id_filter(query, %{"current_location_id" => current_location_id})
       when current_location_id == "" or is_nil(current_location_id),
       do: query

  defp handle_current_location_id_filter(query, %{"current_location_id" => current_location_id}) do
    where(query, [a], a.current_location_id == ^current_location_id)
  end

  defp handle_yard_siding_filter(query, %{"yard_siding" => yard_siding})
       when yard_siding == "" or is_nil(yard_siding),
       do: query

  defp handle_yard_siding_filter(query, %{"yard_siding" => yard_siding}) do
    where(query, [a], fragment("lower(?) LIKE lower(?)", a.yard_siding, ^"%#{yard_siding}%"))
  end

  defp handle_commodity_id_filter(query, %{"commodity_id" => commodity_id})
       when commodity_id == "" or is_nil(commodity_id),
       do: query

  defp handle_commodity_id_filter(query, %{"commodity_id" => commodity_id}) do
    # where(query, [a], fragment("lower(?) LIKE lower(?)", a.commodity_id, ^"%#{commodity_id}%"))
    where(query, [a], a.commodity_id == ^commodity_id)
  end

  defp handle_origin_id_filter(query, %{"origin_id" => origin_id})
       when origin_id == "" or is_nil(origin_id),
       do: query

  defp handle_origin_id_filter(query, %{"origin_id" => origin_id}) do
    where(query, [a], a.origin_id == ^origin_id)
  end

  defp handle_destination_id_filter(query, %{"destination_id" => destination_id})
       when destination_id == "" or is_nil(destination_id),
       do: query

  defp handle_destination_id_filter(query, %{"destination_id" => destination_id}) do
    where(query, [a], a.destination_id == ^destination_id)
  end

  defp handle_train_no_filter(query, %{"train_no" => train_no})
       when train_no == "" or is_nil(train_no),
       do: query

  defp handle_train_no_filter(query, %{"train_no" => train_no}) do
    where(query, [a], fragment("lower(?) LIKE lower(?)", a.train_no, ^"%#{train_no}%"))
  end

  defp compose_isearch_filter(query, search_term) do
    query
    |> where(
      [a, b, c, d, e, f, g, k, l, m, n, o, p],
      fragment("lower(?) LIKE lower(?)", b.code, ^search_term) or
        fragment("lower(?) LIKE lower(?)", l.client_name, ^search_term) or
        fragment("lower(?) LIKE lower(?)", a.update_date, ^search_term) or
        fragment("lower(?) LIKE lower(?)", k.description, ^search_term) or
        fragment("lower(?) LIKE lower(?)", f.description, ^search_term) or
        fragment("lower(?) LIKE lower(?)", e.description, ^search_term) or
        fragment("lower(?) LIKE lower(?)", a.origin_id, ^search_term) or
        fragment("lower(?) LIKE lower(?)", a.yard_siding, ^search_term) or
        fragment("lower(?) LIKE lower(?)", a.train_no, ^search_term) or
        fragment("lower(?) LIKE lower(?)", g.description, ^search_term)
    )
  end

  defp compose_report_select(query) do
    query
    |> select([a, b, c, d, e, f, g, k, l, m, n, o, p], %{
      id: a.id,
      update_date: a.update_date,
      region: o.description,
      domain: p.description,
      departure: a.departure,
      arrival: a.arrival,
      train_no: a.train_no,
      condition: m.description,
      yard_siding: a.yard_siding,
      sub_category: a.sub_category,
      comment: a.comment,
      net_ton: a.net_ton,
      bound: a.bound,
      allocated_to_customer: a.allocated_to_customer,
      wagon_id: a.wagon_id,
      current_location_id: a.current_location_id,
      condition_id: a.current_location_id,
      condition_description: m.description,
      commodity_id: a.commodity_id,
      current_location: g.description,
      customer_id: a.customer_id,
      client_name: l.client_name,
      origin_id: a.origin_id,
      destination_id: a.destination_id,
      maker_id: a.maker_id,
      checker_id: a.checker_id,
      inserted_at: a.inserted_at,
      updated_at: a.updated_at,
      month: a.month,
      origin_station: f.description,
      commodity: k.description,
      dest_station: e.description,
      wagon_status: a.id,
      year: a.year,
      wagon_code: b.code,
      wagon: b.code,
      wagon_type: c.description,
      wagon_owner: d.code,
      days_at: a.days_at,
      on_hire: a.on_hire
    })
  end

  def get_wagon_tracker_grouped_by_allocation(query) do
    query
    |> where([a], not is_nil(a.allocated_cust_id))
    |> join(:left, [a], b in Rms.SystemUtilities.Wagon, on: a.wagon_id == b.id)
    |> join(:left, [a, b], c in Rms.Accounts.RailwayAdministrator, on: b.owner_id == c.id)
    |> join(:left, [a, b, c], d in Rms.SystemUtilities.Country, on: c.country == d.code)
    |> join(:left, [a, b, c, d], e in Rms.SystemUtilities.Region, on: d.region_id == e.id)
    |> join(:left, [a, b, c, d, e], f in Rms.Accounts.Clients, on: a.allocated_cust_id == f.id)
    |> order_by([a, b, c, d, e, f], desc: [e.code, f.client_name])
    |> group_by([a, b, c, d, e, f], [e.code, f.client_name])
    |> select([a, b, c, d, e, f], %{
      count: count(a.id),
      customer: f.client_name,
      region: e.code
    })
  end

  def wagon_allocation_lookup(search_params, page, size, _user) do
    Rms.SystemUtilities.Wagon
    |> where([a], a.assigned == "YES")
    |> join(:left, [a], c in Rms.Accounts.RailwayAdministrator, on: a.owner_id == c.id)
    |> join(:left, [a, c], d in Rms.SystemUtilities.Country, on: c.country == d.code)
    |> join(:left, [a, c, d], e in Rms.SystemUtilities.Domain, on: a.domain_id == e.id)
    |> join(:left, [a, c, d, e], f in Rms.Accounts.Clients,
      on: a.allocated_cust_id == f.id and a.assigned == "YES"
    )
    |> handle_allocation_report_filter(search_params)
    |> compose_report_select_by_allocation()
    |> Repo.paginate(page: page, page_size: size)
  end

  def wagon_allocation_lookup(_source, search_params, _user) do
    Rms.SystemUtilities.Wagon
    |> where([a], a.assigned == "YES")
    |> join(:left, [a], c in Rms.Accounts.RailwayAdministrator, on: a.owner_id == c.id)
    |> join(:left, [a, c], d in Rms.SystemUtilities.Country, on: c.country == d.code)
    |> join(:left, [a, c, d], e in Rms.SystemUtilities.Domain, on: a.domain_id == e.id)
    |> join(:left, [a, c, d, e], f in Rms.Accounts.Clients,
      on: a.allocated_cust_id == f.id and a.assigned == "YES"
    )
    |> handle_allocation_report_filter(search_params)
    |> compose_report_select_by_allocation()
  end

  defp handle_allocation_report_filter(query, %{"isearch" => search_term} = search_params)
       when search_term == "" or is_nil(search_term) do
    query
    |> handle_customer_filter(search_params)
    |> handle_domain_filter(search_params)
    |> handle_allocation_date_filter(search_params)
  end

  defp handle_allocation_report_filter(query, %{"isearch" => search_term}) do
    search_term = "%#{search_term}%"
    compose_allocation_isearch_filter(query, search_term)
  end

  defp handle_customer_filter(query, %{"customer_ids" => customer_ids})
       when customer_ids == "" or is_nil(customer_ids),
       do: query

  defp handle_customer_filter(query, %{"customer_ids" => customer_ids}) do
    where(query, [a], a.allocated_cust_id == ^customer_ids)
  end

  defp handle_allocation_date_filter(query, %{"from" => from, "to" => to})
       when byte_size(from) > 0 and byte_size(to) > 0 do
    query
    |> where(
      [a],
      fragment("CAST(? AS DATE) >= ?", a.inserted_at, ^from) and
        fragment("CAST(? AS DATE) <= ?", a.inserted_at, ^to)
    )
  end

  defp handle_allocation_date_filter(query, _params), do: query

  defp compose_allocation_isearch_filter(query, search_term) do
    query
    |> where(
      [a, c, d, e, f],
      fragment("lower(?) LIKE lower(?)", f.client_name, ^search_term) or
        fragment("lower(?) LIKE lower(?)", e.description, ^search_term)
    )
  end

  defp compose_report_select_by_allocation(query) do
    query
    |> where([a, c, d, e, f], not is_nil(a.allocated_cust_id))
    |> order_by([a, c, d, e, f], desc: [e.description, f.client_name])
    |> group_by([a, c, d, e, f], [e.description, f.client_name, a.domain_id])
    |> select([a, c, d, e, f], %{
      count: count(a.id),
      customer: f.client_name,
      region: e.description,
      region_id: a.domain_id
    })
  end

  def get_wagon_yard_position(query) do
    query
    |> group_by([b, c, d, e], [c.description, d.code, b.wagon_symbol, e.code])
    |> select([b, c, d, e], %{
      count: count(b.id),
      current_location: c.description,
      owner: d.code,
      wagon_symbol: b.wagon_symbol,
      commodity: e.code
    })
  end

  def get_all_wagon_yard_position(search_params, page, size, _user) do
    Rms.SystemUtilities.Wagon
    |> where([b], not is_nil(b.station_id) and not is_nil(b.owner_id) and not is_nil(b.commodity_id))
    |> join(:left, [b], c in Rms.SystemUtilities.Station, on: b.station_id == c.id)
    |> join(:left, [b, c], d in Rms.Accounts.RailwayAdministrator, on: b.owner_id == d.id)
    |> join(:left, [b, c, d], e in Rms.SystemUtilities.Commodity, on: b.commodity_id == e.id)
    |> order_by([b, c, d, e, f], desc: [c.description, d.code, b.wagon_symbol])
    |> handle_yard_report_filter(search_params)
    |> get_wagon_yard_position()
    |> Repo.paginate(page: page, page_size: size)
  end

  def get_all_wagon_yard_position(_source, search_params, _user) do
    Rms.SystemUtilities.Wagon
    |> where([b], not is_nil(b.station_id) and not is_nil(b.owner_id) and not is_nil(b.commodity_id))
    |> join(:left, [b], c in Rms.SystemUtilities.Station, on: b.station_id == c.id)
    |> join(:left, [b, c], d in Rms.Accounts.RailwayAdministrator, on: b.owner_id == d.id)
    |> join(:left, [b, c, d], e in Rms.SystemUtilities.Commodity, on: b.commodity_id == e.id)
    |> order_by([b, c, d, e, f], desc: [c.description, d.code, b.wagon_symbol])
    |> handle_yard_report_filter(search_params)
    |> get_wagon_yard_position()
  end

  defp handle_yard_report_filter(query, %{"isearch" => search_term} = search_params)
       when search_term == "" or is_nil(search_term) do
    query
    |> handle_current_position_filter(search_params)
    |> handle_wagon_ownder_filter(search_params)
    |> handle_commodity_filter(search_params)
    |> handle_wagon_yard_date_filter(search_params)
  end

  defp handle_yard_report_filter(query, %{"isearch" => search_term}) do
    search_term = "%#{search_term}%"
    compose_yard_isearch_filter(query, search_term)
  end

  defp handle_current_position_filter(query, %{"current_location_ids" => current_location_ids})
       when current_location_ids == "" or is_nil(current_location_ids),
       do: query

  defp handle_current_position_filter(query, %{"current_location_ids" => current_location_ids}) do
    where(query, [a], a.station_id == ^current_location_ids)
  end

  defp handle_wagon_ownder_filter(query, %{"wagon_owner_ids" => wagon_owner_ids})
       when wagon_owner_ids == "" or is_nil(wagon_owner_ids),
       do: query

  defp handle_wagon_ownder_filter(query, %{"wagon_owner_ids" => wagon_owner_ids}) do
    where(query, [a], a.owner_id == ^wagon_owner_ids)
  end

  defp handle_commodity_filter(query, %{"commodity_ids" => commodity_ids})
       when commodity_ids == "" or is_nil(commodity_ids),
       do: query

  defp handle_commodity_filter(query, %{"commodity_ids" => commodity_ids}) do
    where(query, [a], a.commodity_id == ^commodity_ids)
  end

  defp handle_wagon_yard_date_filter(query, %{"from" => from, "to" => to})
       when byte_size(from) > 0 and byte_size(to) > 0 do
    query
    |> where(
      [a],
      fragment("CAST(? AS DATE) >= ?", a.inserted_at, ^from) and
        fragment("CAST(? AS DATE) <= ?", a.inserted_at, ^to)
    )
  end

  defp handle_wagon_yard_date_filter(query, _params), do: query

  defp compose_yard_isearch_filter(query, search_term) do
    query
    |> where(
      [b, c, d, e],
      fragment("lower(?) LIKE lower(?)", c.description, ^search_term) or
        fragment("lower(?) LIKE lower(?)", d.code, ^search_term) or
        fragment("lower(?) LIKE lower(?)", e.code, ^search_term) or
        fragment("lower(?) LIKE lower(?)", b.wagon_symbol, ^search_term)
    )
  end

  def get_wagon_daily_position() do
    WagonTracking
    |> join(:left, [a], b in Rms.SystemUtilities.Wagon, on: a.wagon_id == b.id)
    |> join(:left, [a, b], c in Rms.SystemUtilities.Station, on: a.current_location_id == c.id)
    |> join(:left, [a, b, c], d in Rms.SystemUtilities.Status, on: a.departure == d.id)
    |> order_by([a, b, c, d], desc: [a.on_hire])
    |> group_by([a, b, c, d], [a.on_hire])
    |> select([a, b, c, d], %{
      hire_status: a.on_hire,
      count_available: count(a.on_hire)
    })
    |> Repo.all()
  end

  def get_delayed_wagon(query) do
    query
    |> join(:left, [a], b in Rms.SystemUtilities.Wagon, on: a.wagon_id == b.id)
    |> join(:left, [a, b], c in Rms.SystemUtilities.Status, on: a.departure == c.id)
    |> order_by([a, b, c], desc: [a.days_at, a.wagon_id, b.code, c.description, a.on_hire])
    |> group_by([a, b, c], [a.days_at, a.wagon_id, b.code, c.description, a.on_hire])
    |> select([a, b, c], %{
      count: count(a.id),
      wagon: b.code,
      days: a.days_at,
      wagon_id: a.wagon_id,
      wagon_status: c.description,
      hire_status: a.on_hire
    })
  end

  def get_all_wagons_delayed(_search_params, page, size, _user) do
    WagonTracking
    |> get_delayed_wagon()
    |> Repo.paginate(page: page, page_size: size)
  end

  # CSV Report
  def get_all_wagons_delayed(_source, _search_params, _user) do
    WagonTracking
    |> get_delayed_wagon()
  end

  def wagons_by_condition_select(query) do
    query
    |> group_by([a, b, c], [c.description, b.description])
    |> select([a, b, c], %{
      count: count(a.id),
      domain: b.description,
      condition: c.description
    })
  end

  def get_all_wagons_by_condition(search_params, page, size, _user) do
    Rms.SystemUtilities.Wagon
    |> where([a], not is_nil(a.domain_id) and not is_nil(a.condition_id))
    |> join(:left, [a], b in Rms.SystemUtilities.Domain, on: a.domain_id == b.id)
    |> join(:left, [a, b], c in Rms.SystemUtilities.Condition, on: a.condition_id == c.id)
    |> order_by([a, b, c], desc: [c.description, b.description])
    |> handle_wagon_by_condition_report_filter(search_params)
    |> wagons_by_condition_select()
    |> Repo.paginate(page: page, page_size: size)
  end

  # CSV Report
  def get_all_wagons_by_condition(_source, search_params, _user) do
    Rms.SystemUtilities.Wagon
    |> where([a], not is_nil(a.domain_id) and not is_nil(a.condition_id))
    |> join(:left, [a], b in Rms.SystemUtilities.Domain, on: a.domain_id == b.id)
    |> join(:left, [a, b], c in Rms.SystemUtilities.Condition, on: a.condition_id == c.id)
    |> order_by([a, b, c], desc: [c.description, b.description])
    |> handle_wagon_by_condition_report_filter(search_params)
    |> wagons_by_condition_select()
  end

  defp handle_wagon_by_condition_report_filter(query, %{"isearch" => search_term} = search_params)
       when search_term == "" or is_nil(search_term) do
    query
    |> handle_wagon_condition_by_doman_filter(search_params)
    |> handle_condition_filter(search_params)
    |> handle_wagon_condition_by_date_filter(search_params)
  end

  defp handle_wagon_by_condition_report_filter(query, %{"isearch" => search_term}) do
    search_term = "%#{search_term}%"
    compose_wagon_by_condition_isearch_filter(query, search_term)
  end

  defp handle_wagon_condition_by_doman_filter(query, %{"domain_id" => domain_id})
       when domain_id == "" or is_nil(domain_id),
       do: query

  defp handle_wagon_condition_by_doman_filter(query, %{"domain_id" => domain_id}) do
    where(query, [a, b, c], a.domain_id == ^domain_id)
  end

  defp handle_condition_filter(query, %{"wagon_condition_id" => wagon_condition_id})
       when wagon_condition_id == "" or is_nil(wagon_condition_id),
       do: query

  defp handle_condition_filter(query, %{"wagon_condition_id" => wagon_condition_id}) do
    where(query, [a, b, c], a.condition_id == ^wagon_condition_id)
  end

  defp handle_wagon_condition_by_date_filter(query, %{"from" => from, "to" => to})
       when byte_size(from) > 0 and byte_size(to) > 0 do
    query
    |> where(
      [a, b, c],
      fragment("CAST(? AS DATE) >= ?", a.inserted_at, ^from) and
        fragment("CAST(? AS DATE) <= ?", a.inserted_at, ^to)
    )
  end

  defp handle_wagon_condition_by_date_filter(query, _params), do: query

  defp compose_wagon_by_condition_isearch_filter(query, search_term) do
    query
    |> where(
      [a, b, c],
      fragment("lower(?) LIKE lower(?)", c.description, ^search_term) or
        fragment("lower(?) LIKE lower(?)", b.description, ^search_term)
    )
  end

  def get_wagon_tracker_grouped_by_wagon_symbol() do
    WagonTracking
    |> join(:left, [a], b in Rms.SystemUtilities.Wagon, on: a.wagon_id == b.id)
    |> join(:left, [a, b], c in Rms.SystemUtilities.Status, on: a.departure == c.id)
    |> join(:left, [a, b, c], d in Rms.SystemUtilities.Domain, on: a.domain_id == d.id)
    |> order_by([a, b, c, d], desc: [d.description, b.load_status])
    |> group_by([a, b, c, d], [
      b.wagon_symbol,
      b.load_status,
      d.description,
      a.departure,
      a.domain_id
    ])
    |> select([a, b, c, d], %{
      count: count(a.id),
      status: b.load_status,
      domain: d.description,
      wagon_symbol: b.wagon_symbol
    })
    |> Repo.all()
  end

  def delayed_wagons_3 do
    WagonTracking
    |> where([a], fragment("? BETWEEN ? AND ?", a.days_at, 0, 3))
    |> join(:left, [a], b in Rms.SystemUtilities.Wagon, on: a.wagon_id == b.id)
    |> join(:left, [a, b], c in Rms.SystemUtilities.Status, on: a.departure == c.id)
    |> join(:left, [a, b, c], d in Rms.SystemUtilities.Domain, on: a.domain_id == d.id)
    |> order_by([a, b, c, d], desc: [b.load_status])
    |> group_by([a, b, c, d], [b.load_status])
    |> select([a, b, c, d], %{
      count_all: count(a.id),
      status: b.load_status
    })
    |> Repo.all()
  end

  def delayed_wagons_lookup(start_end, end_date) do
    WagonTracking
    |> where(
      [a],
      fragment("CAST(? AS DATE) >= ?", a.inserted_at, ^start_end) and
        fragment("CAST(? AS DATE) <= ?", a.inserted_at, ^end_date)
    )
    |> join(:left, [a], b in Wagon, on: a.wagon_id == b.id)
    |> join(:inner, [a, b], c in Rms.SystemUtilities.CompanyInfo,
      on: b.owner_id == c.current_railway_admin
    )
    |> group_by([a, b, c], [
      fragment(
        """
        CASE

          WHEN ? BETWEEN 4 and 6 THEN '4-6 days'
          WHEN ? BETWEEN 7 and 13 THEN '7-13 days'
          WHEN ? BETWEEN 14 and 29 THEN '14-29 days'
          WHEN ? BETWEEN 30 and 90 THEN '1-3 months'
          WHEN ? BETWEEN 91 and 180 THEN '3-6 months'
          WHEN days_at > 180 THEN 'Over 6 months'
        END
        """,
        a.days_at,
        a.days_at,
        a.days_at,
        a.days_at,
        a.days_at
      ),
      b.load_status
    ])
    |> where([_a, b, c], b.owner_id == c.current_railway_admin)
    |> select([a, b, c],
      count: fragment("count(1)"),
      status: b.load_status,
      period:
        fragment(
          """
          CASE
            WHEN ? BETWEEN 4 and 6 THEN '4-6 days'
            WHEN ? BETWEEN 7 and 13 THEN '7-13 days'
            WHEN ? BETWEEN 14 and 29 THEN '14-29 days'
            WHEN ? BETWEEN 30 and 90 THEN '1-3 months'
            WHEN ? BETWEEN 91 and 180 THEN '3-6 months'
            WHEN days_at > 180 THEN 'Over 6 months'
          END
          """,
          a.days_at,
          a.days_at,
          a.days_at,
          a.days_at,
          a.days_at
        )
    )
    |> Repo.all()
    |> Enum.map(&Enum.into(&1, %{}))
  end

  def count_wagons(start_end, end_date) do
    WagonTracking
    |> where(
      [a],
      fragment("CAST(? AS DATE) >= ?", a.inserted_at, ^start_end) and
        fragment("CAST(? AS DATE) <= ?", a.inserted_at, ^end_date)
    )
    |> where([a], fragment("? > ? ", a.days_at, 3))
    |> join(:left, [a], b in Rms.SystemUtilities.Wagon, on: a.wagon_id == b.id)
    |> join(:left, [a, b], c in Rms.SystemUtilities.CompanyInfo,
      on: b.owner_id == c.current_railway_admin
    )
    |> order_by([a, b, c], desc: [b.load_status])
    |> group_by([a, b, c], [b.load_status])
    |> where([_a, b, c], b.owner_id == c.current_railway_admin)
    |> select([a, b], %{
      count_all: count(a.id),
      status: count(b.load_status),
      wagon_status: b.load_status
    })
    |> Repo.all()
  end

  def bad_order_lookup do
    Wagon
    |> join(:inner, [a], b in Rms.SystemUtilities.Condition, on: a.condition_id == b.id)
    |> order_by([a, b], desc: [a.condition_id])
    |> group_by([a, b], [a.condition_id])
    |> select([a, b], %{
      date:
        fragment(
          "FORMAT(cast(DATEADD(day, -1, CAST(GETDATE() AS date)) as date), 'MM-dd-yy', 'en-US')"
        ),
      conditon_id: a.condition_id,
      commulative_loaded:
        fragment(
          """
            count(case
              when ? = 'L' then ?
              else null
            end)
          """,
          a.load_status,
          a.id
        ),
      count_active:
        fragment(
          """
            count(case
              when ? = 'A' then ?
              else null
            end)
          """,
          a.mvt_status,
          a.id
        ),
      non_act_count:
        fragment(
          """
            count(case
              when ? = 'N' then ?
              else null
            end)
          """,
          a.mvt_status,
          a.id
        ),
      total_wagons: count(a.id),
      curr_loaded:
        fragment(
          """
          select count(t.id)
          from tbl_wagon_tracking as t
          inner join tbl_commodity as c
          on t.commodity_id = c.id
          where
            c.load_status = 'L'
            and t.condition_id = ?
            and t.update_date = cast(DATEADD(day, -1, CAST(GETDATE() AS date)) as date)
          """,
          a.condition_id
        )
    })
    |> Repo.all()
  end

  def wagon_load_status_lookup() do
    start_end = Timex.today() |> to_string()
    end_date = Timex.today() |> to_string()

    WagonTracking
    |> where([a, b], b.load_status == "L")
    |> where(
      [a, b],
      fragment("CAST(? AS DATE) >= ?", b.inserted_at, ^start_end) and
        fragment("CAST(? AS DATE) <= ?", b.inserted_at, ^end_date)
    )
    |> join(:left, [a], b in Rms.SystemUtilities.Wagon, on: a.wagon_id == b.id)
    |> order_by([a, b],
      desc: [fragment("FORMAT(?, 'MM-dd-yy', 'en-US')", b.inserted_at), b.load_status]
    )
    |> group_by([a, b], [fragment("FORMAT(?, 'MM-dd-yy', 'en-US')", b.inserted_at), b.load_status])
    |> select([a, b], %{
      load_status_date: fragment("FORMAT(?, 'MM-dd-yy', 'en-US')", b.inserted_at),
      load_status: b.load_status,
      curr_loaded: count(b.load_status)
    })
    |> Repo.all()
  end

  def wagon_daily_log do
    load_params = Rms.Tracking.wagon_load_status_lookup() |> Enum.at(0)
    bo_params = Rms.Tracking.bad_order_lookup()

    Enum.each(bo_params, fn item ->
      Map.merge(load_params, item)
    end)
  end

  # def bad_order_lookup_by_cond(_search_params, page, size, _user, start_end, end_date) do
  #   WagonTracking
  #   |> bad_order_lookup(start_end, end_date)
  #   |> Repo.paginate(page: page, page_size: size)
  # end

  # # CSV Report
  # def bad_order_lookup_by_cond(_source, _search_params, _user, start_end, end_date) do
  #   WagonTracking
  #   |> bad_order_lookup(start_end, end_date)
  # end

  alias Rms.Tracking.WagonLog

  @doc """
  Returns the list of tbl_wagon_status_daily_log.

  ## Examples

      iex> list_tbl_wagon_status_daily_log()
      [%WagonLog{}, ...]

  """
  def list_tbl_wagon_status_daily_log do
    Repo.all(WagonLog)
  end

  @doc """
  Gets a single wagon_log.

  Raises `Ecto.NoResultsError` if the Wagon log does not exist.

  ## Examples

      iex> get_wagon_log!(123)
      %WagonLog{}

      iex> get_wagon_log!(456)
      ** (Ecto.NoResultsError)

  """
  def get_wagon_log!(id), do: Repo.get!(WagonLog, id)

  @doc """
  Creates a wagon_log.

  ## Examples

      iex> create_wagon_log(%{field: value})
      {:ok, %WagonLog{}}

      iex> create_wagon_log(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_wagon_log(attrs \\ %{}) do
    %WagonLog{}
    |> WagonLog.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a wagon_log.

  ## Examples

      iex> update_wagon_log(wagon_log, %{field: new_value})
      {:ok, %WagonLog{}}

      iex> update_wagon_log(wagon_log, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_wagon_log(%WagonLog{} = wagon_log, attrs) do
    wagon_log
    |> WagonLog.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a wagon_log.

  ## Examples

      iex> delete_wagon_log(wagon_log)
      {:ok, %WagonLog{}}

      iex> delete_wagon_log(wagon_log)
      {:error, %Ecto.Changeset{}}

  """
  def delete_wagon_log(%WagonLog{} = wagon_log) do
    Repo.delete(wagon_log)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking wagon_log changes.

  ## Examples

      iex> change_wagon_log(wagon_log)
      %Ecto.Changeset{data: %WagonLog{}}

  """
  def change_wagon_log(%WagonLog{} = wagon_log, attrs \\ %{}) do
    WagonLog.changeset(wagon_log, attrs)
  end

  def wagon_days_lookup(days) do
    Wagon
    |> join(:inner, [a], b in WagonTracking, on: a.id == b.wagon_id)
    |> select([a, b], a.id)
    |> where([a, b], a.mvt_status == "A" and b.days_at > ^days)
    |> distinct(true)
    |> order_by([a], a.id)
    |> Repo.all()
  end

  def bad_order_average_lookup(query) do
    query
    |> join(:inner, [a], b in Rms.SystemUtilities.Condition, on: a.conditon_id == b.id)
    |> order_by([a, b], desc: [fragment("cast(? as date)", a.date)])
    |> select([a, b], %{
      date: fragment("cast(? as date)", a.date),
      condition: b.code,
      curr_loaded: a.curr_loaded,
      commulative_loaded: a.commulative_loaded,
      count_active: a.count_active,
      non_act_count: a.non_act_count,
      total_wagons: a.total_wagons,
      utilization:
        coalesce(
          fragment(
            """
            select sum(t.commulative_loaded)
              from tbl_wagon_status_daily_log as t
              inner join tbl_condition as c
              on t.conditon_id = c.id
              where
              c.code = 'GO'
              and t.date = ?
              and c.id = ?
            """,
            a.date,
            a.conditon_id
          ) /
            fragment(
              """
              select sum(t.total_wagons)
                from tbl_wagon_status_daily_log as t
                inner join tbl_condition as c
                on t.conditon_id = c.id
                where
                c.code = 'GO'
                and t.date = ?
                and c.id = ?
              """,
              a.date,
              a.conditon_id
            ),
          0
        ),
      daily_utilization:
        coalesce(
          fragment(
            """
            select sum(t.curr_loaded)
              from tbl_wagon_status_daily_log as t
              inner join tbl_condition as c
              on t.conditon_id = c.id
              where
              c.code = 'GO'
              and t.date = ?
              and c.id = ?
            """,
            a.date,
            a.conditon_id
          ) /
            fragment(
              """
              select sum(t.total_wagons)
                from tbl_wagon_status_daily_log as t
                inner join tbl_condition as c
                on t.conditon_id = c.id
                where
                c.code = 'GO'
                and t.date = ?
                and c.id = ?
              """,
              a.date,
              a.conditon_id
            ),
          0
        ),
      reliability:
        coalesce(
          coalesce(
            coalesce(
              fragment(
                """
                select sum(t.total_wagons)
                  from tbl_wagon_status_daily_log as t
                  inner join tbl_condition as c
                  on t.conditon_id = c.id
                  where
                  c.code = 'GO'
                  and t.date = ?
                  and c.id = ?
                """,
                a.date,
                a.conditon_id
              ),
              0
            ) -
              (coalesce(
                 fragment(
                   """
                   select sum(t.total_wagons)
                     from tbl_wagon_status_daily_log as t
                     inner join tbl_condition as c
                     on t.conditon_id = c.id
                     where
                     c.code = 'RX Stopped' or  c.code = 'Rx stopped'
                     and t.date = ?
                     and c.id = ?
                   """,
                   a.date,
                   a.conditon_id
                 ),
                 0
               ) +
                 coalesce(
                   fragment(
                     """
                     select sum(t.total_wagons)
                       from tbl_wagon_status_daily_log as t
                       inner join tbl_condition as c
                       on t.conditon_id = c.id
                       where
                       c.code = 'YX Stopped' or  c.code = 'Yx stopped'
                       and t.date = ?
                       and c.id = ?
                     """,
                     a.date,
                     a.conditon_id
                   ),
                   0
                 )),
            0
          ) /
            fragment(
              """
              select sum(t.total_wagons)
                from tbl_wagon_status_daily_log as t
                inner join tbl_condition as c
                on t.conditon_id = c.id
                where
                c.code = 'GO'
                and t.date = ?
                and c.id = ?
              """,
              a.date,
              a.conditon_id
            ),
          0
        )
    })
  end

  def get_bad_order_average(search_params, page, size, _user) do
    WagonLog
    |> handle_bad_order_report_filter(search_params)
    |> bad_order_average_lookup()
    |> Repo.paginate(page: page, page_size: size)
  end

  def get_bad_order_average(_source, search_params, _user) do
    WagonLog
    |> handle_bad_order_report_filter(search_params)
    |> bad_order_average_lookup()
  end

  defp handle_bad_order_report_filter(query, %{"isearch" => search_term} = search_params)
       when search_term == "" or is_nil(search_term) do
    query
    |> handle_bad_order_condition_filter(search_params)
    |> handle_bad_order_date_filter(search_params)
  end

  defp handle_bad_order_report_filter(query, %{"isearch" => search_term}) do
    search_term = "%#{search_term}%"
    compose_bad_order_isearch_filter(query, search_term)
  end

  defp handle_bad_order_condition_filter(query, %{"bo_wagon_condition" => bo_wagon_condition})
       when bo_wagon_condition == "" or is_nil(bo_wagon_condition),
       do: query

  defp handle_bad_order_condition_filter(query, %{"bo_wagon_condition" => bo_wagon_condition}) do
    where(
      query,
      [a],
      fragment("lower(?) LIKE lower(?)", a.conditon_id, ^"%#{bo_wagon_condition}%")
    )
  end

  defp handle_bad_order_date_filter(query, %{"from" => from, "to" => to})
       when byte_size(from) > 0 and byte_size(to) > 0 do
    query
    |> where(
      [a],
      fragment("CAST(? AS DATE) >= ?", a.inserted_at, ^from) and
        fragment("CAST(? AS DATE) <= ?", a.inserted_at, ^to)
    )
  end

  defp handle_bad_order_date_filter(query, _params), do: query

  defp compose_bad_order_isearch_filter(query, search_term) do
    query
    |> where(
      [a],
      fragment("lower(?) LIKE lower(?)", a.conditon_id, ^search_term)
    )
  end

  alias Rms.Tracking.WagonTrkSpares

  @doc """
  Returns the list of tbl_wagon_tracking_defect_spares.

  ## Examples

      iex> list_tbl_wagon_tracking_defect_spares()
      [%WagonTrkSpares{}, ...]

  """
  def list_tbl_wagon_tracking_defect_spares do
    Repo.all(WagonTrkSpares)
  end

  @doc """
  Gets a single wagon_trk_spares.

  Raises `Ecto.NoResultsError` if the Wagon trk spares does not exist.

  ## Examples

      iex> get_wagon_trk_spares!(123)
      %WagonTrkSpares{}

      iex> get_wagon_trk_spares!(456)
      ** (Ecto.NoResultsError)

  """
  def get_wagon_trk_spares!(id), do: Repo.get!(WagonTrkSpares, id)

  @doc """
  Creates a wagon_trk_spares.

  ## Examples

      iex> create_wagon_trk_spares(%{field: value})
      {:ok, %WagonTrkSpares{}}

      iex> create_wagon_trk_spares(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_wagon_trk_spares(attrs \\ %{}) do
    %WagonTrkSpares{}
    |> WagonTrkSpares.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a wagon_trk_spares.

  ## Examples

      iex> update_wagon_trk_spares(wagon_trk_spares, %{field: new_value})
      {:ok, %WagonTrkSpares{}}

      iex> update_wagon_trk_spares(wagon_trk_spares, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_wagon_trk_spares(%WagonTrkSpares{} = wagon_trk_spares, attrs) do
    wagon_trk_spares
    |> WagonTrkSpares.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a wagon_trk_spares.

  ## Examples

      iex> delete_wagon_trk_spares(wagon_trk_spares)
      {:ok, %WagonTrkSpares{}}

      iex> delete_wagon_trk_spares(wagon_trk_spares)
      {:error, %Ecto.Changeset{}}

  """
  def delete_wagon_trk_spares(%WagonTrkSpares{} = wagon_trk_spares) do
    Repo.delete(wagon_trk_spares)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking wagon_trk_spares changes.

  ## Examples

      iex> change_wagon_trk_spares(wagon_trk_spares)
      %Ecto.Changeset{data: %WagonTrkSpares{}}

  """
  def change_wagon_trk_spares(%WagonTrkSpares{} = wagon_trk_spares, attrs \\ %{}) do
    WagonTrkSpares.changeset(wagon_trk_spares, attrs)
  end

  def defect_spares_lookup(tracker_id, wagon_id) do
    WagonTrkSpares
    |> where([a], a.tracker_id == ^tracker_id and a.wagon_id == ^wagon_id)
    |> join(:left, [a], b in Rms.SystemUtilities.Spare, on: a.spare_id == b.id)
    |> join(:left, [a, b], c in Rms.SystemUtilities.SpareFee,
      on:
        a.spare_id == c.spare_id and fragment("CAST(? AS DATE) >= ?", a.inserted_at, c.start_date)
    )
    |> select([a, b, c], %{
      code: b.code,
      spare: b.description,
      quantity: a.quantity,
      cost: c.amount
    })
    |> Repo.all()
  end

  alias Rms.Tracking.Material

  @doc """
  Returns the list of tbl_interchange_material.

  ## Examples

      iex> list_tbl_interchange_material()
      [%Material{}, ...]

  """
  def list_tbl_interchange_material do
    Repo.all(Material)
  end

  @doc """
  Gets a single material.

  Raises `Ecto.NoResultsError` if the Material does not exist.

  ## Examples

      iex> get_material!(123)
      %Material{}

      iex> get_material!(456)
      ** (Ecto.NoResultsError)

  """
  def get_material!(id), do: Repo.get!(Material, id)

  @doc """
  Creates a material.

  ## Examples

      iex> create_material(%{field: value})
      {:ok, %Material{}}

      iex> create_material(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_material(attrs \\ %{}) do
    %Material{}
    |> Material.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a material.

  ## Examples

      iex> update_material(material, %{field: new_value})
      {:ok, %Material{}}

      iex> update_material(material, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_material(%Material{} = material, attrs) do
    material
    |> Material.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a material.

  ## Examples

      iex> delete_material(material)
      {:ok, %Material{}}

      iex> delete_material(material)
      {:error, %Ecto.Changeset{}}

  """
  def delete_material(%Material{} = material) do
    Repo.delete(material)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking material changes.

  ## Examples

      iex> change_material(material)
      %Ecto.Changeset{data: %Material{}}

  """
  def change_material(%Material{} = material, attrs \\ %{}) do
    Material.changeset(material, attrs)
  end

  def material_report_lookup(search_params, page, size, _user) do
    Material
    |> join(:left, [a], b in Rms.SystemUtilities.Spare, on: a.spare_id == b.id)
    |> join(:left, [a, b], c in Rms.Accounts.RailwayAdministrator, on: a.admin_id == c.id)
    |> join(:left, [a, b, c], d in Rms.Accounts.User, on: a.maker_id == d.id)
    |> join(:left, [a, b, c, d], e in Rms.SystemUtilities.Currency, on: a.currency_id == e.id)
    |> order_by([a, b, c, d, e], desc: [a.id])
    |> handle_material_report_filter(search_params)
    |> compose_material_report_select()
    |> Repo.paginate(page: page, page_size: size)
  end

  def material_report_lookup(_source, search_params, _user) do
    Material
    |> join(:left, [a], b in Rms.SystemUtilities.Spare, on: a.spare_id == b.id)
    |> join(:left, [a, b], c in Rms.Accounts.RailwayAdministrator, on: a.admin_id == c.id)
    |> join(:left, [a, b, c], d in Rms.Accounts.User, on: a.maker_id == d.id)
    |> join(:left, [a, b, c, d], e in Rms.SystemUtilities.Currency, on: a.currency_id == e.id)
    |> order_by([a, b, c, d, e], desc: [a.id])
    |> handle_material_report_filter(search_params)
    |> compose_material_report_select()
  end

  defp handle_material_report_filter(query, %{"isearch" => search_term} = search_params)
       when search_term == "" or is_nil(search_term) do
    query
    |> handle_material_date_filter(search_params)
    |> handle_equipment_filter(search_params)
    |> handle_material_administrator_filter(search_params)
    |> handle_date_received_filter(search_params)
    |> handle_date_sent_filter(search_params)
    |> handle_material_direction_filter(search_params)
  end

  defp handle_material_report_filter(query, %{"isearch" => search_term, "direction" => direction}) do
    search_term = "%#{search_term}%"
    compose_material_isearch_filter(query, search_term, direction)
  end

  defp handle_material_date_filter(query, %{"from" => from, "to" => to})
       when from == "" or is_nil(from) or to == "" or is_nil(to),
       do: query

  defp handle_material_date_filter(query, %{"from" => from, "to" => to}) do
    query
    |> where(
      [a],
      fragment("CAST(? AS DATE) >= ?", a.inserted_at, ^from) and
        fragment("CAST(? AS DATE) <= ?", a.inserted_at, ^to)
    )
  end

  defp handle_equipment_filter(query, %{"equipment" => equipment})
       when equipment == "" or is_nil(equipment),
       do: query

  defp handle_equipment_filter(query, %{"equipment" => equipment}) do
    where(query, [a], a.spare_id == ^equipment)
  end

  defp handle_material_administrator_filter(query, %{"administrator" => administrator})
       when administrator == "" or is_nil(administrator),
       do: query

  defp handle_material_administrator_filter(query, %{"administrator" => administrator}) do
    where(query, [a], a.admin_id == ^administrator)
  end

  defp handle_date_received_filter(query, %{
         "date_received_from" => date_received_from,
         "date_received_to" => date_received_to
       })
       when date_received_from == "" or is_nil(date_received_from) or date_received_to == "" or
              is_nil(date_received_to),
       do: query

  defp handle_date_received_filter(query, %{
         "date_received_from" => date_received_from,
         "date_received_to" => date_received_to
       }) do
    query
    |> where(
      [a],
      fragment("CAST(? AS DATE) >= ?", a.date_received, ^date_received_from) and
        fragment("CAST(? AS DATE) <= ?", a.date_received, ^date_received_to)
    )
  end

  defp handle_date_sent_filter(query, %{
         "date_sent_from" => date_sent_from,
         "date_sent_to" => date_sent_to
       })
       when date_sent_from == "" or is_nil(date_sent_from) or date_sent_to == "" or
              is_nil(date_sent_to),
       do: query

  defp handle_date_sent_filter(query, %{
         "date_sent_from" => date_sent_from,
         "date_sent_to" => date_sent_to
       }) do
    query
    |> where(
      [a],
      fragment("CAST(? AS DATE) >= ?", a.date_sent, ^date_sent_from) and
        fragment("CAST(? AS DATE) <= ?", a.date_sent, ^date_sent_to)
    )
  end

  defp handle_material_direction_filter(query, %{"direction" => direction})
       when direction == "" or is_nil(direction),
       do: query

  defp handle_material_direction_filter(query, %{"direction" => direction}) do
    where(
      query,
      [a],
      fragment("lower(?) LIKE lower(?)", a.direction, ^"%#{direction}%")
    )
  end

  defp compose_material_isearch_filter(query, search_term, direction) do
    query
    |> where([a, b, c, d, e], a.direction == ^direction)
    |> where(
      [a, b, c, d, e],
      fragment("lower(?) LIKE lower(?)", b.description, ^search_term) or
        fragment("lower(?) LIKE lower(?)", b.code, ^search_term) or
        fragment("lower(?) LIKE lower(?)", c.description, ^search_term) or
        fragment("lower(?) LIKE lower(?)", c.code, ^search_term) or
        fragment("lower(?) LIKE lower(?)", a.amount, ^search_term) or
        fragment("lower(?) LIKE lower(?)", a.fin_year, ^search_term)
    )
  end

  defp compose_material_report_select(query) do
    query
    |> select([a, b, c, d, e], %{
      id: a.id,
      direction: a.direction,
      date_sent: a.date_sent,
      date_received: a.date_received,
      status: a.status,
      equipment_id: a.equipment_id,
      equipment: b.description,
      symbol: e.symbol,
      administrator: c.description,
      admin_id: a.admin_id,
      maker_id: a.maker_id,
      inserted_at: a.inserted_at,
      updated_at: a.updated_at,
      year: a.fin_year,
      amount: a.amount
    })
  end

  alias Rms.Tracking.Auxiliary

  @doc """
  Returns the list of tbl_interchange_auxiliary.

  ## Examples

      iex> list_tbl_interchange_auxiliary()
      [%Auxiliary{}, ...]

  """
  def list_tbl_interchange_auxiliary do
    Repo.all(Auxiliary)
  end

  @doc """
  Gets a single auxiliary.

  Raises `Ecto.NoResultsError` if the Auxiliary does not exist.

  ## Examples

      iex> get_auxiliary!(123)
      %Auxiliary{}

      iex> get_auxiliary!(456)
      ** (Ecto.NoResultsError)

  """
  def get_auxiliary!(id), do: Repo.get!(Auxiliary, id)

  @doc """
  Creates a auxiliary.

  ## Examples

      iex> create_auxiliary(%{field: value})
      {:ok, %Auxiliary{}}

      iex> create_auxiliary(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_auxiliary(attrs \\ %{}) do
    %Auxiliary{}
    |> Auxiliary.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a auxiliary.

  ## Examples

      iex> update_auxiliary(auxiliary, %{field: new_value})
      {:ok, %Auxiliary{}}

      iex> update_auxiliary(auxiliary, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_auxiliary(%Auxiliary{} = auxiliary, attrs) do
    auxiliary
    |> Auxiliary.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a auxiliary.

  ## Examples

      iex> delete_auxiliary(auxiliary)
      {:ok, %Auxiliary{}}

      iex> delete_auxiliary(auxiliary)
      {:error, %Ecto.Changeset{}}

  """
  def delete_auxiliary(%Auxiliary{} = auxiliary) do
    Repo.delete(auxiliary)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking auxiliary changes.

  ## Examples

      iex> change_auxiliary(auxiliary)
      %Ecto.Changeset{data: %Auxiliary{}}

  """
  def change_auxiliary(%Auxiliary{} = auxiliary, attrs \\ %{}) do
    Auxiliary.changeset(auxiliary, attrs)
  end

  def auxiliary_report_lookup(
        %{"status" => status, "direction" => direction} = search_params,
        page,
        size,
        _user
      ) do
    Auxiliary
    |> where([a], a.dirction == ^direction and a.auth_status == ^status)
    |> join(:left, [a], b in Rms.SystemUtilities.Equipment, on: a.equipment_id == b.id)
    |> join(:left, [a, b], c in Rms.Accounts.RailwayAdministrator, on: a.admin_id == c.id)
    |> join(:left, [a, b, c], d in Rms.Accounts.User, on: a.maker_id == d.id)
    |> join(:left, [a, b, c, d], e in Rms.SystemUtilities.Currency, on: a.currency_id == e.id)
    |> join(:left, [a, b, c, d, e], f in Rms.SystemUtilities.Station,
      on: a.current_station_id == f.id
    )
    |> join(:left, [a, b, c, d, e, f], g in Rms.SystemUtilities.Station,
      on: a.interchange_point_id == g.id
    )
    |> join(:left, [a, b, c, d, e, f, g], h in Rms.SystemUtilities.Wagon, on: a.wagon_id == h.id)
    |> order_by([a, b, c, d, e, f, g, h], desc: [a.id])
    |> handle_auxiliary_report_filter(search_params)
    |> compose_auxiliary_report_select()
    |> Repo.paginate(page: page, page_size: size)
  end

  def auxiliary_report_lookup(
        _source,
        %{"status" => status, "direction" => direction} = search_params,
        _user
      ) do
    Auxiliary
    |> where([a], a.dirction == ^direction and a.auth_status == ^status)
    |> join(:left, [a], b in Rms.SystemUtilities.Equipment, on: a.equipment_id == b.id)
    |> join(:left, [a, b], c in Rms.Accounts.RailwayAdministrator, on: a.admin_id == c.id)
    |> join(:left, [a, b, c], d in Rms.Accounts.User, on: a.maker_id == d.id)
    |> join(:left, [a, b, c, d], e in Rms.SystemUtilities.Currency, on: a.currency_id == e.id)
    |> join(:left, [a, b, c, d, e], f in Rms.SystemUtilities.Station,
      on: a.current_station_id == f.id
    )
    |> join(:left, [a, b, c, d, e, f], g in Rms.SystemUtilities.Station,
      on: a.interchange_point_id == g.id
    )
    |> join(:left, [a, b, c, d, e, f, g], h in Rms.SystemUtilities.Wagon, on: a.wagon_id == h.id)
    |> order_by([a, b, c, d, e, f, g, h], desc: [a.id])
    |> handle_auxiliary_report_filter(search_params)
    |> compose_auxiliary_report_select()
  end

  defp handle_auxiliary_report_filter(query, %{"isearch" => search_term} = search_params)
       when search_term == "" or is_nil(search_term) do
    query
    |> handle_auxiliary_date_filter(search_params)
    |> handle_auxiliary_filter(search_params)
    |> handle_auxiliary_administrator_filter(search_params)
    |> handle_auxiliary_date_received_filter(search_params)
    |> handle_auxiliary_date_sent_filter(search_params)
    |> handle_auxiliary_direction_filter(search_params)
  end

  defp handle_auxiliary_report_filter(query, %{
         "isearch" => search_term,
         "direction" => direction,
         "status" => status
       }) do
    search_term = "%#{search_term}%"
    compose_auxiliary_isearch_filter(query, search_term, direction, status)
  end

  defp handle_auxiliary_date_filter(query, %{"from" => from, "to" => to})
       when from == "" or is_nil(from) or to == "" or is_nil(to),
       do: query

  defp handle_auxiliary_date_filter(query, %{"from" => from, "to" => to}) do
    query
    |> where(
      [a],
      fragment("CAST(? AS DATE) >= ?", a.inserted_at, ^from) and
        fragment("CAST(? AS DATE) <= ?", a.inserted_at, ^to)
    )
  end

  defp handle_auxiliary_filter(query, %{"equipment" => equipment})
       when equipment == "" or is_nil(equipment),
       do: query

  defp handle_auxiliary_filter(query, %{"equipment" => equipment}) do
    where(query, [a], a.equipment_id == ^equipment)
  end

  defp handle_auxiliary_administrator_filter(query, %{"administrator" => administrator})
       when administrator == "" or is_nil(administrator),
       do: query

  defp handle_auxiliary_administrator_filter(query, %{"administrator" => administrator}) do
    where(query, [a], a.admin_id == ^administrator)
  end

  defp handle_auxiliary_date_received_filter(query, %{
         "date_received_from" => date_received_from,
         "date_received_to" => date_received_to
       })
       when date_received_from == "" or is_nil(date_received_from) or date_received_to == "" or
              is_nil(date_received_to),
       do: query

  defp handle_auxiliary_date_received_filter(query, %{
         "date_received_from" => date_received_from,
         "date_received_to" => date_received_to
       }) do
    query
    |> where(
      [a],
      fragment("CAST(? AS DATE) >= ?", a.received_date, ^date_received_from) and
        fragment("CAST(? AS DATE) <= ?", a.received_date, ^date_received_to)
    )
  end

  defp handle_auxiliary_date_sent_filter(query, %{
         "date_sent_from" => date_sent_from,
         "date_sent_to" => date_sent_to
       })
       when date_sent_from == "" or is_nil(date_sent_from) or date_sent_to == "" or
              is_nil(date_sent_to),
       do: query

  defp handle_auxiliary_date_sent_filter(query, %{
         "date_sent_from" => date_sent_from,
         "date_sent_to" => date_sent_to
       }) do
    query
    |> where(
      [a],
      fragment("CAST(? AS DATE) >= ?", a.sent_date, ^date_sent_from) or
        fragment("CAST(? AS DATE) <= ?", a.sent_date, ^date_sent_to)
    )
  end

  defp handle_auxiliary_direction_filter(query, %{"direction" => direction})
       when direction == "" or is_nil(direction),
       do: query

  defp handle_auxiliary_direction_filter(query, %{"direction" => direction}) do
    where(
      query,
      [a],
      fragment("lower(?) LIKE lower(?)", a.dirction, ^"%#{direction}%")
    )
  end

  defp compose_auxiliary_isearch_filter(query, search_term, direction, status) do
    query
    |> where([a, b, c, d, e, f, g, h], a.dirction == ^direction and a.auth_status == ^status)
    |> where(
      [a, b, c, d, e, f, g, h],
      fragment("lower(?) LIKE lower(?)", b.description, ^search_term) or
        fragment("lower(?) LIKE lower(?)", b.code, ^search_term) or
        fragment("lower(?) LIKE lower(?)", c.description, ^search_term) or
        fragment("lower(?) LIKE lower(?)", c.code, ^search_term) or
        fragment("lower(?) LIKE lower(?)", a.amount, ^search_term) or
        fragment("lower(?) LIKE lower(?)", a.accumlative_days, ^search_term)
    )
  end

  defp compose_auxiliary_report_select(query) do
    query
    |> select([a, b, c, d, e, f, g, h], %{
      id: a.id,
      direction: a.dirction,
      sent_date: a.sent_date,
      received_date: a.received_date,
      status: a.status,
      equipment_id: a.equipment_id,
      equipment: b.description,
      symbol: e.symbol,
      administrator: c.code,
      admin_id: a.admin_id,
      maker_id: a.maker_id,
      inserted_at: a.inserted_at,
      updated_at: a.updated_at,
      amount: a.amount,
      accumlative_days: a.accumlative_days,
      off_hire_date: a.off_hire_date,
      current_station_id: a.current_station_id,
      current_station: f.description,
      interchange_point_id: a.interchange_point_id,
      interchange_point: g.description,
      update_date: a.update_date,
      wagon_id: a.wagon_id,
      wagon_code: h.code,
      on_hire_date: a.on_hire_date,
      equipment_code: a.equipment_code,
      total_accum_days: a.total_accum_days,
      total_amount: a.total_amount
    })
  end

  def auxiliary_lookup(id) do
    Auxiliary
    |> where([a], a.id == ^id)
    |> join(:left, [a], b in Rms.SystemUtilities.Equipment, on: a.equipment_id == b.id)
    |> join(:left, [a, b], c in Rms.Accounts.RailwayAdministrator, on: a.admin_id == c.id)
    |> join(:left, [a, b, c], d in Rms.Accounts.User, on: a.maker_id == d.id)
    |> join(:left, [a, b, c, d], e in Rms.SystemUtilities.Currency, on: a.currency_id == e.id)
    |> join(:left, [a, b, c, d, e], f in Rms.SystemUtilities.Station,
      on: a.current_station_id == f.id
    )
    |> join(:left, [a, b, c, d, e, f], g in Rms.SystemUtilities.Station,
      on: a.interchange_point_id == g.id
    )
    |> join(:left, [a, b, c, d, e, f, g], h in Rms.SystemUtilities.Wagon, on: a.wagon_id == h.id)
    |> join(:left, [a, b, c, d, e, f, g, h], i in Rms.Accounts.RailwayAdministrator, on: i.id == h.owner_id)
    |> join(:left, [a, b, c, d, e, f, g, h, i], j in Rms.SystemUtilities.Wagon, on: a.current_wagon_id == j.id)
    |> join(:left, [a, b, c, d, e, f, g, h, i, j], k in Rms.Accounts.RailwayAdministrator, on: k.id == j.owner_id)
    |> select([a, b, c, d, e, f, g, h, i, j, k], %{
      id: a.id,
      direction: a.dirction,
      dirction: a.dirction,
      sent_date: a.sent_date,
      received_date: a.received_date,
      status: a.status,
      equipment_id: a.equipment_id,
      equipment: b.description,
      symbol: e.symbol,
      administrator: c.code,
      admin_id: a.admin_id,
      maker_id: a.maker_id,
      inserted_at: a.inserted_at,
      updated_at: a.updated_at,
      amount: a.amount,
      comment: a.comment,
      accumlative_days: a.accumlative_days,
      off_hire_date: a.off_hire_date,
      current_station_id: a.current_station_id,
      current_station: f.description,
      interchange_point_id: a.interchange_point_id,
      interchange_point: g.description,
      update_date: a.update_date,
      wagon_id: a.wagon_id,
      on_hire_date: a.on_hire_date,
      wagon_code: h.code,
      wagon_owner: i.code,
      current_wagon_code: j.code,
      current_wagon_owner: k.code,
      equipment_code: a.equipment_code,
      current_wagon_id: a.current_wagon_id,
      modification_reason: a.modification_reason,
      total_accum_days: a.total_accum_days,
      total_amount: a.total_amount
    })
    |> Repo.one()
  end

  def auxiliary_tracking_lookup(wagon_code, equipment_id) do
    Auxiliary
    |> join(:left, [a], b in Rms.SystemUtilities.Equipment, on: a.equipment_id == b.id)
    |> join(:left, [a, b], c in Rms.Accounts.RailwayAdministrator, on: a.admin_id == c.id)
    |> join(:left, [a, b, c], d in Rms.Accounts.User, on: a.maker_id == d.id)
    |> join(:left, [a, b, c, d], e in Rms.SystemUtilities.Currency, on: a.currency_id == e.id)
    |> join(:left, [a, b, c, d, e], f in Rms.SystemUtilities.Station,
      on: a.current_station_id == f.id
    )
    |> join(:left, [a, b, c, d, e, f], g in Rms.SystemUtilities.Station,
      on: a.interchange_point_id == g.id
    )
    |> join(:left, [a, b, c, d, e, f, g], h in Rms.SystemUtilities.Wagon, on: a.wagon_id == h.id)
    |> join(:left, [a, b, c, d, e, f, g, h], i in Rms.SystemUtilities.Wagon,
      on: a.current_wagon_id == i.id
    )
    |> where(
      [a, b, c, d, e, f, g, h, i],
      a.equipment_id == ^equipment_id and h.code == ^wagon_code and a.auth_status == "PENDING"
    )
    |> order_by([a, b, c, d, e, f, g, h, i], desc: [a.id])
    |> select([a, b, c, d, e, f, g, h, i], %{
      id: a.id,
      direction: a.dirction,
      dirction: a.dirction,
      sent_date: a.sent_date,
      received_date: a.received_date,
      status: a.status,
      equipment_id: a.equipment_id,
      equipment: b.description,
      symbol: e.symbol,
      administrator: c.code,
      admin_id: a.admin_id,
      maker_id: a.maker_id,
      inserted_at: a.inserted_at,
      updated_at: a.updated_at,
      amount: a.amount,
      comment: a.comment,
      accumlative_days: a.accumlative_days,
      off_hire_date: a.off_hire_date,
      current_station_id: a.current_station_id,
      current_station: f.description,
      interchange_point_id: a.interchange_point_id,
      interchange_point: g.description,
      update_date: a.update_date,
      wagon_id: a.wagon_id,
      on_hire_date: a.on_hire_date,
      wagon_code: h.code,
      equipment_code: a.equipment_code,
      current_wagon_id: a.current_wagon_id,
      current_wagon: i.code,
      total_accum_days: a.total_accum_days,
      total_amount:  a.total_amount,
    })
    |> limit(1)
    |> Repo.one()
  end

  def auxiliary_bulk_tracking_lookup(direction, equipment_id) do
    Auxiliary
    |> where(
      [a],
      a.equipment_id == ^equipment_id and a.dirction == ^direction and a.auth_status == "PENDING"
    )
    |> join(:left, [a], b in Rms.SystemUtilities.Equipment, on: a.equipment_id == b.id)
    |> join(:left, [a, b], c in Rms.Accounts.RailwayAdministrator, on: a.admin_id == c.id)
    |> join(:left, [a, b, c], d in Rms.Accounts.User, on: a.maker_id == d.id)
    |> join(:left, [a, b, c, d], e in Rms.SystemUtilities.Currency, on: a.currency_id == e.id)
    |> join(:left, [a, b, c, d, e], f in Rms.SystemUtilities.Station,
      on: a.current_station_id == f.id
    )
    |> join(:left, [a, b, c, d, e, f], g in Rms.SystemUtilities.Station,
      on: a.interchange_point_id == g.id
    )
    |> join(:left, [a, b, c, d, e, f, g], h in Rms.SystemUtilities.Wagon, on: a.wagon_id == h.id)
    |> join(:left, [a, b, c, d, e, f, g, h], i in Rms.SystemUtilities.Wagon,
      on: a.current_wagon_id == i.id
    )
    |> join(:left, [a, b, c, d, e, f, g, h, i], j in Rms.Accounts.RailwayAdministrator,
      on: i.owner_id == j.id
    )
    |> order_by([a, b, c, d, e, f, g, h, i, j], desc: [a.id])
    |> select([a, b, c, d, e, f, g, h, i, j], %{
      id: a.id,
      direction: a.dirction,
      dirction: a.dirction,
      sent_date: a.sent_date,
      received_date: a.received_date,
      status: a.status,
      equipment_id: a.equipment_id,
      equipment: b.description,
      symbol: e.symbol,
      administrator: c.code,
      admin_id: a.admin_id,
      maker_id: a.maker_id,
      inserted_at: a.inserted_at,
      updated_at: a.updated_at,
      amount: a.amount,
      comment: a.comment,
      accumlative_days: a.accumlative_days,
      off_hire_date: a.off_hire_date,
      current_station_id: a.current_station_id,
      current_station: f.description,
      interchange_point_id: a.interchange_point_id,
      interchange_point: g.description,
      update_date: a.update_date,
      wagon_id: a.wagon_id,
      on_hire_date: a.on_hire_date,
      wagon_code: h.code,
      equipment_code: a.equipment_code,
      current_wagon_id: a.current_wagon_id,
      current_wagon: i.code,
      current_wagon_owner: j.code,
      total_accum_days: a.total_accum_days
    })
    |> Repo.all()
  end

  def auxiliary_daily_summary_report_lookup(search_params, page, size, _user) do
    Auxiliary
    |> where([a], a.auth_status in ["PENDING", "COMPLETE"])
    |> join(:left, [a], b in Rms.SystemUtilities.Equipment, on: a.equipment_id == b.id)
    |> join(:left, [a, b], c in Rms.Accounts.RailwayAdministrator, on: a.admin_id == c.id)
    |> join(:left, [a, b, c], d in Rms.Accounts.User, on: a.maker_id == d.id)
    |> join(:left, [a, b, c, d], e in Rms.SystemUtilities.Currency, on: a.currency_id == e.id)
    |> join(:left, [a, b, c, d, e], f in Rms.SystemUtilities.Station,
      on: a.current_station_id == f.id
    )
    |> join(:left, [a, b, c, d, e, f], g in Rms.SystemUtilities.Station,
      on: a.interchange_point_id == g.id
    )
    |> join(:left, [a, b, c, d, e, f, g], h in Rms.SystemUtilities.Wagon, on: a.wagon_id == h.id)
    |> order_by([a, b, c, d, e, f, g, h], desc: [a.id])
    |> handle_auxiliary_report_filter(search_params)
    |> compose_auxiliary_daily_summary_report_select()
    |> Repo.paginate(page: page, page_size: size)
  end

  def auxiliary_daily_summary_report_lookup(_source, search_params, _user) do
    Auxiliary
    |> where([a], a.auth_status in ["PENDING", "COMPLETE"])
    |> join(:left, [a], b in Rms.SystemUtilities.Equipment, on: a.equipment_id == b.id)
    |> join(:left, [a, b], c in Rms.Accounts.RailwayAdministrator, on: a.admin_id == c.id)
    |> join(:left, [a, b, c], d in Rms.Accounts.User, on: a.maker_id == d.id)
    |> join(:left, [a, b, c, d], e in Rms.SystemUtilities.Currency, on: a.currency_id == e.id)
    |> join(:left, [a, b, c, d, e], f in Rms.SystemUtilities.Station,
      on: a.current_station_id == f.id
    )
    |> join(:left, [a, b, c, d, e, f], g in Rms.SystemUtilities.Station,
      on: a.interchange_point_id == g.id
    )
    |> join(:left, [a, b, c, d, e, f, g], h in Rms.SystemUtilities.Wagon, on: a.wagon_id == h.id)
    |> order_by([a, b, c, d, e, f, g, h], desc: [a.id])
    |> handle_auxiliary_daily_summary_report_filter(search_params)
    |> compose_auxiliary_daily_summary_report_select()
  end

  defp handle_auxiliary_daily_summary_report_filter(
         query,
         %{"isearch" => search_term} = search_params
       )
       when search_term == "" or is_nil(search_term) do
    query
    |> handle_auxiliary_date_filter(search_params)
    |> handle_auxiliary_filter(search_params)
    |> handle_auxiliary_administrator_filter(search_params)
    |> handle_auxiliary_date_received_filter(search_params)
    |> handle_auxiliary_date_sent_filter(search_params)
    |> handle_auxiliary_direction_filter(search_params)
  end

  defp handle_auxiliary_daily_summary_report_filter(query, %{"isearch" => search_term}) do
    search_term = "%#{search_term}%"
    compose_auxiliary_daily_summary_isearch_filter(query, search_term)
  end

  defp compose_auxiliary_daily_summary_isearch_filter(query, search_term) do
    query
    |> where(
      [a, b, c, d, e, f, g, h],
      fragment("lower(?) LIKE lower(?)", b.description, ^search_term) or
        fragment("lower(?) LIKE lower(?)", b.code, ^search_term) or
        fragment("lower(?) LIKE lower(?)", c.description, ^search_term) or
        fragment("lower(?) LIKE lower(?)", c.code, ^search_term) or
        fragment("lower(?) LIKE lower(?)", a.amount, ^search_term) or
        fragment("lower(?) LIKE lower(?)", a.accumlative_days, ^search_term)
    )
  end

  defp compose_auxiliary_daily_summary_report_select(query) do
    query
    |> where(
      [a, b, c, d, e, f, g, h],
      a.id in subquery(
        from(t in Auxiliary,
          where: t.auth_status in ["PENDING", "COMPLETE"],
          group_by: [t.equipment_id, t.equipment_code, t.admin_id, t.received_date, t.sent_date],
          select: max(t.id)
        )
      )
    )
    |> select([a, b, c, d, e, f, g, h], %{
      id: a.id,
      direction: a.dirction,
      sent_date: a.sent_date,
      received_date: a.received_date,
      status: a.status,
      equipment_id: a.equipment_id,
      equipment: b.description,
      symbol: e.symbol,
      administrator: c.code,
      admin_id: a.admin_id,
      maker_id: a.maker_id,
      inserted_at: a.inserted_at,
      updated_at: a.updated_at,
      amount: a.amount,
      accumlative_days: a.accumlative_days,
      off_hire_date: a.off_hire_date,
      current_station_id: a.current_station_id,
      current_station: f.description,
      interchange_point_id: a.interchange_point_id,
      interchange_point: g.description,
      update_date: a.update_date,
      wagon_id: a.wagon_id,
      wagon_code: h.code,
      on_hire_date: a.on_hire_date,
      equipment_code: a.equipment_code,
      total_accum_days: a.total_accum_days
    })
  end

  def auxiliary_on_hire_lookup() do
    Auxiliary
    |> where([a], a.status in ["ON_HIRE", "OFF_HIRE"] and a.auth_status == "PENDING")
    |> Repo.all()
  end

  alias Rms.Tracking.LocoDetention

  @doc """
  Returns the list of tbl_loco_detention.

  ## Examples

      iex> list_tbl_loco_detention()
      [%LocoDetention{}, ...]

  """
  def list_tbl_loco_detention do
    Repo.all(LocoDetention)
  end

  @doc """
  Gets a single loco_detention.

  Raises `Ecto.NoResultsError` if the Loco detention does not exist.

  ## Examples

      iex> get_loco_detention!(123)
      %LocoDetention{}

      iex> get_loco_detention!(456)
      ** (Ecto.NoResultsError)

  """
  def get_loco_detention!(id), do: Repo.get!(LocoDetention, id)

  @doc """
  Creates a loco_detention.

  ## Examples

      iex> create_loco_detention(%{field: value})
      {:ok, %LocoDetention{}}

      iex> create_loco_detention(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_loco_detention(attrs \\ %{}) do
    %LocoDetention{}
    |> LocoDetention.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a loco_detention.

  ## Examples

      iex> update_loco_detention(loco_detention, %{field: new_value})
      {:ok, %LocoDetention{}}

      iex> update_loco_detention(loco_detention, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_loco_detention(%LocoDetention{} = loco_detention, attrs) do
    loco_detention
    |> LocoDetention.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a loco_detention.

  ## Examples

      iex> delete_loco_detention(loco_detention)
      {:ok, %LocoDetention{}}

      iex> delete_loco_detention(loco_detention)
      {:error, %Ecto.Changeset{}}

  """
  def delete_loco_detention(%LocoDetention{} = loco_detention) do
    Repo.delete(loco_detention)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking loco_detention changes.

  ## Examples

      iex> change_loco_detention(loco_detention)
      %Ecto.Changeset{data: %LocoDetention{}}

  """
  def change_loco_detention(%LocoDetention{} = loco_detention, attrs \\ %{}) do
    LocoDetention.changeset(loco_detention, attrs)
  end

  def loco_detention_report_lookup(
        %{"status" => status, "direction" => direction} = search_params,
        page,
        size,
        _user
      ) do
    LocoDetention
    |> where([a], a.status == ^status and a.direction == ^direction)
    |> join(:left, [a], b in Rms.Locomotives.Locomotive, on: a.locomotive_id == b.id)
    |> join(:left, [a, b], c in Rms.Accounts.RailwayAdministrator, on: a.admin_id == c.id)
    |> join(:left, [a, b, c], d in Rms.Accounts.User, on: a.maker_id == d.id)
    |> join(:left, [a, b, c, d], e in Rms.SystemUtilities.Currency, on: a.currency_id == e.id)
    |> join(:left, [a, b, c, d, e], f in Rms.Accounts.User, on: f.checker_id == e.id)
    |> handle_loco_detention_report_filter(search_params)
    |> compose_loco_detention_report_select()
    |> Repo.paginate(page: page, page_size: size)
  end

  def loco_detention_report_lookup(
        _source,
        %{"status" => status, "direction" => direction} = search_params,
        _user
      ) do
    LocoDetention
    |> where([a], a.status == ^status and a.direction == ^direction)
    |> join(:left, [a], b in Rms.Locomotives.Locomotive, on: a.locomotive_id == b.id)
    |> join(:left, [a, b], c in Rms.Accounts.RailwayAdministrator, on: a.admin_id == c.id)
    |> join(:left, [a, b, c], d in Rms.Accounts.User, on: a.maker_id == d.id)
    |> join(:left, [a, b, c, d], e in Rms.SystemUtilities.Currency, on: a.currency_id == e.id)
    |> join(:left, [a, b, c, d, e], f in Rms.Accounts.User, on: f.checker_id == e.id)
    |> handle_loco_detention_report_filter(search_params)
    |> compose_loco_detention_report_select()
  end

  defp handle_loco_detention_report_filter(query, %{"isearch" => search_term} = search_params)
       when search_term == "" or is_nil(search_term) do
    query
    |> handle_loco_detention_date_filter(search_params)
    |> handle_loco_dentation_interchange_date_filter(search_params)
    |> handle_loco_detention_train_no_filter(search_params)
    |> handle_loco_detention_loco_no_filter(search_params)
    |> handle_loco_detention_admin_filter(search_params)
    |> handle_loco_detention_direction_filter(search_params)
    |> handle_loco_dentation_departure_date_filter(search_params)
    |> handle_loco_detention_departure_time_filter(search_params)
    |> handle_loco_detention_arrival_time_filter(search_params)
  end

  defp handle_loco_detention_report_filter(query, %{
         "isearch" => search_term,
         "direction" => direction,
         "status" => status
       }) do
    search_term = "%#{search_term}%"
    compose_loco_detention_isearch_filter(query, search_term, direction, status)
  end

  defp handle_loco_detention_date_filter(query, %{"from" => from, "to" => to})
       when from == "" or is_nil(from) or to == "" or is_nil(to),
       do: query

  defp handle_loco_detention_date_filter(query, %{"from" => from, "to" => to}) do
    query
    |> where(
      [a],
      fragment("CAST(? AS DATE) >= ?", a.inserted_at, ^from) and
        fragment("CAST(? AS DATE) <= ?", a.inserted_at, ^to)
    )
  end

  defp handle_loco_dentation_interchange_date_filter(query, %{
         "interchange_date_from" => from,
         "interchange_date_to" => to
       })
       when from == "" or is_nil(from) or to == "" or is_nil(to),
       do: query

  defp handle_loco_dentation_interchange_date_filter(query, %{
         "interchange_date_from" => from,
         "interchange_date_to" => to
       }) do
    query
    |> where(
      [a],
      fragment("CAST(? AS DATE) >= ?", a.interchange_date, ^from) and
        fragment("CAST(? AS DATE) <= ?", a.interchange_date, ^to)
    )
  end

  defp handle_loco_detention_train_no_filter(query, %{"train_no" => train_no})
       when train_no == "" or is_nil(train_no),
       do: query

  defp handle_loco_detention_train_no_filter(query, %{"train_no" => train_no}) do
    where(
      query,
      [a],
      fragment("lower(?) LIKE lower(?)", a.train_no, ^"%#{train_no}%")
    )
  end

  defp handle_loco_detention_loco_no_filter(query, %{"loco_no" => loco_no})
       when loco_no == "" or is_nil(loco_no),
       do: query

  defp handle_loco_detention_loco_no_filter(query, %{"loco_no" => loco_no}) do
    where(query, [a], a.locomotive_id == ^loco_no)
  end

  defp handle_loco_detention_admin_filter(query, %{"admin" => admin})
       when admin == "" or is_nil(admin),
       do: query

  defp handle_loco_detention_admin_filter(query, %{"admin" => admin}) do
    where(query, [a], a.admin_id == ^admin)
  end

  defp handle_loco_detention_direction_filter(query, %{"direction" => direction})
       when direction == "" or is_nil(direction),
       do: query

  defp handle_loco_detention_direction_filter(query, %{"direction" => direction}) do
    where(
      query,
      [a],
      fragment("lower(?) LIKE lower(?)", a.direction, ^"%#{direction}%")
    )
  end

  defp handle_loco_dentation_departure_date_filter(query, %{
         "departure_date_from" => from,
         "departure_date_to" => to
       })
       when from == "" or is_nil(from) or to == "" or is_nil(to),
       do: query

  defp handle_loco_dentation_departure_date_filter(query, %{
         "departure_date_from" => from,
         "departure_date_to" => to
       }) do
    query
    |> where(
      [a],
      fragment("CAST(? AS DATE) >= ?", a.departure_date, ^from) and
        fragment("CAST(? AS DATE) <= ?", a.departure_date, ^to)
    )
  end

  defp handle_loco_detention_arrival_time_filter(query, %{"arrival_time" => arrival_time})
       when arrival_time == "" or is_nil(arrival_time),
       do: query

  defp handle_loco_detention_arrival_time_filter(query, %{"arrival_time" => arrival_time}) do
    where(
      query,
      [a],
      fragment("lower(?) LIKE lower(?)", a.arrival_time, ^"%#{arrival_time}%")
    )
  end

  defp handle_loco_detention_departure_time_filter(query, %{"departure_time" => departure_time})
       when departure_time == "" or is_nil(departure_time),
       do: query

  defp handle_loco_detention_departure_time_filter(query, %{"departure_time" => departure_time}) do
    where(
      query,
      [a],
      fragment("lower(?) LIKE lower(?)", a.departure_time, ^"%#{departure_time}%")
    )
  end

  defp compose_loco_detention_isearch_filter(query, search_term, direction, status) do
    query
    |> where([a, b, c, d, e, f], a.dirction == ^direction and a.auth_status == ^status)
    |> where(
      [a, b, c, d, e, f],
      fragment("lower(?) LIKE lower(?)", a.train_no, ^search_term) or
        fragment("lower(?) LIKE lower(?)", b.loco_number, ^search_term) or
        fragment("lower(?) LIKE lower(?)", c.description, ^search_term) or
        fragment("lower(?) LIKE lower(?)", a.interchange_date, ^search_term) or
        fragment("lower(?) LIKE lower(?)", a.departure_date, ^search_term) or
        fragment("lower(?) LIKE lower(?)", a.arrival_time, ^search_term) or
        fragment("lower(?) LIKE lower(?)", a.departure_time, ^search_term)
    )
  end

  defp compose_loco_detention_report_select(query) do
    query
    |> order_by([a, _b, _c, _d, _e, f], desc: a.inserted_at)
    |> select([a, b, c, d, e, f], %{
      id: a.id,
      status: a.status,
      comment: a.comment,
      interchange_date: a.interchange_date,
      arrival_date: a.arrival_date,
      arrival_time: a.arrival_time,
      departure_date: a.departure_date,
      departure_time: a.departure_time,
      train_no: a.train_no,
      direction: a.direction,
      chargeable_delay: a.chargeable_delay,
      actual_delay: a.actual_delay,
      grace_period: a.grace_period,
      amount: a.amount,
      maker_id: a.maker_id,
      checker_id: a.checker_id,
      admin_id: a.admin_id,
      locomotive_id: a.locomotive_id,
      inserted_at: a.inserted_at,
      updated_at: a.updated_at,
      loco_no: a.loco_no,
      admin: c.description,
      currency: e.symbol,
      rate: a.rate
    })
  end

  def loco_item_lookup(id) do
    LocoDetention
    |> where([a], a.id == ^id)
    |> join(:left, [a], b in Rms.Locomotives.Locomotive, on: a.locomotive_id == b.id)
    |> join(:left, [a, b], c in Rms.Accounts.RailwayAdministrator, on: a.admin_id == c.id)
    |> join(:left, [a, b, c], d in Rms.Accounts.User, on: a.maker_id == d.id)
    |> join(:left, [a, b, c, d], e in Rms.SystemUtilities.Currency, on: a.currency_id == e.id)
    |> join(:left, [a, b, c, d, e], f in Rms.Accounts.User, on: f.checker_id == e.id)
    |> select([a, b, c, d, e, f], %{
      id: a.id,
      status: a.status,
      comment: a.comment,
      interchange_date: a.interchange_date,
      arrival_date: a.arrival_date,
      arrival_time: a.arrival_time,
      departure_date: a.departure_date,
      departure_time: a.departure_time,
      train_no: a.train_no,
      direction: a.direction,
      chargeable_delay: a.chargeable_delay,
      actual_delay: a.actual_delay,
      grace_period: a.grace_period,
      amount: a.amount,
      maker_id: a.maker_id,
      checker_id: a.checker_id,
      admin_id: a.admin_id,
      locomotive_id: a.locomotive_id,
      inserted_at: a.inserted_at,
      updated_at: a.updated_at,
      loco_no: b.loco_number,
      admin: c.description,
      currency: e.symbol,
      modification_reason: a.modification_reason,
      rate: a.rate
    })
    |> Repo.one()
  end

  def loco_detention_summary_report_lookup(search_params, page, size, _user) do
    LocoDetention
    |> where([a], a.status == ^"COMPLETE")
    |> join(:left, [a], b in Rms.Locomotives.Locomotive, on: a.locomotive_id == b.id)
    |> join(:left, [a, b], c in Rms.Accounts.RailwayAdministrator, on: a.admin_id == c.id)
    |> join(:left, [a, b, c], d in Rms.Accounts.User, on: a.maker_id == d.id)
    |> join(:left, [a, b, c, d], e in Rms.SystemUtilities.Currency, on: a.currency_id == e.id)
    |> join(:left, [a, b, c, d, e], f in Rms.Accounts.User, on: f.checker_id == e.id)
    |> handle_loco_detention_summary_report_filter(search_params)
    |> compose_loco_detention_summary_report_select()
    |> Repo.paginate(page: page, page_size: size)
  end

  def loco_detention_summary_report_lookup(_source, search_params, _user) do
    LocoDetention
    |> where([a], a.status == ^"COMPLETE")
    |> join(:left, [a], b in Rms.Locomotives.Locomotive, on: a.locomotive_id == b.id)
    |> join(:left, [a, b], c in Rms.Accounts.RailwayAdministrator, on: a.admin_id == c.id)
    |> join(:left, [a, b, c], d in Rms.Accounts.User, on: a.maker_id == d.id)
    |> join(:left, [a, b, c, d], e in Rms.SystemUtilities.Currency, on: a.currency_id == e.id)
    |> join(:left, [a, b, c, d, e], f in Rms.Accounts.User, on: f.checker_id == e.id)
    |> handle_loco_detention_summary_report_filter(search_params)
    |> compose_loco_detention_summary_report_select()
  end

  defp handle_loco_detention_summary_report_filter(
         query,
         %{"isearch" => search_term} = search_params
       )
       when search_term == "" or is_nil(search_term) do
    query
    |> handle_loco_detention_date_filter(search_params)
    |> handle_loco_detention_admin_filter(search_params)
    |> handle_loco_detention_direction_filter(search_params)
  end

  defp handle_loco_detention_summary_report_filter(query, %{"isearch" => search_term}) do
    search_term = "%#{search_term}%"
    compose_loco_detention_report_isearch_filter(query, search_term)
  end

  defp compose_loco_detention_report_isearch_filter(query, search_term) do
    query
    |> where(
      [a, b, c, d, e, f],
      fragment("lower(?) LIKE lower(?)", c.description, ^search_term) or
        fragment("lower(?) LIKE lower(?)", a.direction, ^search_term)
    )
  end

  def compose_loco_detention_summary_report_select(query) do
    query
    |> order_by([a, b, c, d, e, f], desc: [c.description, a.direction, e.symbol])
    |> group_by([a, b, c, d, e, f], [c.description, a.direction, e.symbol])
    |> select([a, b, c, d, e, f], %{
      amount: sum(a.amount),
      chargeable_delay: sum(a.chargeable_delay),
      admin: c.description,
      direction: a.direction,
      currency: e.symbol
    })
  end

  alias Rms.Tracking.Haulage

  @doc """
  Returns the list of tbl_haulage.

  ## Examples

      iex> list_tbl_haulage()
      [%Haulage{}, ...]

  """
  def list_tbl_haulage do
    Repo.all(Haulage)
  end

  @doc """
  Gets a single haulage.

  Raises `Ecto.NoResultsError` if the Haulage does not exist.

  ## Examples

      iex> get_haulage!(123)
      %Haulage{}

      iex> get_haulage!(456)
      ** (Ecto.NoResultsError)

  """
  def get_haulage!(id), do: Repo.get!(Haulage, id)

  @doc """
  Creates a haulage.

  ## Examples

      iex> create_haulage(%{field: value})
      {:ok, %Haulage{}}

      iex> create_haulage(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_haulage(attrs \\ %{}) do
    %Haulage{}
    |> Haulage.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a haulage.

  ## Examples

      iex> update_haulage(haulage, %{field: new_value})
      {:ok, %Haulage{}}

      iex> update_haulage(haulage, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_haulage(%Haulage{} = haulage, attrs) do
    haulage
    |> Haulage.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a haulage.

  ## Examples

      iex> delete_haulage(haulage)
      {:ok, %Haulage{}}

      iex> delete_haulage(haulage)
      {:error, %Ecto.Changeset{}}

  """
  def delete_haulage(%Haulage{} = haulage) do
    Repo.delete(haulage)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking haulage changes.

  ## Examples

      iex> change_haulage(haulage)
      %Ecto.Changeset{data: %Haulage{}}

  """
  def change_haulage(%Haulage{} = haulage, attrs \\ %{}) do
    Haulage.changeset(haulage, attrs)
  end

  def haulage_report_lookup(%{"direction" => direction} = search_params, page, size, _user) do
    Haulage
    |> where([a], a.direction == ^direction)
    |> join(:left, [a], b in Rms.Accounts.RailwayAdministrator, on: a.admin_id == b.id)
    |> join(:left, [a, b], c in Rms.Accounts.User, on: a.maker_id == c.id)
    |> join(:left, [a, b, c], d in Rms.SystemUtilities.Currency, on: a.currency_id == d.id)
    |> handle_haulage_report_filter(search_params)
    |> compose_haulage_report_select()
    |> Repo.paginate(page: page, page_size: size)
  end

  def haulage_report_lookup(_source, %{"direction" => direction} = search_params, _user) do
    Haulage
    |> where([a], a.direction == ^direction)
    |> join(:left, [a], b in Rms.Accounts.RailwayAdministrator, on: a.admin_id == b.id)
    |> join(:left, [a, b], c in Rms.Accounts.User, on: a.maker_id == c.id)
    |> join(:left, [a, b, c], d in Rms.SystemUtilities.Currency, on: a.currency_id == d.id)
    |> handle_haulage_report_filter(search_params)
    |> compose_haulage_report_select()
  end

  defp handle_haulage_report_filter(query, %{"isearch" => search_term} = search_params)
       when search_term == "" or is_nil(search_term) do
    query
    |> handle_haulage_date_filter(search_params)
    |> handle_loco_detention_date_filter(search_params)
    |> handle_loco_detention_train_no_filter(search_params)
    |> handle_loco_detention_admin_filter(search_params)
  end

  defp handle_haulage_report_filter(query, %{"isearch" => search_term, "direction" => direction}) do
    search_term = "%#{search_term}%"
    compose_haulage_isearch_filter(query, search_term, direction)
  end

  defp handle_haulage_date_filter(query, %{"date_from" => from, "date_to" => to})
       when from == "" or is_nil(from) or to == "" or is_nil(to),
       do: query

  defp handle_haulage_date_filter(query, %{"date_from" => from, "date_to" => to}) do
    query
    |> where(
      [a],
      fragment("CAST(? AS DATE) >= ?", a.date, ^from) and
        fragment("CAST(? AS DATE) <= ?", a.date, ^to)
    )
  end

  defp compose_haulage_isearch_filter(query, search_term, direction) do
    query
    |> where([a, b, c, d], a.direction == ^direction)
    |> where(
      [a, b, c, d],
      fragment("lower(?) LIKE lower(?)", a.train_no, ^search_term) or
        fragment("lower(?) LIKE lower(?)", b.description, ^search_term)
    )
  end

  defp compose_haulage_report_select(query) do
    query
    |> order_by([a, _b, _c, _d], desc: a.inserted_at)
    |> select([a, b, c, d], %{
      id: a.id,
      admin: b.description,
      currency: d.symbol,
      date: a.date,
      train_no: a.train_no,
      status: a.status,
      loco_no: a.loco_no,
      comment: a.comment,
      direction: a.direction,
      observation: a.observation,
      total_wagons: a.total_wagons,
      wagon_ratio: a.wagon_ratio,
      wagon_grand_total: a.wagon_grand_total,
      amount: a.amount,
      rate: a.rate,
      distance: a.distance,
      admin_id: a.admin_id,
      rate_id: a.rate_id,
      maker_id: a.maker_id,
      currency_id: a.currency_id,
      inserted_at: a.inserted_at,
      updated_at: a.updated_at
    })
  end

  def haulage_item_lookup(id) do
    Haulage
    |> where([a], a.id == ^id)
    |> join(:left, [a], b in Rms.Accounts.RailwayAdministrator, on: a.admin_id == b.id)
    |> join(:left, [a, b], c in Rms.Accounts.User, on: a.maker_id == c.id)
    |> join(:left, [a, b, c], d in Rms.SystemUtilities.Currency, on: a.currency_id == d.id)
    |> select([a, b, c, d], %{
      id: a.id,
      admin: b.description,
      currency: d.symbol,
      date: a.date,
      train_no: a.train_no,
      status: a.status,
      loco_no: a.loco_no,
      comment: a.comment,
      direction: a.direction,
      observation: a.observation,
      total_wagons: a.total_wagons,
      wagon_ratio: a.wagon_ratio,
      wagon_grand_total: a.wagon_grand_total,
      distance: a.distance,
      amount: a.amount,
      rate: a.rate,
      admin_id: a.admin_id,
      rate_id: a.rate_id,
      maker_id: a.maker_id,
      currency_id: a.currency_id,
      inserted_at: a.inserted_at,
      updated_at: a.updated_at,
      modification_reason: a.modification_reason,
      payee_admin_id: a.payee_admin_id
    })
    |> Repo.one()
  end

  # def haulage_report_lookup(search_params, page, size, _user) do
  #   Rms.Tracking.InterchangeDefect
  #   |> where([a], a.direction == ^direction)
  #   |> join(:left, [a], b in Rms.Accounts.RailwayAdministrator, on: a.admin_id == b.id)
  #   |> join(:left, [a, b], c in Rms.Accounts.User, on: a.maker_id == c.id)
  #   |> join(:left, [a, b, c], d in Rms.SystemUtilities.Currency, on: a.currency_id == d.id)
  #   |> handle_haulage_report_filter(search_params)
  #   |> compose_haulage_report_select()
  #   |> Repo.paginate(page: page, page_size: size)
  # end

  def mechanical_bills_report_lookup(_source, search_params, _user) do
    Rms.Tracking.InterchangeDefect
    |> join(:left, [a], b in Rms.SystemUtilities.Defect, on: a.defect_id == b.id)
    |> join(:left, [a, b], c in Rms.Tracking.Interchange,
      on: a.interchange_id == c.id and a.wagon_id == c.wagon_id
    )
    |> join(:left, [a, b, c], d in Rms.SystemUtilities.DefectSpare, on: a.defect_id == d.defect_id)
    |> join(:left, [a, b, c, d], e in Rms.SystemUtilities.SpareFee,
      on: d.spare_id == e.spare_id and c.adminstrator_id == e.railway_admin
    )
    |> join(:left, [a, b, c, d, e], f in Rms.SystemUtilities.Spare, on: d.spare_id == f.id)
    |> join(:left, [a, b, c, d, e, f], g in Rms.SystemUtilities.Currency,
      on: e.currency_id == g.id
    )
    |> join(:left, [a, b, c, d, e, f, g], h in Rms.SystemUtilities.Wagon, on: a.wagon_id == h.id)
    |> join(:left, [a, b, c, d, e, f, g, h], i in Rms.Accounts.RailwayAdministrator,
      on: c.adminstrator_id == i.id
    )
    |> handle_mechanical_bills_report_filter(search_params)
    |> compose_mechanical_bills_report_select()
  end

  defp handle_mechanical_bills_report_filter(query, %{"isearch" => search_term} = search_params)
       when search_term == "" or is_nil(search_term) do
    query
    |> handle_mechanical_bills_date_filter(search_params)
    |> handle_mechanical_bills_capture_date_filter(search_params)
    |> handle_mechanical_bills_admin_filter(search_params)
    |> handle_mechanical_bills_wagon_filter(search_params)
  end

  defp handle_mechanical_bills_report_filter(query, _) do
    # search_term = "%#{search_term}%"
    # compose_haulage_isearch_filter(query, search_term)
    query
  end

  defp handle_mechanical_bills_date_filter(query, %{"date_from" => from, "date_to" => to})
       when from == "" or is_nil(from) or to == "" or is_nil(to),
       do: query

  defp handle_mechanical_bills_date_filter(query, %{"date_from" => from, "date_to" => to}) do
    query
    |> where(
      [a, b, c, d, e, f, g, h, i],
      fragment("CAST(? AS DATE) >= ?", c.update_date, ^from) and
        fragment("CAST(? AS DATE) <= ?", c.update_date, ^to)
    )
  end

  defp handle_mechanical_bills_capture_date_filter(query, %{"from" => from, "to" => to})
       when from == "" or is_nil(from) or to == "" or is_nil(to),
       do: query

  defp handle_mechanical_bills_capture_date_filter(query, %{"from" => from, "to" => to}) do
    query
    |> where(
      [a, b, c, d, e, f, g, h, i],
      fragment("CAST(? AS DATE) >= ?", c.inserted_at, ^from) and
        fragment("CAST(? AS DATE) <= ?", c.inserted_at, ^to)
    )
  end

  defp handle_mechanical_bills_admin_filter(query, %{"admin" => admin})
       when admin == "" or is_nil(admin),
       do: query

  defp handle_mechanical_bills_admin_filter(query, %{"admin" => admin}) do
    where(query, [a, b, c, d, e, f, g, h, i], c.adminstrator_id == ^admin)
  end

  defp handle_mechanical_bills_wagon_filter(query, %{"wagon_code" => wagon_code})
       when wagon_code == "" or is_nil(wagon_code),
       do: query

  defp handle_mechanical_bills_wagon_filter(query, %{"wagon_code" => wagon_code}) do
    where(
      query,
      [a, b, c, d, e, f, g, h, i],
      fragment("lower(?) LIKE lower(?)", h.code, ^"%#{wagon_code}%")
    )
  end

  defp compose_mechanical_bills_report_select(query) do
    query
    |> order_by([a, b, c, d, e, f, g, h, i], desc: c.update_date)
    |> select([a, b, c, d, e, f, g, h, i], %{
      id: a.id,
      defect: b.description,
      curreny_symbol: g.symbol,
      spare: f.description,
      cataloge: e.cataloge,
      amount: e.amount,
      update_date: c.update_date,
      wagon_symbol: h.wagon_symbol,
      wagon_code: h.code,
      admin_id: c.adminstrator_id,
      defect_cost: b.cost,
      man_hours: b.man_hours,
      admin: i.description
    })
  end

  alias Rms.Tracking.Demurrage

  @doc """
  Returns the list of tbl_demurrage_master.

  ## Examples

      iex> list_tbl_demurrage_master()
      [%Demurrage{}, ...]

  """
  def list_tbl_demurrage_master do
    Repo.all(Demurrage)
  end

  @doc """
  Gets a single demurrage.

  Raises `Ecto.NoResultsError` if the Demurrage does not exist.

  ## Examples

      iex> get_demurrage!(123)
      %Demurrage{}

      iex> get_demurrage!(456)
      ** (Ecto.NoResultsError)

  """
  def get_demurrage!(id), do: Repo.get!(Demurrage, id)

  @doc """
  Creates a demurrage.

  ## Examples

      iex> create_demurrage(%{field: value})
      {:ok, %Demurrage{}}

      iex> create_demurrage(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_demurrage(attrs \\ %{}) do
    %Demurrage{}
    |> Demurrage.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a demurrage.

  ## Examples

      iex> update_demurrage(demurrage, %{field: new_value})
      {:ok, %Demurrage{}}

      iex> update_demurrage(demurrage, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_demurrage(%Demurrage{} = demurrage, attrs) do
    demurrage
    |> Demurrage.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a demurrage.

  ## Examples

      iex> delete_demurrage(demurrage)
      {:ok, %Demurrage{}}

      iex> delete_demurrage(demurrage)
      {:error, %Ecto.Changeset{}}

  """
  def delete_demurrage(%Demurrage{} = demurrage) do
    Repo.delete(demurrage)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking demurrage changes.

  ## Examples

      iex> change_demurrage(demurrage)
      %Ecto.Changeset{data: %Demurrage{}}

  """
  def change_demurrage(%Demurrage{} = demurrage, attrs \\ %{}) do
    Demurrage.changeset(demurrage, attrs)
  end

  def demurrage_report_lookup(search_params, page, size, _user) do
    Demurrage
    |> join(:left, [a], b in Rms.SystemUtilities.Wagon, on: a.wagon_id == b.id)
    |> join(:left, [a, b], c in Rms.Accounts.RailwayAdministrator, on: b.owner_id == c.id)
    |> join(:left, [a, b, c], d in Rms.Accounts.User, on: a.maker_id == d.id)
    |> join(:left, [a, b, c, d], e in Rms.SystemUtilities.Commodity, on: a.commodity_in_id == e.id)
    |> join(:left, [a, b, c, d, e], f in Rms.SystemUtilities.Commodity,
      on: a.commodity_out_id == f.id
    )
    |> join(:left, [a, b, c, d, e, f], g in Rms.SystemUtilities.Currency,
      on: a.currency_id == g.id
    )
    |> demurrage_report_filter(search_params)
    |> compose_demurrage_report_select()
    |> Repo.paginate(page: page, page_size: size)
  end

  def demurrage_report_lookup(_source, search_params, _user) do
    Demurrage
    |> join(:left, [a], b in Rms.SystemUtilities.Wagon, on: a.wagon_id == b.id)
    |> join(:left, [a, b], c in Rms.Accounts.RailwayAdministrator, on: b.owner_id == c.id)
    |> join(:left, [a, b, c], d in Rms.Accounts.User, on: a.maker_id == d.id)
    |> join(:left, [a, b, c, d], e in Rms.SystemUtilities.Commodity, on: a.commodity_in_id == e.id)
    |> join(:left, [a, b, c, d, e], f in Rms.SystemUtilities.Commodity,
      on: a.commodity_out_id == f.id
    )
    |> join(:left, [a, b, c, d, e, f], g in Rms.SystemUtilities.Currency,
      on: a.currency_id == g.id
    )
    |> demurrage_report_filter(search_params)
    |> compose_demurrage_report_select()
  end

  defp demurrage_report_filter(query, %{"isearch" => search_term} = search_params)
       when search_term == "" or is_nil(search_term) do
    query
    |> handle_loco_detention_date_filter(search_params)
    |> handle_demurrage_offloaded_date_filter(search_params)
    |> handle_demurrage_loaded_date_filter(search_params)
    |> handle_demurrage_arrival_date_filter(search_params)
    |> handle_demurrage_commodity_out_filter(search_params)
    |> handle_demurrage_commodity_in_filter(search_params)
    |> handle_demurrage_wagon_owner_filter(search_params)
    |> handle_demurrage_wagon_filter(search_params)
  end

  defp demurrage_report_filter(query, %{"isearch" => search_term}) do
    search_term = "%#{search_term}%"
    compose_demurrage_report_isearch_filter(query, search_term)
  end

  defp handle_demurrage_offloaded_date_filter(query, %{
         "dt_offloaded_from" => from,
         "dt_offloaded_to" => to
       })
       when from == "" or is_nil(from) or to == "" or is_nil(to),
       do: query

  defp handle_demurrage_offloaded_date_filter(query, %{
         "dt_offloaded_from" => from,
         "dt_offloaded_to" => to
       }) do
    query
    |> where(
      [a],
      fragment("CAST(? AS DATE) >= ?", a.date_offloaded, ^from) and
        fragment("CAST(? AS DATE) <= ?", a.date_offloaded, ^to)
    )
  end

  defp handle_demurrage_loaded_date_filter(query, %{
         "dt_loaded_from" => from,
         "dt_loaded_to" => to
       })
       when from == "" or is_nil(from) or to == "" or is_nil(to),
       do: query

  defp handle_demurrage_loaded_date_filter(query, %{
         "dt_loaded_from" => from,
         "dt_loaded_to" => to
       }) do
    query
    |> where(
      [a],
      fragment("CAST(? AS DATE) >= ?", a.date_loaded, ^from) and
        fragment("CAST(? AS DATE) <= ?", a.date_loaded, ^to)
    )
  end

  defp handle_demurrage_arrival_date_filter(query, %{
         "arrival_date_from" => from,
         "arrival_date_to" => to
       })
       when from == "" or is_nil(from) or to == "" or is_nil(to),
       do: query

  defp handle_demurrage_arrival_date_filter(query, %{
         "arrival_date_from" => from,
         "arrival_date_to" => to
       }) do
    query
    |> where(
      [a],
      fragment("CAST(? AS DATE) >= ?", a.arrival_dt, ^from) and
        fragment("CAST(? AS DATE) <= ?", a.arrival_dt, ^to)
    )
  end

  defp handle_demurrage_wagon_owner_filter(query, %{"administrator" => admin})
       when admin == "" or is_nil(admin),
       do: query

  defp handle_demurrage_wagon_owner_filter(query, %{"administrator" => admin}) do
    where(query, [a, b, c, d, e, f, g], b.owner_id == ^admin)
  end

  defp handle_demurrage_commodity_out_filter(query, %{"commodity_out" => commodity_out})
       when commodity_out == "" or is_nil(commodity_out),
       do: query

  defp handle_demurrage_commodity_out_filter(query, %{"commodity_out" => commodity_out}) do
    where(query, [a], a.commodity_out_id == ^commodity_out)
  end

  defp handle_demurrage_commodity_in_filter(query, %{"commodity_in" => commodity_in})
       when commodity_in == "" or is_nil(commodity_in),
       do: query

  defp handle_demurrage_commodity_in_filter(query, %{"commodity_in" => commodity_in}) do
    where(query, [a], a.commodity_in_id == ^commodity_in)
  end

  defp handle_demurrage_wagon_filter(query, %{"wagon_code" => wagon_code})
       when wagon_code == "" or is_nil(wagon_code),
       do: query

  defp handle_demurrage_wagon_filter(query, %{"wagon_code" => wagon_code}) do
    where(
      query,
      [a, b, c, d, e, f, g],
      fragment("lower(?) LIKE lower(?)", b.code, ^"%#{wagon_code}%")
    )
  end

  defp compose_demurrage_report_isearch_filter(query, search_term) do
    query
    |> where(
      [a, b, c, d, e, f, g],
      fragment("lower(?) LIKE lower(?)", c.code, ^search_term) or
        fragment("lower(?) LIKE lower(?)", e.description, ^search_term) or
        fragment("lower(?) LIKE lower(?)", f.description, ^search_term) or
        fragment("lower(?) LIKE lower(?)", b.code, ^search_term)
    )
  end

  def compose_demurrage_report_select(query) do
    query
    |> order_by([a, b, c, d, e, f, g], desc: a.id)
    |> select([a, b, c, d, e, f, g], %{
      id: a.id,
      yard: a.yard,
      sidings: a.sidings,
      total_days: a.total_days,
      total_charge: a.total_charge,
      charge_rate: a.charge_rate,
      comment: a.comment,
      commodity_in_id: a.commodity_in_id,
      commodity_out_id: a.commodity_out_id,
      commodity_in: e.description,
      commodity_out: f.description,
      arrival_dt: a.arrival_dt,
      date_placed: a.date_placed,
      dt_placed_over_weekend: a.dt_placed_over_weekend,
      date_offloaded: a.date_offloaded,
      date_loaded: a.date_loaded,
      date_cleared: a.date_cleared,
      wagon_owner: c.code,
      wagon_code: b.code,
      currency: g.symbol,
      currency_id: a.currency_id
    })
  end

  def demurrage_lookup(id) do
    Demurrage
    |> where([a], a.id == ^id)
    |> join(:left, [a], b in Rms.SystemUtilities.Wagon, on: a.wagon_id == b.id)
    |> join(:left, [a, b], c in Rms.Accounts.RailwayAdministrator, on: b.owner_id == c.id)
    |> join(:left, [a, b, c], d in Rms.Accounts.User, on: a.maker_id == d.id)
    |> join(:left, [a, b, c, d], e in Rms.SystemUtilities.Commodity, on: a.commodity_in_id == e.id)
    |> join(:left, [a, b, c, d, e], f in Rms.SystemUtilities.Commodity,
      on: a.commodity_out_id == f.id
    )
    |> join(:left, [a, b, c, d, e, f], g in Rms.SystemUtilities.Currency,
      on: a.currency_id == g.id
    )
    |> select([a, b, c, d, e, f, g], %{
      id: c.id,
      yard: a.yard,
      sidings: a.sidings,
      total_days: a.total_days,
      total_charge: a.total_charge,
      charge_rate: a.charge_rate,
      commodity_in_id: a.commodity_in_id,
      commodity_out_id: a.commodity_out_id,
      commodity_in: e.description,
      commodity_out: f.description,
      comment: a.comment,
      arrival_dt: a.arrival_dt,
      date_placed: a.date_placed,
      dt_placed_over_weekend: a.dt_placed_over_weekend,
      date_offloaded: a.date_offloaded,
      date_loaded: a.date_loaded,
      date_cleared: a.date_cleared,
      wagon_owner: c.code,
      wagon_code: b.code,
      currency: g.symbol,
      currency_id: a.currency_id
    })
    |> Repo.one()
  end

  def current_account_lookup(year, direction, admin_id, start_dt, end_dt) do
    from(a in subquery(haulage_rows(admin_id, direction, start_dt, end_dt)))
    |> join(
      :right,
      [a],
      month in fragment("""
        SELECT DATENAME(MONTH, DATEADD(MM, s.number, CONVERT(DATETIME, 0))) AS [month_name],
        MONTH(DATEADD(MM, s.number, CONVERT(DATETIME, 0))) AS [month_No]
        FROM master.dbo.spt_values s
        WHERE [type] = 'P' AND s.number BETWEEN 0 AND 11
      """),
      on: month.month_No == fragment("MONTH(?)", a.inserted_at) and
          fragment("YEAR(?) = ?", a.inserted_at, ^year)
    )
    |> join(:left, [a, month], b in subquery(loco_rows(admin_id, direction, start_dt, end_dt)),
      on:
        month.month_No == fragment("MONTH(?)", b.inserted_at) and
          fragment("YEAR(?) = ?", b.inserted_at, ^year)
    )
    |> join(:left, [a, month, b], c in subquery(mat_rows(admin_id, direction, start_dt, end_dt)),
      on:
        month.month_No == fragment("MONTH(?)", c.inserted_at) and
          fragment("YEAR(?) = ?", c.inserted_at, ^year)
    )
    |> join(:left, [a, month, b, c], d in subquery(max_aux_rows(admin_id, direction, start_dt, end_dt)),
      on:
        month.month_No == fragment("MONTH(?)", d.interchange_date) and
          fragment("YEAR(?) = ?", d.interchange_date, ^year)
    )
    |> join(:left, [a, month, b, c, d], e in subquery(max_wagon_hire_rows(admin_id, direction, start_dt, end_dt)),
      on:
        month.month_No == fragment("MONTH(?)", e.inserted_at) and
          fragment("YEAR(?) = ?", e.inserted_at, ^year)
    )
    |> handle_group_by(start_dt, end_dt)
    |> compose_current_acc_select(start_dt, end_dt, direction)
    |> Repo.all()
  end

  defp handle_group_by(query, start_dt, end_dt) when not is_nil(start_dt) and not is_nil(end_dt) do
    query
    |> group_by([_a, _month, _b, _c, _d, e], [e.admin_id])
  end

  defp handle_group_by(query, _start_dt, _end_dt) do
    group_by(query, [_a, month, _b, _c, _d, _e], [month.month_name, month.month_No])
  end

  defp compose_current_acc_select(query, start_dt, end_dt, direction) when not is_nil(start_dt) and not is_nil(end_dt) do
    query
    |> select([a, month, b, c, d, e], %{
      direction: ^direction,
      total_amount: ( coalesce(sum(e.accumulative_amount), 0.00) + coalesce(sum(b.amount), 0.00) + coalesce(sum(d.total_amount), 0.00) + coalesce(sum(c.amount), 0.00) + coalesce(sum(a.amount), 0.00)),
      admin_name: fragment("select code from tbl_railway_administrator where id = ?", e.admin_id)
    })
  end

  defp compose_current_acc_select(query, _start_dt, _end_dt, direction) do
    query
    |> select([a, month, b, c, d, e], %{
      month_name: month.month_name,
      month_No: month.month_No,
      haulage_amount: coalesce(sum(a.amount), 0.00),
      material_sup_amount: coalesce(sum(c.amount), 0.00),
      axuxilary_amount: coalesce(sum(d.total_amount), 0.00),
      loco_dent_amount: coalesce(sum(b.amount), 0.00),
      total_amount: ( coalesce(sum(e.accumulative_amount), 0.00) + coalesce(sum(b.amount), 0.00) + coalesce(sum(d.total_amount), 0.00) + coalesce(sum(c.amount), 0.00) + coalesce(sum(a.amount), 0.00)),
      direction: ^direction,
      wagon_hire_amount: coalesce(sum(e.accumulative_amount), 0.00)
    })
  end

  def mat_rows(admin_id, direction, start_dt, end_dt) when not is_nil(start_dt) and not is_nil(end_dt) do
    from(x in Material,
      where: x.status in ["COMPLETE"] and x.admin_id in ^admin_id and x.direction == ^direction and
        fragment("cast(? as date) >= ? and cast(? as date) <= ?", x.inserted_at, ^start_dt, x.inserted_at, ^end_dt),
      select: %{
        admin_id: x.admin_id,
        amount: x.amount,
        id: x.id,
        inserted_at: x.inserted_at,
        direction: x.direction
      }
    )
  end

  def mat_rows(admin_id, direction, _start_dt, _end_dt) do
    from(x in Material,
      where: x.status in ["COMPLETE"] and x.admin_id in ^admin_id and x.direction == ^direction,
      select: %{
        admin_id: x.admin_id,
        amount: x.amount,
        id: x.id,
        inserted_at: x.inserted_at,
        direction: x.direction
      }
    )
  end

  def loco_rows(admin_id, direction, start_dt, end_dt) when not is_nil(start_dt) and not is_nil(end_dt) do
    from(x in LocoDetention,
      where: x.status in ["COMPLETE"] and x.admin_id in ^admin_id and x.direction == ^direction and
        fragment("cast(? as date) >= ? and cast(? as date) <= ?", x.inserted_at, ^start_dt, x.inserted_at, ^end_dt),
      select: %{
        admin_id: x.admin_id,
        amount: x.amount,
        id: x.id,
        inserted_at: x.inserted_at,
        direction: x.direction
      }
    )
  end

  def loco_rows(admin_id, direction, _start_dt, _end_dt) do
    from(x in LocoDetention,
      where: x.status in ["COMPLETE"] and x.admin_id in ^admin_id and x.direction == ^direction,
      select: %{
        admin_id: x.admin_id,
        amount: x.amount,
        id: x.id,
        inserted_at: x.inserted_at,
        direction: x.direction
      }
    )
  end

  def max_aux_rows(admin_id, direction, start_dt, end_dt) when not is_nil(start_dt) and not is_nil(end_dt) do
    from(x in Auxiliary,
      where: x.auth_status in ["COMPLETE"] and x.admin_id in ^admin_id and x.dirction == ^direction and
       (fragment("cast(? as date) >= ? and cast(? as date) <= ?", x.received_date, ^start_dt, x.received_date, ^end_dt) or
        fragment("cast(? as date) >= ? and cast(? as date) <= ?", x.sent_date, ^start_dt, x.sent_date, ^end_dt)
       ),
      group_by: [
        x.equipment_id,
        x.equipment_code,
        x.admin_id,
        coalesce(x.received_date, x.sent_date),
        x.admin_id
      ],
      select: %{
        admin_id: x.admin_id,
        total_amount:
          fragment("(select total_amount from tbl_interchange_auxiliary where id = ?)", max(x.id)),
        id: max(x.id),
        interchange_date: coalesce(x.received_date, x.sent_date),
        direction:
          fragment("(select dirction from tbl_interchange_auxiliary where id = ?)", max(x.id))
      }
    )
  end

  def max_aux_rows(admin_id, direction, _start_dt, _end_dt) do
    from(x in Auxiliary,
      where: x.auth_status in ["COMPLETE"] and x.admin_id in ^admin_id and x.dirction == ^direction,
      group_by: [
        x.equipment_id,
        x.equipment_code,
        x.admin_id,
        coalesce(x.received_date, x.sent_date),
        x.admin_id
      ],
      select: %{
        admin_id: x.admin_id,
        total_amount:
          fragment("(select total_amount from tbl_interchange_auxiliary where id = ?)", max(x.id)),
        id: max(x.id),
        interchange_date: coalesce(x.received_date, x.sent_date),
        direction:
          fragment("(select dirction from tbl_interchange_auxiliary where id = ?)", max(x.id))
      }
    )
  end

  def max_wagon_hire_rows(admin_id, direction, start_dt, end_dt) when not is_nil(start_dt) and not is_nil(end_dt) do
    from(t in Interchange,
      where: not is_nil(t.train_no) and t.direction == ^direction and t.adminstrator_id in ^admin_id and t.auth_status =="COMPLETE" and
        fragment("cast(? as date) >= ? and cast(? as date) <= ?", t.inserted_at, ^start_dt, t.inserted_at, ^end_dt),
      group_by: [t.train_no, t.wagon_id, t.adminstrator_id],
      select: %{
        admin_id: t.adminstrator_id,
        accumulative_amount:
          fragment("(select accumulative_amount from tbl_interchange where id = ?)", max(t.id)),
        id: max(t.id),
        inserted_at:
          fragment(
            "(select cast(inserted_at as date) from tbl_interchange where id = ?)",
            max(t.id)
          ),
        direction: fragment("(select direction from tbl_interchange where id = ?)", max(t.id))
      }
    )
  end

  def max_wagon_hire_rows(admin_id, direction, _start_dt, _end_dt) do
    from(t in Interchange,
      where: not is_nil(t.train_no) and t.direction == ^direction and t.adminstrator_id in ^admin_id and t.auth_status =="COMPLETE",
      group_by: [t.train_no, t.wagon_id, t.adminstrator_id],
      select: %{
        admin_id: t.adminstrator_id,
        accumulative_amount:
          fragment("(select accumulative_amount from tbl_interchange where id = ?)", max(t.id)),
        id: max(t.id),
        inserted_at:
          fragment(
            "(select cast(inserted_at as date) from tbl_interchange where id = ?)",
            max(t.id)
          ),
        direction: fragment("(select direction from tbl_interchange where id = ?)", max(t.id))
      }
    )
  end

  def haulage_rows(admin_id, direction, start_dt, end_dt) when not is_nil(start_dt) and not is_nil(end_dt) do
    settings = Rms.SystemUtilities.list_company_info()

    query =
      from(a in Haulage,
        where: a.admin_id in ^admin_id and fragment("cast(? as date) >= ? and cast(? as date) <= ?", a.inserted_at, ^start_dt, a.inserted_at, ^end_dt),
        select: %{
          admin_id: a.admin_id,
          amount: a.amount,
          direction: a.direction,
          inserted_at: a.inserted_at
        })
    handle_payee_admin(query, settings.current_railway_admin, direction)
  end

  def haulage_rows(admin_id, direction, _start_dt, _end_dt) do
    settings = Rms.SystemUtilities.list_company_info()

    query =
      from(a in Haulage,
        where: a.admin_id in ^admin_id,
        select: %{
          admin_id: a.admin_id,
          amount: a.amount,
          direction: a.direction,
          inserted_at: a.inserted_at
        })
    handle_payee_admin(query, settings.current_railway_admin, direction)
  end

  defp handle_payee_admin(query, local_admin, "INCOMING") do
    where(query, [a], a.payee_admin_id != ^local_admin or is_nil(a.payee_admin_id))
  end
  defp handle_payee_admin(query, local_admin, _direction) do
    where(query, [a], a.payee_admin_id == ^local_admin)
  end

  def wagon_turn_around_lookup(direction, from, to) do
    Interchange
    |> join(:left, [a], b in Rms.Accounts.RailwayAdministrator, on: b.id == a.adminstrator_id)
    |> handle_wagon_turn_around_filter(direction, from, to)
    |> group_by([a, b], [b.code])
    |> select([a, b], %{
      count: count(a.id),
      administrator: b.code,
      total_accum_days: sum(a.total_accum_days),
      average: (sum(a.total_accum_days)/ count(a.id))
    })
    |> Repo.all()
  end

  defp handle_wagon_turn_around_filter(query, direction, from, to)
  when byte_size(direction) > 0 and byte_size(to) > 0 and  byte_size(from) > 0 do
    query
    |> where(
      [a, _b],
        fragment("CAST(? AS DATE) >= ?", a.inserted_at, ^from) and
        fragment("CAST(? AS DATE) <= ?", a.inserted_at, ^to) and
        a.direction == ^direction and
        a.auth_status == "COMPLETE"
      )
  end

  defp handle_wagon_turn_around_filter(query, _direction, _from, _to) do
    query
    |> where(
      [a, _b],
        a.auth_status == "NONE"
      )
  end

  def wagon_turn_around_lookup() do
    Interchange
    |> join(:left, [a], b in Rms.Accounts.RailwayAdministrator, on: b.id == a.adminstrator_id)
    |> where(
      [a, _b],
        a.auth_status == "COMPLETE"
      )
    |> group_by([a, b], [b.code])
    |> select([a, b], %{
      count: count(a.id),
      administrator: b.code,
      total_accum_days: sum(a.total_accum_days),
      average: avg(a.total_accum_days)
    })
    |> Repo.all()
  end


end
