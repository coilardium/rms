defmodule RmsWeb.RouteControllerTest do
  use RmsWeb.ConnCase

  alias Rms.Routes

  @create_attrs %{
    code: "some code",
    description: "some description",
    destination_station: "some destination_station",
    distance: "some distance",
    operator: "some operator",
    origin_station: "some origin_station",
    status: "some status",
    transport_type: "some transport_type"
  }
  @update_attrs %{
    code: "some updated code",
    description: "some updated description",
    destination_station: "some updated destination_station",
    distance: "some updated distance",
    operator: "some updated operator",
    origin_station: "some updated origin_station",
    status: "some updated status",
    transport_type: "some updated transport_type"
  }
  @invalid_attrs %{
    code: nil,
    description: nil,
    destination_station: nil,
    distance: nil,
    operator: nil,
    origin_station: nil,
    status: nil,
    transport_type: nil
  }

  def fixture(:route) do
    {:ok, route} = Routes.create_route(@create_attrs)
    route
  end

  describe "index" do
    test "lists all tbl_routes", %{conn: conn} do
      conn = get(conn, Routes.route_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Tbl routes"
    end
  end

  describe "new route" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.route_path(conn, :new))
      assert html_response(conn, 200) =~ "New Route"
    end
  end

  describe "create route" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.route_path(conn, :create), route: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.route_path(conn, :show, id)

      conn = get(conn, Routes.route_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Route"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.route_path(conn, :create), route: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Route"
    end
  end

  describe "edit route" do
    setup [:create_route]

    test "renders form for editing chosen route", %{conn: conn, route: route} do
      conn = get(conn, Routes.route_path(conn, :edit, route))
      assert html_response(conn, 200) =~ "Edit Route"
    end
  end

  describe "update route" do
    setup [:create_route]

    test "redirects when data is valid", %{conn: conn, route: route} do
      conn = put(conn, Routes.route_path(conn, :update, route), route: @update_attrs)
      assert redirected_to(conn) == Routes.route_path(conn, :show, route)

      conn = get(conn, Routes.route_path(conn, :show, route))
      assert html_response(conn, 200) =~ "some updated code"
    end

    test "renders errors when data is invalid", %{conn: conn, route: route} do
      conn = put(conn, Routes.route_path(conn, :update, route), route: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Route"
    end
  end

  describe "delete route" do
    setup [:create_route]

    test "deletes chosen route", %{conn: conn, route: route} do
      conn = delete(conn, Routes.route_path(conn, :delete, route))
      assert redirected_to(conn) == Routes.route_path(conn, :index)

      assert_error_sent 404, fn ->
        get(conn, Routes.route_path(conn, :show, route))
      end
    end
  end

  defp create_route(_) do
    route = fixture(:route)
    %{route: route}
  end
end
