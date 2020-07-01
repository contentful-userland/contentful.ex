defmodule Contentful.Entry.AssetResolverTest do
  use ExUnit.Case

  alias Contentful.{Entry, SysData}
  alias Contentful.Entry.AssetResolver

  describe "find_linked_asset_ids/1" do
    test "resolves simple ids from fields" do
      entry = %Entry{
        assets: [],
        fields: %{
          "image" => %{
            "sys" => %{
              "id" => "5ECf6ltDUOnX441PtBR8Wk",
              "linkType" => "Asset",
              "type" => "Link"
            }
          },
          "name" => "A standard category"
        },
        sys: %SysData{
          id: "4RPjazUzQMqemyNlcD3b9i",
          revision: 2,
          version: nil
        }
      }

      ["5ECf6ltDUOnX441PtBR8Wk"] = entry |> AssetResolver.find_linked_asset_ids()
    end

    test "resolves ids nested in complex fields" do
      entry = %Entry{
        assets: [],
        fields: %{
          "description" => %{
            "content" => [
              %{
                "content" => [
                  %{
                    "data" => %{},
                    "marks" => [],
                    "nodeType" => "text",
                    "value" => "as seen in Zoolander."
                  }
                ],
                "data" => %{},
                "nodeType" => "paragraph"
              },
              %{
                "content" => [
                  %{
                    "data" => %{},
                    "marks" => [],
                    "nodeType" => "text",
                    "value" => "Also:"
                  }
                ],
                "data" => %{},
                "nodeType" => "paragraph"
              },
              %{
                "content" => [],
                "data" => %{
                  "target" => %{
                    "sys" => %{
                      "id" => "5UeyMKZrmqMYyMMJvCP3Ls",
                      "linkType" => "Entry",
                      "type" => "Link"
                    }
                  }
                },
                "nodeType" => "embedded-entry-block"
              },
              %{
                "content" => [],
                "data" => %{
                  "target" => %{
                    "sys" => %{
                      "id" => "577fpmbIfYD71VCjCpYA84",
                      "linkType" => "Asset",
                      "type" => "Link"
                    }
                  }
                },
                "nodeType" => "embedded-asset-block"
              },
              %{
                "content" => [
                  %{"data" => %{}, "marks" => [], "nodeType" => "text", "value" => ""}
                ],
                "data" => %{},
                "nodeType" => "paragraph"
              }
            ],
            "data" => %{},
            "nodeType" => "document"
          },
          "image" => %{
            "sys" => %{
              "id" => "5ECf6ltDUOnX441PtBR8Wk",
              "linkType" => "Asset",
              "type" => "Link"
            }
          },
          "name" => "Blue steel",
          "price" => 12,
          "sku" => 1234,
          "stock" => 12
        },
        sys: %SysData{
          id: "5UeyMKZrmqMYyMMJvCP3Ls",
          revision: 6,
          version: nil
        }
      }

      ["5ECf6ltDUOnX441PtBR8Wk", "577fpmbIfYD71VCjCpYA84"] =
        entry |> AssetResolver.find_linked_asset_ids()
    end

    test "does not choke up on contentful taglist (list of bitstrings)" do
      entry = %Entry{
        assets: [],
        fields: %{
          "my-tags" => ["hello", "world"]
        }
      }

      [] = entry |> AssetResolver.find_linked_asset_ids()
    end
  end
end
