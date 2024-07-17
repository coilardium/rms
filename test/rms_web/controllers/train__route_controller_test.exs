defmodule RmsWeb.Train_RouteControllerTest do
  use RmsWeb.ConnCase

  alias Rms.Train_Routes

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

  def fixture(:train__route) do
    {:ok, train__route} = Train_Routes.create_train__route(@create_attrs)
    train__route
  end

  describe "index" do
    test "lists all tbl_train_routes", %{conn: conn} do
      conn = get(conn, Routes.train__route_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Tbl train routes"
    end
  end

  describe "new train__route" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.train__route_path(conn, :new))
      assert html_response(conn, 200) =~ "New Train  route"
    end
  end

  describe "create train__route" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.train__route_path(conn, :create), train__route: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.train__route_path(conn, :show, id)

      conn = get(conn, Routes.train__route_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Train  route"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.train__route_path(conn, :create), train__route: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Train  route"
    end
  end

  describe "edit train__route" do
    setup [:create_train__route]

    test "renders form for editing chosen train__route", %{conn: conn, train__route: train__route} do
      conn = get(conn, Routes.train__route_path(conn, :edit, train__route))
      assert html_response(conn, 200) =~ "Edit Train  route"
    end
  end

  describe "update train__route" do
    setup [:create_train__route]

    test "redirects when data is valid", %{conn: conn, train__route: train__route} do
      conn =
        put(conn, Routes.train__route_path(conn, :update, train__route),
          train__route: @update_attrs
        )

      assert redirected_to(conn) == Routes.train__route_path(conn, :show, train__route)

      conn = get(conn, Routes.train__route_path(conn, :show, train__route))
      assert html_response(conn, 200) =~ "some updated code"
    end

    test "renders errors when data is invalid", %{conn: conn, train__route: train__route} do
      conn =
        put(conn, Routes.train__route_path(conn, :update, train__route),
          train__route: @invalid_attrs
        )

      assert html_response(conn, 200) =~ "Edit Train  route"
    end
  end

  describe "delete train__route" do
    setup [:create_train__route]

    test "deletes chosen train__route", %{conn: conn, train__route: train__route} do
      conn = delete(conn, Routes.train__route_path(conn, :delete, train__route))
      assert redirected_to(conn) == Routes.train__route_path(conn, :index)

      assert_error_sent 404, fn ->
        get(conn, Routes.train__route_path(conn, :show, train__route))
      end
    end
  end

  defp create_train__route(_) do
    train__route = fixture(:train__route)
    %{train__route: train__route}
  end
end
