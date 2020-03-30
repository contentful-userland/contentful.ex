defmodule Contentful.ContentTypeTest do
  use ExUnit.Case
  alias Contentful.ContentType
  alias Contentful.ContentType.Field

  doctest ContentType

  describe ".display_field" do
    test "will return the display field from the content type fields" do
      [_, _, field_2] =
        fields = [
          %Field{name: "barfoo"},
          %Field{name: "foobaz"},
          %Field{name: "foobar"}
        ]

      ct = %ContentType{display_field: "foobar", fields: fields}

      assert ct |> ContentType.display_field() == field_2
    end
  end
end
