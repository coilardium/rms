defmodule RmsWeb.MovementExceptionControllerTest do
  use RmsWeb.ConnCase

  alias Rms.MovementExceptions

  @create_attrs %{
    axles: "120.5",
    capture_date: ~D[2010-04-17],
    derailment: "120.5",
    empty_wagons: "120.5",
    light_engines: "120.5",
    status: "some status"
  }
  @update_attrs %{
    axles: "456.7",
    capture_date: ~D[2011-05-18],
    derailment: "456.7",
    empty_wagons: "456.7",
    light_engines: "456.7",
    status: "some updated status"
  }
  @invalid_attrs %{
    axles: nil,
    capture_date: nil,
    derailment: nil,
    empty_wagons: nil,
    light_engines: nil,
    status: nil
  }

  def fixture(:movement_exception) do
    {:ok, movement_exception} = MovementExceptions.create_movement_exception(@create_attrs)
    movement_exception
  end

  describe "index" do
    test "lists all tbl_mvt_exceptions", %{conn: conn} do
      conn = get(conn, Routes.movement_exception_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Tbl mvt exceptions"
    end
  end

  describe "new movement_exception" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.movement_exception_path(conn, :new))
      assert html_response(conn, 200) =~ "New Movement exception"
    end
  end

  describe "create movement_exception" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn =
        post(conn, Routes.movement_exception_path(conn, :create),
          movement_exception: @create_attrs
        )

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.movement_exception_path(conn, :show, id)

      conn = get(conn, Routes.movement_exception_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Movement exception"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn =
        post(conn, Routes.movement_exception_path(conn, :create),
          movement_exception: @invalid_attrs
        )

      assert html_response(conn, 200) =~ "New Movement exception"
    end
  end

  describe "edit movement_exception" do
    setup [:create_movement_exception]

    test "renders form for editing chosen movement_exception", %{
      conn: conn,
      movement_exception: movement_exception
    } do
      conn = get(conn, Routes.movement_exception_path(conn, :edit, movement_exception))
      assert html_response(conn, 200) =~ "Edit Movement exception"
    end
  end

  describe "update movement_exception" do
    setup [:create_movement_exception]

    test "redirects when data is valid", %{conn: conn, movement_exception: movement_exception} do
      conn =
        put(conn, Routes.movement_exception_path(conn, :update, movement_exception),
          movement_exception: @update_attrs
        )

      assert redirected_to(conn) ==
               Routes.movement_exception_path(conn, :show, movement_exception)

      conn = get(conn, Routes.movement_exception_path(conn, :show, movement_exception))
      assert html_response(conn, 200) =~ "some updated status"
    end

    test "renders errors when data is invalid", %{
      conn: conn,
      movement_exception: movement_exception
    } do
      conn =
        put(conn, Routes.movement_exception_path(conn, :update, movement_exception),
          movement_exception: @invalid_attrs
        )

      assert html_response(conn, 200) =~ "Edit Movement exception"
    end
  end

  describe "delete movement_exception" do
    setup [:create_movement_exception]

    test "deletes chosen movement_exception", %{
      conn: conn,
      movement_exception: movement_exception
    } do
      conn = delete(conn, Routes.movement_exception_path(conn, :delete, movement_exception))
      assert redirected_to(conn) == Routes.movement_exception_path(conn, :index)

      assert_error_sent 404, fn ->
        get(conn, Routes.movement_exception_path(conn, :show, movement_exception))
      end
    end
  end

  defp create_movement_exception(_) do
    movement_exception = fixture(:movement_exception)
    %{movement_exception: movement_exception}
  end
end
