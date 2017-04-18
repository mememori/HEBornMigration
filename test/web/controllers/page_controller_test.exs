defmodule HEBornMigration.Web.PageControllerTest do
  use HEBornMigration.Web.ConnCase, async: true

  alias HEBornMigration.Repo
  # alias HEBornMigration.Web.Account

  alias HEBornMigration.Factory

  @moduletag :integration

  def get_token(conn) do
    result =
      conn
      |> get("/claim/username")
      |> json_response(200)

    result["token"]
  end

  describe "GET /" do
    test "returns the home page", %{conn: conn} do
      conn = get conn, "/"
      assert html_response(conn, 200) =~ "Migrate"
    end
  end

  describe "POST /" do
    test "succeeds returning the migration in progress page", %{conn: conn} do
      token = get_token(conn)

      params = %{
        account: %{
          token: token,
          email: "example@email.com",
          password: "12345678",
          password_confirmation: "12345678",
        }
      }

      conn = post(conn, "/", params)
      assert html_response(conn, 200) =~ "almost ready!"
    end

    test "fails returning the home page with input errors", %{conn: conn} do
      params = %{
        account: %{
          token: "",
          email: "",
          password: "",
          password_confirmation: "12345678",
        }
      }

      conn = post(conn, "/", params)
      assert html_response(conn, 200) =~ "Migrate"
    end
  end

  describe "GET /confirm" do
    test "returns the confirmation page", %{conn: conn} do
      conn = get conn, "/confirm"
      assert html_response(conn, 200) =~ "Confirm your account migration"
    end
  end

  describe "POST /confirm" do
    test "succeeds returning the migration completed page", %{conn: conn} do
      code =
        :account
        |> Factory.insert()
        |> Repo.preload(:confirmation)
        |> Map.fetch!(:confirmation)
        |> Map.fetch!(:code)

      params = %{confirmation: %{code: code}}

      conn = post(conn, "/confirm", params)
      assert html_response(conn, 200) =~ "migration completed"
    end

    test "fails returning the confirm page with input errors", %{conn: conn} do
      params = %{confirmation: %{code: ""}}

      conn = post(conn, "/confirm", params)
      assert html_response(conn, 200) =~ "Confirm your account migration"
    end
  end

  describe "GET /claim/:username" do
    test "succeeds returning a json with the token", %{conn: conn} do
      conn = get conn, "/claim/username"
      assert %{"token" => _} = json_response(conn, 200)
    end

    test "fails returning json with the errors", %{conn: conn} do
      conn = get conn, "/claim/@invalid~username"
      assert %{"errors" => _} = json_response(conn, 422)
    end
  end

  describe "GET /confirm/:code" do
    test "succeeds returning the migration completed page", %{conn: conn} do
      code =
        :account
        |> Factory.insert()
        |> Repo.preload(:confirmation)
        |> Map.fetch!(:confirmation)
        |> Map.fetch!(:code)

      conn = get(conn, "/confirm/#{code}")
      assert html_response(conn, 200) =~ "migration completed"
    end

    test "fails returning the confirm page with input errors", %{conn: conn} do
      conn = get(conn, "/confirm/0")
      assert html_response(conn, 200) =~ "Confirm your account migration"
    end
  end
end
