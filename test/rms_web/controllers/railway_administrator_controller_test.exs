defmodule RmsWeb.RailwayAdministratorControllerTest do
  use RmsWeb.ConnCase

  alias Rms.RailwayAdministrators

  @create_attrs %{
    code: "some code",
    country: "some country",
    description: "some description",
    status: "some status"
  }
  @update_attrs %{
    code: "some updated code",
    country: "some updated country",
    description: "some updated description",
    status: "some updated status"
  }
  @invalid_attrs %{code: nil, country: nil, description: nil, status: nil}

  def fixture(:railway_administrator) do
    {:ok, railway_administrator} =
      RailwayAdministrators.create_railway_administrator(@create_attrs)

    railway_administrator
  end

  describe "index" do
    test "lists all tbl_railway_administrator", %{conn: conn} do
      conn = get(conn, Routes.railway_administrator_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Tbl railway administrator"
    end
  end

  describe "new railway_administrator" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.railway_administrator_path(conn, :new))
      assert html_response(conn, 200) =~ "New Railway administrator"
    end
  end

  describe "create railway_administrator" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn =
        post(conn, Routes.railway_administrator_path(conn, :create),
          railway_administrator: @create_attrs
        )

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.railway_administrator_path(conn, :show, id)

      conn = get(conn, Routes.railway_administrator_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Railway administrator"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn =
        post(conn, Routes.railway_administrator_path(conn, :create),
          railway_administrator: @invalid_attrs
        )

      assert html_response(conn, 200) =~ "New Railway administrator"
    end
  end

  describe "edit railway_administrator" do
    setup [:create_railway_administrator]

    test "renders form for editing chosen railway_administrator", %{
      conn: conn,
      railway_administrator: railway_administrator
    } do
      conn = get(conn, Routes.railway_administrator_path(conn, :edit, railway_administrator))
      assert html_response(conn, 200) =~ "Edit Railway administrator"
    end
  end

  describe "update railway_administrator" do
    setup [:create_railway_administrator]

    test "redirects when data is valid", %{
      conn: conn,
      railway_administrator: railway_administrator
    } do
      conn =
        put(conn, Routes.railway_administrator_path(conn, :update, railway_administrator),
          railway_administrator: @update_attrs
        )

      assert redirected_to(conn) ==
               Routes.railway_administrator_path(conn, :show, railway_administrator)

      conn = get(conn, Routes.railway_administrator_path(conn, :show, railway_administrator))
      assert html_response(conn, 200) =~ "some updated code"
    end

    test "renders errors when data is invalid", %{
      conn: conn,
      railway_administrator: railway_administrator
    } do
      conn =
        put(conn, Routes.railway_administrator_path(conn, :update, railway_administrator),
          railway_administrator: @invalid_attrs
        )

      assert html_response(conn, 200) =~ "Edit Railway administrator"
    end
  end

  describe "delete railway_administrator" do
    setup [:create_railway_administrator]

    test "deletes chosen railway_administrator", %{
      conn: conn,
      railway_administrator: railway_administrator
    } do
      conn = delete(conn, Routes.railway_administrator_path(conn, :delete, railway_administrator))
      assert redirected_to(conn) == Routes.railway_administrator_path(conn, :index)

      assert_error_sent 404, fn ->
        get(conn, Routes.railway_administrator_path(conn, :show, railway_administrator))
      end
    end
  end

  defp create_railway_administrator(_) do
    railway_administrator = fixture(:railway_administrator)
    %{railway_administrator: railway_administrator}
  end
end
