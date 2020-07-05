defmodule Contentful.QueryTest do
  use ExUnit.Case

  alias Contentful.Delivery.{Assets, Entries}
  alias Contentful.Query

  describe "include/2" do
    test "throws an error when being passed an argument greater 10" do
      assert_raise(ArgumentError, fn ->
        Entries |> Query.include(999) |> Query.fetch_all()
      end)
    end

    test "will omit the argument if the queryable passed is not Entries" do
      Assets = Assets |> Query.include(2)
    end

    test "will add the argument as an include parameter" do
      {Entries, include: 2} = Entries |> Query.include(2)
    end

    test "will preserve chained arguments" do
      {Entries, include: 2, limit: 4} = Entries |> Query.limit(4) |> Query.include(2)
    end
  end

  describe "by/2" do
    test "throws an error when used for entries without a content_type call before" do
      assert_raise(ArgumentError, fn ->
        Entries |> Query.by(id: "foobar")
      end)
    end

    test "throws no error when used for entries with a content_type" do
      {Entries,
       [
         {:select_params, [id: "foobar"]},
         {:content_type, "car"}
       ]} = Entries |> Query.content_type("car") |> Query.by(id: "foobar")
    end

    test "allows passing multiple fields into it" do
      {Entries,
       [
         select_params: [id: "foobar", name: [ne: "Mercedes"]],
         content_type: "car"
       ]} =
        Entries
        |> Query.content_type("car")
        |> Query.by(id: "foobar", name: [ne: "Mercedes"])
    end
  end
end
