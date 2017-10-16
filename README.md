# Contentful Delivery SDK

Elixir client for the [Contentful](https://www.contentful.com) Content Delivery API.

[Contentful](https://www.contentful.com) is a content management platform for web applications, mobile apps and connected devices. It allows you to create, edit & manage content in the cloud and publish it anywhere via powerful API. Contentful offers tools for managing editorial teams and enabling cooperation between organizations.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add contentful to your list of dependencies in `mix.exs`:

        def deps do
          [{:contentful, "~> 0.1.0"}]
        end

  2. Ensure contentful is started before your application:

        def application do
          [applications: [:contentful]]
        end


## Usage

All request accept an extra parameter for request parameters.

### Entries

* All Entries:

```elixir
SPACE_ID = "my_space_id"
ACCESS_TOKEN = "my_access_token"

entries = Contentful.Delivery.entries(SPACE_ID, ACCESS_TOKEN)

# Printing Content Type ID for every entry
Enum.each(entries, fn (entry) -> IO.puts(entry["sys"]["contentType"]["sys"]["id"]) end)
```

* Single Entry:

```elixir
SPACE_ID = "my_space_id"
ACCESS_TOKEN = "my_access_token"
ENTRY_ID = "my_entry_id"

entry = Contentful.Delivery.entry(SPACE_ID, ACCESS_TOKEN, ENTRY_ID)
```

* Search Parameters

```elixir
SPACE_ID = "my_space_id"
ACCESS_TOKEN = "my_access_token"
SEARCH_PARAMS = %{
  "query" => "Some Fancy Text",
  "content_type" => "cat"
}

entries = Contentful.Delivery.entries(SPACE_ID, ACCESS_TOKEN, SEARCH_PARAMS)
```

### Assets

* All Assets:

```elixir
SPACE_ID = "my_space_id"
ACCESS_TOKEN = "my_access_token"

assets = Contentful.Delivery.assets(SPACE_ID, ACCESS_TOKEN)
```

* Single Asset:

```elixir
SPACE_ID = "my_space_id"
ACCESS_TOKEN = "my_access_token"
ASSET_ID = "my_asset_id"

asset = Contentful.Delivery.asset(SPACE_ID, ACCESS_TOKEN, ASSET_ID)
```

### Content Types

* All Content Types:

```elixir
SPACE_ID = "my_space_id"
ACCESS_TOKEN = "my_access_token"

content_types = Contentful.Delivery.content_types(SPACE_ID, ACCESS_TOKEN)
```

* Single Content Type:

```elixir
SPACE_ID = "my_space_id"
ACCESS_TOKEN = "my_access_token"
CONTENT_TYPE_ID = "my_content_type_id"

content_type = Contentful.Delivery.content_type(SPACE_ID, ACCESS_TOKEN, CONTENT_TYPE_ID)
```

### Space

```elixir
SPACE_ID = "my_space_id"
ACCESS_TOKEN = "my_access_token"

space = Contentful.Delivery.space(SPACE_ID, ACCESS_TOKEN)
```

### Delivery vs Preview

Delivery and Preview modules implement the same set of functions but refer to two different endpoints.
The Delivery endpoint is set to cdn.contentful.com which delivers content in published state.
The Preview endpoint is set to preview.contentful.com which delivers both published and draft content and is useful to preview changes.


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
