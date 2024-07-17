defmodule Rms.Order do
  @moduledoc """
  The Order context.
  """

  import Ecto.Query, warn: false
  alias Rms.Repo

  alias Rms.Order.Movement
  alias Rms.MovementExceptions.MovementException

  @doc """
  Returns the list of tbl_movement.

  ## Examples

      iex> list_tbl_movement()
      [%Movement{}, ...]

  """

  # def list_tbl_movement do
  #   Repo.all(Movement)
  # end

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

  def verify_depo_requisites(query, user) do
    with("M" <- user.role.report.aces_lvl) do
      query
    else
      _ ->
        where(
          query,
          [a],
          a.depo_refueled_id == ^user.station_id
        )
    end
  end

  def verify_user_station_id_for_consignment(query, user) do
    with("M" <- user.role.report.aces_lvl) do
      query
    else
      _ ->
        where(
          query,
          [a],
          a.final_destination_id == ^user.station_id or a.origin_station_id == ^user.station_id
        )
    end
  end

  def verify_user_station_id_for_movement(query, user) do
    with("M" <- user.role.report.aces_lvl) do
      query
    else
      _ ->
        where(
          query,
          [a],
          a.origin_station_id == ^user.station_id or a.destin_station_id == ^user.station_id
        )
    end
  end

  def list_tbl_movement do
    Movement
    |> preload([
      :maker,
      :checker,
      :commodity,
      :origin_station,
      :destin_station,
      :loco,
      :payer,
      :wagon
    ])
    |> Repo.all()
  end

  def search_for_train_list_entry(wagon_id, train_no) do
    Movement
    |> where([m], m.wagon_id == ^wagon_id and m.train_no == ^train_no)
    |> join(:left, [m], c in Rms.Order.Consignment,
      on:
        c.commodity_id == m.commodity_id and c.document_date == m.consignment_date and
          c.final_destination_id == m.destin_station_id and
          c.origin_station_id == m.origin_station_id and c.wagon_id == m.wagon_id and
          c.consignee_id == m.consignee_id and c.consigner_id == m.consigner_id
    )
    |> limit(1)
    |> select([m, c], %{
      customer_id: c.customer_id,
      origin_station_id: m.origin_station_id,
      commodity_id: m.commodity_id,
      destin_station_id: m.destin_station_id
    })
    |> Repo.one()
  end

  def search_for_train(train_no) do
    Movement
    |> where([m], m.train_no == ^train_no)
    |> select([m], %{
      origin_station_id: m.movement_origin_id,
      destin_station_id: m.movement_destination_id
    })
    |> limit(1)
    |> Repo.one()
  end

  @doc """
  Gets a single movement.

  Raises `Ecto.NoResultsError` if the Movement does not exist.

  ## Examples

      iex> get_movement!(123)
      %Movement{}

      iex> get_movement!(456)
      ** (Ecto.NoResultsError)

  """
  def get_movement!(id), do: Repo.get!(Movement, id)

  @doc """
  Creates a movement.

  ## Examples

      iex> create_movement(%{field: value})
      {:ok, %Movement{}}

      iex> create_movement(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_movement(attrs \\ %{}) do
    %Movement{}
    |> Movement.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a movement.

  ## Examples

      iex> update_movement(movement, %{field: new_value})
      {:ok, %Movement{}}

      iex> update_movement(movement, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_movement(%Movement{} = movement, attrs) do
    movement
    |> Movement.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a movement.

  ## Examples

      iex> delete_movement(movement)
      {:ok, %Movement{}}

      iex> delete_movement(movement)
      {:error, %Ecto.Changeset{}}

  """
  def delete_movement(%Movement{} = movement) do
    Repo.delete(movement)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking movement changes.

  ## Examples

      iex> change_movement(movement)
      %Ecto.Changeset{data: %Movement{}}

  """
  def change_movement(%Movement{} = movement, attrs \\ %{}) do
    Movement.changeset(movement, attrs)
  end

  alias Rms.Order.FuelMonitoring

  @doc """
  Returns the list of tbl_fuel_monitoring.

  ## Examples

      iex> list_tbl_fuel_monitoring()
      [%FuelMonitoring{}, ...]

  """

  def get_fuel_monitor_by_date(quarter, year) do
    FuelMonitoring
    |> where(
      [a],
      a.status == "COMPLETE" and
        fragment("DATEPART(QUARTER, ?) = ? and YEAR(?) = ?", a.date, ^quarter, a.date, ^year)
    )
    |> join(:left, [a], b in Rms.SystemUtilities.Refueling, on: a.refuel_type == b.id)
    |> join(:left, [a, b], c in Rms.SystemUtilities.Rates, on: a.depo_refueled_id == c.id)
    |> order_by([a, b, c], desc: [b.description, fragment("FORMAT(?, 'MMMM', 'en-US')", a.date)])
    |> group_by([a, b, c], [
      fragment("FORMAT(?, 'MMMM', 'en-US')", a.date),
      b.category,
      b.description,
      a.fuel_rate,
      a.refuel_type,
      a.fuel_consumed
    ])
    |> select([a, b, c], %{
      count: count(a.id),
      avarage: fragment("select avg(fuel_rate) from tbl_fuel_monitoring"),
      monthly_total: a.fuel_consumed,
      category: b.category,
      total_fuel_rate: sum(a.fuel_rate),
      date: fragment("FORMAT(?, 'MMMM', 'en-US')", a.date),
      total_consumed: sum(a.fuel_consumed),
      total_payment: sum(a.fuel_consumed) * sum(a.fuel_rate),
      refuel_type: b.description,
      distance: sum(a.km_to_destin)
    })
    |> Repo.all()
  end

  def lookup_tonnage(quarter, year) do
    from(a in Rms.Order.FuelMonitoring, as: :requisite)
    |> where(
      [a],
      a.status == "COMPLETE" and
        fragment("DATEPART(QUARTER, ?) = ? and YEAR(?) = ?", a.date, ^quarter, a.date, ^year)
    )
    |> join(:left, [a], b in Rms.Order.Movement, on: a.train_number == b.train_no)
    |> join(:left, [a, b], c in Rms.Order.Consignment,
      on:
        c.document_date == b.consignment_date and c.final_destination_id == b.destin_station_id and
          c.origin_station_id == b.origin_station_id and c.wagon_id == b.wagon_id and
          c.consignee_id == b.consignee_id and c.consigner_id == b.consigner_id
    )
    |> where(
      [a, b],
      exists(
        from(m in Rms.Order.Movement, where: parent_as(:requisite).train_number == m.train_no)
      )
    )
    |> order_by([a, b, c], desc: [fragment("FORMAT(?, 'MMMM', 'en-US')", a.date)])
    |> group_by([a, b, c], [
      a.train_destination_id,
      a.depo_refueled_id,
      fragment("FORMAT(?, 'MMMM', 'en-US')", a.date)
    ])
    |> select([a, b, c], %{
      mvt_revenue: sum(c.total),
      date: fragment("FORMAT(?, 'MMMM', 'en-US')", a.date),
      tonnages:
        fragment(
          "sum(case when ? < 1 then ? else ? end)",
          c.actual_tonnes,
          c.container_no,
          c.actual_tonnes
        ),
      tonnages_per_km:
        fragment(
          "sum(case when ? < 1 then ? else ? end)",
          c.actual_tonnes,
          c.container_no,
          c.actual_tonnes
        ) *
          fragment(
            "select distance from tbl_distance where destin = ? and station_orig = ? ",
            a.train_destination_id,
            a.depo_refueled_id
          )
    })
    |> Repo.all()
  end

  def get_fuel_request_weekly(month, year) do
    FuelMonitoring
    |> where(
      [a],
      a.status == "COMPLETE" and
        fragment("DATEPART(MONTH, ?) = ? and YEAR(?) = ?", a.date, ^month, a.date, ^year)
    )
    |> join(:left, [a], b in Rms.SystemUtilities.Refueling, on: a.refuel_type == b.id)
    |> join(:left, [a, b], c in Rms.SystemUtilities.Rates, on: a.depo_refueled_id == c.id)
    |> order_by([a, b, c], desc: [b.description])
    |> group_by([a, b, c], [
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
        a.date,
        a.date,
        a.date,
        a.date
      ),
      b.category,
      b.description,
      a.fuel_rate,
      a.refuel_type,
      a.fuel_consumed
    ])
    |> select([a, b, c],
      # count: count(a.id),
      count: fragment("count(1)"),
      avarage: fragment("select avg(fuel_rate) from tbl_fuel_monitoring"),
      monthly_total: a.fuel_consumed,
      category: b.category,
      total_fuel_rate: sum(a.fuel_rate),
      total_consumed: sum(a.fuel_consumed),
      total_payment: sum(a.fuel_consumed) * sum(a.fuel_rate),
      refuel_type: b.description,
      distance: sum(a.km_to_destin),
      # date: fragment("DATEPART(week, ?)%MONTH(?)", a.date, a.date),
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
          a.date,
          a.date,
          a.date,
          a.date
        )
    )
    |> Repo.all()
    |> Enum.map(&Enum.into(&1, %{}))
  end

  def lookup_weekly_tonnage(month, year) do
    from(a in Rms.Order.FuelMonitoring, as: :requisite)
    |> where(
      [a],
      a.status == "COMPLETE" and
        fragment("DATEPART(MONTH, ?) = ? and YEAR(?) = ?", a.date, ^month, a.date, ^year)
    )
    |> join(:left, [a], b in Rms.Order.Movement, on: a.train_number == b.train_no)
    |> join(:left, [a, b], c in Rms.Order.Consignment, on: c.document_date == b.consignment_date)
    |> where(
      [a, b],
      exists(
        from(m in Rms.Order.Movement, where: parent_as(:requisite).train_number == m.train_no)
      )
    )
    |> order_by([a, b, c], desc: [a.train_destination_id])
    |> group_by([a, b, c], [
      a.train_destination_id,
      a.depo_stn,
      fragment(
        """
        CASE

          WHEN DAY(?) BETWEEN 1 and 7 THEN 'Week 1'
          WHEN DAY(?) BETWEEN 7 and 14 THEN 'Week 2'
          WHEN DAY(?)BETWEEN 14 and 21 THEN 'Week 3'
          WHEN DAY(?)BETWEEN 21 and 29 THEN 'Week 4'
          ELSE 'Week 5'
        END
        """,
        a.date,
        a.date,
        a.date,
        a.date
      )
    ])
    |> select([a, b, c], %{
      mvt_revenue: sum(c.total),
      # date: fragment("FORMAT(?, 'MMMM', 'en-US')", a.date),
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
          a.date,
          a.date,
          a.date,
          a.date
        ),
      tonnages:
        fragment(
          "sum(case when ? < 1 then ? else ? end)",
          c.actual_tonnes,
          c.container_no,
          c.actual_tonnes
        ),
      tonnages_per_km:
        fragment(
          "sum(case when ? < 1 then ? else ? end)",
          c.actual_tonnes,
          c.container_no,
          c.actual_tonnes
        ) *
          fragment(
            "select distance from tbl_distance where destin = ? and station_orig = ? ",
            a.train_destination_id,
            a.depo_stn
          )
    })
    |> Repo.all()
  end

  def get_mvt_exceptions(month, year) do
    MovementException
    |> where(
      [a],
      a.status == "A" and
        fragment(
          "DATEPART(MONTH, ?) = ? and YEAR(?) = ?",
          a.capture_date,
          ^month,
          a.capture_date,
          ^year
        )
    )
    # |> order_by([a, b, c], desc: [b.description])
    |> group_by([a], [
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
        a.capture_date,
        a.capture_date,
        a.capture_date,
        a.capture_date
      )
    ])
    |> select([a], %{
      # count: count(a.id),
      count: fragment("count(1)"),
      derailment: sum(a.derailment),
      axles: sum(a.axles),
      light_engines: sum(a.light_engines),
      empty_wagons: sum(a.empty_wagons),
      # average: avg(a.derailment),
      week_no:
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
          a.capture_date,
          a.capture_date,
          a.capture_date,
          a.capture_date
        )
    })
    |> Repo.all()
    |> Enum.map(&Enum.into(&1, %{}))
  end

  def get_consumption_by_routes(month, year) do
    from(a in Rms.Order.FuelMonitoring, as: :requisite)
    |> where(
      [a],
      a.status == "COMPLETE" and
        fragment("DATEPART(MONTH, ?) = ? and YEAR(?) = ?", a.date, ^month, a.date, ^year)
    )
    |> join(:left, [a], b in Rms.Order.Movement, on: a.train_number == b.train_no)
    |> join(:left, [a, b], c in Rms.Order.Consignment, on: c.document_date == b.consignment_date)
    |> join(:left, [a, b, c], d in Rms.SystemUtilities.Section, on: a.section_id == d.id)
    |> where(
      [a, b],
      exists(
        from(m in Rms.Order.Movement, where: parent_as(:requisite).train_number == m.train_no)
      )
    )
    |> order_by([a, b, c, d], desc: [d.description, a.train_destination_id, a.depo_stn])
    |> group_by([a, b, c, d], [
      d.description,
      a.fuel_consumed,
      a.train_destination_id,
      a.depo_stn,
      fragment(
        """
        CASE

          WHEN DAY(?) BETWEEN 1 and 7 THEN 'Week 1'
          WHEN DAY(?) BETWEEN 7 and 14 THEN 'Week 2'
          WHEN DAY(?)BETWEEN 14 and 21 THEN 'Week 3'
          WHEN DAY(?)BETWEEN 21 and 29 THEN 'Week 4'
          ELSE 'Week 5'
        END
        """,
        a.date,
        a.date,
        a.date,
        a.date
      )
    ])
    |> select([a, b, c, d], %{
      litres: a.fuel_consumed,
      section: d.description,
      week_no:
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
          a.date,
          a.date,
          a.date,
          a.date
        ),
      # tonnages: fragment("sum(case when ? < 1 then ? else ? end)", c.actual_tonnes, c.container_no, c.actual_tonnes),
      tonnages_per_km:
        fragment(
          "sum(case when ? < 1 then ? else ? end)",
          c.actual_tonnes,
          c.container_no,
          c.actual_tonnes
        ) *
          fragment(
            "select distance from tbl_distance where destin = ? and station_orig = ? ",
            a.train_destination_id,
            a.depo_stn
          )
    })
    |> Repo.all()
  end

  def get_users_name() do
    FuelMonitoring
    |> join(:left, [a], b in Rms.Accounts.User, on: a.commercial_clerk_id == b.id)
    |> select([a, b], %{
      Maker_firstname: b.first_name,
      Maker_lastname: b.last_name
    })
    |> Repo.all()
  end

  # def get_fuel_monitor_by_date() do
  #   FuelMonitoring
  #   |> where([a], a.status == "COMPLETE")
  #   |> join(:left, [a], b in Rms.SystemUtilities.Refueling, on: a.refuel_type == b.id)
  #   |> order_by([a, b], desc: [b.description])
  #   |> group_by([a, b], [b.description, fragment("FORMAT(?, 'MMMM', 'en-US')", a.date), a.refuel_type, a.fuel_consumed])
  #   |> select([a, b], %{
  #     count: count(a.id),
  #     total_consumed: sum(a.fuel_consumed),
  #     monthly_total: a.fuel_consumed,
  #     date: fragment("FORMAT(?, 'MMMM', 'en-US')", a.date),
  #     refuel_type: b.description,
  #     distance: sum(a.km_to_destin)
  #   })
  #   |> Repo.all()
  # end

  def list_tbl_fuel_monitoring do
    Repo.all(FuelMonitoring)
  end

  @doc """
  Gets a single fuel_monitoring.

  Raises `Ecto.NoResultsError` if the Fuel monitoring does not exist.

  ## Examples

      iex> get_fuel_monitoring!(123)
      %FuelMonitoring{}

      iex> get_fuel_monitoring!(456)
      ** (Ecto.NoResultsError)

  """
  def get_fuel_monitoring!(id), do: Repo.get!(FuelMonitoring, id)

  @doc """
  Creates a fuel_monitoring.

  ## Examples

      iex> create_fuel_monitoring(%{field: value})
      {:ok, %FuelMonitoring{}}

      iex> create_fuel_monitoring(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_fuel_monitoring(attrs \\ %{}) do
    %FuelMonitoring{}
    |> FuelMonitoring.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a fuel_monitoring.

  ## Examples %{loco_driver_id:1, depo_refueled_id:1, commercial_clerk_id:1}

      iex> update_fuel_monitoring(fuel_monitoring, %{field: new_value})
      {:ok, %FuelMonitoring{}}

      iex> update_fuel_monitoring(fuel_monitoring, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_fuel_monitoring(%FuelMonitoring{} = fuel_monitoring, attrs) do
    fuel_monitoring
    |> FuelMonitoring.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a fuel_monitoring.

  ## Examples

      iex> delete_fuel_monitoring(fuel_monitoring)
      {:ok, %FuelMonitoring{}}

      iex> delete_fuel_monitoring(fuel_monitoring)
      {:error, %Ecto.Changeset{}}

  """
  def delete_fuel_monitoring(%FuelMonitoring{} = fuel_monitoring) do
    Repo.delete(fuel_monitoring)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking fuel_monitoring changes.

  ## Examples

      iex> change_fuel_monitoring(fuel_monitoring)
      %Ecto.Changeset{data: %FuelMonitoring{}}

  """
  def change_fuel_monitoring(%FuelMonitoring{} = fuel_monitoring, attrs \\ %{}) do
    FuelMonitoring.changeset(fuel_monitoring, attrs)
  end

  alias Rms.Order.Batch

  @doc """
  Returns the list of tbl_batch.

  ## Examples

      iex> list_tbl_batch()
      [%Batch{}, ...]

  """
  def list_tbl_batch do
    Repo.all(Batch)
  end

  @doc """
  Gets a single batch.

  Raises `Ecto.NoResultsError` if the Batch does not exist.

  ## Examples

      iex> get_batch!(123)
      %Batch{}

      iex> get_batch!(456)
      ** (Ecto.NoResultsError)

  """
  def get_batch!(id), do: Repo.get!(Batch, id)

  @doc """
  Creates a batch.

  ## Examples

      iex> create_batch(%{field: value})
      {:ok, %Batch{}}

      iex> create_batch(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_batch(attrs \\ %{}) do
    %Batch{}
    |> Batch.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a batch.

  ## Examples

      iex> update_batch(batch, %{field: new_value})
      {:ok, %Batch{}}

      iex> update_batch(batch, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_batch(%Batch{} = batch, attrs) do
    batch
    |> Batch.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a batch.

  ## Examples

      iex> delete_batch(batch)
      {:ok, %Batch{}}

      iex> delete_batch(batch)
      {:error, %Ecto.Changeset{}}

  """
  def delete_batch(%Batch{} = batch) do
    Repo.delete(batch)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking batch changes.

  ## Examples

      iex> change_batch(batch)
      %Ecto.Changeset{data: %Batch{}}

  """
  def change_batch(%Batch{} = batch, attrs \\ %{}) do
    Batch.changeset(batch, attrs)
  end

  def select_last_batch(user_id) do
    from(a in Batch,
      order_by: [desc: a.id],
      where: a.current_user_id == ^user_id and a.last_user_id == ^user_id,
      where: fragment("CAST(? as date) = CAST(GETDATE() as date)", a.trans_date),
      limit: 1,
      select: a
    )
    |> Repo.one()
  end

  def data_batch(status) do
    Batch
    |> join(:left, [a], b in Rms.Order.Consignment, on: a.id == b.batch_id)
    |> where([a, _b], status: ^status)
    |> group_by([a, b], [a.id, b.batch_id, a.batch_no, a.trans_date])
    |> select([a, _b], map(a, [:id, :batch_no, :trans_date]))
    |> Repo.all()
  end

  def data_entry_batch(user_id) do
    Batch
    |> join(:left, [a], b in Rms.Order.Consignment, on: a.id == b.batch_id)
    |> join(:left, [a, _b], c in Rms.Accounts.User, on: a.last_user_id == c.id)
    |> where([a, _b, _c], status: "O", last_user_id: ^user_id, current_user_id: ^user_id)
    |> group_by([a, b, c], [a.id, b.batch_id, a.batch_no, a.trans_date, c.first_name, c.last_name])
    # |> select([a, _b], map(a, [:id, :batch_no, :trans_date]))
    |> select([a, b, c], %{
      id: a.id,
      batch_no: a.batch_no,
      trans_date: a.trans_date,
      first_name: c.first_name,
      last_name: c.last_name
    })
    |> Repo.all()
  end

  def consignment_draft_batches(user) do
    Batch
    |> join(:left, [a], b in Rms.Order.Consignment, on: a.id == b.batch_id)
    |> join(:left, [a, _b], c in Rms.Accounts.User, on: a.last_user_id == c.id)
    |> verify_user_region_batch(user, "O", "CONSIGNMENT")
    |> group_by([a, b, c], [a.id, b.batch_id, a.batch_no, a.trans_date, c.first_name, c.last_name])
    |> select([a, b, c], %{
      id: a.id,
      batch_no: a.batch_no,
      trans_date: a.trans_date,
      first_name: c.first_name,
      last_name: c.last_name
    })
    |> Repo.all()
  end

  def verify_user_region_batch(query, user, status, batch_type) do
    with("M" <- user.role.report.aces_lvl) do
      where(
        query,
        [a, _b, _c],
        a.status == ^status and a.batch_type == ^batch_type
      )
    else
      _ ->
        where(
          query,
          [a, _b, _c],
          a.status == ^status and a.batch_type == ^batch_type and a.last_user_id == ^user.id and
            a.current_user_id == ^user.id
        )
    end
  end

  def consignment_rejected_batches(user) do
    Batch
    |> join(:left, [a], b in Rms.Order.Consignment, on: a.id == b.batch_id)
    |> join(:left, [a, _b], c in Rms.Accounts.User, on: a.last_user_id == c.id)
    |> verify_user_region_batch(user, "R", "CONSIGNMENT")
    |> select([a, b, c], %{
      id: a.id,
      batch_no: a.batch_no,
      trans_date: a.trans_date,
      first_name: c.first_name,
      last_name: c.last_name
    })
    |> Repo.all()
  end

  def list_batch_items(batch_id, empty_commodity) do
    Rms.Order.Consignment
    |> where([a], a.batch_id == ^batch_id and a.commodity_id != ^empty_commodity)
    |> join(:left, [a], b in Rms.SystemUtilities.Wagon, on: a.wagon_id == b.id)
    |> join(:left, [a, b], c in Rms.SystemUtilities.WagonType, on: b.wagon_type_id == c.id)
    |> join(:left, [a, b, _c], d in Rms.Accounts.RailwayAdministrator, on: b.owner_id == d.id)
    |> join(:left, [a, b, _c, _d], e in Rms.SystemUtilities.TariffLine, on: e.id == a.tarrif_id)
    |> join(:left, [a, b, _c, _d, e], f in Rms.SystemUtilities.Surchage,
      on: e.surcharge_id == f.id
    )
    |> select([a, b, c, d, e, f], %{
      id: a.id,
      capture_date: a.capture_date,
      code: a.code,
      customer_ref: a.customer_ref,
      document_date: a.document_date,
      sale_order: a.sale_order,
      station_code: a.station_code,
      status: a.status,
      vat_amount: a.vat_amount,
      invoice_no: a.invoice_no,
      final_destination_id: a.final_destination_id,
      origin_station_id: a.origin_station_id,
      reporting_station_id: a.reporting_station_id,
      commodity_id: a.commodity_id,
      consignee_id: a.consignee_id,
      consigner_id: a.consigner_id,
      customer_id: a.customer_id,
      payer_id: a.payer_id,
      tarrif_id: a.tarrif_id,
      maker_id: a.maker_id,
      batch_id: a.batch_id,
      wagon_id: a.wagon_id,
      checker_id: a.checker_id,
      comment: a.comment,
      capacity_tonnes: a.capacity_tonnes,
      actual_tonnes: a.actual_tonnes,
      tariff_tonnage: a.tariff_tonnage,
      tariff_origin_id: a.tariff_origin_id,
      tariff_destination_id: a.tariff_destination_id,
      container_no: a.container_no,
      wagon_owner: d.description,
      wagon_type: c.description,
      invoice_number: a.invoice_no,
      train_number: a.invoice_no,
      move_date: a.invoice_no,
      total: a.total,
      vat_applied: a.vat_applied,
      grand_total: a.grand_total,
      wagon_code: b.code,
      surcharge: f.surcharge_percent
    })
    |> limit(1)
    |> Repo.one()
  end

  def monthly_income_summary(start_end, end_date, unmatched_period, user) do
    from(a in Rms.Order.Consignment, as: :consign)
    |> where(
      [a],
      a.status in ["COMPLETE", "PENDING_INVOICE"] and not is_nil(a.total) and
        fragment("CAST(? AS DATE) >= ?", a.inserted_at, ^start_end) and
        fragment("CAST(? AS DATE) <= ?", a.inserted_at, ^end_date)
    )
    |> verify_user_station_id_for_consignment(user)
    |> join(:left, [a], b in Rms.SystemUtilities.Commodity, on: a.commodity_id == b.id)
    |> join(:left, [a, b], c in Rms.SystemUtilities.TariffLine, on: a.tarrif_id == c.id)
    |> join(:left, [a, b, c], d in Rms.SystemUtilities.Currency, on: c.currency_id == d.id)
    |> join(:left, [a, b, c, d], e in Rms.SystemUtilities.TrainRoute, on: a.route_id == e.id)
    |> join(:left, [a, b, c, d, e], f in Rms.SystemUtilities.TransportType,
      on: e.transport_type == f.id
    )
    |> join(:left, [a, b, c, d, e, f], g in Rms.Order.Movement,
      on:
        a.commodity_id == g.commodity_id and a.document_date == g.consignment_date and
          a.final_destination_id == g.destin_station_id and
          a.origin_station_id == g.origin_station_id and a.wagon_id == g.wagon_id and
          a.consignee_id == g.consignee_id and a.consigner_id == g.consigner_id
    )
    |> where(
      [a, b, c, d, e, f],
      exists(
        from(m in Rms.Order.Movement,
          where:
            parent_as(:consign).commodity_id == m.commodity_id and
              parent_as(:consign).document_date == m.consignment_date and
              parent_as(:consign).final_destination_id == m.destin_station_id and
              parent_as(:consign).origin_station_id == m.origin_station_id and
              parent_as(:consign).wagon_id == m.wagon_id and
              parent_as(:consign).consignee_id == m.consignee_id and
              parent_as(:consign).consigner_id == m.consigner_id and
              (m.inserted_at <=
                 date_add(parent_as(:consign).inserted_at, ^unmatched_period, "day") or
                 m.manual_matching == "YES")
        )
      )
    )
    |> order_by([a, b, c, d, e, f, g], desc: [a.commodity_id])
    |> group_by([a, b, c, d, e, f, g], [f.description, a.commodity_id, b.description, c.id, d.id])
    |> select([a, b, c, d, e, f, g], %{
      tarrif_id: c.id,
      transport_type: f.description,
      wagons: count(a.id),
      currency_symbol: fragment("select symbol from tbl_currency where id = ?", d.id),
      currency_id: d.id,
      commodity_type: b.description,
      commodity_id: a.commodity_id,
      amount: sum(a.total),
      rate: fragment("select sum(rate) from tbl_tariff_line_rates where tariff_id = ?", c.id),
      tarrif_rate_count:
        fragment("select count(*) from tbl_tariff_line_rates where tariff_id = ?", c.id),
      tonnages:
        fragment(
          "sum(case when ? > 0 then ? else ? end)",
          a.tariff_tonnage,
          a.tariff_tonnage,
          a.actual_tonnes
        )
    })
    |> Repo.all()
  end

  def haulage_invoice_report(start_end, end_date, unmatched_period, user) do
    from(a in Rms.Order.Consignment, as: :consign)
    |> where(
      [a],
      a.status in ["COMPLETE", "PENDING_INVOICE"] and not is_nil(a.total) and
        fragment("CAST(? AS DATE) >= ?", a.inserted_at, ^start_end) and
        fragment("CAST(? AS DATE) <= ?", a.inserted_at, ^end_date)
    )
    |> verify_user_station_id_for_consignment(user)
    |> join(:left, [a], b in Rms.SystemUtilities.Commodity, on: a.commodity_id == b.id)
    |> join(:left, [a, b], c in Rms.SystemUtilities.TariffLine, on: a.tarrif_id == c.id)
    |> join(:left, [a, b, c], d in Rms.SystemUtilities.Currency, on: c.currency_id == d.id)
    |> join(:left, [a, b, c, d], e in Rms.SystemUtilities.TrainRoute, on: a.route_id == e.id)
    |> join(:left, [a, b, c, d, e], f in Rms.SystemUtilities.TransportType,
      on: e.transport_type == f.id
    )
    |> join(:left, [a, b, c, d, e, f], g in Rms.Order.Movement,
      on:
        a.commodity_id == g.commodity_id and a.document_date == g.consignment_date and
          a.final_destination_id == g.destin_station_id and
          a.origin_station_id == g.origin_station_id and a.wagon_id == g.wagon_id and
          a.consignee_id == g.consignee_id and a.consigner_id == g.consigner_id
    )
    |> where(
      [a, b, c, d, e, f],
      exists(
        from(m in Rms.Order.Movement,
          where:
            parent_as(:consign).commodity_id == m.commodity_id and
              parent_as(:consign).document_date == m.consignment_date and
              parent_as(:consign).final_destination_id == m.destin_station_id and
              parent_as(:consign).origin_station_id == m.origin_station_id and
              parent_as(:consign).wagon_id == m.wagon_id and
              parent_as(:consign).consignee_id == m.consignee_id and
              parent_as(:consign).consigner_id == m.consigner_id and
              (m.inserted_at <=
                 date_add(parent_as(:consign).inserted_at, ^unmatched_period, "day") or
                 m.manual_matching == "YES")
        )
      )
    )
    |> order_by([a, b, c, d, e, f, g], desc: [a.commodity_id])
    |> group_by([a, b, c, d, e, f, g], [
      f.description,
      a.commodity_id,
      b.description,
      c.id,
      a.final_destination_id,
      a.origin_station_id,
      d.id
    ])
    |> select([a, b, c, d, e, f, g], %{
      transport_type: f.description,
      wagons: count(a.id),
      tarrif_id: c.id,
      currency_symbol: fragment("select symbol from tbl_currency where id = ?", d.id),
      currency_id: d.id,
      commodity_type: b.description,
      commodity_id: a.commodity_id,
      amount: sum(a.total),
      tonnages_per_km:
        fragment(
          "sum(case when ? > 0 then ? else ? end)",
          a.tariff_tonnage,
          a.tariff_tonnage,
          a.actual_tonnes
        ) *
          fragment(
            "select distance from tbl_distance where destin = ? and station_orig = ? ",
            a.final_destination_id,
            a.origin_station_id
          ),
      # avg(d.rate),
      rate: fragment("select sum(rate) from tbl_tariff_line_rates where tariff_id = ?", c.id),
      tarrif_rate_count:
        fragment("select count(*) from tbl_tariff_line_rates where tariff_id = ?", c.id),
      tonnages:
        fragment(
          "sum(case when ? > 0 then ? else ? end)",
          a.tariff_tonnage,
          a.tariff_tonnage,
          a.actual_tonnes
        )
    })
    |> Repo.all()
  end

  def unmatched_unaging(start_end, end_date, unmatched_period, user) do
    from(a in Rms.Order.Consignment, as: :consign)
    |> where(
      [a],
      a.status in ["COMPLETE", "PENDING_INVOICE"] and not is_nil(a.total) and
        fragment("CAST(? AS DATE) >= ?", a.inserted_at, ^start_end) and
        fragment("CAST(? AS DATE) <= ?", a.inserted_at, ^end_date)
    )
    |> verify_user_station_id_for_consignment(user)
    |> join(:left, [a], b in Rms.SystemUtilities.Commodity, on: a.commodity_id == b.id)
    |> join(:left, [a, b], c in Rms.SystemUtilities.TariffLine, on: a.tarrif_id == c.id)
    |> join(:left, [a, b, c, d], d in Rms.SystemUtilities.Currency, on: c.currency_id == d.id)
    |> join(:left, [a, b, c, d], e in Rms.SystemUtilities.TrainRoute, on: a.route_id == e.id)
    |> join(:left, [a, b, c, d, e], f in Rms.SystemUtilities.TransportType,
      on: e.transport_type == f.id
    )
    # |> join(:left, [a, b, c, e, f, ], g in Rms.Order.Movement, on: a.commodity_id == g.commodity_id and a.document_date == g.consignment_date and a.final_destination_id == g.destin_station_id and a.origin_station_id == g.origin_station_id and a.wagon_id == g.wagon_id and a.consignee_id == g.consignee_id and a.consigner_id == g.consigner_id)
    |> where(
      [a, b, c, d, e, f],
      exists(
        from(m in Rms.Order.Movement,
          where:
            parent_as(:consign).commodity_id == m.commodity_id and
              parent_as(:consign).document_date == m.consignment_date and
              parent_as(:consign).final_destination_id == m.destin_station_id and
              parent_as(:consign).origin_station_id == m.origin_station_id and
              parent_as(:consign).wagon_id == m.wagon_id and
              parent_as(:consign).consignee_id == m.consignee_id and
              parent_as(:consign).consigner_id == m.consigner_id and
              m.inserted_at > date_add(parent_as(:consign).inserted_at, ^unmatched_period, "day") and
              m.manual_matching == "NO"
        )
      )
    )
    |> order_by([a, b, c, d, e, f], desc: [a.commodity_id])
    |> group_by([a, b, c, d, e, f], [f.description, a.commodity_id, b.description, c.id, d.id])
    |> select([a, b, c, d, e, f], %{
      tarrif_id: c.id,
      transport_type: f.description,
      wagons: count(a.id),
      currency_symbol: fragment("select symbol from tbl_currency where id = ?", d.id),
      currency_id: d.id,
      commodity_type: b.description,
      commodity_id: a.commodity_id,
      amount: sum(a.total),
      rate: fragment("select sum(rate) from tbl_tariff_line_rates where tariff_id = ?", c.id),
      tarrif_rate_count:
        fragment("select count(*) from tbl_tariff_line_rates where tariff_id = ?", c.id),
      tonnages:
        fragment(
          "sum(case when ? > 0 then ? else ? end)",
          a.tariff_tonnage,
          a.tariff_tonnage,
          a.actual_tonnes
        )
    })
    |> Repo.all()
  end

  def all_batch_items(batch_id, status) do
    Rms.Order.Consignment
    |> where([a], a.batch_id == ^batch_id and a.status in ^status)
    |> join(:left, [a], b in Rms.SystemUtilities.Wagon, on: a.wagon_id == b.id)
    |> join(:left, [a, b], c in Rms.SystemUtilities.WagonType, on: b.wagon_type_id == c.id)
    |> join(:left, [a, b, _c], d in Rms.Accounts.RailwayAdministrator, on: b.owner_id == d.id)
    |> join(:left, [a, b, _c, _d], e in Rms.SystemUtilities.TariffLine, on: e.id == a.tarrif_id)
    |> join(:left, [a, b, _c, _d, e], f in Rms.SystemUtilities.Surchage,
      on: e.surcharge_id == f.id
    )
    |> select([a, b, c, d, e, f], %{
      id: a.id,
      capture_date: a.capture_date,
      code: a.code,
      customer_ref: a.customer_ref,
      document_date: a.document_date,
      sale_order: a.sale_order,
      station_code: a.station_code,
      status: a.status,
      vat_amount: a.vat_amount,
      invoice_no: a.invoice_no,
      final_destination_id: a.final_destination_id,
      origin_station_id: a.origin_station_id,
      reporting_station_id: a.reporting_station_id,
      commodity_id: a.commodity_id,
      consignee_id: a.consignee_id,
      consigner_id: a.consigner_id,
      customer_id: a.customer_id,
      payer_id: a.payer_id,
      tarrif_id: a.tarrif_id,
      maker_id: a.maker_id,
      batch_id: a.batch_id,
      wagon_id: a.wagon_id,
      checker_id: a.checker_id,
      comment: a.comment,
      capacity_tonnes: c.weight,
      actual_tonnes: a.actual_tonnes,
      tariff_tonnage: a.tariff_tonnage,
      tariff_origin_id: a.tariff_origin_id,
      tariff_destination_id: a.tariff_destination_id,
      container_no: a.container_no,
      wagon_owner: d.code,
      wagon_type: c.description,
      invoice_number: a.invoice_no,
      train_number: a.invoice_no,
      move_date: a.invoice_no,
      total: a.total,
      vat_applied: a.vat_applied,
      grand_total: a.grand_total,
      wagon_code: b.code,
      surcharge: f.surcharge_percent
    })
    |> Repo.all()
  end

  # /////////////////////////movement report///////////////////////

  def movement_report_lookup(search_params, page, size, user) do
    Rms.Order.Movement
    |> where([a], a.status == "APPROVED")
    |> verify_user_station_id_for_movement(user)
    |> join(:left, [a], b in Rms.SystemUtilities.Wagon, on: a.wagon_id == b.id)
    |> join(:left, [a, b], c in Rms.SystemUtilities.WagonType, on: b.wagon_type_id == c.id)
    |> join(:left, [a, b, _c], d in Rms.Accounts.RailwayAdministrator, on: b.owner_id == d.id)
    |> join(:left, [a, _b, _c, _d], e in Rms.Accounts.Clients, on: a.consigner_id == e.id)
    |> join(:left, [a, _b, _c, _d, _e], f in Rms.Accounts.Clients, on: a.consignee_id == f.id)
    |> join(:left, [a, _b, _c, _d, _e, _f], g in Rms.Accounts.Clients, on: a.payer_id == g.id)
    |> join(:left, [a, _b, _c, _d, _e, _f, _g], h in Rms.SystemUtilities.Station,
      on: a.movement_destination_id == h.id
    )
    |> join(:left, [a, _b, _c, _d, _e, _f, _g, _h], i in Rms.SystemUtilities.Station,
      on: a.movement_origin_id == i.id
    )
    |> join(:left, [a, _b, _c, _d, _e, _f, _g, _h, _i], j in Rms.SystemUtilities.Commodity,
      on: a.commodity_id == j.id
    )
    |> join(:left, [a, _b, _c, _d, _e, _f, _g, _h, _i, j], k in Rms.SystemUtilities.Station,
      on: a.movement_reporting_station_id == k.id
    )
    |> join(:left, [a, _b, _c, _d, _e, _f, _g, _h, _i, _j, _k], z in Rms.Accounts.Clients,
      on: a.customer_id == z.id
    )
    |> handle_movement_report_filter(search_params)
    |> compose_movement_report_select()
    |> Repo.paginate(page: page, page_size: size)
  end

  def movement_report_lookup(_source, search_params, user) do
    Rms.Order.Movement
    |> where([a], a.status == "APPROVED")
    |> verify_user_station_id_for_movement(user)
    |> join(:left, [a], b in Rms.SystemUtilities.Wagon, on: a.wagon_id == b.id)
    |> join(:left, [a, b], c in Rms.SystemUtilities.WagonType, on: b.wagon_type_id == c.id)
    |> join(:left, [a, b, _c], d in Rms.Accounts.RailwayAdministrator, on: b.owner_id == d.id)
    |> join(:left, [a, _b, _c, _d], e in Rms.Accounts.Clients, on: a.consigner_id == e.id)
    |> join(:left, [a, _b, _c, _d, _e], f in Rms.Accounts.Clients, on: a.consignee_id == f.id)
    |> join(:left, [a, _b, _c, _d, _e, _f], g in Rms.Accounts.Clients, on: a.payer_id == g.id)
    |> join(:left, [a, _b, _c, _d, _e, _f, _g], h in Rms.SystemUtilities.Station,
      on: a.movement_destination_id == h.id
    )
    |> join(:left, [a, _b, _c, _d, _e, _f, _g, _h], i in Rms.SystemUtilities.Station,
      on: a.movement_origin_id == i.id
    )
    |> join(:left, [a, _b, _c, _d, _e, _f, _g, _h, _i], j in Rms.SystemUtilities.Commodity,
      on: a.commodity_id == j.id
    )
    |> join(:left, [a, _b, _c, _d, _e, _f, _g, _h, _i, j], k in Rms.SystemUtilities.Station,
      on: a.movement_reporting_station_id == k.id
    )
    |> join(:left, [a, _b, _c, _d, _e, _f, _g, _h, _i, _j, _k], z in Rms.Accounts.Clients,
      on: a.customer_id == z.id
    )
    |> handle_movement_report_filter(search_params)
    |> compose_movement_report_select()
  end

  def movement_report_lookup_excel(_source, search_params, settings, user) do
    Rms.Order.Movement
    |> where([a], a.status == "APPROVED")
    |> verify_user_station_id_for_movement(user)
    |> join(:left, [a], b in Rms.SystemUtilities.Wagon, on: a.wagon_id == b.id)
    |> join(:left, [a, b], c in Rms.SystemUtilities.WagonType, on: b.wagon_type_id == c.id)
    |> join(:left, [a, b, _c], d in Rms.Accounts.RailwayAdministrator, on: b.owner_id == d.id)
    |> join(:left, [a, _b, _c, _d], e in Rms.Accounts.Clients, on: a.consigner_id == e.id)
    |> join(:left, [a, _b, _c, _d, _e], f in Rms.Accounts.Clients, on: a.consignee_id == f.id)
    |> join(:left, [a, _b, _c, _d, _e, _f], g in Rms.Accounts.Clients, on: a.payer_id == g.id)
    |> join(:left, [a, _b, _c, _d, _e, _f, _g], h in Rms.SystemUtilities.Station,
      on: a.destin_station_id == h.id
    )
    |> join(:left, [a, _b, _c, _d, _e, _f, _g, _h], i in Rms.SystemUtilities.Station,
      on: a.origin_station_id == i.id
    )
    |> join(:left, [a, _b, _c, _d, _e, _f, _g, _h, _i], j in Rms.SystemUtilities.Commodity,
      on: a.commodity_id == j.id
    )
    |> join(:left, [a, _b, _c, _d, _e, _f, _g, _h, _i, j], k in Rms.SystemUtilities.Station,
      on: a.movement_reporting_station_id == k.id
    )
    |> join(:left, [a, _b, _c, _d, _e, _f, _g, _h, _i, _j, _k], z in Rms.Accounts.Clients,
      on: a.customer_id == z.id
    )
    |> join(:left, [a, _b, _c, _d, _e, _f, _g, _h, _i, j, k, _z], l in Rms.Order.Consignment,
      on:
        l.status in ["COMPLETE", "PENDING_INVOICE"] and l.commodity_id == a.commodity_id and
          l.document_date == a.consignment_date and l.final_destination_id == a.destin_station_id and
          l.origin_station_id == a.origin_station_id and l.wagon_id == a.wagon_id and
          l.consignee_id == a.consignee_id and l.consigner_id == a.consigner_id and
          (a.inserted_at <= date_add(l.inserted_at, ^settings.unmatched_aging_period, "day") or
             l.manual_matching == "YES")
    )
    |> join(
      :left,
      [a, _b, _c, _d, _e, _f, _g, _h, _i, _j, _k, _z, l],
      m in Rms.SystemUtilities.Station,
      on: l.tariff_destination_id == m.id
    )
    |> join(
      :left,
      [a, _b, _c, _d, _e, _f, _g, _h, _i, _j, _k, _z, l, _m],
      n in Rms.SystemUtilities.Station,
      on: l.tariff_origin_id == n.id
    )
    |> join(
      :left,
      [a, _b, _c, _d, _e, _f, _g, _h, _i, _j, _k, _z, l, _m, _n],
      o in Rms.SystemUtilities.Currency,
      on: l.invoice_currency_id == o.id
    )
    |> join(
      :left,
      [a, _b, _c, _d, _e, _f, _g, _h, _i, _j, _k, _z, l, _m, _n, _o],
      p in Rms.Accounts.Clients,
      on: l.payer_id == p.id
    )
    |> join(
      :left,
      [a, _b, _c, _d, _e, _f, _g, _h, _i, _j, _k, _z, _l, _m, _n, _o, _p],
      q in Rms.SystemUtilities.TrainRoute,
      on: q.origin_station == a.origin_station_id and q.destination_station == a.destin_station_id
    )
    |> join(
      :left,
      [a, _b, _c, _d, _e, _f, _g, _h, _i, _j, _k, _z, _l, _m, _n, _o, p, q],
      r in Rms.SystemUtilities.TransportType,
      on: r.id == q.transport_type
    )
    |> join(
      :left,
      [a, b, _c, _d, _e, _f, _g, _h, _i, _j, _k, _z, l, _m, _n, _o, _p, _q, _r],
      s in Rms.SystemUtilities.TariffLine,
      on: l.tarrif_id == s.id
    )
    |> join(
      :left,
      [a, b, _c, _d, _e, _f, _g, _h, _i, _j, _k, _z, _l, _m, _n, _o, _p, _q, _r, s],
      t in Rms.SystemUtilities.Currency,
      on: s.currency_id == t.id
    )
    |> handle_movement_report_filter(search_params)
    |> compose_movement_report_select_excel(settings)
  end

  defp handle_movement_report_filter(query, %{"isearch" => search_term} = search_params)
       when search_term == "" or is_nil(search_term) do
    query
    |> handle_movement_capture_date_filter(search_params)
    |> handle_movement_train_list_no_filter(search_params)
    |> handle_movement_time_filter(search_params)
    |> handle_movement_train_no_filter(search_params)
    |> handle_movement_origin_filter(search_params)
    |> handle_movement_origin_filter(search_params)
    |> handle_movement_destination_filter(search_params)
    |> handle_movement_date_filter(search_params)
    |> handle_movement_wagon_code_filter(search_params)
    |> handle_movement_commodity_filter(search_params)
    |> handle_movement_customer_filter(search_params)
    |> handle_movement_consignee_filter(search_params)
  end

  defp handle_movement_report_filter(query, %{"isearch" => search_term}) do
    search_term = "%#{search_term}%"
    compose_movement_isearch_filter(query, search_term)
  end

  defp handle_movement_capture_date_filter(query, %{"from" => from, "to" => to})
       when from == "" or is_nil(from) or to == "" or is_nil(to),
       do: query

  defp handle_movement_capture_date_filter(query, %{"from" => from, "to" => to}) do
    query
    |> where(
      [a],
      fragment("CAST(? AS DATE) >= ?", a.inserted_at, ^from) and
        fragment("CAST(? AS DATE) <= ?", a.inserted_at, ^to)
    )
  end

  defp handle_movement_train_list_no_filter(query, %{"train_list_no" => train_list_no})
       when train_list_no == "" or is_nil(train_list_no),
       do: query

  defp handle_movement_train_list_no_filter(query, %{"train_list_no" => train_list_no}) do
    where(query, [a], fragment("lower(?) LIKE lower(?)", a.train_list_no, ^"%#{train_list_no}%"))
  end

  defp handle_movement_time_filter(query, %{"movement_time" => movement_time})
       when movement_time == "" or is_nil(movement_time),
       do: query

  defp handle_movement_time_filter(query, %{"movement_time" => movement_time}) do
    where(query, [a], fragment("lower(?) LIKE lower(?)", a.movement_time, ^"%#{movement_time}%"))
  end

  defp handle_movement_train_no_filter(query, %{"train_no" => train_no})
       when train_no == "" or is_nil(train_no),
       do: query

  defp handle_movement_train_no_filter(query, %{"train_no" => train_no}) do
    where(query, [a], fragment("lower(?) LIKE lower(?)", a.train_no, ^"%#{train_no}%"))
  end

  defp handle_movement_origin_filter(query, %{"origin" => origin})
       when origin == "" or is_nil(origin),
       do: query

  defp handle_movement_origin_filter(query, %{"origin" => origin}) do
    where(query, [a], a.movement_origin_id == ^origin)
  end

  defp handle_movement_date_filter(query, %{
         "movement_from" => movement_from,
         "movement_to" => movement_to
       })
       when movement_from == "" or is_nil(movement_from) or movement_to == "" or
              is_nil(movement_to),
       do: query

  defp handle_movement_date_filter(query, %{
         "movement_from" => movement_from,
         "movement_to" => movement_to
       }) do
    query
    |> where(
      [a],
      fragment("CAST(? AS DATE) >= ?", a.movement_date, ^movement_from) and
        fragment("CAST(? AS DATE) <= ?", a.movement_date, ^movement_to)
    )
  end

  defp handle_movement_destination_filter(query, %{"destination" => destination})
       when destination == "" or is_nil(destination),
       do: query

  defp handle_movement_destination_filter(query, %{"destination" => destination}) do
    where(query, [a], a.movement_destination_id == ^destination)
  end

  defp handle_movement_wagon_code_filter(query, %{"movement_wagon_code" => movement_wagon_code})
       when movement_wagon_code == "" or is_nil(movement_wagon_code),
       do: query

  defp handle_movement_wagon_code_filter(query, %{"movement_wagon_code" => movement_wagon_code}) do
    where(query, [a, b], fragment("lower(?) LIKE lower(?)", b.code, ^"%#{movement_wagon_code}%"))
  end

  defp handle_movement_commodity_filter(query, %{"commodity" => commodity})
       when commodity == "" or is_nil(commodity),
       do: query

  defp handle_movement_commodity_filter(query, %{"commodity" => commodity}) do
    where(query, [a], a.commodity_id == ^commodity)
  end

  defp handle_movement_customer_filter(query, %{"customer" => customer})
       when customer == "" or is_nil(customer),
       do: query

  defp handle_movement_customer_filter(query, %{"customer" => customer}) do
    where(query, [a], a.customer_id == ^customer)
  end

  defp handle_movement_consignee_filter(query, %{"consignee" => consignee})
       when consignee == "" or is_nil(consignee),
       do: query

  defp handle_movement_consignee_filter(query, %{"consignee" => consignee}) do
    where(query, [a], a.consignee_id == ^consignee)
  end

  defp compose_movement_isearch_filter(query, search_term) do
    query
    |> where(
      [a, b, c, d, e, f, g, h, i, j, k, z],
      fragment("lower(?) LIKE lower(?)", i.description, ^search_term) or
        fragment("lower(?) LIKE lower(?)", h.description, ^search_term) or
        fragment("lower(?) LIKE lower(?)", k.description, ^search_term) or
        fragment("lower(?) LIKE lower(?)", a.movement_date, ^search_term) or
        fragment("lower(?) LIKE lower(?)", a.train_no, ^search_term) or
        fragment("lower(?) LIKE lower(?)", b.code, ^search_term) or
        fragment("lower(?) LIKE lower(?)", a.sales_order, ^search_term) or
        fragment("lower(?) LIKE lower(?)", a.station_code, ^search_term) or
        fragment("lower(?) LIKE lower(?)", a.train_list_no, ^search_term)
    )
  end

  defp compose_movement_report_select(query) do
    query
    |> where(
      [a, b, c, d, e, f, g, h, i, j, k, z],
      a.id in subquery(
        from(t in Rms.Order.Movement,
          where: t.status == "APPROVED",
          group_by: t.batch_id,
          select: max(t.id)
        )
      )
    )
    |> order_by([a, b, c, d, e, f, g, h, i, j, k, z], desc: a.inserted_at)
    |> select([a, b, c, d, e, f, g, h, i, j, k, z], %{
      id: a.id,
      wagon_id: a.wagon_id,
      origin_station_id: a.origin_station_id,
      destin_station_id: a.destin_station_id,
      commodity_id: a.commodity_id,
      netweight: a.netweight,
      consigner: a.consigner_id,
      consignee: a.consignee_id,
      container_no: a.container_no,
      sales_order: a.sales_order,
      train_list_no: a.train_list_no,
      consignment_date: a.consignment_date,
      payer_id: a.payer_id,
      movement_date: a.movement_date,
      movement_time: a.movement_time,
      reporting_station: a.movement_reporting_station_id,
      train_no: a.train_no,
      loco_id: a.loco_id,
      dead_loco: a.dead_loco,
      wagon_owner: d.description,
      wagon_code: b.code,
      wagon_type: c.description,
      origin: a.movement_origin_id,
      destination: a.movement_destination_id,
      maker_id: a.maker_id,
      checker_id: a.checker_id,
      inserted_at: a.inserted_at,
      updated_at: a.updated_at,
      payer: g.client_name,
      consigner_name: e.client_name,
      customer_name: z.client_name,
      consignee_name: f.client_name,
      status: a.status,
      consignment_id: a.consignment_id,
      origin_name: i.description,
      destination_name: h.description,
      reporting_stat: k.description,
      commodity_name: j.description,
      batch_id: a.batch_id
    })
  end

  defp compose_movement_report_select_excel(query, settings) do
    query
    |> order_by([a, b, c, d, e, f, g, h, i, j, k, z, l, m, n, o, p, q, r, s, t],
      desc: a.inserted_at
    )
    |> select([a, b, c, d, e, f, g, h, i, j, k, z, l, m, n, o, p, q, r, s, t], %{
      id: a.id,
      wagon_id: a.wagon_id,
      origin_station_id: a.origin_station_id,
      destin_station_id: a.destin_station_id,
      rate_ccy: t.code,
      commodity_id: a.commodity_id,
      netweight: a.netweight,
      consigner: a.consigner_id,
      consignee: a.consignee_id,
      container_no: a.container_no,
      sales_order: l.sale_order,
      station_code: l.station_code,
      train_list_no: a.train_list_no,
      consignment_date: a.consignment_date,
      payer_id: a.payer_id,
      movement_date: a.movement_date,
      movement_time: a.movement_time,
      reporting_station: a.movement_reporting_station_id,
      train_no: a.train_no,
      loco_id: a.loco_id,
      dead_loco: a.dead_loco,
      wagon_owner: d.description,
      wagon_code: b.code,
      wagon_type: c.description,
      origin: a.movement_origin_id,
      destination: a.movement_destination_id,
      maker_id: a.maker_id,
      checker_id: a.checker_id,
      inserted_at: a.inserted_at,
      updated_at: a.updated_at,
      payer: p.client_name,
      consigner_name: e.client_name,
      consignee_name: f.client_name,
      status: a.status,
      consignment_id: a.consignment_id,
      origin_name: i.description,
      destination_name: h.description,
      reporting_stat: k.description,
      commodity_name: j.description,
      batch_id: a.batch_id,
      tariff_origin: n.description,
      tariff_destination: m.description,
      currency: o.code,
      tonnages: l.actual_tonnes,
      amount_total: l.total,
      containers: l.container_no,
      invoice_date: l.invoice_date,
      invoice_amount: l.invoice_amount,
      invoice_no: l.invoice_no,
      distance: q.distance,
      transport_type: r.description,
      actual_tonnes: l.actual_tonnes,
      tariff_tonnage: l.tariff_tonnage,
      capture_date: l.capture_date,
      document_date: l.document_date,
      amount: l.total,
      tarrif_id: l.tarrif_id,
      customer_name: z.client_name,
      loco_no: a.loco_no,
      avg_rate:
        fragment(
          "select rate from tbl_tariff_line_rates where tariff_id = ? and admin_id = ?",
          l.tarrif_id,
          ^settings.current_railway_admin
        )
      # avg_rate: fragment("select avg(rate) from tbl_tariff_line_rates where tariff_id = ?",  l.tarrif_id),
    })
  end

  # /////////////////////////consignment report///////////////////////

  def consignment_report_lookup(search_params, page, size, user, empty_commodity) do
    Rms.Order.Consignment
    |> where(
      [a],
      a.status in ["COMPLETE", "PENDING_INVOICE"] and a.commodity_id != ^empty_commodity
    )
    |> verify_user_station_id_for_consignment(user)
    |> join(:left, [a], b in Rms.SystemUtilities.Wagon, on: a.wagon_id == b.id)
    |> join(:left, [a, b], c in Rms.SystemUtilities.WagonType, on: b.wagon_type_id == c.id)
    |> join(:left, [a, b, _c], d in Rms.Accounts.RailwayAdministrator, on: b.owner_id == d.id)
    |> join(:left, [a, b, _c, _d], e in Rms.SystemUtilities.Station,
      on: a.tariff_destination_id == e.id
    )
    |> join(:left, [a, b, _c, _d, _e], f in Rms.SystemUtilities.Station,
      on: a.tariff_origin_id == f.id
    )
    |> join(:left, [a, b, _c, _d, _e, _f], g in Rms.SystemUtilities.Station,
      on: a.final_destination_id == g.id
    )
    |> join(:left, [a, b, _c, _d, _e, _f, _g], h in Rms.SystemUtilities.Station,
      on: a.origin_station_id == h.id
    )
    |> join(:left, [a, b, _c, _d, _e, _f, _g, _h], i in Rms.SystemUtilities.Station,
      on: a.reporting_station_id == i.id
    )
    |> join(:left, [a, b, _c, _d, _e, _f, _g, _h, _i], j in Rms.SystemUtilities.Commodity,
      on: a.commodity_id == j.id
    )
    |> join(:left, [a, b, _c, _d, _e, _f, _g, _h, _i, _j], k in Rms.Accounts.Clients,
      on: a.consignee_id == k.id
    )
    |> join(:left, [a, b, _c, _d, _e, _f, _g, _h, _i, _j, _k], l in Rms.Accounts.Clients,
      on: a.consigner_id == l.id
    )
    |> join(:left, [a, b, _c, _d, _e, _f, _g, _h, _i, _j, _k, _l], m in Rms.Accounts.Clients,
      on: a.customer_id == m.id
    )
    |> join(:left, [a, b, _c, _d, _e, _f, _g, _h, _i, _j, _k, _l, _m], n in Rms.Accounts.Clients,
      on: a.payer_id == n.id
    )
    |> join(:left, [a, b, _c, _d, _e, _f, _g, _h, _i, _j, _k, _l, _m, _n], o in Rms.Order.Batch,
      on: a.batch_id == o.id
    )
    |> handle_consignment_report_filter(search_params)
    |> compose_consignment_report_select(empty_commodity)
    |> Repo.paginate(page: page, page_size: size)
  end

  # def consignment_report_lookup(_source, search_params, user) do
  #   Rms.Order.Consignment
  #   |> where([a], a.status in ["COMPLETE", "PENDING_INVOICE"])
  #   |> verify_user_station_id_for_consignment(user)
  #   |> join(:left, [a], b in Rms.SystemUtilities.Wagon, on: a.wagon_id == b.id)
  #   |> join(:left, [a, b], c in Rms.SystemUtilities.WagonType, on: b.wagon_type_id == c.id)
  #   |> join(:left, [a, b, _c], d in Rms.Accounts.RailwayAdministrator, on: b.owner_id == d.id)
  #   |> join(:left, [a, b, _c, _d], e in Rms.SystemUtilities.Station,
  #     on: a.tariff_destination_id == e.id
  #   )
  #   |> join(:left, [a, b, _c, _d, _e], f in Rms.SystemUtilities.Station,
  #     on: a.tariff_origin_id == f.id
  #   )
  #   |> join(:left, [a, b, _c, _d, _e, _f], g in Rms.SystemUtilities.Station,
  #     on: a.final_destination_id == g.id
  #   )
  #   |> join(:left, [a, b, _c, _d, _e, _f, _g], h in Rms.SystemUtilities.Station,
  #     on: a.origin_station_id == h.id
  #   )
  #   |> join(:left, [a, b, _c, _d, _e, _f, _g, _h], i in Rms.SystemUtilities.Station,
  #     on: a.reporting_station_id == i.id
  #   )
  #   |> join(:left, [a, b, _c, _d, _e, _f, _g, _h, _i], j in Rms.SystemUtilities.Commodity,
  #     on: a.commodity_id == j.id
  #   )
  #   |> join(:left, [a, b, _c, _d, _e, _f, _g, _h, _i, _j], k in Rms.Accounts.Clients,
  #     on: a.consignee_id == k.id
  #   )
  #   |> join(:left, [a, b, _c, _d, _e, _f, _g, _h, _i, _j, _k], l in Rms.Accounts.Clients,
  #     on: a.consigner_id == l.id
  #   )
  #   |> join(:left, [a, b, _c, _d, _e, _f, _g, _h, _i, _j, _k, _l], m in Rms.Accounts.Clients,
  #     on: a.customer_id == m.id
  #   )
  #   |> join(:left, [a, b, _c, _d, _e, _f, _g, _h, _i, _j, _k, _l, _m], n in Rms.Accounts.Clients,
  #     on: a.payer_id == n.id
  #   )
  #   |> join(:left, [a, b, _c, _d, _e, _f, _g, _h, _i, _j, _k, _l, _m, _n], o in Rms.Order.Batch,
  #     on: a.batch_id == o.id
  #   )
  #   |> handle_consignment_report_filter(search_params)
  #   |> compose_consignment_report_select(empty_commodity)
  # end

  def consignment_report_excel(_source, search_params, settings, user) do
    Rms.Order.Consignment
    |> where([a], a.status in ["COMPLETE", "PENDING_INVOICE"])
    |> verify_user_station_id_for_consignment(user)
    |> join(:left, [a], b in Rms.SystemUtilities.Wagon, on: a.wagon_id == b.id)
    |> join(:left, [a, b], c in Rms.SystemUtilities.WagonType, on: b.wagon_type_id == c.id)
    |> join(:left, [a, b, _c], d in Rms.Accounts.RailwayAdministrator, on: b.owner_id == d.id)
    |> join(:left, [a, b, _c, _d], e in Rms.SystemUtilities.Station,
      on: a.tariff_destination_id == e.id
    )
    |> join(:left, [a, b, _c, _d, _e], f in Rms.SystemUtilities.Station,
      on: a.tariff_origin_id == f.id
    )
    |> join(:left, [a, b, _c, _d, _e, _f], g in Rms.SystemUtilities.Station,
      on: a.final_destination_id == g.id
    )
    |> join(:left, [a, b, _c, _d, _e, _f, _g], h in Rms.SystemUtilities.Station,
      on: a.origin_station_id == h.id
    )
    |> join(:left, [a, b, _c, _d, _e, _f, _g, _h], i in Rms.SystemUtilities.Station,
      on: a.reporting_station_id == i.id
    )
    |> join(:left, [a, b, _c, _d, _e, _f, _g, _h, _i], j in Rms.SystemUtilities.Commodity,
      on: a.commodity_id == j.id
    )
    |> join(:left, [a, b, _c, _d, _e, _f, _g, _h, _i, _j], k in Rms.Accounts.Clients,
      on: a.consignee_id == k.id
    )
    |> join(:left, [a, b, _c, _d, _e, _f, _g, _h, _i, _j, _k], l in Rms.Accounts.Clients,
      on: a.consigner_id == l.id
    )
    |> join(:left, [a, b, _c, _d, _e, _f, _g, _h, _i, _j, _k, _l], m in Rms.Accounts.Clients,
      on: a.customer_id == m.id
    )
    |> join(:left, [a, b, _c, _d, _e, _f, _g, _h, _i, _j, _k, _l, _m], n in Rms.Accounts.Clients,
      on: a.payer_id == n.id
    )
    |> join(:left, [a, b, _c, _d, _e, _f, _g, _h, _i, _j, _k, _l, _m, n], o in Rms.Order.Movement,
      on:
        o.status == "APPROVED" and a.commodity_id == o.commodity_id and
          a.document_date == o.consignment_date and a.final_destination_id == o.destin_station_id and
          a.origin_station_id == o.origin_station_id and a.wagon_id == o.wagon_id and
          a.consignee_id == o.consignee_id and a.consigner_id == o.consigner_id and
          (o.inserted_at <= date_add(a.inserted_at, ^settings.unmatched_aging_period, "day") or
             o.manual_matching == "YES")
    )
    |> join(
      :left,
      [a, b, _c, _d, _e, _f, _g, _h, _i, _j, _k, _l, _m, n, o],
      p in Rms.SystemUtilities.Currency,
      on: a.invoice_currency_id == p.id
    )
    |> join(
      :left,
      [a, b, _c, _d, _e, _f, _g, _h, _i, _j, _k, _l, _m, n, o, p],
      q in Rms.SystemUtilities.TrainRoute,
      on: a.route_id == q.id
    )
    |> join(
      :left,
      [a, b, _c, _d, _e, _f, _g, _h, _i, _j, _k, _l, _m, n, o, p, q],
      r in Rms.SystemUtilities.TransportType,
      on: q.transport_type == r.id
    )
    |> join(
      :left,
      [a, b, _c, _d, _e, _f, _g, _h, _i, _j, _k, _l, _m, _n, _o, _p, _q, _r],
      s in Rms.SystemUtilities.TariffLine,
      on: a.tarrif_id == s.id
    )
    |> join(
      :left,
      [a, b, _c, _d, _e, _f, _g, _h, _i, _j, _k, _l, _m, _n, _o, _p, _q, _r, s],
      t in Rms.SystemUtilities.Currency,
      on: s.currency_id == t.id
    )
    |> handle_consignment_report_filter(search_params)
    |> compose_consignment_report_select_excel(settings)
  end

  defp handle_consignment_report_filter(query, %{"isearch" => search_term} = search_params)
       when search_term == "" or is_nil(search_term) do
    query
    |> handle_date_filter(search_params)
    |> handle_consignment_customer_filter(search_params)
    |> handle_consignment_station_code_filter(search_params)
    |> handle_consignment_sales_order_filter(search_params)
    |> handle_consignment_reporting_station_filter(search_params)
    # |> handle_consignment_capture_date_filter(search_params)
    |> handle_consignment_consignee_filter(search_params)
    |> handle_consignment_payer_filter(search_params)
    |> handle_consignment_commodity_filter(search_params)
  end

  defp handle_consignment_report_filter(query, %{"isearch" => search_term}) do
    search_term = "%#{search_term}%"
    compose_consignment_isearch_filter(query, search_term)
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

  defp handle_consignment_customer_filter(query, %{"consignment_customer" => consignment_customer})
       when consignment_customer == "" or is_nil(consignment_customer),
       do: query

  defp handle_consignment_customer_filter(query, %{"consignment_customer" => consignment_customer}) do
    where(query, [a], a.customer_id == ^consignment_customer)
  end

  defp handle_consignment_station_code_filter(query, %{
         "consignment_station_code" => consignment_station_code
       })
       when consignment_station_code == "" or is_nil(consignment_station_code),
       do: query

  defp handle_consignment_station_code_filter(query, %{
         "consignment_station_code" => consignment_station_code
       }) do
    where(
      query,
      [a],
      fragment("lower(?) LIKE lower(?)", a.station_code, ^"%#{consignment_station_code}%")
    )
  end

  defp handle_consignment_sales_order_filter(query, %{
         "consignment_sales_order" => consignment_sales_order
       })
       when consignment_sales_order == "" or is_nil(consignment_sales_order),
       do: query

  defp handle_consignment_sales_order_filter(query, %{
         "consignment_sales_order" => consignment_sales_order
       }) do
    where(
      query,
      [a],
      fragment("lower(?) LIKE lower(?)", a.sale_order, ^"%#{consignment_sales_order}%")
    )
  end

  defp handle_consignment_reporting_station_filter(query, %{
         "consignment_reporting_station" => consignment_reporting_station
       })
       when consignment_reporting_station == "" or is_nil(consignment_reporting_station),
       do: query

  defp handle_consignment_reporting_station_filter(query, %{
         "consignment_reporting_station" => consignment_reporting_station
       }) do
    where(query, [a], a.reporting_station_id == ^consignment_reporting_station)
  end

  defp handle_consignment_capture_date_filter(query, %{
         "consignment_capture_date" => consignment_capture_date
       })
       when consignment_capture_date == "" or is_nil(consignment_capture_date),
       do: query

  defp handle_consignment_capture_date_filter(query, %{
         "consignment_capture_date" => consignment_capture_date
       }) do
    query
    |> where(
      [a],
      fragment("CAST(? AS DATE) >= ?", a.capture_date, ^consignment_capture_date)
    )
  end

  defp handle_consignment_consignee_filter(query, %{
         "consignment_consignee" => consignment_consignee
       })
       when consignment_consignee == "" or is_nil(consignment_consignee),
       do: query

  defp handle_consignment_consignee_filter(query, %{
         "consignment_consignee" => consignment_consignee
       }) do
    where(query, [a], a.consignee_id == ^consignment_consignee)
  end

  defp handle_consignment_payer_filter(query, %{"consignment_payer" => consignment_payer})
       when consignment_payer == "" or is_nil(consignment_payer),
       do: query

  defp handle_consignment_payer_filter(query, %{"consignment_payer" => consignment_payer}) do
    where(query, [a], a.payer_id == ^consignment_payer)
  end

  defp handle_consignment_commodity_filter(query, %{
         "consignment_commodity" => consignment_commodity
       })
       when consignment_commodity == "" or is_nil(consignment_commodity),
       do: query

  defp handle_consignment_commodity_filter(query, %{
         "consignment_commodity" => consignment_commodity
       }) do
    where(query, [a], a.commodity_id == ^consignment_commodity)
  end

  defp compose_consignment_isearch_filter(query, search_term) do
    query
    |> where(
      [a, b, c, d, e, f, g, h, i, j, k, l, m, n],
      fragment("lower(?) LIKE lower(?)", f.description, ^search_term) or
        fragment("lower(?) LIKE lower(?)", i.description, ^search_term) or
        fragment("lower(?) LIKE lower(?)", h.description, ^search_term) or
        fragment("lower(?) LIKE lower(?)", k.client_name, ^search_term) or
        fragment("lower(?) LIKE lower(?)", a.capture_date, ^search_term) or
        fragment("lower(?) LIKE lower(?)", j.description, ^search_term) or
        fragment("lower(?) LIKE lower(?)", n.client_name, ^search_term) or
        fragment("lower(?) LIKE lower(?)", b.code, ^search_term) or
        fragment("lower(?) LIKE lower(?)", a.station_code, ^search_term) or
        fragment("lower(?) LIKE lower(?)", a.sale_order, ^search_term)
    )
  end

  defp compose_consignment_report_select(query, empty_commodity) do
    query
    |> where(
      [a, b, c, d, e, f, g, h, i, j, k, l, m, n],
      a.id in subquery(
        from(t in Rms.Order.Consignment,
          where:
            t.status in ["PENDING_INVOICE", "COMPLETE"] and t.commodity_id != ^empty_commodity,
          group_by: t.batch_id,
          select: max(t.id)
        )
      )
    )
    |> order_by([a, _b, _c, _d, _e, _f, _g, _h, _i, _j, _k, _l, _m, _n, _o], desc: a.inserted_at)
    |> select([a, b, c, d, e, f, g, h, i, j, k, l, m, n, o], %{
      id: a.id,
      capture_date: a.capture_date,
      code: a.code,
      customer_ref: a.customer_ref,
      document_date: a.document_date,
      sale_order: a.sale_order,
      station_code: a.station_code,
      status: a.status,
      tariff_destination: e.description,
      tariff_origin: f.description,
      final_destination: g.description,
      origin_station: h.description,
      reporting_station: i.description,
      consignee: k.client_name,
      consigner: l.client_name,
      customer: m.client_name,
      payer: n.client_name,
      commodity: j.description,
      vat_amount: a.vat_amount,
      invoice_no: a.invoice_no,
      uuid: o.uuid,
      tzr_project: a.tzr_project,
      additional_chg: a.additional_chg,
      final_destination_id: a.final_destination_id,
      origin_station_id: a.origin_station_id,
      reporting_station_id: a.reporting_station_id,
      commodity_id: a.commodity_id,
      consignee_id: a.consignee_id,
      consigner_id: a.consigner_id,
      customer_id: a.customer_id,
      payer_id: a.payer_id,
      tarrif_id: a.tarrif_id,
      maker_id: a.maker_id,
      batch_id: a.batch_id,
      wagon_id: a.wagon_id,
      checker_id: a.checker_id,
      comment: a.comment,
      capacity_tonnes: a.capacity_tonnes,
      actual_tonnes: a.actual_tonnes,
      tariff_tonnage: a.tariff_tonnage,
      tariff_origin_id: a.tariff_origin_id,
      tariff_destination_id: a.tariff_destination_id,
      container_no: a.container_no,
      wagon_owner: d.description,
      wagon_type: c.description,
      invoice_number: a.invoice_no,
      train_number: a.invoice_no,
      move_date: a.invoice_no,
      total: a.invoice_no,
      wagon_code: b.code,
      invoice_date: a.invoice_date,
      invoice_amount: a.invoice_amount,
      invoice_term: a.invoice_term,
      invoice_currency_id: a.invoice_currency_id
    })
  end

  defp compose_consignment_report_select_excel(query, settings) do
    query
    |> order_by([a, _b, _c, _d, _e, _f, _g, _h, _i, _j, _k, _l, _m, _n, _o, _P, _q, _r, _s, _t],
      desc: a.inserted_at
    )
    |> select([a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t], %{
      id: a.id,
      route_id: a.route_id,
      distance: q.distance,
      rate_ccy: t.code,
      transport_type: r.description,
      capture_date: a.capture_date,
      code: a.code,
      customer_ref: a.customer_ref,
      amount: a.total,
      document_date: a.document_date,
      sale_order: a.sale_order,
      station_code: a.station_code,
      status: a.status,
      tariff_destination: e.description,
      tariff_origin: f.description,
      final_destination: g.description,
      origin_station: h.description,
      reporting_station: i.description,
      consignee: k.client_name,
      consigner: l.client_name,
      customer: m.client_name,
      payer: n.client_name,
      commodity: j.description,
      vat_amount: a.vat_amount,
      invoice_no: a.invoice_no,
      additional_chg: a.additional_chg,
      final_destination_id: a.final_destination_id,
      origin_station_id: a.origin_station_id,
      reporting_station_id: a.reporting_station_id,
      commodity_id: a.commodity_id,
      consignee_id: a.consignee_id,
      consigner_id: a.consigner_id,
      customer_id: a.customer_id,
      payer_id: a.payer_id,
      tarrif_id: a.tarrif_id,
      maker_id: a.maker_id,
      batch_id: a.batch_id,
      wagon_id: a.wagon_id,
      checker_id: a.checker_id,
      comment: a.comment,
      capacity_tonnes: a.capacity_tonnes,
      actual_tonnes: a.actual_tonnes,
      tariff_tonnage: a.tariff_tonnage,
      tariff_origin_id: a.tariff_origin_id,
      tariff_destination_id: a.tariff_destination_id,
      container_no: a.container_no,
      wagon_owner: d.description,
      wagon_type: c.description,
      invoice_number: a.invoice_no,
      train_number: a.invoice_no,
      move_date: a.invoice_no,
      total: a.invoice_no,
      invoice_currency: p.code,
      wagon_code: b.code,
      invoice_date: a.invoice_date,
      invoice_amount: a.invoice_amount,
      invoice_term: a.invoice_term,
      invoice_currency_id: a.invoice_currency_id,
      movement_date: o.movement_date,
      movement_time: o.movement_time,
      train_list_no: o.train_list_no,
      train_no: o.train_no,
      loco_no: o.loco_no,
      avg_rate:
        fragment(
          "select rate from tbl_tariff_line_rates where tariff_id = ? and admin_id = ?",
          a.tarrif_id,
          ^settings.current_railway_admin
        )
    })
  end

  def manual_matching_report_lookup(search_params, page, size, unmatched_period, user) do
    from(a in Rms.Order.Consignment, as: :consign)
    |> where([a], a.status == "COMPLETE")
    |> verify_user_station_id_for_consignment(user)
    |> join(:left, [a], b in Rms.SystemUtilities.Wagon, on: a.wagon_id == b.id)
    |> join(:left, [a, b], c in Rms.SystemUtilities.WagonType, on: b.wagon_type_id == c.id)
    |> join(:left, [a, b, _c], d in Rms.Accounts.RailwayAdministrator, on: b.owner_id == d.id)
    |> join(:left, [a, b, _c, _d], e in Rms.SystemUtilities.Station,
      on: a.tariff_destination_id == e.id
    )
    |> join(:left, [a, b, _c, _d, _e], f in Rms.SystemUtilities.Station,
      on: a.tariff_origin_id == f.id
    )
    |> join(:left, [a, b, _c, _d, _e, _f], g in Rms.SystemUtilities.Station,
      on: a.final_destination_id == g.id
    )
    |> join(:left, [a, b, _c, _d, _e, _f, _g], h in Rms.SystemUtilities.Station,
      on: a.origin_station_id == h.id
    )
    |> join(:left, [a, b, _c, _d, _e, _f, _g, _h], i in Rms.SystemUtilities.Station,
      on: a.reporting_station_id == i.id
    )
    |> join(:left, [a, b, _c, _d, _e, _f, _g, _h, _i], j in Rms.SystemUtilities.Commodity,
      on: a.commodity_id == j.id
    )
    |> join(:left, [a, b, _c, _d, _e, _f, _g, _h, _i, _j], k in Rms.Accounts.Clients,
      on: a.consignee_id == k.id
    )
    |> join(:left, [a, b, _c, _d, _e, _f, _g, _h, _i, _j, _k], l in Rms.Accounts.Clients,
      on: a.consigner_id == l.id
    )
    |> join(:left, [a, b, _c, _d, _e, _f, _g, _h, _i, _j, _k, _l], m in Rms.Accounts.Clients,
      on: a.customer_id == m.id
    )
    |> join(:left, [a, b, _c, _d, _e, _f, _g, _h, _i, _j, _k, _l, _m], n in Rms.Accounts.Clients,
      on: a.payer_id == n.id
    )
    |> join(
      :left,
      [a, b, _c, _d, _e, _f, _g, _h, _i, _j, _k, _l, _m, n],
      p in Rms.SystemUtilities.Currency,
      on: a.invoice_currency_id == p.id
    )
    |> handle_manual_matching_report_filter(search_params)
    |> compose_manual_matching_report_select(unmatched_period)
    |> Repo.paginate(page: page, page_size: size)
  end

  def manual_matching_report_lookup(_source, search_params, unmatched_period, user) do
    from(a in Rms.Order.Consignment, as: :consign)
    |> where([a], a.status == "COMPLETE")
    |> verify_user_station_id_for_consignment(user)
    |> join(:left, [a], b in Rms.SystemUtilities.Wagon, on: a.wagon_id == b.id)
    |> join(:left, [a, b], c in Rms.SystemUtilities.WagonType, on: b.wagon_type_id == c.id)
    |> join(:left, [a, b, _c], d in Rms.Accounts.RailwayAdministrator, on: b.owner_id == d.id)
    |> join(:left, [a, b, _c, _d], e in Rms.SystemUtilities.Station,
      on: a.tariff_destination_id == e.id
    )
    |> join(:left, [a, b, _c, _d, _e], f in Rms.SystemUtilities.Station,
      on: a.tariff_origin_id == f.id
    )
    |> join(:left, [a, b, _c, _d, _e, _f], g in Rms.SystemUtilities.Station,
      on: a.final_destination_id == g.id
    )
    |> join(:left, [a, b, _c, _d, _e, _f, _g], h in Rms.SystemUtilities.Station,
      on: a.origin_station_id == h.id
    )
    |> join(:left, [a, b, _c, _d, _e, _f, _g, _h], i in Rms.SystemUtilities.Station,
      on: a.reporting_station_id == i.id
    )
    |> join(:left, [a, b, _c, _d, _e, _f, _g, _h, _i], j in Rms.SystemUtilities.Commodity,
      on: a.commodity_id == j.id
    )
    |> join(:left, [a, b, _c, _d, _e, _f, _g, _h, _i, _j], k in Rms.Accounts.Clients,
      on: a.consignee_id == k.id
    )
    |> join(:left, [a, b, _c, _d, _e, _f, _g, _h, _i, _j, _k], l in Rms.Accounts.Clients,
      on: a.consigner_id == l.id
    )
    |> join(:left, [a, b, _c, _d, _e, _f, _g, _h, _i, _j, _k, _l], m in Rms.Accounts.Clients,
      on: a.customer_id == m.id
    )
    |> join(:left, [a, b, _c, _d, _e, _f, _g, _h, _i, _j, _k, _l, _m], n in Rms.Accounts.Clients,
      on: a.payer_id == n.id
    )
    |> join(
      :left,
      [a, b, _c, _d, _e, _f, _g, _h, _i, _j, _k, _l, _m, n],
      p in Rms.SystemUtilities.Currency,
      on: a.invoice_currency_id == p.id
    )
    |> handle_manual_matching_report_filter(search_params)
    |> compose_manual_matching_report_select(unmatched_period)
  end

  defp handle_manual_matching_report_filter(query, %{"isearch" => search_term} = search_params)
       when search_term == "" or is_nil(search_term) do
    query
    |> handle_date_filter(search_params)
    |> handle_consignment_customer_filter(search_params)
    |> handle_consignment_station_code_filter(search_params)
    |> handle_consignment_sales_order_filter(search_params)
    |> handle_consignment_reporting_station_filter(search_params)
    |> handle_consignment_capture_date_filter(search_params)
    |> handle_consignment_consignee_filter(search_params)
    |> handle_consignment_payer_filter(search_params)
    |> handle_consignment_commodity_filter(search_params)
  end

  defp handle_manual_matching_report_filter(query, %{"isearch" => search_term}) do
    search_term = "%#{search_term}%"
    compose_manual_matching_isearch_filter(query, search_term)
  end

  defp compose_manual_matching_isearch_filter(query, search_term) do
    query
    |> where(
      [a, b, c, d, e, f, g, h, i, j, k, l, m, n],
      fragment("lower(?) LIKE lower(?)", f.description, ^search_term) or
        fragment("lower(?) LIKE lower(?)", i.description, ^search_term) or
        fragment("lower(?) LIKE lower(?)", h.description, ^search_term) or
        fragment("lower(?) LIKE lower(?)", k.client_name, ^search_term) or
        fragment("lower(?) LIKE lower(?)", a.capture_date, ^search_term) or
        fragment("lower(?) LIKE lower(?)", j.description, ^search_term) or
        fragment("lower(?) LIKE lower(?)", n.client_name, ^search_term) or
        fragment("lower(?) LIKE lower(?)", a.sale_order, ^search_term)
    )
  end

  defp compose_manual_matching_report_select(query, unmatched_period) do
    query
    |> where(
      [a, b, c, e, f],
      exists(
        from(m in Rms.Order.Movement,
          where:
            parent_as(:consign).commodity_id == m.commodity_id and
              parent_as(:consign).document_date == m.consignment_date and
              parent_as(:consign).final_destination_id == m.destin_station_id and
              parent_as(:consign).origin_station_id == m.origin_station_id and
              parent_as(:consign).wagon_id == m.wagon_id and
              parent_as(:consign).consignee_id == m.consignee_id and
              parent_as(:consign).consigner_id == m.consigner_id and
              m.inserted_at > date_add(parent_as(:consign).inserted_at, ^unmatched_period, "day") and
              m.manual_matching == "NO"
        )
      )
    )
    |> order_by([a, _b, _c, _d, _e, _f, _g, _h, _i, _j, _k, _l, _m, _n, _P], desc: a.inserted_at)
    |> select([a, b, c, d, e, f, g, h, i, j, k, l, m, n, p], %{
      id: a.id,
      capture_date: a.capture_date,
      code: a.code,
      customer_ref: a.customer_ref,
      document_date: a.document_date,
      sale_order: a.sale_order,
      station_code: a.station_code,
      status: a.status,
      tariff_destination: e.description,
      tariff_origin: f.description,
      final_destination: g.description,
      origin_station: h.description,
      reporting_station: i.description,
      consignee: k.client_name,
      consigner: l.client_name,
      customer: m.client_name,
      payer: n.client_name,
      commodity: j.description,
      vat_amount: a.vat_amount,
      invoice_no: a.invoice_no,
      final_destination_id: a.final_destination_id,
      origin_station_id: a.origin_station_id,
      reporting_station_id: a.reporting_station_id,
      commodity_id: a.commodity_id,
      consignee_id: a.consignee_id,
      consigner_id: a.consigner_id,
      customer_id: a.customer_id,
      payer_id: a.payer_id,
      tarrif_id: a.tarrif_id,
      maker_id: a.maker_id,
      batch_id: a.batch_id,
      wagon_id: a.wagon_id,
      checker_id: a.checker_id,
      comment: a.comment,
      capacity_tonnes: a.capacity_tonnes,
      actual_tonnes: a.actual_tonnes,
      tariff_tonnage: a.tariff_tonnage,
      tariff_origin_id: a.tariff_origin_id,
      tariff_destination_id: a.tariff_destination_id,
      container_no: a.container_no,
      wagon_owner: d.description,
      wagon_type: c.description,
      invoice_number: a.invoice_no,
      train_number: a.invoice_no,
      move_date: a.invoice_no,
      total: a.invoice_no,
      wagon_code: b.code,
      invoice_date: a.invoice_date,
      invoice_amount: a.invoice_amount,
      invoice_term: a.invoice_term,
      invoice_currency_id: a.invoice_currency_id,
      invoice_currency: p.code,
      train_list_no: "",
      train_no: "",
      movement_date: "",
      movement_time: ""
    })
  end

  def tarrif_rates(tarrif_id) do
    Rms.SystemUtilities.TariffLineRate
    |> join(:left, [a], b in Rms.Accounts.RailwayAdministrator, on: a.admin_id == b.id)
    |> where([a, _b], a.tariff_id == ^tarrif_id)
    |> select([a, b], %{
      rate: a.rate,
      admin_id: a.admin_id,
      admin: b.code
    })
    |> Repo.all()
  end

  def list_consignment_batch_item(batch_id) do
    Rms.Order.Consignment
    |> where([a], a.batch_id == ^batch_id)
    |> join(:left, [a], b in Rms.SystemUtilities.Wagon, on: a.wagon_id == b.id)
    |> join(:left, [a, b], c in Rms.SystemUtilities.WagonType, on: b.wagon_type_id == c.id)
    |> join(:left, [a, b, _c], d in Rms.Accounts.RailwayAdministrator, on: b.owner_id == d.id)
    |> join(:left, [a, b, _c, _d], e in Rms.SystemUtilities.Station,
      on: a.tariff_destination_id == e.id
    )
    |> join(:left, [a, b, _c, _d, _e], f in Rms.SystemUtilities.Station,
      on: a.tariff_origin_id == f.id
    )
    |> join(:left, [a, b, _c, _d, _e, _f], g in Rms.SystemUtilities.Station,
      on: a.final_destination_id == g.id
    )
    |> join(:left, [a, b, _c, _d, _e, _f, _g], h in Rms.SystemUtilities.Station,
      on: a.origin_station_id == h.id
    )
    |> join(:left, [a, b, _c, _d, _e, _f, _g, _h], i in Rms.SystemUtilities.Station,
      on: a.reporting_station_id == i.id
    )
    |> join(:left, [a, b, _c, _d, _e, _f, _g, _h, _i], j in Rms.SystemUtilities.Commodity,
      on: a.commodity_id == j.id
    )
    |> join(:left, [a, b, _c, _d, _e, _f, _g, _h, _i, _j], k in Rms.Accounts.Clients,
      on: a.consignee_id == k.id
    )
    |> join(:left, [a, b, _c, _d, _e, _f, _g, _h, _i, _j, _k], l in Rms.Accounts.Clients,
      on: a.consigner_id == l.id
    )
    |> join(:left, [a, b, _c, _d, _e, _f, _g, _h, _i, _j, _k, _l], m in Rms.Accounts.Clients,
      on: a.customer_id == m.id
    )
    |> join(:left, [a, b, _c, _d, _e, _f, _g, _h, _i, _j, _k, _l, _m], n in Rms.Accounts.Clients,
      on: a.payer_id == n.id
    )
    |> join(
      :left,
      [a, b, _c, _d, _e, _f, _g, _h, _i, _j, _k, _l, _m, _n],
      o in Rms.SystemUtilities.TariffLine,
      on: o.id == a.tarrif_id
    )
    |> join(
      :left,
      [a, b, _c, _d, _e, _f, _g, _h, _i, _j, _k, _l, _m, _n, o],
      p in Rms.SystemUtilities.Surchage,
      on: o.surcharge_id == p.id
    )
    |> where(
      [a, b, c, d, e, f, g, h, i, j, k, l, m, n],
      a.id in subquery(
        from(t in Rms.Order.Consignment,
          where: t.status in ["COMPLETE", "PENDING_INVOICE"],
          group_by: t.batch_id,
          select: max(t.id)
        )
      )
    )
    |> order_by([a, _b, _c, _d, _e, _f, _g, _h, _i, _j, _k, _l, _m, _n, _o, _p],
      desc: a.inserted_at
    )
    |> select([a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p], %{
      id: a.id,
      capture_date: a.capture_date,
      code: a.code,
      vat_applied: a.vat_applied,
      surcharge: p.surcharge_percent,
      customer_ref: a.customer_ref,
      document_date: a.document_date,
      sale_order: a.sale_order,
      station_code: a.station_code,
      status: a.status,
      tariff_destination: e.description,
      tariff_origin: f.description,
      final_destination: g.description,
      origin_station: h.description,
      reporting_station: i.description,
      consignee: k.client_name,
      consigner: l.client_name,
      customer: m.client_name,
      payer: n.client_name,
      commodity: j.description,
      vat_amount: a.vat_amount,
      invoice_no: a.invoice_no,
      final_destination_id: a.final_destination_id,
      origin_station_id: a.origin_station_id,
      reporting_station_id: a.reporting_station_id,
      commodity_id: a.commodity_id,
      consignee_id: a.consignee_id,
      consigner_id: a.consigner_id,
      customer_id: a.customer_id,
      payer_id: a.payer_id,
      tarrif_id: a.tarrif_id,
      maker_id: a.maker_id,
      batch_id: a.batch_id,
      wagon_id: a.wagon_id,
      checker_id: a.checker_id,
      comment: a.comment,
      capacity_tonnes: a.capacity_tonnes,
      actual_tonnes: a.actual_tonnes,
      tariff_tonnage: a.tariff_tonnage,
      tariff_origin_id: a.tariff_origin_id,
      tariff_destination_id: a.tariff_destination_id,
      container_no: a.container_no,
      wagon_owner: d.description,
      wagon_type: c.description,
      invoice_number: a.invoice_no,
      train_number: a.invoice_no,
      move_date: a.invoice_no,
      total: a.invoice_no,
      wagon_code: b.code,
      invoice_date: a.invoice_date,
      invoice_amount: a.invoice_amount,
      invoice_term: a.invoice_term,
      invoice_currency_id: a.invoice_currency_id
    })
    |> limit(1)
    |> Repo.one()
  end

  def consignment_batch_lookup(status, user, empty_commodity) do
    Rms.Order.Consignment
    |> where([a], a.status == ^status and a.commodity_id != ^empty_commodity)
    |> verify_user_station_id_for_consignment(user)
    |> join(:left, [a], b in Rms.SystemUtilities.Wagon, on: a.wagon_id == b.id)
    |> join(:left, [a, b], c in Rms.SystemUtilities.WagonType, on: b.wagon_type_id == c.id)
    |> join(:left, [a, b, _c], d in Rms.Accounts.RailwayAdministrator, on: b.owner_id == d.id)
    |> join(:left, [a, b, _c, _d], e in Rms.SystemUtilities.Station,
      on: a.tariff_destination_id == e.id
    )
    |> join(:left, [a, b, _c, _d, _e], f in Rms.SystemUtilities.Station,
      on: a.tariff_origin_id == f.id
    )
    |> join(:left, [a, b, _c, _d, _e, _f], g in Rms.SystemUtilities.Station,
      on: a.final_destination_id == g.id
    )
    |> join(:left, [a, b, _c, _d, _e, _f, _g], h in Rms.SystemUtilities.Station,
      on: a.origin_station_id == h.id
    )
    |> join(:left, [a, b, _c, _d, _e, _f, _g, _h], i in Rms.SystemUtilities.Station,
      on: a.reporting_station_id == i.id
    )
    |> join(:left, [a, b, _c, _d, _e, _f, _g, _h, _i], j in Rms.SystemUtilities.Commodity,
      on: a.commodity_id == j.id
    )
    |> join(:left, [a, b, _c, _d, _e, _f, _g, _h, _i, _j], k in Rms.Accounts.Clients,
      on: a.consignee_id == k.id
    )
    |> join(:left, [a, b, _c, _d, _e, _f, _g, _h, _i, _j, _k], l in Rms.Accounts.Clients,
      on: a.consigner_id == l.id
    )
    |> join(:left, [a, b, _c, _d, _e, _f, _g, _h, _i, _j, _k, _l], m in Rms.Accounts.Clients,
      on: a.customer_id == m.id
    )
    |> join(:left, [a, b, _c, _d, _e, _f, _g, _h, _i, _j, _k, _l, _m], n in Rms.Accounts.Clients,
      on: a.payer_id == n.id
    )
    |> join(:left, [a, b, _c, _d, _e, _f, _g, _h, _i, _j, _k, _l, _m, _n], o in Rms.Order.Batch,
      on: a.batch_id == o.id
    )
    |> where(
      [a, b, c, d, e, f, g, h, i, j, k, l, m, n, o],
      a.id in subquery(
        from(t in Rms.Order.Consignment,
          where: t.status == ^status and t.commodity_id != ^empty_commodity,
          group_by: t.batch_id,
          select: max(t.id)
        )
      )
    )
    |> order_by([a, _b, _c, _d, _e, _f, _g, _h, _i, _j, _k, _l, _m, _n, _o], desc: a.inserted_at)
    |> select([a, b, c, d, e, f, g, h, i, j, k, l, m, n, o], %{
      id: a.id,
      capture_date: a.capture_date,
      code: a.code,
      customer_ref: a.customer_ref,
      document_date: a.document_date,
      sale_order: a.sale_order,
      station_code: a.station_code,
      status: a.status,
      tariff_destination: e.description,
      tariff_origin: f.description,
      final_destination: g.description,
      origin_station: h.description,
      reporting_station: i.description,
      consignee: k.client_name,
      consigner: l.client_name,
      customer: m.client_name,
      payer: n.client_name,
      commodity: j.description,
      vat_amount: a.vat_amount,
      invoice_no: a.invoice_no,
      uuid: o.uuid,
      final_destination_id: a.final_destination_id,
      origin_station_id: a.origin_station_id,
      reporting_station_id: a.reporting_station_id,
      commodity_id: a.commodity_id,
      consignee_id: a.consignee_id,
      consigner_id: a.consigner_id,
      customer_id: a.customer_id,
      payer_id: a.payer_id,
      tarrif_id: a.tarrif_id,
      maker_id: a.maker_id,
      batch_id: a.batch_id,
      wagon_id: a.wagon_id,
      checker_id: a.checker_id,
      comment: a.comment,
      capacity_tonnes: a.capacity_tonnes,
      actual_tonnes: a.actual_tonnes,
      tariff_tonnage: a.tariff_tonnage,
      tariff_origin_id: a.tariff_origin_id,
      tariff_destination_id: a.tariff_destination_id,
      container_no: a.container_no,
      wagon_owner: d.description,
      wagon_type: c.description,
      invoice_number: a.invoice_no,
      train_number: a.invoice_no,
      move_date: a.invoice_no,
      total: a.invoice_no,
      wagon_code: b.code,
      invoice_currency: "",
      invoice_amount: a.invoice_amount,
      invoice_date: "",
      train_list_no: "",
      train_no: "",
      movement_date: "",
      movement_time: ""
    })
    |> Repo.all()
  end

  def con_batch_lookup(user, empty_com_id) do
    Rms.Order.Consignment
    |> where(
      [a],
      a.status == "PENDING_APPROVAL" and a.maker_id == ^user.id and
        a.commodity_id != ^empty_com_id
    )
    |> verify_user_station_id_for_consignment(user)
    |> join(:left, [a], b in Rms.SystemUtilities.Wagon, on: a.wagon_id == b.id)
    |> join(:left, [a, b], c in Rms.SystemUtilities.WagonType, on: b.wagon_type_id == c.id)
    |> join(:left, [a, b, _c], d in Rms.Accounts.RailwayAdministrator, on: b.owner_id == d.id)
    |> join(:left, [a, b, _c, _d], e in Rms.SystemUtilities.Station,
      on: a.tariff_destination_id == e.id
    )
    |> join(:left, [a, b, _c, _d, _e], f in Rms.SystemUtilities.Station,
      on: a.tariff_origin_id == f.id
    )
    |> join(:left, [a, b, _c, _d, _e, _f], g in Rms.SystemUtilities.Station,
      on: a.final_destination_id == g.id
    )
    |> join(:left, [a, b, _c, _d, _e, _f, _g], h in Rms.SystemUtilities.Station,
      on: a.origin_station_id == h.id
    )
    |> join(:left, [a, b, _c, _d, _e, _f, _g, _h], i in Rms.SystemUtilities.Station,
      on: a.reporting_station_id == i.id
    )
    |> join(:left, [a, b, _c, _d, _e, _f, _g, _h, _i], j in Rms.SystemUtilities.Commodity,
      on: a.commodity_id == j.id
    )
    |> join(:left, [a, b, _c, _d, _e, _f, _g, _h, _i, _j], k in Rms.Accounts.Clients,
      on: a.consignee_id == k.id
    )
    |> join(:left, [a, b, _c, _d, _e, _f, _g, _h, _i, _j, _k], l in Rms.Accounts.Clients,
      on: a.consigner_id == l.id
    )
    |> join(:left, [a, b, _c, _d, _e, _f, _g, _h, _i, _j, _k, _l], m in Rms.Accounts.Clients,
      on: a.customer_id == m.id
    )
    |> join(:left, [a, b, _c, _d, _e, _f, _g, _h, _i, _j, _k, _l, _m], n in Rms.Accounts.Clients,
      on: a.payer_id == n.id
    )
    |> join(:left, [a, b, _c, _d, _e, _f, _g, _h, _i, _j, _k, _l, _m, _n], o in Rms.Order.Batch,
      on: a.batch_id == o.id
    )
    |> where(
      [a, b, c, d, e, f, g, h, i, j, k, l, m, n, o],
      a.id in subquery(
        from(t in Rms.Order.Consignment,
          where: t.status == "PENDING_APPROVAL" and t.commodity_id != ^empty_com_id,
          group_by: t.batch_id,
          select: max(t.id)
        )
      )
    )
    |> order_by([a, _b, _c, _d, _e, _f, _g, _h, _i, _j, _k, _l, _m, _n, _o], desc: a.inserted_at)
    |> select([a, b, c, d, e, f, g, h, i, j, k, l, m, n, o], %{
      id: a.id,
      capture_date: a.capture_date,
      code: a.code,
      customer_ref: a.customer_ref,
      document_date: a.document_date,
      sale_order: a.sale_order,
      station_code: a.station_code,
      status: a.status,
      tariff_destination: e.description,
      tariff_origin: f.description,
      final_destination: g.description,
      origin_station: h.description,
      reporting_station: i.description,
      consignee: k.client_name,
      consigner: l.client_name,
      customer: m.client_name,
      payer: n.client_name,
      commodity: j.description,
      vat_amount: a.vat_amount,
      invoice_no: a.invoice_no,
      uuid: o.uuid,
      final_destination_id: a.final_destination_id,
      origin_station_id: a.origin_station_id,
      reporting_station_id: a.reporting_station_id,
      commodity_id: a.commodity_id,
      consignee_id: a.consignee_id,
      consigner_id: a.consigner_id,
      customer_id: a.customer_id,
      payer_id: a.payer_id,
      tarrif_id: a.tarrif_id,
      maker_id: a.maker_id,
      batch_id: a.batch_id,
      wagon_id: a.wagon_id,
      checker_id: a.checker_id,
      comment: a.comment,
      capacity_tonnes: a.capacity_tonnes,
      actual_tonnes: a.actual_tonnes,
      tariff_tonnage: a.tariff_tonnage,
      tariff_origin_id: a.tariff_origin_id,
      tariff_destination_id: a.tariff_destination_id,
      container_no: a.container_no,
      wagon_owner: d.description,
      wagon_type: c.description,
      invoice_number: a.invoice_no,
      train_number: a.invoice_no,
      move_date: a.invoice_no,
      total: a.invoice_no,
      wagon_code: b.code,
      invoice_currency: "",
      invoice_amount: a.invoice_amount,
      invoice_date: "",
      train_list_no: "",
      train_no: "",
      movement_date: "",
      movement_time: ""
    })
    |> Repo.all()
  end

  def con_empties_batch_lookup(user, empty_com_id) do
    Rms.Order.Consignment
    |> where(
      [a],
      a.status == "PENDING_APPROVAL" and a.maker_id == ^user.id and
        a.commodity_id == ^empty_com_id
    )
    |> verify_user_station_id_for_consignment(user)
    |> join(:left, [a], b in Rms.SystemUtilities.Wagon, on: a.wagon_id == b.id)
    |> join(:left, [a, b], c in Rms.SystemUtilities.WagonType, on: b.wagon_type_id == c.id)
    |> join(:left, [a, b, _c], d in Rms.Accounts.RailwayAdministrator, on: b.owner_id == d.id)
    |> join(:left, [a, b, _c, _d], e in Rms.SystemUtilities.Station,
      on: a.tariff_destination_id == e.id
    )
    |> join(:left, [a, b, _c, _d, _e], f in Rms.SystemUtilities.Station,
      on: a.tariff_origin_id == f.id
    )
    |> join(:left, [a, b, _c, _d, _e, _f], g in Rms.SystemUtilities.Station,
      on: a.final_destination_id == g.id
    )
    |> join(:left, [a, b, _c, _d, _e, _f, _g], h in Rms.SystemUtilities.Station,
      on: a.origin_station_id == h.id
    )
    |> join(:left, [a, b, _c, _d, _e, _f, _g, _h], i in Rms.SystemUtilities.Station,
      on: a.reporting_station_id == i.id
    )
    |> join(:left, [a, b, _c, _d, _e, _f, _g, _h, _i], j in Rms.SystemUtilities.Commodity,
      on: a.commodity_id == j.id
    )
    |> join(:left, [a, b, _c, _d, _e, _f, _g, _h, _i, _j], k in Rms.Accounts.Clients,
      on: a.consignee_id == k.id
    )
    |> join(:left, [a, b, _c, _d, _e, _f, _g, _h, _i, _j, _k], l in Rms.Accounts.Clients,
      on: a.consigner_id == l.id
    )
    |> join(:left, [a, b, _c, _d, _e, _f, _g, _h, _i, _j, _k, _l], m in Rms.Accounts.Clients,
      on: a.customer_id == m.id
    )
    |> join(:left, [a, b, _c, _d, _e, _f, _g, _h, _i, _j, _k, _l, _m], n in Rms.Accounts.Clients,
      on: a.payer_id == n.id
    )
    |> join(:left, [a, b, _c, _d, _e, _f, _g, _h, _i, _j, _k, _l, _m, _n], o in Rms.Order.Batch,
      on: a.batch_id == o.id
    )
    |> where(
      [a, b, c, d, e, f, g, h, i, j, k, l, m, n, o],
      a.id in subquery(
        from(t in Rms.Order.Consignment,
          where: t.status == "PENDING_APPROVAL" and t.commodity_id == ^empty_com_id,
          group_by: t.batch_id,
          select: max(t.id)
        )
      )
    )
    |> order_by([a, _b, _c, _d, _e, _f, _g, _h, _i, _j, _k, _l, _m, _n, _o], desc: a.inserted_at)
    |> select([a, b, c, d, e, f, g, h, i, j, k, l, m, n, o], %{
      id: a.id,
      capture_date: a.capture_date,
      code: a.code,
      customer_ref: a.customer_ref,
      document_date: a.document_date,
      sale_order: a.sale_order,
      station_code: a.station_code,
      status: a.status,
      tariff_destination: e.description,
      tariff_origin: f.description,
      final_destination: g.description,
      origin_station: h.description,
      reporting_station: i.description,
      consignee: k.client_name,
      consigner: l.client_name,
      customer: m.client_name,
      payer: n.client_name,
      commodity: j.description,
      vat_amount: a.vat_amount,
      invoice_no: a.invoice_no,
      uuid: o.uuid,
      final_destination_id: a.final_destination_id,
      origin_station_id: a.origin_station_id,
      reporting_station_id: a.reporting_station_id,
      commodity_id: a.commodity_id,
      consignee_id: a.consignee_id,
      consigner_id: a.consigner_id,
      customer_id: a.customer_id,
      payer_id: a.payer_id,
      tarrif_id: a.tarrif_id,
      maker_id: a.maker_id,
      batch_id: a.batch_id,
      wagon_id: a.wagon_id,
      checker_id: a.checker_id,
      comment: a.comment,
      capacity_tonnes: a.capacity_tonnes,
      actual_tonnes: a.actual_tonnes,
      tariff_tonnage: a.tariff_tonnage,
      tariff_origin_id: a.tariff_origin_id,
      tariff_destination_id: a.tariff_destination_id,
      container_no: a.container_no,
      wagon_owner: d.description,
      wagon_type: c.description,
      invoice_number: a.invoice_no,
      train_number: a.invoice_no,
      move_date: a.invoice_no,
      total: a.invoice_no,
      wagon_code: b.code,
      invoice_currency: "",
      invoice_amount: a.invoice_amount,
      invoice_date: "",
      train_list_no: "",
      train_no: "",
      movement_date: "",
      movement_time: ""
    })
    |> Repo.all()
  end

  def consignment_batch_lookup_excel(status, user) do
    unmatched_aging = Rms.SystemUtilities.list_company_info().unmatched_aging_period

    Rms.Order.Consignment
    |> where([a], a.status == ^status)
    |> verify_user_station_id_for_consignment(user)
    |> join(:left, [a], b in Rms.SystemUtilities.Wagon, on: a.wagon_id == b.id)
    |> join(:left, [a, b], c in Rms.SystemUtilities.WagonType, on: b.wagon_type_id == c.id)
    |> join(:left, [a, b, _c], d in Rms.Accounts.RailwayAdministrator, on: b.owner_id == d.id)
    |> join(:left, [a, b, _c, _d], e in Rms.SystemUtilities.Station,
      on: a.tariff_destination_id == e.id
    )
    |> join(:left, [a, b, _c, _d, _e], f in Rms.SystemUtilities.Station,
      on: a.tariff_origin_id == f.id
    )
    |> join(:left, [a, b, _c, _d, _e, _f], g in Rms.SystemUtilities.Station,
      on: a.final_destination_id == g.id
    )
    |> join(:left, [a, b, _c, _d, _e, _f, _g], h in Rms.SystemUtilities.Station,
      on: a.origin_station_id == h.id
    )
    |> join(:left, [a, b, _c, _d, _e, _f, _g, _h], i in Rms.SystemUtilities.Station,
      on: a.reporting_station_id == i.id
    )
    |> join(:left, [a, b, _c, _d, _e, _f, _g, _h, _i], j in Rms.SystemUtilities.Commodity,
      on: a.commodity_id == j.id
    )
    |> join(:left, [a, b, _c, _d, _e, _f, _g, _h, _i, _j], k in Rms.Accounts.Clients,
      on: a.consignee_id == k.id
    )
    |> join(:left, [a, b, _c, _d, _e, _f, _g, _h, _i, _j, _k], l in Rms.Accounts.Clients,
      on: a.consigner_id == l.id
    )
    |> join(:left, [a, b, _c, _d, _e, _f, _g, _h, _i, _j, _k, _l], m in Rms.Accounts.Clients,
      on: a.customer_id == m.id
    )
    |> join(:left, [a, b, _c, _d, _e, _f, _g, _h, _i, _j, _k, _l, _m], n in Rms.Accounts.Clients,
      on: a.payer_id == n.id
    )
    |> join(:left, [a, b, _c, _d, _e, _f, _g, _h, _i, _j, _k, _l, _m, _n], o in Rms.Order.Batch,
      on: a.batch_id == o.id
    )
    |> join(
      :left,
      [a, b, _c, _d, _e, _f, _g, _h, _i, _j, _k, _l, _m, _n, _o],
      p in Rms.Order.Movement,
      on:
        p.status == "APPROVED" and a.commodity_id == p.commodity_id and
          a.document_date == p.consignment_date and a.final_destination_id == p.destin_station_id and
          a.origin_station_id == p.origin_station_id and a.wagon_id == p.wagon_id and
          a.consignee_id == p.consignee_id and a.consigner_id == p.consigner_id and
          (p.inserted_at <= date_add(a.inserted_at, ^unmatched_aging, "day") or
             p.manual_matching == "YES")
    )
    |> join(
      :left,
      [a, b, _c, _d, _e, _f, _g, _h, _i, _j, _k, _l, _m, _n, _o, _p],
      q in Rms.SystemUtilities.Currency,
      on: a.invoice_currency_id == q.id
    )
    |> join(
      :left,
      [a, b, _c, _d, _e, _f, _g, _h, _i, _j, _k, _l, _m, _n, _o, _p, _q],
      r in Rms.SystemUtilities.TrainRoute,
      on: a.route_id == r.id
    )
    |> join(
      :left,
      [a, b, _c, _d, _e, _f, _g, _h, _i, _j, _k, _l, _m, _n, _o, _p, _q, r],
      s in Rms.SystemUtilities.TransportType,
      on: r.transport_type == s.id
    )
    |> order_by([a, _b, _c, _d, _e, _f, _g, _h, _i, _j, _k, _l, _m, _n, _o, _p, _q, _r],
      desc: a.inserted_at
    )
    |> select([a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s], %{
      id: a.id,
      capture_date: a.capture_date,
      code: a.code,
      customer_ref: a.customer_ref,
      document_date: a.document_date,
      sale_order: a.sale_order,
      station_code: a.station_code,
      status: a.status,
      tariff_destination: e.description,
      tariff_origin: f.description,
      final_destination: g.description,
      origin_station: h.description,
      reporting_station: i.description,
      consignee: k.client_name,
      consigner: l.client_name,
      customer: m.client_name,
      payer: n.client_name,
      commodity: j.description,
      vat_amount: a.vat_amount,
      invoice_no: a.invoice_no,
      uuid: o.uuid,
      final_destination_id: a.final_destination_id,
      origin_station_id: a.origin_station_id,
      reporting_station_id: a.reporting_station_id,
      commodity_id: a.commodity_id,
      consignee_id: a.consignee_id,
      consigner_id: a.consigner_id,
      customer_id: a.customer_id,
      payer_id: a.payer_id,
      tarrif_id: a.tarrif_id,
      maker_id: a.maker_id,
      batch_id: a.batch_id,
      wagon_id: a.wagon_id,
      checker_id: a.checker_id,
      comment: a.comment,
      capacity_tonnes: a.capacity_tonnes,
      actual_tonnes: a.actual_tonnes,
      tariff_tonnage: a.tariff_tonnage,
      tariff_origin_id: a.tariff_origin_id,
      tariff_destination_id: a.tariff_destination_id,
      container_no: a.container_no,
      wagon_owner: d.description,
      wagon_type: c.description,
      invoice_number: a.invoice_no,
      train_number: a.invoice_no,
      move_date: a.invoice_no,
      total: a.invoice_no,
      wagon_code: b.code,
      invoice_currency: "",
      invoice_amount: a.invoice_amount,
      invoice_date: "",
      train_list_no: p.train_list_no,
      train_no: p.train_list_no,
      movement_date: p.movement_date,
      movement_time: p.movement_time,
      distance: r.distance,
      transport_type: s.description,
      loco_no: p.loco_no
    })
    |> Repo.all()
  end

  # ///////////////////////// teddy fuel  report///////////////////////

  def fuel_report_lookup(search_params, page, size, user) do
    Rms.Order.FuelMonitoring
    |> where([a], a.status == "COMPLETE")
    # |> verify_user_region_id(user)
    |> verify_depo_requisites(user)
    |> join(:left, [a], b in Rms.SystemUtilities.Rates, on: a.depo_refueled_id == b.id)
    |> join(:left, [a, b], c in Rms.SystemUtilities.Station, on: a.train_destination_id == c.id)
    |> join(:left, [a, b, _c], d in Rms.Accounts.User, on: a.commercial_clerk_id == d.id)
    |> join(:left, [a, _b, _c, _d], e in Rms.SystemUtilities.TrainType,
      on: a.train_type_id == e.id
    )
    |> join(:left, [a, _b, _c, _d, _e], f in Rms.Accounts.User, on: a.locomotive_driver_id == f.id)
    |> join(:left, [a, _b, _c, _d, _e, _f], g in Rms.Locomotives.LocomotiveType,
      on: a.loco_id == g.id
    )
    |> join(:left, [a, _b, _c, _d, _e, _f, _g], h in Rms.SystemUtilities.Station,
      on: a.train_origin_id == h.id
    )
    |> join(:left, [a, _b, _c, _d, _e, _f, _g, _h], i in Rms.SystemUtilities.Refueling,
      on: a.refuel_type == i.id
    )
    |> join(:left, [a, _b, _c, _d, _e, _f, _g, _h, _i], j in Rms.SystemUtilities.Section,
      on: a.section_id == j.id
    )
    |> join(:left, [a, _b, _c, _d, _e, _f, _g, _h, _i, _j], k in Rms.Locomotives.Locomotive,
      on: a.loco_id == k.type_id
    )
    |> handle_fuel_report_filter(search_params)
    |> compose_fuel_report_select()
    |> Repo.paginate(page: page, page_size: size)
  end

  def fuel_report_lookup(_source, search_params, user) do
    Rms.Order.FuelMonitoring
    |> where([a], a.status == "COMPLETE")
    # |> verify_user_region_id(user)
    |> verify_depo_requisites(user)
    |> join(:left, [a], b in Rms.SystemUtilities.Rates, on: a.depo_refueled_id == b.id)
    |> join(:left, [a, b], c in Rms.SystemUtilities.Station, on: a.train_destination_id == c.id)
    |> join(:left, [a, b, _c], d in Rms.Accounts.User, on: a.commercial_clerk_id == d.id)
    |> join(:left, [a, _b, _c, _d], e in Rms.SystemUtilities.TrainType,
      on: a.train_type_id == e.id
    )
    |> join(:left, [a, _b, _c, _d, _e], f in Rms.Accounts.User, on: a.locomotive_driver_id == f.id)
    |> join(:left, [a, _b, _c, _d, _e, _f], g in Rms.Locomotives.LocomotiveType,
      on: a.loco_id == g.id
    )
    |> join(:left, [a, _b, _c, _d, _e, _f, _g], h in Rms.SystemUtilities.Station,
      on: a.train_origin_id == h.id
    )
    |> join(:left, [a, _b, _c, _d, _e, _f, _g, _h], i in Rms.SystemUtilities.Refueling,
      on: a.refuel_type == i.id
    )
    |> join(:left, [a, _b, _c, _d, _e, _f, _g, _h, _i], j in Rms.SystemUtilities.Section,
      on: a.section_id == j.id
    )
    |> join(:left, [a, _b, _c, _d, _e, _f, _g, _h, _i, _j], k in Rms.Locomotives.Locomotive,
      on: a.loco_id == k.type_id
    )
    |> handle_fuel_report_filter(search_params)
    |> compose_fuel_report_select()
  end

  defp handle_fuel_report_filter(query, %{"isearch" => search_term} = search_params)
       when search_term == "" or is_nil(search_term) do
    query
    |> handle_fuel_date_filter(search_params)
    |> handle_loco_number_report_filter(search_params)
    |> handle_train_number_filter(search_params)
    |> handle_fuel_requisition_no_filter(search_params)
    |> handle_fuel_depo_refueled_filter(search_params)
    # |> handle_fuel_capture_date_filter(search_params)
    |> handle_loco_number_filter(search_params)
    |> handle_fuel_section_filter(search_params)
    |> handle_refuel_type_filter(search_params)
  end

  defp handle_fuel_date_filter(query, %{"from" => from, "to" => to})
       when from == "" or is_nil(from) or to == "" or is_nil(to),
       do: query

  defp handle_fuel_date_filter(query, %{"from" => from, "to" => to}) do
    query
    |> where(
      [a],
      fragment("CAST(? AS DATE) >= ?", a.inserted_at, ^from) and
        fragment("CAST(? AS DATE) <= ?", a.inserted_at, ^to)
    )
  end

  defp handle_loco_number_report_filter(query, %{"isearch" => search_term}) do
    search_term = "%#{search_term}%"
    compose_fuel_isearch_filter(query, search_term)
  end

  defp handle_train_number_filter(query, %{"fuel_train_number" => fuel_train_number})
       when fuel_train_number == "" or is_nil(fuel_train_number),
       do: query

  defp handle_train_number_filter(query, %{"fuel_train_number" => fuel_train_number}) do
    where(
      query,
      [a],
      fragment("lower(?) LIKE lower(?)", a.train_number, ^"%#{fuel_train_number}%")
    )
  end

  defp handle_loco_number_filter(query, %{"fuel_loco_number" => fuel_loco_number})
       when fuel_loco_number == "" or is_nil(fuel_loco_number),
       do: query

  defp handle_loco_number_filter(query, %{"fuel_loco_number" => fuel_loco_number}) do
    where(query, [a], fragment("lower(?) LIKE lower(?)", a.loco_no, ^"%#{fuel_loco_number}%"))
  end

  defp handle_fuel_section_filter(query, %{"fuel_section_name" => fuel_section_name})
       when fuel_section_name == "" or is_nil(fuel_section_name),
       do: query

  defp handle_fuel_section_filter(query, %{"fuel_section_name" => fuel_section_name}) do
    where(query, [a], fragment("lower(?) LIKE lower(?)", a.section_id, ^"%#{fuel_section_name}%"))
  end

  defp handle_fuel_requisition_no_filter(query, %{"fuel_requisition_no" => fuel_requisition_no})
       when fuel_requisition_no == "" or is_nil(fuel_requisition_no),
       do: query

  defp handle_fuel_requisition_no_filter(query, %{"fuel_requisition_no" => fuel_requisition_no}) do
    where(
      query,
      [a],
      fragment("lower(?) LIKE lower(?)", a.requisition_no, ^"%#{fuel_requisition_no}%")
    )
  end

  defp handle_fuel_depo_refueled_filter(query, %{"fuel_depo_refueled" => fuel_depo_refueled})
       when fuel_depo_refueled == "" or is_nil(fuel_depo_refueled),
       do: query

  defp handle_fuel_depo_refueled_filter(query, %{"fuel_depo_refueled" => fuel_depo_refueled}) do
    where(query, [a], fragment("lower(?) LIKE lower(?)", a.depo_stn, ^"%#{fuel_depo_refueled}%"))
  end

  defp handle_refuel_type_filter(query, %{"filter_refuel_type" => filter_refuel_type})
       when filter_refuel_type == "" or is_nil(filter_refuel_type),
       do: query

  defp handle_refuel_type_filter(query, %{"filter_refuel_type" => filter_refuel_type}) do
    where(
      query,
      [a],
      fragment("lower(?) LIKE lower(?)", a.refuel_type, ^"%#{filter_refuel_type}%")
    )
  end

  # defp handle_fuel_capture_date_filter(query, %{"fuel_capture_date" => fuel_capture_date})
  #   when fuel_capture_date == "" or is_nil(fuel_capture_date),
  #     do: query

  # defp handle_fuel_capture_date_filter(query, %{"fuel_capture_date" => fuel_capture_date}) do
  #   query
  #   |> where(
  #   [a],
  #   fragment("CAST(? AS DATE) >= ?", a.date, ^fuel_capture_date))
  # end

  defp compose_fuel_isearch_filter(query, search_term) do
    query
    |> where(
      [a, b, c, d, e, f, g, h, i, j, k, l, m, n],
      fragment("lower(?) LIKE lower(?)", a.train_number, ^search_term) or
        fragment("lower(?) LIKE lower(?)", a.requisition_no, ^search_term) or
        fragment("lower(?) LIKE lower(?)", a.approved_refuel, ^search_term) or
        fragment("lower(?) LIKE lower(?)", a.quantity_refueled, ^search_term) or
        fragment("lower(?) LIKE lower(?)", a.balance_before_refuel, ^search_term) or
        fragment("lower(?) LIKE lower(?)", a.reading_after_refuel, ^search_term) or
        fragment("lower(?) LIKE lower(?)", a.section, ^search_term) or
        fragment("lower(?) LIKE lower(?)", a.total_cost, ^search_term) or
        fragment("lower(?) LIKE lower(?)", a.time, ^search_term) or
        fragment("lower(?) LIKE lower(?)", a.status, ^search_term)
    )
  end

  defp compose_fuel_report_select(query) do
    query
    |> where(
      [a, b, c, d, e, f, g, h, i, j, k, l, m, n],
      a.id in subquery(
        from(t in Rms.Order.FuelMonitoring,
          where: t.status == "COMPLETE",
          group_by: t.batch_id,
          select: max(t.id)
        )
      )
    )
    |> order_by([a, _b, _c, _d, _e, _f, _g, _h, _i, _j, _k, _l, _m, _n], desc: a.inserted_at)
    |> select([a, b, c, d, e, f, g, h, i, j, k, l, m, n], %{
      id: a.id,
      loco_no: a.loco_no,
      train_number: a.train_number,
      requisition_no: a.requisition_no,
      seal_number_at_arrival: a.seal_number_at_arrival,
      seal_number_at_depture: a.seal_number_at_depture,
      seal_color_at_arrival: a.seal_color_at_arrival,
      seal_color_at_depture: a.seal_color_at_depture,
      time: a.time,
      balance_before_refuel: a.balance_before_refuel,
      approved_refuel: a.approved_refuel,
      quantity_refueled: a.quantity_refueled,
      deff_ctc_actual: a.deff_ctc_actual,
      reading_after_refuel: a.reading_after_refuel,
      bp_meter_before: a.bp_meter_before,
      bp_meter_after: a.bp_meter_after,
      reading: a.reading,
      fuel_consumed: a.fuel_consumed,
      consumption_per_km: a.consumption_per_km,
      fuel_rate: a.fuel_rate,
      section: a.section,
      date: a.date,
      week_no: a.week_no,
      total_cost: a.total_cost,
      comment: a.comment,
      loco_id: a.loco_id,
      loco_type: g.description,
      locomotive_driver_id: a.locomotive_driver_id,
      loco_driver_fname: d.first_name,
      loco_driver_srname: d.last_name,
      loco_number: k.loco_number,
      train_type_id: a.train_type_id,
      commercial_clerk_id: a.commercial_clerk_id,
      clerk_fname: d.first_name,
      clerk_sname: d.last_name,
      depo_refueled_id: a.depo_refueled_id,
      depo_stn: a.depo_stn,
      depo_stn_name: c.description,
      train_destination_id: a.train_destination_id,
      train_destination: c.description,
      maker_id: a.maker_id,
      checker_id: a.checker_id,
      inserted_at: a.inserted_at,
      updated_at: a.updated_at,
      status: a.status,
      batch_id: a.batch_id,
      train_origin_id: a.train_origin_id,
      km_to_destin: a.km_to_destin,
      refuel_type: a.refuel_type,
      stn_foreman: a.stn_foreman,
      oil_rep_name: a.oil_rep_name,
      asset_protection_officers_name: a.asset_protection_officers_name,
      other_refuel: a.other_refuel,
      other_refuel_no: a.other_refuel_no,
      section_id: a.section_id,
      section_name: j.code,
      refuel_type: i.description,
      fuel_blc_figures: a.fuel_blc_figures,
      ctc_datestamp: a.ctc_datestamp,
      ctc_time: a.ctc_time,
      fuel_blc_words: a.fuel_blc_words,
      litres_in_words: a.litres_in_words,
      locomotive_type: a.locomotive_type,
      locomotive_id: a.locomotive_id
    })
  end

  # /////////////////////////////////////////////////////////////////

  def select_last_movement_batch(user_id) do
    from(a in Batch,
      order_by: [desc: a.id],
      where:
        a.current_user_id == ^user_id and a.last_user_id == ^user_id and
          a.batch_type == "MOVEMENT",
      where: fragment("CAST(? as date) = CAST(GETDATE() as date)", a.trans_date),
      limit: 1,
      select: a
    )
    |> Repo.one()
  end

  def list_movement_batch_items(batch_id) do
    Rms.Order.Movement
    |> where([a], a.batch_id == ^batch_id)
    |> join(:left, [a], b in Rms.SystemUtilities.Station,
      on: a.movement_reporting_station_id == b.id
    )
    |> join(:left, [a, b], c in Rms.Accounts.RailwayAdministrator, on: b.owner_id == c.id)
    |> select([a, b, c], %{
      id: a.id,
      wagon_id: a.wagon_id,
      origin_station_id: a.origin_station_id,
      destin_station_id: a.destin_station_id,
      commodity_id: a.commodity_id,
      netweight: a.netweight,
      consigner_id: a.consigner_id,
      consignee_id: a.consignee_id,
      container_no: a.container_no,
      sales_order: a.sales_order,
      # station_code: a.station_code,
      consignment_date: a.consignment_date,
      payer_id: a.payer_id,
      movement_date: a.movement_date,
      movement_time: a.movement_time,
      movement_reporting_station_id: a.movement_reporting_station_id,
      movement_destination_id: a.movement_destination_id,
      movement_origin_id: a.movement_origin_id,
      train_list_no: a.train_list_no,
      train_no: a.train_no,
      loco_id: a.loco_id,
      loco_no: a.loco_no,
      dead_loco: a.dead_loco,
      batch_id: a.batch_id,
      maker_id: a.maker_id,
      checker_id: a.checker_id,
      inserted_at: a.inserted_at,
      comment: a.comment,
      has_consignmt: a.has_consignmt,
      updated_at: a.updated_at,
      status: a.status,
      reporting_station_owner: c.description,
      consignment_id: a.consignment_id
    })
    |> limit(1)
    |> Repo.one()
  end

  def movement_draft_batches(user) do
    Batch
    |> join(:left, [a], b in Rms.Order.Movement, on: a.id == b.batch_id)
    |> join(:left, [a, _b], c in Rms.Accounts.User, on: a.last_user_id == c.id)
    |> verify_user_region_batch(user, "O", "MOVEMENT")
    |> group_by([a, b, c], [a.id, b.batch_id, a.batch_no, a.trans_date, c.first_name, c.last_name])
    # |> select([a, _b], map(a, [:id, :batch_no, :trans_date]))
    |> select([a, b, c], %{
      id: a.id,
      batch_no: a.batch_no,
      trans_date: a.trans_date,
      first_name: c.first_name,
      last_name: c.last_name
    })
    |> Repo.all()
  end

  def movement_rejected_batches(user) do
    Batch
    |> join(:left, [a], b in Rms.Order.Movement, on: a.id == b.batch_id)
    |> join(:left, [a, _b], c in Rms.Accounts.User, on: a.last_user_id == c.id)
    |> verify_user_region_batch(user, "R", "MOVEMENT")
    |> group_by([a, b, c], [a.id, b.batch_id, a.batch_no, a.trans_date, c.first_name, c.last_name])
    |> select([a, b, c], %{
      id: a.id,
      batch_no: a.batch_no,
      trans_date: a.trans_date,
      first_name: c.first_name,
      last_name: c.last_name
    })
    |> Repo.all()
  end

  def movement_entry_batch() do
    Batch
    |> join(:left, [a], b in Rms.Order.Consignment, on: a.id == b.batch_id)
    |> where([a, _b], status: "C", batch_type: ^"MOVEMENT")
    |> group_by([a, b], [a.id, b.batch_id, a.batch_no, a.trans_date])
    |> select([a, _b], map(a, [:id, :batch_no, :trans_date]))
    |> Repo.all()
  end

  def all_movement_batch_entries(batch_id, status, unmatched_aging) do
    Rms.Order.Movement
    |> where([a], a.batch_id == ^batch_id and (a.status == ^status or a.status == "REJECTED"))
    |> join(:left, [a], b in Rms.SystemUtilities.Wagon, on: a.wagon_id == b.id)
    |> join(:left, [a, b], c in Rms.SystemUtilities.WagonType, on: b.wagon_type_id == c.id)
    |> join(:left, [a, b, _c], d in Rms.Accounts.RailwayAdministrator, on: b.owner_id == d.id)
    |> join(:left, [a, _b, _c, _d], e in Rms.Accounts.Clients, on: a.consigner_id == e.id)
    |> join(:left, [a, _b, _c, _d, _e], f in Rms.Accounts.Clients, on: a.consignee_id == f.id)
    |> join(:left, [a, _b, _c, _d, _e, _f], g in Rms.Accounts.Clients, on: a.payer_id == g.id)
    |> join(:left, [a, _b, _c, _d, _e, _f, _g], h in Rms.SystemUtilities.Station,
      on: a.destin_station_id == h.id
    )
    |> join(:left, [a, _b, _c, _d, _e, _f, _g, _h], i in Rms.SystemUtilities.Station,
      on: a.origin_station_id == i.id
    )
    |> join(:left, [a, _b, _c, _d, _e, _f, _g, _h, _i], j in Rms.SystemUtilities.Commodity,
      on: a.commodity_id == j.id
    )
    |> join(:left, [a, _b, _c, _d, _e, _f, _g, _h, _i, j], l in Rms.Order.Consignment,
      on:
        l.status in ["COMPLETE", "PENDING_INVOICE"] and l.commodity_id == a.commodity_id and
          l.document_date == a.consignment_date and l.final_destination_id == a.destin_station_id and
          l.origin_station_id == a.origin_station_id and l.wagon_id == a.wagon_id and
          l.consignee_id == a.consignee_id and l.consigner_id == a.consigner_id and
          (a.inserted_at <= date_add(l.inserted_at, ^unmatched_aging, "day") or
             l.manual_matching == "YES")
    )
    |> select([a, b, c, d, e, f, g, h, i, j, l], %{
      id: a.id,
      wagon_id: a.wagon_id,
      origin_station_id: a.origin_station_id,
      destin_station_id: a.destin_station_id,
      commodity_id: a.commodity_id,
      netweight: a.netweight,
      consigner_id: a.consigner_id,
      consigner_id: a.consigner_id,
      container_no: a.container_no,
      train_list_no: a.train_list_no,
      sales_order: a.sales_order,
      consignment_date: a.consignment_date,
      consignment_sales_order: a.sales_order,
      payer_id: a.payer_id,
      movement_date: a.movement_date,
      movement_time: a.movement_time,
      movement_reporting_station_id: a.movement_reporting_station_id,
      train_no: a.train_no,
      loco_id: a.loco_id,
      dead_loco: a.dead_loco,
      wagon_owner: d.code,
      wagon_code: b.code,
      station_code: a.station_code,
      wagon_type: c.description,
      maker_id: a.maker_id,
      checker_id: a.checker_id,
      inserted_at: a.inserted_at,
      updated_at: a.updated_at,
      payer: g.client_name,
      consigner_name: e.client_name,
      consignee_name: f.client_name,
      status: a.status,
      consignment_id: a.consignment_id,
      origin_name: i.description,
      destination_name: h.description,
      commodity_name: j.description,
      invoice_no: a.invoice_no
    })
    |> Repo.all()
  end

  def mvt_lookup_train_no(train_no) do
    Rms.Order.Movement
    |> where([a], a.train_no == ^train_no and a.status in ["INTRANSIT"])
    |> join(:left, [a], b in Rms.SystemUtilities.Wagon, on: a.wagon_id == b.id)
    |> join(:left, [a, b], c in Rms.SystemUtilities.WagonType, on: b.wagon_type_id == c.id)
    |> join(:left, [a, b, _c], d in Rms.Accounts.RailwayAdministrator, on: b.owner_id == d.id)
    |> join(:left, [a, _b, _c, _d], e in Rms.Accounts.Clients, on: a.consigner_id == e.id)
    |> join(:left, [a, _b, _c, _d, _e], f in Rms.Accounts.Clients, on: a.consignee_id == f.id)
    |> join(:left, [a, _b, _c, _d, _e, _f], g in Rms.Accounts.Clients, on: a.payer_id == g.id)
    |> join(:left, [a, _b, _c, _d, _e, _f, _g], h in Rms.SystemUtilities.Station,
      on: a.destin_station_id == h.id
    )
    |> join(:left, [a, _b, _c, _d, _e, _f, _g, _h], i in Rms.SystemUtilities.Station,
      on: a.origin_station_id == i.id
    )
    |> join(:left, [a, _b, _c, _d, _e, _f, _g, _h, _i], j in Rms.SystemUtilities.Commodity,
      on: a.commodity_id == j.id
    )
    |> join(:left, [a, _b, _c, _d, _e, _f, _g, _h, _i, j], l in Rms.Order.Consignment,
      on:
        l.status in ["COMPLETE", "PENDING_INVOICE"] and l.commodity_id == a.commodity_id and
          l.document_date == a.consignment_date and l.final_destination_id == a.destin_station_id and
          l.origin_station_id == a.origin_station_id and l.wagon_id == a.wagon_id and
          l.consignee_id == a.consignee_id and l.consigner_id == a.consigner_id
    )
    |> join(:left, [a, b, _c, _d, _e, _f, _g, _h, _i, _l], n in Rms.SystemUtilities.Station,
      on: b.station_id == n.id
    )
    # |> join(:left, [a, b, _c, _d, _e, _f, _g, _h, _i, _l, _n], o in Rms.SystemUtilities.Condition, on: b.condition_id == o.id)
    |> select([a, b, c, d, e, f, g, h, i, j, l, n], %{
      id: a.id,
      wagon_id: a.wagon_id,
      origin_station_id: a.origin_station_id,
      destination_station_id: a.destin_station_id,
      destin_station_id: a.destin_station_id,
      destination_station_id: a.destin_station_id,
      condition_id: b.condition_id,
      commodity_id: a.commodity_id,
      netweight: a.netweight,
      consigner_id: a.consigner_id,
      consigner_id: a.consigner_id,
      container_no: a.container_no,
      train_list_no: a.train_list_no,
      sales_order: a.sales_order,
      consignment_date: a.consignment_date,
      consignment_sales_order: a.sales_order,
      payer_id: a.payer_id,
      movement_date: a.movement_date,
      movement_time: a.movement_time,
      movement_reporting_station_id: a.movement_reporting_station_id,
      current_location: n.description,
      current_location_id: b.station_id,
      train_no: a.train_no,
      loco_id: a.loco_id,
      dead_loco: a.dead_loco,
      wagon_owner: d.code,
      wagon_code: b.code,
      station_code: a.station_code,
      wagon_type: c.description,
      maker_id: a.maker_id,
      checker_id: a.checker_id,
      inserted_at: a.inserted_at,
      updated_at: a.updated_at,
      payer: g.client_name,
      consigner_name: e.client_name,
      customer_name: e.client_name,
      consignee_name: f.client_name,
      status: a.status,
      consignment_id: a.consignment_id,
      origin_name: i.description,
      destination_name: h.description,
      commodity_name: j.description,
      invoice_no: a.invoice_no
    })
    |> Repo.all()
  end

  def mvt_detected_wagon_lookup(id) do
    Rms.Order.Movement
    |> where([a], a.id == ^id)
    |> select([a], %{
      id: a.id,
      wagon_id: a.wagon_id,
      origin_station_id: a.origin_station_id,
      destination_station_id: a.destin_station_id,
      destin_station_id: a.destin_station_id,
      destination_station_id: a.destin_station_id,
      commodity_id: a.commodity_id,
      netweight: a.netweight,
      consigner_id: a.consigner_id,
      consigner_id: a.consigner_id,
      container_no: a.container_no,
      train_list_no: a.train_list_no,
      sales_order: a.sales_order,
      consignment_date: a.consignment_date,
      consignment_sales_order: a.sales_order,
      payer_id: a.payer_id,
      movement_date: a.movement_date,
      movement_time: a.movement_time,
      movement_reporting_station_id: a.movement_reporting_station_id,
      train_no: a.train_no,
      loco_id: a.loco_id,
      dead_loco: a.dead_loco,
      station_code: a.station_code,
      maker_id: a.maker_id,
      checker_id: a.checker_id,
      inserted_at: a.inserted_at,
      updated_at: a.updated_at,
      status: a.status,
      consignment_id: a.consignment_id,
      invoice_no: a.invoice_no
    })
    |> Repo.one()
  end

  def lookup_train_no(train_no) do
    Rms.Order.Movement
    |> where([a], a.train_no == ^train_no and a.status not in ["REJECTED", "DISCARDED"])
    |> join(:left, [a], b in Rms.SystemUtilities.Wagon, on: a.wagon_id == b.id)
    |> join(:left, [a, b], c in Rms.SystemUtilities.WagonType, on: b.wagon_type_id == c.id)
    |> join(:left, [a, b, _c], d in Rms.Accounts.RailwayAdministrator, on: b.owner_id == d.id)
    |> join(:left, [a, _b, _c, _d], e in Rms.Accounts.Clients, on: a.consigner_id == e.id)
    |> join(:left, [a, _b, _c, _d, _e], f in Rms.Accounts.Clients, on: a.consignee_id == f.id)
    |> join(:left, [a, _b, _c, _d, _e, _f], g in Rms.Accounts.Clients, on: a.payer_id == g.id)
    |> join(:left, [a, _b, _c, _d, _e, _f, _g], h in Rms.SystemUtilities.Station,
      on: a.destin_station_id == h.id
    )
    |> join(:left, [a, _b, _c, _d, _e, _f, _g, _h], i in Rms.SystemUtilities.Station,
      on: a.origin_station_id == i.id
    )
    |> join(:left, [a, _b, _c, _d, _e, _f, _g, _h, _i], j in Rms.SystemUtilities.Commodity,
      on: a.commodity_id == j.id
    )
    |> join(:left, [a, _b, _c, _d, _e, _f, _g, _h, _i, j], l in Rms.Order.Consignment,
      on:
        l.status in ["COMPLETE", "PENDING_INVOICE"] and l.commodity_id == a.commodity_id and
          l.document_date == a.consignment_date and l.final_destination_id == a.destin_station_id and
          l.origin_station_id == a.origin_station_id and l.wagon_id == a.wagon_id and
          l.consignee_id == a.consignee_id and l.consigner_id == a.consigner_id
    )
    |> join(:left, [a, b, _c, _d, _e, _f, _g, _h, _i, _l], n in Rms.SystemUtilities.Station,
      on: b.station_id == n.id
    )
    # |> join(:left, [a, b, _c, _d, _e, _f, _g, _h, _i, _l, _n], o in Rms.SystemUtilities.Condition, on: b.condition_id == o.id)
    |> select([a, b, c, d, e, f, g, h, i, j, l, n], %{
      id: a.id,
      wagon_id: a.wagon_id,
      origin_station_id: a.origin_station_id,
      destination_station_id: a.destin_station_id,
      destin_station_id: a.destin_station_id,
      destination_station_id: a.destin_station_id,
      condition_id: b.condition_id,
      commodity_id: a.commodity_id,
      consigner_id: a.consigner_id,
      consigner_id: a.consigner_id,
      container_no: a.container_no,
      train_list_no: a.train_list_no,
      sales_order: a.sales_order,
      consignment_date: a.consignment_date,
      consignment_sales_order: a.sales_order,
      payer_id: a.payer_id,
      movement_date: a.movement_date,
      movement_time: a.movement_time,
      movement_reporting_station_id: a.movement_reporting_station_id,
      current_location: n.description,
      current_location_id: b.station_id,
      train_no: a.train_no,
      loco_id: a.loco_id,
      dead_loco: a.dead_loco,
      wagon_owner: d.code,
      wagon_code: b.code,
      station_code: a.station_code,
      wagon_type: c.description,
      maker_id: a.maker_id,
      checker_id: a.checker_id,
      inserted_at: a.inserted_at,
      updated_at: a.updated_at,
      payer: g.client_name,
      consigner_name: e.client_name,
      customer_name: e.client_name,
      consignee_name: f.client_name,
      status: a.status,
      consignment_id: a.consignment_id,
      origin_name: i.description,
      destination_name: h.description,
      commodity_name: j.description,
      invoice_no: a.invoice_no
    })
    |> Repo.all()
  end

  def mvt_item_lookup(id, unmatched_aging) do
    Rms.Order.Movement
    |> where([a], a.id == ^id)
    |> join(:left, [a], b in Rms.SystemUtilities.Wagon, on: a.wagon_id == b.id)
    |> join(:left, [a, b], c in Rms.SystemUtilities.WagonType, on: b.wagon_type_id == c.id)
    |> join(:left, [a, b, _c], d in Rms.Accounts.RailwayAdministrator, on: b.owner_id == d.id)
    |> join(:left, [a, _b, _c, _d], e in Rms.Accounts.Clients, on: a.consigner_id == e.id)
    |> join(:left, [a, _b, _c, _d, _e], f in Rms.Accounts.Clients, on: a.consignee_id == f.id)
    |> join(:left, [a, _b, _c, _d, _e, _f], g in Rms.Accounts.Clients, on: a.payer_id == g.id)
    |> join(:left, [a, _b, _c, _d, _e, _f, _g], h in Rms.SystemUtilities.Station,
      on: a.destin_station_id == h.id
    )
    |> join(:left, [a, _b, _c, _d, _e, _f, _g, _h], i in Rms.SystemUtilities.Station,
      on: a.origin_station_id == i.id
    )
    |> join(:left, [a, _b, _c, _d, _e, _f, _g, _h, _i], j in Rms.SystemUtilities.Commodity,
      on: a.commodity_id == j.id
    )
    |> join(:left, [a, _b, _c, _d, _e, _f, _g, _h, _i, j], l in Rms.Order.Consignment,
      on:
        l.status in ["COMPLETE", "PENDING_INVOICE"] and l.commodity_id == a.commodity_id and
          l.document_date == a.consignment_date and l.final_destination_id == a.destin_station_id and
          l.origin_station_id == a.origin_station_id and l.wagon_id == a.wagon_id and
          l.consignee_id == a.consignee_id and l.consigner_id == a.consigner_id and
          (a.inserted_at <= date_add(l.inserted_at, ^unmatched_aging, "day") or
             l.manual_matching == "YES")
    )
    |> select([a, b, c, d, e, f, g, h, i, j, l], %{
      id: a.id,
      wagon_id: a.wagon_id,
      origin_station_id: a.origin_station_id,
      destin_station_id: a.destin_station_id,
      commodity_id: a.commodity_id,
      netweight: a.netweight,
      consigner_id: a.consigner_id,
      consignee_id: a.consignee_id,
      container_no: a.container_no,
      train_list_no: a.train_list_no,
      sales_order: a.sales_order,
      consignment_date: a.consignment_date,
      consignment_sales_order: a.sales_order,
      payer_id: a.payer_id,
      movement_date: a.movement_date,
      movement_time: a.movement_time,
      movement_reporting_station_id: a.movement_reporting_station_id,
      train_no: a.train_no,
      loco_id: a.loco_id,
      dead_loco: a.dead_loco,
      wagon_owner: d.code,
      wagon_code: b.code,
      station_code: a.station_code,
      wagon_type: c.description,
      maker_id: a.maker_id,
      checker_id: a.checker_id,
      inserted_at: a.inserted_at,
      updated_at: a.updated_at,
      payer: g.client_name,
      consigner_name: e.client_name,
      consignee_name: f.client_name,
      status: a.status,
      consignment_id: a.consignment_id,
      origin_name: i.description,
      destination_name: h.description,
      commodity_name: j.description,
      invoice_no: a.invoice_no
    })
    |> Repo.one()
  end

  def movement_report_entry_lookup(id) do
    Rms.Order.Movement
    |> where([a], a.id == ^id)
    |> join(:left, [a], b in Rms.SystemUtilities.Wagon, on: a.wagon_id == b.id)
    |> join(:left, [a, b], c in Rms.SystemUtilities.WagonType, on: b.wagon_type_id == c.id)
    |> join(:left, [a, b, _c], d in Rms.Accounts.RailwayAdministrator, on: b.owner_id == d.id)
    |> join(:left, [a, _b, _c, _d], e in Rms.Accounts.Clients, on: a.consigner == e.id)
    |> join(:left, [a, _b, _c, _d, _e], f in Rms.Accounts.Clients, on: a.consignee == f.id)
    |> join(:left, [a, _b, _c, _d, _e, _f], g in Rms.Accounts.Clients, on: a.payer_id == g.id)
    |> join(:left, [a, _b, _c, _d, _e, _f, _g], h in Rms.SystemUtilities.Station,
      on: a.movement_destination_id == h.id
    )
    |> join(:left, [a, _b, _c, _d, _e, _f, _g, _h], i in Rms.SystemUtilities.Station,
      on: a.movement_origin_id == i.id
    )
    |> join(:left, [a, _b, _c, _d, _e, _f, _g, _h, _i], j in Rms.SystemUtilities.Commodity,
      on: a.commodity_id == j.id
    )
    |> join(:left, [a, _b, _c, _d, _e, _f, _g, _h, _i, _j], k in Rms.Order.Consignment,
      on:
        a.commodity_id == k.commodity_id and a.consignment_date == k.document_date and
          a.destin_station_id == k.final_destination_id and
          a.origin_station_id == k.origin_station_id and a.wagon_id == k.wagon_id and
          a.consignee == k.consignee_id
    )
    |> select([a, b, c, d, e, f, g, h, i, j, k], %{
      id: a.id,
      wagon_id: a.wagon_id,
      origin_station_id: a.origin_station_id,
      destin_station_id: a.destin_station_id,
      commodity_id: a.commodity_id,
      netweight: a.netweight,
      consigner: a.consigner,
      consignee: a.consignee,
      container_no: a.container_no,
      sales_order: a.sales_order,
      station_code: a.station_code,
      consignment_date: a.consignment_date,
      consignment_sales_order: k.sale_order,
      payer_id: a.payer_id,
      movement_date: a.movement_date,
      movement_time: a.movement_time,
      reporting_station: a.reporting_station,
      train_no: a.train_no,
      loco_id: a.loco_id,
      dead_loco: a.dead_loco,
      wagon_owner: d.code,
      wagon_code: b.code,
      wagon_type: c.description,
      origin: a.origin,
      destination: a.destination,
      maker_id: a.maker_id,
      checker_id: a.checker_id,
      inserted_at: a.inserted_at,
      updated_at: a.updated_at,
      payer: g.client_name,
      consigner_name: e.client_name,
      consignee_name: f.client_name,
      status: a.status,
      consignment_id: a.consignment_id,
      origin_name: i.description,
      destination_name: h.description,
      commodity_name: j.code
    })
    |> Repo.one()
  end

  def movement_verification_batch_entries(user) do
    Rms.Order.Movement
    |> where([a], a.status == "PENDING_VERIFICATION")
    |> verify_user_station_id_for_movement(user)
    |> join(:left, [a], b in Rms.SystemUtilities.Wagon, on: a.wagon_id == b.id)
    |> join(:left, [a, b], c in Rms.SystemUtilities.WagonType, on: b.wagon_type_id == c.id)
    |> join(:left, [a, b, _c], d in Rms.Accounts.RailwayAdministrator, on: b.owner_id == d.id)
    |> join(:left, [a, _b, _c, _d], e in Rms.Accounts.Clients, on: a.consigner_id == e.id)
    |> join(:left, [a, _b, _c, _d, _e], f in Rms.Accounts.Clients, on: a.consignee_id == f.id)
    |> join(:left, [a, _b, _c, _d, _e, _f], g in Rms.Accounts.Clients, on: a.payer_id == g.id)
    |> join(:left, [a, _b, _c, _d, _e, _f, _g], h in Rms.SystemUtilities.Station,
      on: a.movement_destination_id == h.id
    )
    |> join(:left, [a, _b, _c, _d, _e, _f, _g, _h], i in Rms.SystemUtilities.Station,
      on: a.movement_origin_id == i.id
    )
    |> join(:left, [a, _b, _c, _d, _e, _f, _g, _h, _i], j in Rms.SystemUtilities.Commodity,
      on: a.commodity_id == j.id
    )
    |> join(:left, [a, _b, _c, _d, _e, _f, _g, _h, _i, j], k in Rms.SystemUtilities.Station,
      on: a.movement_reporting_station_id == k.id
    )
    |> where(
      [a, b, c, d, e, f, g, h, i, j, k],
      a.id in subquery(
        from(t in Rms.Order.Movement,
          where: t.status == "PENDING_VERIFICATION",
          group_by: t.batch_id,
          select: max(t.id)
        )
      )
    )
    |> select([a, b, c, d, e, f, g, h, i, j, k], %{
      id: a.id,
      wagon_id: a.wagon_id,
      origin_station_id: a.origin_station_id,
      destin_station_id: a.destin_station_id,
      commodity_id: a.commodity_id,
      netweight: a.netweight,
      consigner: a.consigner_id,
      consignee: a.consignee_id,
      container_no: a.container_no,
      sales_order: a.sales_order,
      # station_code: a.station_code,
      consignment_date: a.consignment_date,
      payer_id: a.payer_id,
      movement_date: a.movement_date,
      movement_time: a.movement_time,
      movement_reporting_station_id: a.movement_reporting_station_id,
      train_no: a.train_no,
      loco_id: a.loco_id,
      dead_loco: a.dead_loco,
      wagon_owner: d.code,
      wagon_code: b.code,
      wagon_type: c.description,
      movement_origin_id: a.movement_origin_id,
      movement_destination_id: a.movement_destination_id,
      train_list_no: a.train_list_no,
      maker_id: a.maker_id,
      checker_id: a.checker_id,
      inserted_at: a.inserted_at,
      updated_at: a.updated_at,
      payer: g.client_name,
      consigner_name: e.client_name,
      consignee_name: f.client_name,
      status: a.status,
      consignment_id: a.consignment_id,
      origin_name: i.description,
      destination_name: h.description,
      reporting_stat: k.description,
      commodity_name: j.code,
      batch_id: a.batch_id
    })
    |> Repo.all()
  end

  def movement_intransit_batch_entries(user, status) do
    Rms.Order.Movement
    |> where([a], a.status == ^status)
    |> verify_user_station_id_for_movement(user)
    |> join(:left, [a], b in Rms.SystemUtilities.Wagon, on: a.wagon_id == b.id)
    |> join(:left, [a, b], c in Rms.SystemUtilities.WagonType, on: b.wagon_type_id == c.id)
    |> join(:left, [a, b, _c], d in Rms.Accounts.RailwayAdministrator, on: b.owner_id == d.id)
    |> join(:left, [a, _b, _c, _d], e in Rms.Accounts.Clients, on: a.consigner_id == e.id)
    |> join(:left, [a, _b, _c, _d, _e], f in Rms.Accounts.Clients, on: a.consignee_id == f.id)
    |> join(:left, [a, _b, _c, _d, _e, _f], g in Rms.Accounts.Clients, on: a.payer_id == g.id)
    |> join(:left, [a, _b, _c, _d, _e, _f, _g], h in Rms.SystemUtilities.Station,
      on: a.movement_destination_id == h.id
    )
    |> join(:left, [a, _b, _c, _d, _e, _f, _g, _h], i in Rms.SystemUtilities.Station,
      on: a.movement_origin_id == i.id
    )
    |> join(:left, [a, _b, _c, _d, _e, _f, _g, _h, _i], j in Rms.SystemUtilities.Commodity,
      on: a.commodity_id == j.id
    )
    |> join(:left, [a, _b, _c, _d, _e, _f, _g, _h, _i, j], k in Rms.SystemUtilities.Station,
      on: a.movement_reporting_station_id == k.id
    )
    |> where(
      [a, b, c, d, e, f, g, h, i, j, k],
      a.id in subquery(
        from(t in Rms.Order.Movement,
          where: t.status == ^status,
          group_by: t.batch_id,
          select: max(t.id)
        )
      )
    )
    |> select([a, b, c, d, e, f, g, h, i, j, k], %{
      id: a.id,
      wagon_id: a.wagon_id,
      origin_station_id: a.origin_station_id,
      destin_station_id: a.destin_station_id,
      commodity_id: a.commodity_id,
      netweight: a.netweight,
      consigner: a.consigner_id,
      consignee: a.consignee_id,
      container_no: a.container_no,
      sales_order: a.sales_order,
      # station_code: a.station_code,
      consignment_date: a.consignment_date,
      payer_id: a.payer_id,
      movement_date: a.movement_date,
      movement_time: a.movement_time,
      movement_reporting_station_id: a.movement_reporting_station_id,
      train_no: a.train_no,
      loco_id: a.loco_id,
      dead_loco: a.dead_loco,
      wagon_owner: d.code,
      wagon_code: b.code,
      wagon_type: c.description,
      movement_origin_id: a.movement_origin_id,
      movement_destination_id: a.movement_destination_id,
      train_list_no: a.train_list_no,
      maker_id: a.maker_id,
      checker_id: a.checker_id,
      inserted_at: a.inserted_at,
      updated_at: a.updated_at,
      payer: g.client_name,
      consigner_name: e.client_name,
      consignee_name: f.client_name,
      status: a.status,
      consignment_id: a.consignment_id,
      origin_name: i.description,
      destination_name: h.description,
      reporting_stat: k.description,
      commodity_name: j.code,
      batch_id: a.batch_id
    })
    |> Repo.all()
  end

  def user_type_name(%{batch_id: batch_id}) do
    from(a in Rms.Order.FuelMonitoring, where: a.batch_id == ^batch_id)
    |> select(
      [a],
      map(
        a,
        [
          :loco_no,
          :train_number,
          :requisition_no,
          :seal_number_at_arrival,
          :seal_number_at_depture,
          :seal_color_at_arrival,
          :seal_color_at_depture,
          :time,
          :balance_before_refuel,
          :approved_refuel,
          :quantity_refueled,
          :deff_ctc_actual,
          :reading_after_refuel,
          :bp_meter_before,
          :bp_meter_after,
          :reading,
          :km_to_destination,
          :fuel_consumed,
          :consumption_per_km,
          :fuel_rate,
          :section,
          :date,
          :week_no,
          :total_cost,
          :comment,
          :loco_id,
          :locomotive_driver_id,
          :train_type_id,
          :commercial_clerk_id,
          :depo_refueled_id,
          :train_destination_id,
          :train_origin_id,
          :maker_id,
          :checker_id,
          :inserted_at,
          :updated_at,
          :status,
          :batch_id,
          :km_to_destin,
          :stn_foreman,
          :oil_rep_name,
          :asset_protection_officers_name,
          :other_refuel,
          :other_refuel_no,
          :section_id,
          :depo_stn,
          :locomotive_id
        ]
      )
    )
    |> limit(1)
    |> Repo.one()
  end

  def movement_batch_pending_approval(user) do
    Rms.Order.Movement
    |> where([a], a.status == "PENDING_VERIFICATION" and a.maker_id == ^user.id)
    |> join(:left, [a], b in Rms.SystemUtilities.Wagon, on: a.wagon_id == b.id)
    |> join(:left, [a, b], c in Rms.SystemUtilities.WagonType, on: b.wagon_type_id == c.id)
    |> join(:left, [a, b, _c], d in Rms.Accounts.RailwayAdministrator, on: b.owner_id == d.id)
    |> join(:left, [a, _b, _c, _d], e in Rms.Accounts.Clients, on: a.consigner_id == e.id)
    |> join(:left, [a, _b, _c, _d, _e], f in Rms.Accounts.Clients, on: a.consignee_id == f.id)
    |> join(:left, [a, _b, _c, _d, _e, _f], g in Rms.Accounts.Clients, on: a.payer_id == g.id)
    |> join(:left, [a, _b, _c, _d, _e, _f, _g], h in Rms.SystemUtilities.Station,
      on: a.movement_destination_id == h.id
    )
    |> join(:left, [a, _b, _c, _d, _e, _f, _g, _h], i in Rms.SystemUtilities.Station,
      on: a.movement_origin_id == i.id
    )
    |> join(:left, [a, _b, _c, _d, _e, _f, _g, _h, _i], j in Rms.SystemUtilities.Commodity,
      on: a.commodity_id == j.id
    )
    |> join(:left, [a, _b, _c, _d, _e, _f, _g, _h, _i, j], k in Rms.SystemUtilities.Station,
      on: a.movement_reporting_station_id == k.id
    )
    |> where(
      [a, b, c, d, e, f, g, h, i, j, k],
      a.id in subquery(
        from(t in Rms.Order.Movement,
          where: t.status == "PENDING_VERIFICATION",
          group_by: t.batch_id,
          select: max(t.id)
        )
      )
    )
    |> select([a, b, c, d, e, f, g, h, i, j, k], %{
      id: a.id,
      wagon_id: a.wagon_id,
      origin_station_id: a.origin_station_id,
      destin_station_id: a.destin_station_id,
      commodity_id: a.commodity_id,
      netweight: a.netweight,
      consigner: a.consigner_id,
      consignee: a.consignee_id,
      container_no: a.container_no,
      sales_order: a.sales_order,
      # station_code: a.station_code,
      consignment_date: a.consignment_date,
      payer_id: a.payer_id,
      movement_date: a.movement_date,
      movement_time: a.movement_time,
      movement_reporting_station_id: a.movement_reporting_station_id,
      train_no: a.train_no,
      loco_id: a.loco_id,
      dead_loco: a.dead_loco,
      wagon_owner: d.code,
      wagon_code: b.code,
      wagon_type: c.description,
      movement_origin_id: a.movement_origin_id,
      movement_destination_id: a.movement_destination_id,
      train_list_no: a.train_list_no,
      maker_id: a.maker_id,
      checker_id: a.checker_id,
      inserted_at: a.inserted_at,
      updated_at: a.updated_at,
      payer: g.client_name,
      consigner_name: e.client_name,
      consignee_name: f.client_name,
      status: a.status,
      consignment_id: a.consignment_id,
      origin_name: i.description,
      destination_name: h.description,
      reporting_stat: k.description,
      commodity_name: j.code,
      batch_id: a.batch_id
    })
    |> Repo.all()
  end

  def intransit_train_lookup(train_no) do
    Rms.Order.Movement
    |> where([a], a.status == "INTRANSIT" and a.train_no == ^train_no)
    |> join(:left, [a], b in Rms.SystemUtilities.Station,
      on: a.movement_destination_id == b.id
    )
    |> join(:left, [a, _b], c in Rms.SystemUtilities.Station,
      on: a.movement_origin_id == c.id
    )
    |> select([a, b, c], %{
      id: a.id,
      wagon_id: a.wagon_id,
      origin_station_id: a.origin_station_id,
      destin_station_id: a.destin_station_id,
      commodity_id: a.commodity_id,
      netweight: a.netweight,
      consigner: a.consigner_id,
      consignee: a.consignee_id,
      container_no: a.container_no,
      sales_order: a.sales_order,
      consignment_date: a.consignment_date,
      payer_id: a.payer_id,
      movement_date: a.movement_date,
      movement_time: a.movement_time,
      movement_reporting_station_id: a.movement_reporting_station_id,
      train_no: a.train_no,
      loco_id: a.loco_id,
      invoice_no: a.invoice_no,
      dead_loco: a.dead_loco,
      movement_origin_id: a.movement_origin_id,
      movement_destination_id: a.movement_destination_id,
      train_list_no: a.train_list_no,
      maker_id: a.maker_id,
      checker_id: a.checker_id,
      inserted_at: a.inserted_at,
      updated_at: a.updated_at,
      status: a.status,
      loco_no: a.loco_no,
      consignment_id: a.consignment_id,
      origin_name: c.description,
      destination_name: b.description,
      batch_id: a.batch_id
    })
    |> limit(1)
    |> Repo.one()
  end

  def list_fuel_monitoring_batch_items(id) do
    Rms.Order.FuelMonitoring
    |> where([a], a.id == ^id)
    |> preload([:maker, :checker])
    |> select(
      [a],
      map(
        a,
        [
          :loco_no,
          :train_number,
          :requisition_no,
          :seal_number_at_arrival,
          :seal_number_at_depture,
          :seal_color_at_arrival,
          :seal_color_at_depture,
          :time,
          :balance_before_refuel,
          :approved_refuel,
          :quantity_refueled,
          :deff_ctc_actual,
          :reading_after_refuel,
          :bp_meter_before,
          :bp_meter_after,
          :reading,
          :km_to_destination,
          :fuel_consumed,
          :consumption_per_km,
          :fuel_rate,
          :section,
          :date,
          :week_no,
          :total_cost,
          :comment,
          :loco_id,
          :locomotive_driver_id,
          :train_type_id,
          :commercial_clerk_id,
          :depo_refueled_id,
          :train_destination_id,
          :train_origin_id,
          :maker_id,
          :checker_id,
          :inserted_at,
          :updated_at,
          :status,
          :batch_id,
          :km_to_destin,
          :stn_foreman,
          :oil_rep_name,
          :asset_protection_officers_name,
          :other_refuel,
          :other_refuel_no,
          :refuel_type,
          :section_id,
          :meter_at_destin,
          :fuel_blc_figures,
          :ctc_datestamp,
          :ctc_time,
          :fuel_blc_words,
          :litres_in_words,
          :depo_stn,
          :loco_engine_capacity,
          :yard_master_id,
          :locomotive_type,
          :locomotive_id,
          :shunt,
          :driver_name,
          :commercial_clk_name,
          :yard_master_name,
          :controllers_name,
          maker: [:first_name, :last_name],
          checker: [:first_name, :last_name]
        ]
      )
    )
    |> limit(1)
    |> Repo.one()
  end

  def pending_control_approvals(user) do
    Rms.Order.FuelMonitoring
    |> where([a], a.status == "PENDING_CONTROL")
    |> verify_depo_requisites(user)
    |> order_by([a], desc: a.batch_id)
    |> group_by([a], [
      a.batch_id,
      a.train_number,
      a.stn_foreman,
      a.meter_at_destin,
      a.section_id,
      a.refuel_type,
      a.other_refuel,
      a.other_refuel_no,
      a.oil_rep_name,
      a.asset_protection_officers_name,
      a.status,
      a.train_origin_id,
      a.km_to_destin,
      a.requisition_no,
      a.balance_before_refuel,
      a.bp_meter_before,
      a.reading,
      a.fuel_rate,
      a.section,
      a.date,
      a.time,
      a.total_cost,
      a.id,
      a.fuel_blc_figures,
      a.ctc_datestamp,
      a.ctc_time,
      a.fuel_blc_words,
      a.litres_in_words,
      a.depo_stn,
      a.loco_engine_capacity,
      a.yard_master_id,
      a.locomotive_id,
      a.locomotive_type,
      a.shunt,
      a.driver_name,
      a.commercial_clk_name,
      a.yard_master_name,
      a.controllers_name
    ])
    |> select([a], %{
      id: a.id,
      section_id: a.section_id,
      stn_foreman: a.stn_foreman,
      oil_rep_name: a.oil_rep_name,
      asset_protection_officers_name: a.asset_protection_officers_name,
      train_origin_id: a.train_origin_id,
      status: a.status,
      km_to_destin: a.km_to_destin,
      total_cost: a.total_cost,
      time: a.time,
      date: a.date,
      section: a.section,
      fuel_rate: a.fuel_rate,
      reading: a.reading,
      bp_meter_before: a.bp_meter_before,
      balance_before_refuel: a.balance_before_refuel,
      requisition_no: a.requisition_no,
      train_number: a.train_number,
      batch_id: a.batch_id,
      other_refuel: a.other_refuel,
      other_refuel_no: a.other_refuel_no,
      refuel_type: a.refuel_type,
      meter_at_destin: a.meter_at_destin,
      fuel_blc_figures: a.fuel_blc_figures,
      ctc_datestamp: a.ctc_datestamp,
      ctc_time: a.ctc_time,
      fuel_blc_words: a.fuel_blc_words,
      litres_in_words: a.litres_in_words,
      depo_stn: a.depo_stn,
      loco_engine_capacity: a.loco_engine_capacity,
      yard_master_id: a.yard_master_id,
      locomotive_id: a.locomotive_id,
      locomotive_type: a.locomotive_type,
      shunt: a.shunt,
      driver_name: a.driver_name,
      commercial_clk_name: a.commercial_clk_name,
      yard_master_name: a.yard_master_name,
      controllers_name: a.controllers_name
    })
    |> Repo.all()
  end

  def initiated_fuel_entries() do
    Rms.Order.FuelMonitoring
    |> where([a], a.status in ["PENDING_COMPLETION", "PENDING_APPROVAL"])
    # |> verify_depo_requisites(user)
    |> order_by([a], desc: a.batch_id)
    |> group_by([a], [
      a.batch_id,
      a.refuel_type,
      a.meter_at_destin,
      a.section_id,
      a.km_to_destin,
      a.stn_foreman,
      a.other_refuel,
      a.other_refuel_no,
      a.oil_rep_name,
      a.asset_protection_officers_name,
      a.train_origin_id,
      a.fuel_consumed,
      a.consumption_per_km,
      a.train_number,
      a.requisition_no,
      a.balance_before_refuel,
      a.bp_meter_before,
      a.reading,
      a.fuel_rate,
      a.section,
      a.date,
      a.time,
      a.total_cost,
      a.id,
      a.status,
      a.fuel_blc_figures,
      a.ctc_datestamp,
      a.ctc_time,
      a.fuel_blc_words,
      a.litres_in_words,
      a.depo_stn,
      a.loco_engine_capacity,
      a.yard_master_id,
      a.locomotive_id,
      a.locomotive_type,
      a.shunt,
      a.driver_name,
      a.commercial_clk_name,
      a.yard_master_name,
      a.controllers_name
    ])
    |> select([a], %{
      id: a.id,
      section_id: a.section_id,
      stn_foreman: a.stn_foreman,
      oil_rep_name: a.oil_rep_name,
      meter_at_destin: a.meter_at_destin,
      asset_protection_officers_name: a.asset_protection_officers_name,
      train_origin_id: a.train_origin_id,
      fuel_consumed: a.fuel_consumed,
      consumption_per_km: a.consumption_per_km,
      fuel_rate: a.fuel_rate,
      status: a.status,
      km_to_destin: a.km_to_destin,
      total_cost: a.total_cost,
      time: a.time,
      date: a.date,
      section: a.section,
      reading: a.reading,
      bp_meter_before: a.bp_meter_before,
      balance_before_refuel: a.balance_before_refuel,
      requisition_no: a.requisition_no,
      train_number: a.train_number,
      batch_id: a.batch_id,
      other_refuel: a.other_refuel,
      other_refuel_no: a.other_refuel_no,
      refuel_type: a.refuel_type,
      fuel_blc_figures: a.fuel_blc_figures,
      ctc_datestamp: a.ctc_datestamp,
      ctc_time: a.ctc_time,
      fuel_blc_words: a.fuel_blc_words,
      litres_in_words: a.litres_in_words,
      depo_stn: a.depo_stn,
      loco_engine_capacity: a.loco_engine_capacity,
      yard_master_id: a.yard_master_id,
      locomotive_id: a.locomotive_id,
      locomotive_type: a.locomotive_type,
      shunt: a.shunt,
      driver_name: a.driver_name,
      commercial_clk_name: a.commercial_clk_name,
      yard_master_name: a.yard_master_name,
      controllers_name: a.controllers_name
    })
    |> Repo.all()
  end

  def pending_backoffice_approvals(id) do
    Rms.Order.FuelMonitoring
    |> where([a], a.status == "PENDING_CONTROL" and a.id == ^id)
    |> order_by([a], desc: a.batch_id)
    |> group_by([a], [
      a.batch_id,
      a.train_number,
      a.refuel_type,
      a.section_id,
      a.km_to_destin,
      a.meter_at_destin,
      a.stn_foreman,
      a.other_refuel,
      a.other_refuel_no,
      a.oil_rep_name,
      a.asset_protection_officers_name,
      a.train_origin_id,
      a.requisition_no,
      a.balance_before_refuel,
      a.bp_meter_before,
      a.reading,
      a.fuel_rate,
      a.section,
      a.date,
      a.time,
      a.total_cost,
      a.id,
      a.fuel_blc_figures,
      a.ctc_datestamp,
      a.ctc_time,
      a.fuel_blc_words,
      a.litres_in_words,
      a.depo_stn,
      a.loco_engine_capacity,
      a.yard_master_id,
      a.locomotive_id,
      a.locomotive_type,
      a.shunt,
      a.driver_name,
      a.commercial_clk_name,
      a.yard_master_name,
      a.controllers_name
    ])
    |> select([a], %{
      id: a.id,
      section_id: a.section_id,
      stn_foreman: a.stn_foreman,
      oil_rep_name: a.oil_rep_name,
      meter_at_destin: a.meter_at_destin,
      asset_protection_officers_name: a.asset_protection_officers_name,
      train_origin_id: a.train_origin_id,
      km_to_destin: a.km_to_destin,
      total_cost: a.total_cost,
      time: a.time,
      date: a.date,
      section: a.section,
      fuel_rate: a.fuel_rate,
      reading: a.reading,
      bp_meter_before: a.bp_meter_before,
      balance_before_refuel: a.balance_before_refuel,
      requisition_no: a.requisition_no,
      train_number: a.train_number,
      batch_id: a.batch_id,
      other_refuel: a.other_refuel,
      other_refuel_no: a.other_refuel_no,
      refuel_type: a.refuel_type,
      fuel_blc_figures: a.fuel_blc_figures,
      ctc_datestamp: a.ctc_datestamp,
      ctc_time: a.ctc_time,
      fuel_blc_words: a.fuel_blc_words,
      litres_in_words: a.litres_in_words,
      depo_stn: a.depo_stn,
      loco_engine_capacity: a.loco_engine_capacity,
      yard_master_id: a.yard_master_id,
      locomotive_id: a.locomotive_id,
      locomotive_type: a.locomotive_type,
      shunt: a.shunt,
      driver_name: a.driver_name,
      commercial_clk_name: a.commercial_clk_name,
      yard_master_name: a.yard_master_name,
      controllers_name: a.controllers_name
    })
    |> Repo.all()
  end

  def pending_backoffice_approvals() do
    Rms.Order.FuelMonitoring
    |> where([a], a.status == "PENDING_APPROVAL")
    |> order_by([a], desc: a.batch_id)
    # |> verify_depo_requisites(user)
    |> group_by([a], [
      a.batch_id,
      a.id,
      a.status,
      a.refuel_type,
      a.section_id,
      a.km_to_destin,
      a.meter_at_destin,
      a.stn_foreman,
      a.other_refuel,
      a.other_refuel_no,
      a.oil_rep_name,
      a.asset_protection_officers_name,
      a.train_origin_id,
      a.fuel_rate,
      a.fuel_consumed,
      a.consumption_per_km,
      a.train_number,
      a.requisition_no,
      a.balance_before_refuel,
      a.bp_meter_before,
      a.reading,
      a.section,
      a.date,
      a.time,
      a.total_cost,
      a.fuel_blc_figures,
      a.ctc_datestamp,
      a.ctc_time,
      a.fuel_blc_words,
      a.litres_in_words,
      a.depo_stn,
      a.loco_engine_capacity,
      a.yard_master_id,
      a.locomotive_id,
      a.locomotive_type,
      a.shunt,
      a.driver_name,
      a.commercial_clk_name,
      a.yard_master_name,
      a.controllers_name
    ])
    |> select([a], %{
      id: a.id,
      section_id: a.section_id,
      stn_foreman: a.stn_foreman,
      oil_rep_name: a.oil_rep_name,
      meter_at_destin: a.meter_at_destin,
      asset_protection_officers_name: a.asset_protection_officers_name,
      train_origin_id: a.train_origin_id,
      km_to_destin: a.km_to_destin,
      fuel_consumed: a.fuel_consumed,
      status: a.status,
      consumption_per_km: a.consumption_per_km,
      fuel_rate: a.fuel_rate,
      total_cost: a.total_cost,
      time: a.time,
      date: a.date,
      section: a.section,
      reading: a.reading,
      bp_meter_before: a.bp_meter_before,
      balance_before_refuel: a.balance_before_refuel,
      requisition_no: a.requisition_no,
      train_number: a.train_number,
      batch_id: a.batch_id,
      other_refuel: a.other_refuel,
      other_refuel_no: a.other_refuel_no,
      refuel_type: a.refuel_type,
      fuel_blc_figures: a.fuel_blc_figures,
      ctc_datestamp: a.ctc_datestamp,
      ctc_time: a.ctc_time,
      fuel_blc_words: a.fuel_blc_words,
      litres_in_words: a.litres_in_words,
      depo_stn: a.depo_stn,
      loco_engine_capacity: a.loco_engine_capacity,
      yard_master_id: a.yard_master_id,
      locomotive_id: a.locomotive_id,
      locomotive_type: a.locomotive_type,
      shunt: a.shunt,
      driver_name: a.driver_name,
      commercial_clk_name: a.commercial_clk_name,
      yard_master_name: a.yard_master_name,
      controllers_name: a.controllers_name
    })
    |> Repo.all()
  end

  def get_rejected_requisite(user) do
    Rms.Order.FuelMonitoring
    |> where([a], a.status == "REJECTED")
    |> verify_depo_requisites(user)
    |> order_by([a], desc: a.batch_id)
    |> group_by([a], [
      a.batch_id,
      a.id,
      a.status,
      a.refuel_type,
      a.section_id,
      a.meter_at_destin,
      a.km_to_destin,
      a.other_refuel,
      a.other_refuel_no,
      a.stn_foreman,
      a.oil_rep_name,
      a.asset_protection_officers_name,
      a.train_origin_id,
      a.fuel_rate,
      a.fuel_consumed,
      a.consumption_per_km,
      a.train_number,
      a.requisition_no,
      a.balance_before_refuel,
      a.bp_meter_before,
      a.reading,
      a.section,
      a.date,
      a.time,
      a.total_cost,
      a.fuel_blc_figures,
      a.ctc_datestamp,
      a.ctc_time,
      a.fuel_blc_words,
      a.litres_in_words,
      a.depo_stn,
      a.loco_engine_capacity,
      a.yard_master_id,
      a.locomotive_id,
      a.locomotive_type,
      a.shunt,
      a.driver_name,
      a.commercial_clk_name,
      a.yard_master_name,
      a.controllers_name
    ])
    |> select([a], %{
      id: a.id,
      section_id: a.section_id,
      stn_foreman: a.stn_foreman,
      oil_rep_name: a.oil_rep_name,
      meter_at_destin: a.meter_at_destin,
      asset_protection_officers_name: a.asset_protection_officers_name,
      train_origin_id: a.train_origin_id,
      km_to_destin: a.km_to_destin,
      fuel_consumed: a.fuel_consumed,
      status: a.status,
      consumption_per_km: a.consumption_per_km,
      fuel_rate: a.fuel_rate,
      total_cost: a.total_cost,
      time: a.time,
      date: a.date,
      section: a.section,
      reading: a.reading,
      bp_meter_before: a.bp_meter_before,
      balance_before_refuel: a.balance_before_refuel,
      requisition_no: a.requisition_no,
      train_number: a.train_number,
      batch_id: a.batch_id,
      other_refuel: a.other_refuel,
      other_refuel_no: a.other_refuel_no,
      refuel_type: a.refuel_type,
      fuel_blc_figures: a.fuel_blc_figures,
      ctc_datestamp: a.ctc_datestamp,
      ctc_time: a.ctc_time,
      fuel_blc_words: a.fuel_blc_words,
      litres_in_words: a.litres_in_words,
      depo_stn: a.depo_stn,
      loco_engine_capacity: a.loco_engine_capacity,
      yard_master_id: a.yard_master_id,
      locomotive_id: a.locomotive_id,
      locomotive_type: a.locomotive_type,
      shunt: a.shunt,
      driver_name: a.driver_name,
      commercial_clk_name: a.commercial_clk_name,
      yard_master_name: a.yard_master_name,
      controllers_name: a.controllers_name
    })
    |> Repo.all()
  end

  def all_fuel_monitoring_entries(requisition_no, user) do
    Rms.Order.FuelMonitoring
    |> where([a], a.requisition_no == ^requisition_no)
    |> verify_depo_requisites(user)
    |> join(:left, [a], b in Rms.SystemUtilities.Rates, on: a.depo_refueled_id == b.id)
    |> join(:left, [a, b], c in Rms.SystemUtilities.Station, on: a.train_destination_id == c.id)
    |> join(:left, [a, b, _c], d in Rms.Accounts.User, on: a.commercial_clerk_id == d.id)
    |> join(:left, [a, _b, _c, _d], e in Rms.SystemUtilities.TrainType,
      on: a.train_type_id == e.id
    )
    |> join(:left, [a, _b, _c, _d, _e], f in Rms.Accounts.User, on: a.locomotive_driver_id == f.id)
    |> join(:left, [a, _b, _c, _d, _e, _f], g in Rms.Locomotives.LocomotiveType,
      on: a.loco_id == g.id
    )
    |> join(:left, [a, _b, _c, _d, _e, _f, _g], h in Rms.SystemUtilities.Station,
      on: a.train_origin_id == h.id
    )
    |> select([a, b, c, d, e, f, g], %{
      id: a.id,
      depo_refueled_id: a.depo_refueled_id,
      train_destination_id: a.train_destination_id,
      train_origin_id: a.train_origin_id,
      commercial_clerk_id: a.commercial_clerk_id,
      train_type_id: a.train_type_id,
      locomotive_driver_id: a.locomotive_driver_id,
      loco_id: a.loco_id,
      approved_refuel: a.approved_refuel,
      balance_before_refuel: a.balance_before_refuel,
      bp_meter_after: a.bp_meter_after,
      bp_meter_before: a.bp_meter_before,
      comment: a.comment,
      consumption_per_km: a.consumption_per_km,
      meter_at_destin: a.meter_at_destin,
      date: a.date,
      deff_ctc_actual: a.deff_ctc_actual,
      fuel_consumed: a.fuel_consumed,
      fuel_rate: a.fuel_rate,
      loco_no: a.loco_no,
      quantity_refueled: a.quantity_refueled,
      reading: a.reading,
      reading_after_refuel: a.reading_after_refuel,
      requisition_no: a.requisition_no,
      seal_color_at_arrival: a.seal_color_at_arrival,
      seal_color_at_depture: a.seal_color_at_depture,
      seal_number_at_arrival: a.seal_number_at_arrival,
      seal_number_at_depture: a.seal_number_at_depture,
      section: a.section,
      time: a.time,
      total_cost: a.total_cost,
      train_number: a.train_number,
      status: a.status,
      maker_id: a.maker_id,
      checker_id: a.checker_id,
      inserted_at: a.inserted_at,
      updated_at: a.updated_at,
      code: e.code,
      first_name: d.first_name,
      code: g.code,
      description: c.description,
      description: g.description,
      code: g.code,
      loco_number: g.code,
      loco_type: g.description,
      driver_name: d.first_name,
      train_origin_stn: c.description,
      train_destin_stn: c.description,
      refuel_depo_stn: c.description,
      display_train_type: a.train_number,
      km_to_destin: a.km_to_destin,
      clerk_name: d.first_name,
      locomotive_type: g.description,
      stn_foreman: a.stn_foreman,
      oil_rep_name: a.oil_rep_name,
      asset_protection_officers_name: a.asset_protection_officers_name,
      other_refuel: a.other_refuel,
      other_refuel_no: a.other_refuel_no,
      refuel_type: a.refuel_type,
      section_id: a.section_id,
      fuel_blc_figures: a.fuel_blc_figures,
      ctc_datestamp: a.ctc_datestamp,
      ctc_time: a.ctc_time,
      fuel_blc_words: a.fuel_blc_words,
      litres_in_words: a.litres_in_words,
      depo_stn: a.depo_stn,
      loco_engine_capacity: a.loco_engine_capacity,
      yard_master_id: a.yard_master_id,
      locomotive_id: a.locomotive_id,
      locomotive_type: a.locomotive_type,
      shunt: a.shunt,
      driver_name: a.driver_name,
      commercial_clk_name: a.commercial_clk_name,
      yard_master_name: a.yard_master_name,
      controllers_name: a.controllers_name
    })
    |> Repo.all()
  end

  def get_complete_fuel_requisite() do
    Rms.Order.FuelMonitoring
    |> where([a], a.status == "COMPLETE")
    |> order_by([a], desc: a.batch_id)
    |> group_by([a], [
      a.batch_id,
      a.id,
      a.status,
      a.approved_refuel,
      a.meter_at_destin,
      a.other_refuel_no,
      a.section_id,
      a.refuel_type,
      a.other_refuel,
      a.stn_foreman,
      a.oil_rep_name,
      a.asset_protection_officers_name,
      a.reading_after_refuel,
      a.quantity_refueled,
      a.fuel_rate,
      a.fuel_consumed,
      a.consumption_per_km,
      a.train_number,
      a.requisition_no,
      a.balance_before_refuel,
      a.bp_meter_before,
      a.reading,
      a.section,
      a.date,
      a.time,
      a.total_cost,
      a.fuel_blc_figures,
      a.ctc_datestamp,
      a.ctc_time,
      a.fuel_blc_words,
      a.litres_in_words,
      a.depo_stn,
      a.loco_engine_capacity,
      a.yard_master_id,
      a.locomotive_id,
      a.locomotive_type,
      a.shunt,
      a.driver_name,
      a.commercial_clk_name,
      a.yard_master_name,
      a.controllers_name
    ])
    |> select([a], %{
      id: a.id,
      section_id: a.section_id,
      stn_foreman: a.stn_foreman,
      meter_at_destin: a.meter_at_destin,
      oil_rep_name: a.oil_rep_name,
      asset_protection_officers_name: a.asset_protection_officers_name,
      balance_before_refuel: a.balance_before_refuel,
      approved_refuel: a.approved_refuel,
      quantity_refueled: a.quantity_refueled,
      reading_after_refuel: a.reading_after_refuel,
      fuel_consumed: a.fuel_consumed,
      status: a.status,
      consumption_per_km: a.consumption_per_km,
      fuel_rate: a.fuel_rate,
      total_cost: a.total_cost,
      time: a.time,
      date: a.date,
      section: a.section,
      reading: a.reading,
      bp_meter_before: a.bp_meter_before,
      balance_before_refuel: a.balance_before_refuel,
      requisition_no: a.requisition_no,
      train_number: a.train_number,
      batch_id: a.batch_id,
      other_refuel: a.other_refuel,
      other_refuel_no: a.other_refuel_no,
      refuel_type: a.refuel_type,
      fuel_blc_figures: a.fuel_blc_figures,
      ctc_datestamp: a.ctc_datestamp,
      ctc_time: a.ctc_time,
      fuel_blc_words: a.fuel_blc_words,
      litres_in_words: a.litres_in_words,
      depo_stn: a.depo_stn,
      loco_engine_capacity: a.loco_engine_capacity,
      yard_master_id: a.yard_master_id,
      locomotive_id: a.locomotive_id,
      locomotive_type: a.locomotive_type,
      shunt: a.shunt,
      driver_name: a.driver_name,
      commercial_clk_name: a.commercial_clk_name,
      yard_master_name: a.yard_master_name,
      controllers_name: a.controllers_name
    })
    |> Repo.all()
  end

  def all_fuel_pending_monitoring(id, status, user) do
    Rms.Order.FuelMonitoring
    |> where([a], a.id == ^id and a.status == ^status)
    |> verify_depo_requisites(user)
    |> join(:left, [a], b in Rms.SystemUtilities.Rates, on: a.depo_refueled_id == b.id)
    |> join(:left, [a, b], c in Rms.SystemUtilities.Station, on: a.train_destination_id == c.id)
    |> join(:left, [a, b, _c], d in Rms.Accounts.User, on: a.commercial_clerk_id == d.id)
    |> join(:left, [a, _b, _c, _d], e in Rms.SystemUtilities.TrainType, on: a.train_type_id == e.id)
    |> join(:left, [a, _b, _c, _d, _e], f in Rms.Accounts.User, on: a.locomotive_driver_id == f.id)
    |> join(:left, [a, _b, _c, _d, _e, _f], g in Rms.Locomotives.LocomotiveType, on: a.loco_id == g.id)
    |> join(:left, [a, _b, _c, _d], e in Rms.SystemUtilities.TrainType,
      on: a.train_type_id == e.id
    )
    |> join(:left, [a, _b, _c, _d, _e], f in Rms.Accounts.LocoDriver, on: a.loco_driver_id == f.id)
    |> join(:left, [a, _b, _c, _d, _e, _f], g in Rms.Locomotives.LocomotiveType,
      on: a.loco_id == g.id
    )
    |> select([a, b, c, d, e, f, g], %{
      id: a.id,
      batch_id: a.batch_id,
      depo_refueled_id: a.depo_refueled_id,
      train_destination_id: a.train_destination_id,
      commercial_clerk_id: a.commercial_clerk_id,
      train_type_id: a.train_type_id,
      locomotive_driver_id: a.locomotive_driver_id,
      loco_id: a.loco_id,
      approved_refuel: a.approved_refuel,
      balance_before_refuel: a.balance_before_refuel,
      bp_meter_after: a.bp_meter_after,
      bp_meter_before: a.bp_meter_before,
      comment: a.comment,
      consumption_per_km: a.consumption_per_km,
      km_to_destin: a.km_to_destin,
      date: a.date,
      deff_ctc_actual: a.deff_ctc_actual,
      fuel_consumed: a.fuel_consumed,
      fuel_rate: a.fuel_rate,
      loco_no: a.loco_no,
      quantity_refueled: a.quantity_refueled,
      reading: a.reading,
      reading_after_refuel: a.reading_after_refuel,
      requisition_no: a.requisition_no,
      seal_color_at_arrival: a.seal_color_at_arrival,
      seal_color_at_depture: a.seal_color_at_depture,
      seal_number_at_arrival: a.seal_number_at_arrival,
      seal_number_at_depture: a.seal_number_at_depture,
      section: a.section,
      time: a.time,
      total_cost: a.total_cost,
      train_number: a.train_number,
      status: a.status,
      maker_id: a.maker_id,
      checker_id: a.checker_id,
      inserted_at: a.inserted_at,
      updated_at: a.updated_at,
      week_no: a.week_no,
      code: e.code,
      first_name: d.first_name,
      code: g.code,
      description: c.description,
      code: g.code,
      stn_foreman: a.stn_foreman,
      oil_rep_name: a.oil_rep_name,
      asset_protection_officers_name: a.asset_protection_officers_name,
      other_refuel: a.other_refuel,
      other_refuel_no: a.other_refuel_no,
      refuel_type: a.refuel_type,
      section_id: a.section_id,
      meter_at_destin: a.meter_at_destin,
      fuel_blc_figures: a.fuel_blc_figures,
      ctc_datestamp: a.ctc_datestamp,
      ctc_time: a.ctc_time,
      fuel_blc_words: a.fuel_blc_words,
      litres_in_words: a.litres_in_words,
      depo_stn: a.depo_stn,
      loco_engine_capacity: a.loco_engine_capacity,
      yard_master_id: a.yard_master_id,
      locomotive_id: a.locomotive_id,
      locomotive_type: a.locomotive_type,
      shunt: a.shunt,
      driver_name: a.driver_name,
      commercial_clk_name: a.commercial_clk_name,
      yard_master_name: a.yard_master_name,
      controllers_name: a.controllers_name
    })
    |> limit(1)
    |> Repo.one()
  end

  def get_fuel_by_batch_id(requisition_no) do
    Rms.Order.FuelMonitoring
    |> where([a], a.requisition_no == ^requisition_no)
    |> Repo.all()
  end

  def get_fuel_request_by_requisition_no(requisition_no, status) do
    Rms.Order.FuelMonitoring
    |> where([a], a.requisition_no == ^requisition_no and a.status == ^status)
    |> Repo.all()
  end

  def search_for_consignment(
        commodity_id,
        document_date,
        final_destination_id,
        origin_station_id,
        wagon_id,
        consignee_id,
        consigner_id
      ) do
    Rms.Order.Consignment
    |> where(
      [a],
      a.commodity_id == ^commodity_id and a.document_date == ^document_date and
        a.final_destination_id == ^final_destination_id and
        a.origin_station_id == ^origin_station_id and a.wagon_id == ^wagon_id and
        a.consignee_id == ^consignee_id and a.consigner_id == ^consigner_id
    )
    |> limit(1)
    |> select([a], %{
      id: a.id,
      capture_date: a.capture_date,
      document_date: a.document_date,
      sale_order: a.sale_order
    })
    |> Repo.one()
  end

  def search_for_consignment_order_item(
        commodity_id,
        document_date,
        final_destination_id,
        origin_station_id,
        wagon_id,
        consignee_id,
        consigner_id
      ) do
    Rms.Order.Consignment
    |> where(
      [a],
      a.commodity_id == ^commodity_id and a.document_date == ^document_date and
        a.final_destination_id == ^final_destination_id and
        a.origin_station_id == ^origin_station_id and a.wagon_id == ^wagon_id and
        a.consignee_id == ^consignee_id and a.consigner_id == ^consigner_id
    )
    |> limit(1)
    |> select([a], %{
      id: a.id,
      capture_date: a.capture_date,
      document_date: a.document_date,
      sale_order: a.sale_order
    })
    |> Repo.one()
  end

  def invoice_lookup(station_code, wagon_id) do
    regex_code = prepare_regex_search_term(station_code)
    Rms.Order.Consignment
    |> where(
      [a], a.wagon_id == ^wagon_id and fragment("? like ?", a.station_code, ^regex_code) and
      a.status in ["COMPLETE", "PENDING_INVOICE"] and not is_nil(a.station_code))
    |> limit(1)
    |> select([a], %{
      id: a.id,
      capture_date: a.capture_date,
      document_date: a.document_date,
      sale_order: a.sale_order,
      capture_date: a.capture_date,
      code: a.code,
      station_code: a.station_code,
      final_destination_id: a.final_destination_id,
      origin_station_id: a.origin_station_id,
      commodity_id: a.commodity_id,
      consignee_id: a.consignee_id,
      consigner_id: a.consigner_id,
      payer_id: a.payer_id,
      wagon_id: a.wagon_id,
      actual_tonnes: a.actual_tonnes,
    })
    |> Repo.one()
  end

  def search_for_consignment_by_station_code(wagon_id, station_code) do
    regex_code = prepare_regex_search_term(station_code)

    Rms.Order.Consignment
    |> where(
      [a],
      a.wagon_id == ^wagon_id and fragment("? like ?", a.station_code, ^regex_code) and
        a.status in ["COMPLETE", "PENDING_INVOICE"]
    )
    |> limit(1)
    |> select([a], %{
      id: a.id,
      capture_date: a.capture_date,
      document_date: a.document_date,
      sale_order: a.sale_order,
      capture_date: a.capture_date,
      code: a.code,
      vat_applied: a.vat_applied,
      customer_ref: a.customer_ref,
      document_date: a.document_date,
      sale_order: a.sale_order,
      station_code: a.station_code,
      final_destination_id: a.final_destination_id,
      origin_station_id: a.origin_station_id,
      reporting_station_id: a.reporting_station_id,
      commodity_id: a.commodity_id,
      consignee_id: a.consignee_id,
      consigner_id: a.consigner_id,
      customer_id: a.customer_id,
      payer_id: a.payer_id,
      tarrif_id: a.tarrif_id,
      invoice_no: a.invoice_no
    })
    |> Repo.one()
  end

  def station_code_lookup(station_code) do
    Rms.Order.Consignment
    |> where([a], a.station_code == ^station_code)
    |> limit(1)
    |> Repo.exists?()
  end

  def search_for_consignment(wagon_id, commodity_id, consignment_date, origin_station_id, destin_station_id, consignee_id) do
    Rms.Order.Consignment
    |> where(
      [a],
      a.wagon_id == ^wagon_id and a.document_date ==^consignment_date and a.status in ["COMPLETE", "PENDING_INVOICE"]
      and a.origin_station_id ==^ origin_station_id and a.final_destination_id ==^destin_station_id
      and a.consignee_id ==^ consignee_id and a.commodity_id ==^commodity_id
    )
    |> select([a], %{
      id: a.id,
      capture_date: a.capture_date,
      document_date: a.document_date,
      sale_order: a.sale_order,
      capture_date: a.capture_date,
      code: a.code,
      vat_applied: a.vat_applied,
      customer_ref: a.customer_ref,
      document_date: a.document_date,
      station_code: a.station_code,
      final_destination_id: a.final_destination_id,
      origin_station_id: a.origin_station_id,
      reporting_station_id: a.reporting_station_id,
      commodity_id: a.commodity_id,
      consignee_id: a.consignee_id,
      consigner_id: a.consigner_id,
      customer_id: a.customer_id,
      payer_id: a.payer_id,
      tarrif_id: a.tarrif_id,
      invoice_no: a.invoice_no
    })
    |> limit(1)
    |> Repo.one()
  end

  def prepare_regex_search_term(term) do
    term
    |> String.trim()
    |> String.replace(~r/[[:blank:]]/, "")
    |> String.split("", trim: true)
    |> Enum.reduce("%", fn char, acc -> acc <> "[#{char}]" end)
  end

  def get_by_uuid(uuid) do
    Batch
    |> where([a], a.uuid == ^uuid)
    |> limit(1)
    |> Repo.one()
  end

  def get_consignment_batch_items(batch_id) do
    Rms.Order.Consignment
    |> where([a], a.batch_id == ^batch_id)
    |> Repo.all()
  end

  def get_consignment_item_by_batch_id(batch_id) do
    Rms.Order.Consignment
    |> where([a], a.batch_id == ^batch_id)
    |> limit(1)
    |> Repo.one()
  end

  # def station_code_lookup(station_code) do
  #   Rms.Order.Consignment
  #   |> where([a], a.station_code == ^station_code)
  #   |> limit(1)
  #   |> Repo.exists?()
  # end

  def consignment_dashboard_params(user) do
    "vw_consgnt_dashboard_params"
    |> join(
      :right,
      [c],
      day in fragment("""
      SELECT CAST(DATEADD(DAY, nbr - 1, DATEADD(month, DATEDIFF(month, 0, CAST(CURRENT_TIMESTAMP AS DATETIME)), 0)) AS DATE) d
      FROM (
        SELECT ROW_NUMBER() OVER (ORDER BY c.object_id) AS Nbr
        FROM sys.columns c
      ) nbrs
      WHERE nbr - 1 <= DATEDIFF(DAY, DATEADD(month, DATEDIFF(month, 0, CAST(CURRENT_TIMESTAMP AS DATETIME)), 0), EOMONTH(CAST(CURRENT_TIMESTAMP AS DATETIME)))
      """),
      on: day.d == fragment("CAST(? AS DATE)", c.inserted_at)
    )
    |> where(
      [c, day],
      c.id in subquery(
        from(t in "vw_consgnt_dashboard_params",
          where: not is_nil(t.status),
          group_by: t.batch_id,
          select: max(t.id)
        )
      )
    )
    |> group_by([c, day], [day.d, c.status])
    |> order_by([_c, day], day.d)
    |> verify_user_station_id_for_consignment(user)
    |> select([c, day], %{
      day: fragment("FORMAT (CAST(? AS DATE), 'yyyy-MM-dd')", day.d),
      count: count(c.id),
      status: c.status
    })
    |> Repo.all()
  end

  def movement_dashboard_params(user) do
    "vw_movement_dashboard_params"
    |> join(
      :right,
      [c],
      day in fragment("""
      SELECT CAST(DATEADD(DAY, nbr - 1, DATEADD(month, DATEDIFF(month, 0, CAST(CURRENT_TIMESTAMP AS DATETIME)), 0)) AS DATE) d
      FROM (
        SELECT ROW_NUMBER() OVER (ORDER BY c.object_id) AS Nbr
        FROM sys.columns c
      ) nbrs
      WHERE nbr - 1 <= DATEDIFF(DAY, DATEADD(month, DATEDIFF(month, 0, CAST(CURRENT_TIMESTAMP AS DATETIME)), 0), EOMONTH(CAST(CURRENT_TIMESTAMP AS DATETIME)))
      """),
      on: day.d == fragment("CAST(? AS DATE)", c.inserted_at)
    )
    |> where(
      [c, day],
      c.id in subquery(
        from(t in "vw_movement_dashboard_params",
          where: not is_nil(t.status),
          group_by: t.batch_id,
          select: max(t.id)
        )
      )
    )
    |> group_by([c, day], [day.d, c.status])
    |> order_by([_c, day], day.d)
    |> verify_user_station_id_for_movement(user)
    |> select([c, day], %{
      day: fragment("FORMAT (CAST(? AS DATE), 'yyyy-MM-dd')", day.d),
      count: count(c.id),
      status: c.status
    })
    |> Repo.all()
  end

  def fuel_requisite_dashboard_params(user) do
    "vw_fuel_requisite_dashboard_params"
    |> join(
      :right,
      [c],
      day in fragment("""
      SELECT CAST(DATEADD(DAY, nbr - 1, DATEADD(month, DATEDIFF(month, 0, CAST(CURRENT_TIMESTAMP AS DATETIME)), 0)) AS DATE) d
      FROM (
        SELECT ROW_NUMBER() OVER (ORDER BY c.object_id) AS Nbr
        FROM sys.columns c
      ) nbrs
      WHERE nbr - 1 <= DATEDIFF(DAY, DATEADD(month, DATEDIFF(month, 0, CAST(CURRENT_TIMESTAMP AS DATETIME)), 0), EOMONTH(CAST(CURRENT_TIMESTAMP AS DATETIME)))
      """),
      on: day.d == fragment("CAST(? AS DATE)", c.inserted_at)
    )
    |> group_by([c, day], [day.d, c.status])
    |> order_by([_c, day], day.d)
    # |> verify_user_region_id(user)
    |> verify_depo_requisites(user)
    |> select([c, day], %{
      day: fragment("FORMAT (CAST(? AS DATE), 'yyyy-MM-dd')", day.d),
      count: count(c.id),
      status: c.status
    })
    |> Repo.all()
  end

  def get_related_movement_items(
        commodity_id,
        consignment_date,
        destin_station_id,
        origin_station_id,
        wagon_id,
        consignee_id,
        consigner_id
      ) do
    Rms.Order.Movement
    |> where(
      [a],
      a.commodity_id == ^commodity_id and a.consignment_date == ^consignment_date and
        a.destin_station_id == ^destin_station_id and a.origin_station_id == ^origin_station_id and
        a.wagon_id == ^wagon_id and a.consignee_id == ^consignee_id and
        a.consigner_id == ^consigner_id
    )
    |> join(:left, [a], b in Rms.SystemUtilities.Wagon, on: a.wagon_id == b.id)
    |> join(:left, [a, b], c in Rms.SystemUtilities.WagonType, on: b.wagon_type_id == c.id)
    |> join(:left, [a, b, _c], d in Rms.Accounts.RailwayAdministrator, on: b.owner_id == d.id)
    |> join(:left, [a, _b, _c, _d], e in Rms.Accounts.Clients, on: a.consigner_id == e.id)
    |> join(:left, [a, _b, _c, _d, _e], f in Rms.Accounts.Clients, on: a.consignee_id == f.id)
    |> join(:left, [a, _b, _c, _d, _e, _f], g in Rms.Accounts.Clients, on: a.payer_id == g.id)
    |> join(:left, [a, _b, _c, _d, _e, _f, _g], h in Rms.SystemUtilities.Station,
      on: a.destin_station_id == h.id
    )
    |> join(:left, [a, _b, _c, _d, _e, _f, _g, _h], i in Rms.SystemUtilities.Station,
      on: a.origin_station_id == i.id
    )
    |> join(:left, [a, _b, _c, _d, _e, _f, _g, _h, _i], j in Rms.SystemUtilities.Commodity,
      on: a.commodity_id == j.id
    )
    |> join(:left, [a, _b, _c, _d, _e, _f, _g, _h, _i, j], k in Rms.SystemUtilities.Station,
      on: a.movement_reporting_station_id == k.id
    )
    |> select([a, b, c, d, e, f, g, h, i, j, k], %{
      id: a.id,
      wagon_id: a.wagon_id,
      origin_station_id: a.origin_station_id,
      destin_station_id: a.destin_station_id,
      commodity_id: a.commodity_id,
      netweight: a.netweight,
      consigner: a.consigner_id,
      consignee: a.consignee_id,
      container_no: a.container_no,
      sales_order: a.sales_order,
      # station_code: a.station_code,
      consignment_date: a.consignment_date,
      payer_id: a.payer_id,
      movement_date: a.movement_date,
      movement_time: a.movement_time,
      movement_reporting_station_id: a.movement_reporting_station_id,
      train_no: a.train_no,
      loco_id: a.loco_id,
      dead_loco: a.dead_loco,
      wagon_owner: d.description,
      wagon_code: b.code,
      wagon_type: c.description,
      movement_origin_id: a.movement_origin_id,
      movement_destination_id: a.movement_destination_id,
      train_list_no: a.train_list_no,
      maker_id: a.maker_id,
      checker_id: a.checker_id,
      inserted_at: a.inserted_at,
      updated_at: a.updated_at,
      payer: g.client_name,
      consigner_name: e.client_name,
      consignee_name: f.client_name,
      status: a.status,
      consignment_id: a.consignment_id,
      origin_name: i.description,
      destination_name: h.description,
      reporting_stat: k.description,
      commodity_name: j.code,
      batch_id: a.batch_id
    })
    |> limit(1)
    |> Repo.all()
  end

  alias Rms.Order.WorksOrders

  @doc """
  Returns the list of tbl_works_order_master.

  ## Examples

      iex> list_tbl_works_order_master()
      [%WorksOrders{}, ...]

  """
  def list_tbl_works_order_master do
    Repo.all(WorksOrders)
  end

  @doc """
  Gets a single works_orders.

  Raises `Ecto.NoResultsError` if the Works orders does not exist.

  ## Examples

      iex> get_works_orders!(123)
      %WorksOrders{}

      iex> get_works_orders!(456)
      ** (Ecto.NoResultsError)

  """
  def get_works_orders!(id), do: Repo.get!(WorksOrders, id)

  @doc """
  Creates a works_orders.

  ## Examples

      iex> create_works_orders(%{field: value})
      {:ok, %WorksOrders{}}

      iex> create_works_orders(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_works_orders(attrs \\ %{}) do
    %WorksOrders{}
    |> WorksOrders.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a works_orders.

  ## Examples

      iex> update_works_orders(works_orders, %{field: new_value})
      {:ok, %WorksOrders{}}

      iex> update_works_orders(works_orders, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_works_orders(%WorksOrders{} = works_orders, attrs) do
    works_orders
    |> WorksOrders.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a works_orders.

  ## Examples

      iex> delete_works_orders(works_orders)
      {:ok, %WorksOrders{}}

      iex> delete_works_orders(works_orders)
      {:error, %Ecto.Changeset{}}

  """
  def delete_works_orders(%WorksOrders{} = works_orders) do
    Repo.delete(works_orders)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking works_orders changes.

  ## Examples

      iex> change_works_orders(works_orders)
      %Ecto.Changeset{data: %WorksOrders{}}

  """
  def change_works_orders(%WorksOrders{} = works_orders, attrs \\ %{}) do
    WorksOrders.changeset(works_orders, attrs)
  end

  def works_order_report_lookup(search_params, page, size, _user) do
    WorksOrders
    |> join(:left, [a], b in Rms.SystemUtilities.Wagon, on: a.wagon_id == b.id)
    |> join(:left, [a, b], c in Rms.Accounts.RailwayAdministrator, on: b.owner_id == c.id)
    |> join(:left, [a, b, c], d in Rms.Accounts.Clients, on: a.client_id == d.id)
    |> join(:left, [a, b, c, d], e in Rms.SystemUtilities.Commodity, on: a.commodity_id == e.id)
    |> join(:left, [a, b, c, d, e], f in Rms.SystemUtilities.Station,
      on: a.origin_station_id == f.id
    )
    |> join(:left, [a, b, c, d, e, f], g in Rms.SystemUtilities.Station,
      on: a.destin_station_id == g.id
    )
    |> works_order_report_filter(search_params)
    |> compose_works_order_report_select()
    |> Repo.paginate(page: page, page_size: size)
  end

  def works_order_report_lookup(_source, search_params, _user) do
    WorksOrders
    |> join(:left, [a], b in Rms.SystemUtilities.Wagon, on: a.wagon_id == b.id)
    |> join(:left, [a, b], c in Rms.Accounts.RailwayAdministrator, on: b.owner_id == c.id)
    |> join(:left, [a, b, c], d in Rms.Accounts.Clients, on: a.client_id == d.id)
    |> join(:left, [a, b, c, d], e in Rms.SystemUtilities.Commodity, on: a.commodity_id == e.id)
    |> join(:left, [a, b, c, d, e], f in Rms.SystemUtilities.Station,
      on: a.origin_station_id == f.id
    )
    |> join(:left, [a, b, c, d, e, f], g in Rms.SystemUtilities.Station,
      on: a.destin_station_id == g.id
    )
    |> works_order_report_filter(search_params)
    |> compose_works_order_report_select()
  end

  defp works_order_report_filter(query, %{"isearch" => search_term} = search_params)
       when search_term == "" or is_nil(search_term) do
    query
    |> handle_works_order_date_filter(search_params)
    |> handle_works_orders_dept_date_filter(search_params)
    |> handle_works_order_commodity_filter(search_params)
    |> handle_works_order_origin_filter(search_params)
    |> handle_works_order_destin_filter(search_params)
    |> handle_works_order_wagon_owner_filter(search_params)
    |> handle_works_order_wagon_filter(search_params)
    |> handle_works_order_dept_time_filter(search_params)
    |> handle_works_order_order_on_filter(search_params)
    |> handle_works_order_train_no_filter(search_params)
    |> handle_works_order_client_filter(search_params)
  end

  defp works_order_report_filter(query, %{"isearch" => search_term}) do
    search_term = "%#{search_term}%"
    compose_works_order_report_isearch_filter(query, search_term)
  end

  defp handle_works_order_date_filter(query, %{"from" => from, "to" => to})
  when from == "" or is_nil(from) or to == "" or is_nil(to),
  do: query

  defp handle_works_order_date_filter(query, %{"from" => from, "to" => to}) do
    query
    |> where(
    [a],
    fragment("CAST(? AS DATE) >= ?", a.inserted_at, ^from) and
      fragment("CAST(? AS DATE) <= ?", a.inserted_at, ^to)
    )
  end

  defp handle_works_orders_dept_date_filter(query, %{
         "departure_date" => departure_date
       })
       when departure_date == "" or is_nil(departure_date),
       do: query

  defp handle_works_orders_dept_date_filter(query, %{
         "departure_date" => departure_date
       }) do
    query
    |> where(
      [a],
      fragment("CAST(? AS DATE) = ?", a.departure_date, ^departure_date)
    )
  end

  defp handle_works_order_wagon_owner_filter(query, %{"administrator_id" => admin})
       when admin == "" or is_nil(admin),
       do: query

  defp handle_works_order_wagon_owner_filter(query, %{"administrator_id" => admin}) do
    where(query, [a, b, c, d, e, f, g], b.owner_id == ^admin)
  end

  defp handle_works_order_commodity_filter(query, %{"commodity_id" => commodity_id})
       when commodity_id == "" or is_nil(commodity_id),
       do: query

  defp handle_works_order_commodity_filter(query, %{"commodity_id" => commodity_id}) do
    where(query, [a], a.commodity_id == ^commodity_id)
  end

  defp handle_works_order_origin_filter(query, %{"origin_station_id" => origin_station_id})
       when origin_station_id == "" or is_nil(origin_station_id),
       do: query

  defp handle_works_order_origin_filter(query, %{"origin_station_id" => origin_station_id}) do
    where(query, [a], a.origin_station_id == ^origin_station_id)
  end

  defp handle_works_order_destin_filter(query, %{"destin_station_id" => destin_station_id})
    when destin_station_id == "" or is_nil(destin_station_id),
    do: query

  defp handle_works_order_destin_filter(query, %{"destin_station_id" => destin_station_id}) do
    where(query, [a], a.destin_station_id == ^destin_station_id)
  end

  defp handle_works_order_wagon_filter(query, %{"wagon_code" => wagon_code})
       when wagon_code == "" or is_nil(wagon_code),
       do: query

  defp handle_works_order_wagon_filter(query, %{"wagon_code" => wagon_code}) do
    where(
      query,
      [a, b, c, d, e, f, g],
      fragment("lower(?) LIKE lower(?)", b.code, ^"%#{wagon_code}%")
    )
  end

  defp handle_works_order_dept_time_filter(query, %{"departure_time" => departure_time})
    when departure_time == "" or is_nil(departure_time),
    do: query

  defp handle_works_order_dept_time_filter(query, %{"departure_time" => departure_time}) do
    where(
      query,
      [a],
      fragment("lower(?) LIKE lower(?)", a.departure_time, ^"%#{departure_time}%")
    )
  end

  defp handle_works_order_order_on_filter(query, %{"order_no" => order_no})
    when order_no == "" or is_nil(order_no),
    do: query

  defp handle_works_order_order_on_filter(query, %{"order_no" => order_no}) do
    where(
      query,
      [a],
      fragment("lower(?) LIKE lower(?)", a.order_no, ^"%#{order_no}%")
    )
  end

  defp handle_works_order_train_no_filter(query, %{"train_no" => train_no})
    when train_no == "" or is_nil(train_no),
    do: query

  defp handle_works_order_train_no_filter(query, %{"train_no" => train_no}) do
    where(
      query,
      [a],
      fragment("lower(?) LIKE lower(?)", a.train_no, ^"%#{train_no}%")
    )
  end

  defp handle_works_order_client_filter(query, %{"client_id" => client_id})
    when client_id == "" or is_nil(client_id),
    do: query

  defp handle_works_order_client_filter(query, %{"client_id" => client_id}) do
    where(query, [a], a.client_id == ^client_id)
  end

  defp compose_works_order_report_isearch_filter(query, search_term) do
    query
    |> where(
      [a, b, c, d, e, f, g],
        fragment("lower(?) LIKE lower(?)", c.code, ^search_term) or
        fragment("lower(?) LIKE lower(?)", e.description, ^search_term) or
        fragment("lower(?) LIKE lower(?)", f.description, ^search_term) or
        fragment("lower(?) LIKE lower(?)", a.train_no, ^search_term) or
        fragment("lower(?) LIKE lower(?)", a.order_no, ^search_term) or
        fragment("lower(?) LIKE lower(?)", a.departure_time, ^search_term) or
        fragment("lower(?) LIKE lower(?)", b.code, ^search_term)
    )
  end

  def compose_works_order_report_select(query) do
    query
    |> order_by([a, b, c, d, e, f, g], desc: a.id)
    |> select([a, b, c, d, e, f, g], %{
      id: a.id,
      comment: a.comment,
      date_on_label: a.date_on_label,
      off_loading_date: a.off_loading_date,
      order_no: a.order_no,
      time_out: a.time_out,
      yard_foreman: a.yard_foreman,
      area_name: a.area_name,
      train_no: a.train_no,
      driver_name: a.driver_name,
      departure_time: a.departure_time,
      departure_date: a.departure_date,
      time_arrival: a.time_arrival,
      placed: a.placed,
      load_date: a.load_date,
      supplied: a.supplied,
      client_id: a.client_id,
      wagon_id: a.wagon_id,
      commodity_id: a.commodity_id,
      origin_station_id: a.origin_station_id,
      destin_station_id: a.destin_station_id,
      maker_id: a.maker_id,
      inserted_at: a.inserted_at,
      updated_at: a.updated_at,
      commodity: e.description,
      wagon_owner: c.code,
      wagon_code: b.code,
      client: d.client_name,
      origin_station: f.description,
      destin_station: g.description
    })
  end

  def works_order_lookup(id) do
    WorksOrders
    |> join(:left, [a], b in Rms.SystemUtilities.Wagon, on: a.wagon_id == b.id)
    |> join(:left, [a, b], c in Rms.Accounts.RailwayAdministrator, on: b.owner_id == c.id)
    |> join(:left, [a, b, c], d in Rms.Accounts.Clients, on: a.client_id == d.id)
    |> join(:left, [a, b, c, d], e in Rms.SystemUtilities.Commodity, on: a.commodity_id == e.id)
    |> join(:left, [a, b, c, d, e], f in Rms.SystemUtilities.Station,
      on: a.origin_station_id == f.id
    )
    |> join(:left, [a, b, c, d, e, f], g in Rms.SystemUtilities.Station,
      on: a.destin_station_id == g.id
    )
    |> where([a], a.id == ^id)
    |> select([a, b, c, d, e, f, g], %{
      id: a.id,
      comment: a.comment,
      date_on_label: a.date_on_label,
      off_loading_date: a.off_loading_date,
      order_no: a.order_no,
      time_out: a.time_out,
      yard_foreman: a.yard_foreman,
      area_name: a.area_name,
      train_no: a.train_no,
      driver_name: a.driver_name,
      departure_time: a.departure_time,
      departure_date: a.departure_date,
      time_arrival: a.time_arrival,
      placed: a.placed,
      load_date: a.load_date,
      supplied: a.supplied,
      client_id: a.client_id,
      wagon_id: a.wagon_id,
      commodity_id: a.commodity_id,
      origin_station_id: a.origin_station_id,
      destin_station_id: a.destin_station_id,
      maker_id: a.maker_id,
      inserted_at: a.inserted_at,
      updated_at: a.updated_at,
      commodity: e.description,
      wagon_owner: c.code,
      wagon_code: b.code,
      client: d.client_name,
      origin_station: f.description,
      destin_station: g.description
    })
    |> Repo.one()
  end

  def works_order_lookup(client_id, train_no, area_name, departure_date) do
    WorksOrders
    |> join(:left, [a], b in Rms.SystemUtilities.Wagon, on: a.wagon_id == b.id)
    |> join(:left, [a, b], c in Rms.Accounts.RailwayAdministrator, on: b.owner_id == c.id)
    |> join(:left, [a, b, c], d in Rms.Accounts.Clients, on: a.client_id == d.id)
    |> join(:left, [a, b, c, d], e in Rms.SystemUtilities.Commodity, on: a.commodity_id == e.id)
    |> join(:left, [a, b, c, d, e], f in Rms.SystemUtilities.Station,
      on: a.origin_station_id == f.id
    )
    |> join(:left, [a, b, c, d, e, f], g in Rms.SystemUtilities.Station,
      on: a.destin_station_id == g.id
    )
    |> where([a], a.client_id == ^client_id and a.train_no ==^train_no and a.area_name ==^area_name and a.departure_date ==^departure_date)
    |> select([a, b, c, d, e, f, g], %{
      id: a.id,
      comment: a.comment,
      date_on_label: a.date_on_label,
      off_loading_date: a.off_loading_date,
      order_no: a.order_no,
      time_out: a.time_out,
      yard_foreman: a.yard_foreman,
      area_name: a.area_name,
      train_no: a.train_no,
      driver_name: a.driver_name,
      departure_time: a.departure_time,
      departure_date: a.departure_date,
      time_arrival: a.time_arrival,
      placed: a.placed,
      load_date: a.load_date,
      supplied: a.supplied,
      client_id: a.client_id,
      wagon_id: a.wagon_id,
      commodity_id: a.commodity_id,
      origin_station_id: a.origin_station_id,
      destin_station_id: a.destin_station_id,
      maker_id: a.maker_id,
      inserted_at: a.inserted_at,
      updated_at: a.updated_at,
      commodity: e.description,
      wagon_owner: c.code,
      wagon_code: b.code,
      client: d.client_name,
      origin_station: f.description,
      destin_station: g.description
    })
    |> Repo.all()
  end

  def consignment_delivery_note_lookup(batch_id) do
    Rms.Order.Consignment
    |> where([a], a.batch_id ==^ batch_id)
    |> join(:left, [a], b in Rms.SystemUtilities.Wagon, on: a.wagon_id == b.id)
    |> join(:left, [a, b], c in Rms.SystemUtilities.WagonType, on: b.wagon_type_id == c.id)
    |> join(:left, [a, b, _c], d in Rms.Accounts.RailwayAdministrator, on: b.owner_id == d.id)
    |> join(:left, [a, b, _c, _d], e in Rms.SystemUtilities.Station,
      on: a.tariff_destination_id == e.id
    )
    |> join(:left, [a, b, _c, _d, _e], f in Rms.SystemUtilities.Station,
      on: a.tariff_origin_id == f.id
    )
    |> join(:left, [a, b, _c, _d, _e, _f], g in Rms.SystemUtilities.Station,
      on: a.final_destination_id == g.id
    )
    |> join(:left, [a, b, _c, _d, _e, _f, _g], h in Rms.SystemUtilities.Station,
      on: a.origin_station_id == h.id
    )
    |> join(:left, [a, b, _c, _d, _e, _f, _g, _h], i in Rms.SystemUtilities.Station,
      on: a.reporting_station_id == i.id
    )
    |> join(:left, [a, b, _c, _d, _e, _f, _g, _h, _i], j in Rms.SystemUtilities.Commodity,
      on: a.commodity_id == j.id
    )
    |> join(:left, [a, b, _c, _d, _e, _f, _g, _h, _i, _j], k in Rms.Accounts.Clients,
      on: a.consignee_id == k.id
    )
    |> join(:left, [a, b, _c, _d, _e, _f, _g, _h, _i, _j, _k], l in Rms.Accounts.Clients,
      on: a.consigner_id == l.id
    )
    |> join(:left, [a, b, _c, _d, _e, _f, _g, _h, _i, _j, _k, _l], m in Rms.Accounts.Clients,
      on: a.customer_id == m.id
    )
    |> join(:left, [a, b, _c, _d, _e, _f, _g, _h, _i, _j, _k, _l, _m], n in Rms.Accounts.Clients,
      on: a.payer_id == n.id
    )
    |> compose_consignment_delivery_note_select()
  end

  defp compose_consignment_delivery_note_select(query) do
    query
    |> order_by([a, _b, _c, _d, _e, _f, _g, _h, _i, _j, _k, _l, _m, _n],
      desc: a.inserted_at
    )
    |> select([a, b, c, d, e, f, g, h, i, j, k, l, m, n], %{
      id: a.id,
      route_id: a.route_id,
      capture_date: a.capture_date,
      code: a.code,
      customer_ref: a.customer_ref,
      amount: a.total,
      document_date: a.document_date,
      sale_order: a.sale_order,
      station_code: a.station_code,
      status: a.status,
      tariff_destination: e.description,
      tariff_origin: f.description,
      final_destination: g.description,
      origin_station: h.description,
      reporting_station: i.description,
      consignee: k.client_name,
      consigner: l.client_name,
      customer: m.client_name,
      payer: n.client_name,
      commodity: j.description,
      vat_amount: a.vat_amount,
      invoice_no: a.invoice_no,
      additional_chg: a.additional_chg,
      final_destination_id: a.final_destination_id,
      origin_station_id: a.origin_station_id,
      reporting_station_id: a.reporting_station_id,
      commodity_id: a.commodity_id,
      consignee_id: a.consignee_id,
      consigner_id: a.consigner_id,
      customer_id: a.customer_id,
      payer_id: a.payer_id,
      tarrif_id: a.tarrif_id,
      maker_id: a.maker_id,
      batch_id: a.batch_id,
      wagon_id: a.wagon_id,
      checker_id: a.checker_id,
      comment: a.comment,
      capacity_tonnes: a.capacity_tonnes,
      actual_tonnes: a.actual_tonnes,
      tariff_tonnage: a.tariff_tonnage,
      tariff_origin_id: a.tariff_origin_id,
      tariff_destination_id: a.tariff_destination_id,
      container_no: a.container_no,
      wagon_owner: d.code,
      wagon_type: c.description,
      invoice_number: a.invoice_no,
      train_number: a.invoice_no,
      move_date: a.invoice_no,
      total: a.invoice_no,
      wagon_code: b.code
    })
    |> Repo.all()
  end

end
