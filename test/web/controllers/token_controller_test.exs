defmodule HEBornMigration.Web.TokenControllerTest do

  use ExUnit.Case, async: true

  alias HEBornMigration.Web.TokenController

  describe "generate/0" do
    @tag :unit
    test "generates a token with 10 characters" do
      token = TokenController.generate()
      assert String.length(token) == 10
    end

    @tag heavy: true, timeout: 120_000
    test "generates 1.2kk tokens with zero conflicts" do
      token_count = 1_200_001

      tokens =
        for _ <- 1..token_count,
          do: TokenController.generate()

      unique_token_count =
        tokens
        |> Enum.uniq()
        |> Enum.count()

      assert 0 == (token_count - unique_token_count)
    end
  end
end
