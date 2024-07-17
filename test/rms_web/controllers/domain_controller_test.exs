defmodule RmsWeb.DomainControllerTest do
  use RmsWeb.ConnCase

  alias Rms.SystemUtilities

  @create_attrs %{code: "some code", description: "some description", status: "some status"}
  @update_attrs %{
    code: "some updated code",
    description: "some updated description",
    status: "some updated status"
  }
  @invalid_attrs %{code: nil, description: nil, status: nil}

  def fixture(:domain) do
    {:ok, domain} = SystemUtilities.create_domain(@create_attrs)
    domain
  end

  describe "index" do
    test "lists all tbl_domain", %{conn: conn} do
      conn = get(conn, Routes.domain_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Tbl domain"
    end
  end

  describe "new domain" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.domain_path(conn, :new))
      assert html_response(conn, 200) =~ "New Domain"
    end
  end

  describe "create domain" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.domain_path(conn, :create), domain: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.domain_path(conn, :show, id)

      conn = get(conn, Routes.domain_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Domain"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.domain_path(conn, :create), domain: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Domain"
    end
  end

  describe "edit domain" do
    setup [:create_domain]

    test "renders form for editing chosen domain", %{conn: conn, domain: domain} do
      conn = get(conn, Routes.domain_path(conn, :edit, domain))
      assert html_response(conn, 200) =~ "Edit Domain"
    end
  end

  describe "update domain" do
    setup [:create_domain]

    test "redirects when data is valid", %{conn: conn, domain: domain} do
      conn = put(conn, Routes.domain_path(conn, :update, domain), domain: @update_attrs)
      assert redirected_to(conn) == Routes.domain_path(conn, :show, domain)

      conn = get(conn, Routes.domain_path(conn, :show, domain))
      assert html_response(conn, 200) =~ "some updated code"
    end

    test "renders errors when data is invalid", %{conn: conn, domain: domain} do
      conn = put(conn, Routes.domain_path(conn, :update, domain), domain: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Domain"
    end
  end

  describe "delete domain" do
    setup [:create_domain]

    test "deletes chosen domain", %{conn: conn, domain: domain} do
      conn = delete(conn, Routes.domain_path(conn, :delete, domain))
      assert redirected_to(conn) == Routes.domain_path(conn, :index)

      assert_error_sent 404, fn ->
        get(conn, Routes.domain_path(conn, :show, domain))
      end
    end
  end

  defp create_domain(_) do
    domain = fixture(:domain)
    %{domain: domain}
  end
end
