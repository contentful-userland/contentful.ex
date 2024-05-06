defmodule Contentful.Entry.LinkResolverTest do
  use ExUnit.Case

  alias Contentful.Asset
  alias Contentful.Entry.LinkResolver
  alias Contentful.{Entry, SysData, ContentType}

  describe "replace_in_situ/2" do
    test "Entry with no links returns unchanged Entry" do
      includes = %{
        "Entry" => [
          %{
            "fields" => %{
              "company" => "ACME",
              "email" => "john@doe.com",
              "facebook" => "johndoe"
            },
            "sys" => %{
              "contentType" => %{
                "sys" => %{
                  "id" => "person",
                  "linkType" => "ContentType",
                  "type" => "Link"
                }
              },
              "id" => "15jwOBqpxqSAOy2eOO4S0m",
              "type" => "Entry",
              "updatedAt" => "2020-04-18T18:44:10.435Z"
            }
          }
        ]
      }

      %Entry{} = %Entry{} |> LinkResolver.replace_in_situ(includes)
    end

    test "empty includes returns unchanged Entry" do
      entry = %Entry{
        fields: %{
          "author" => %{
            "sys" => %{
              "id" => "15jwOBqpxqSAOy2eOO4S0m",
              "linkType" => "Entry",
              "type" => "Link"
            }
          }
        },
        sys: %SysData{
          id: "2PtC9h1YqIA6kaUaIsWEQ0",
          revision: 2,
          locale: "en-US",
          updated_at: "2020-04-18T18:44:10.843Z",
          created_at: "2019-03-22T08:33:45.069Z",
          content_type: %ContentType{id: "blogPost"}
        }
      }

      ^entry = entry |> LinkResolver.replace_in_situ(%{})
    end

    test "links found in 'includes' are resolved in entry, others not found are left unchanged" do
      entry = %Entry{
        fields: %{
          "author" => %{
            "sys" => %{
              "id" => "15jwOBqpxqSAOy2eOO4S0m",
              "linkType" => "Entry",
              "type" => "Link"
            }
          },
          "heroImage" => %{
            "sys" => %{
              "id" => "4NzwDSDlGECGIiokKomsyI",
              "linkType" => "Asset",
              "type" => "Link"
            }
          }
        },
        sys: %SysData{
          id: "2PtC9h1YqIA6kaUaIsWEQ0",
          revision: 2,
          locale: "en-US",
          updated_at: "2020-04-18T18:44:10.843Z",
          created_at: "2019-03-22T08:33:45.069Z",
          content_type: %ContentType{id: "blogPost"}
        }
      }

      includes = %{
        "Entry" => [
          %{
            "fields" => %{
              "company" => "ACME",
              "email" => "john@doe.com",
              "name" => "John Doe"
            },
            "sys" => %{
              "contentType" => %{
                "sys" => %{
                  "id" => "person",
                  "linkType" => "ContentType",
                  "type" => "Link"
                }
              },
              "id" => "15jwOBqpxqSAOy2eOO4S0m",
              "type" => "Entry",
              "revision" => 2,
              "createdAt" => "2019-03-22T08:33:44.329Z",
              "updatedAt" => "2020-04-18T18:44:10.435Z",
              "locale" => "en-US"
            }
          }
        ]
      }

      %Entry{
        sys: %SysData{
          id: "2PtC9h1YqIA6kaUaIsWEQ0",
          revision: 2,
          created_at: "2019-03-22T08:33:45.069Z",
          updated_at: "2020-04-18T18:44:10.843Z",
          locale: "en-US",
          content_type: %ContentType{
            id: "blogPost"
          }
        },
        fields: %{
          "author" => %Entry{
            sys: %SysData{
              id: "15jwOBqpxqSAOy2eOO4S0m",
              revision: 2,
              created_at: "2019-03-22T08:33:44.329Z",
              updated_at: "2020-04-18T18:44:10.435Z",
              locale: "en-US",
              content_type: %ContentType{
                id: "person"
              }
            },
            fields: %{"company" => "ACME", "email" => "john@doe.com", "name" => "John Doe"}
          },
          "heroImage" => %{
            "sys" => %{
              "id" => "4NzwDSDlGECGIiokKomsyI",
              "linkType" => "Asset",
              "type" => "Link"
            }
          }
        }
      } = entry |> LinkResolver.replace_in_situ(includes)
    end

    test "resolves links nested in complex fields" do
      entry = %Entry{
        fields: %{
          "author" => %{
            "sys" => %{
              "id" => "15jwOBqpxqSAOy2eOO4S0m",
              "linkType" => "Entry",
              "type" => "Link"
            }
          },
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
                "content" => [],
                "data" => %{
                  "target" => %{
                    "sys" => %{
                      "id" => "7orLdboQQowIUs22KAW4U",
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
          }
        },
        sys: %SysData{
          id: "2PtC9h1YqIA6kaUaIsWEQ0",
          revision: 2,
          locale: "en-US",
          updated_at: "2020-04-18T18:44:10.843Z",
          created_at: "2019-03-22T08:33:45.069Z",
          content_type: %ContentType{id: "blogPost"}
        }
      }

      includes = %{
        "Entry" => [
          %{
            "fields" => %{
              "company" => "ACME",
              "email" => "john@doe.com",
              "name" => "John Doe",
              "image" => %{
                "sys" => %{
                  "type" => "Link",
                  "linkType" => "Asset",
                  "id" => "7orLdboQQowIUs22KAW4U"
                }
              }
            },
            "sys" => %{
              "contentType" => %{
                "sys" => %{
                  "id" => "person",
                  "linkType" => "ContentType",
                  "type" => "Link"
                }
              },
              "id" => "15jwOBqpxqSAOy2eOO4S0m",
              "type" => "Entry",
              "revision" => 2,
              "createdAt" => "2019-03-22T08:33:44.329Z",
              "updatedAt" => "2020-04-18T18:44:10.435Z",
              "locale" => "en-US"
            }
          }
        ],
        "Asset" => [
          %{
            "metadata" => %{
              "tags" => []
            },
            "sys" => %{
              "space" => %{
                "sys" => %{
                  "type" => "Link",
                  "linkType" => "Space",
                  "id" => "gtrsnz13drim"
                }
              },
              "id" => "7orLdboQQowIUs22KAW4U",
              "type" => "Asset",
              "createdAt" => "2019-03-22T08:33:38.110Z",
              "updatedAt" => "2020-04-18T18:44:04.820Z",
              "environment" => %{
                "sys" => %{
                  "id" => "master",
                  "type" => "Link",
                  "linkType" => "Environment"
                }
              },
              "revision" => 2,
              "locale" => "en-US"
            },
            "fields" => %{
              "title" => "Sparkler",
              "description" => "John with Sparkler",
              "file" => %{
                "url" =>
                  "//images.ctfassets.net/gtrsnz13drim/7orLdboQQowIUs22KAW4U/ae1e04accdfcf6c3def7a449d12bff4c/matt-palmer-254999.jpg",
                "details" => %{
                  "size" => 2_293_094,
                  "image" => %{
                    "width" => 3000,
                    "height" => 2000
                  }
                },
                "fileName" => "matt-palmer-254999.jpg",
                "contentType" => "image/jpeg"
              }
            }
          }
        ]
      }

      %Entry{
        sys: %SysData{
          id: "2PtC9h1YqIA6kaUaIsWEQ0",
          revision: 2,
          created_at: "2019-03-22T08:33:45.069Z",
          updated_at: "2020-04-18T18:44:10.843Z",
          locale: "en-US",
          content_type: %ContentType{
            id: "blogPost"
          }
        },
        fields: %{
          "author" => %Entry{
            sys: %SysData{
              id: "15jwOBqpxqSAOy2eOO4S0m",
              revision: 2,
              created_at: "2019-03-22T08:33:44.329Z",
              updated_at: "2020-04-18T18:44:10.435Z",
              locale: "en-US",
              content_type: %ContentType{
                id: "person"
              }
            },
            fields: %{
              "company" => "ACME",
              "email" => "john@doe.com",
              "name" => "John Doe",
              "image" => %Asset{
                sys: %SysData{
                  id: "7orLdboQQowIUs22KAW4U"
                },
                fields: %Asset.Fields{
                  title: "Sparkler",
                  description: "John with Sparkler",
                  file: %{
                    content_type: "image/jpeg",
                    details: %{
                      "image" => %{
                        "height" => 2000,
                        "width" => 3000
                      },
                      "size" => 2_293_094
                    },
                    file_name: "matt-palmer-254999.jpg",
                    url: %URI{
                      host: "images.ctfassets.net",
                      path:
                        "/gtrsnz13drim/7orLdboQQowIUs22KAW4U/ae1e04accdfcf6c3def7a449d12bff4c/matt-palmer-254999.jpg"
                    }
                  }
                }
              }
            }
          },
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
                "content" => [],
                "data" => %{
                  "target" => %Asset{
                    sys: %SysData{
                      id: "7orLdboQQowIUs22KAW4U"
                    },
                    fields: %Asset.Fields{
                      title: "Sparkler",
                      description: "John with Sparkler",
                      file: %{
                        content_type: "image/jpeg",
                        details: %{
                          "image" => %{
                            "height" => 2000,
                            "width" => 3000
                          },
                          "size" => 2_293_094
                        },
                        file_name: "matt-palmer-254999.jpg",
                        url: %URI{
                          host: "images.ctfassets.net",
                          path:
                            "/gtrsnz13drim/7orLdboQQowIUs22KAW4U/ae1e04accdfcf6c3def7a449d12bff4c/matt-palmer-254999.jpg"
                        }
                      }
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
          }
        }
      } = entry |> LinkResolver.replace_in_situ(includes)
    end

    test "ignores unknown LinkTypes we don't know how to parse even if matching entity exists in includes" do
      entry = %Entry{
        fields: %{
          "author" => %{
            "sys" => %{
              "id" => "15jwOBqpxqSAOy2eOO4S0m",
              "linkType" => "Unknown",
              "type" => "Link"
            }
          }
        },
        sys: %SysData{
          id: "2PtC9h1YqIA6kaUaIsWEQ0",
          revision: 2,
          locale: "en-US",
          updated_at: "2020-04-18T18:44:10.843Z",
          created_at: "2019-03-22T08:33:45.069Z",
          content_type: %ContentType{id: "blogPost"}
        }
      }

      includes = %{
        "Unknown" => [
          %{
            "fields" => %{
              "company" => "ACME",
              "email" => "john@doe.com",
              "facebook" => "johndoe"
            },
            "sys" => %{
              "contentType" => %{
                "sys" => %{
                  "id" => "person",
                  "linkType" => "ContentType",
                  "type" => "Link"
                }
              },
              "id" => "15jwOBqpxqSAOy2eOO4S0m",
              "type" => "Entry",
              "updatedAt" => "2020-04-18T18:44:10.435Z"
            }
          }
        ]
      }

      ^entry = entry |> LinkResolver.replace_in_situ(includes)
    end

    test "resolves nested links within lists of Entries" do
      entry = %Entry{
        fields: %{
          "blocks" => [
            %{
              "sys" => %{
                "id" => "2IqBemFvusQUTEcnB93jDO",
                "linkType" => "Entry",
                "type" => "Link"
              }
            }
          ],
          "slug" => "my-page-with-content-blocks",
          "title" => "My Page with Content Blocks"
        },
        sys: %SysData{
          id: "2PtC9h1YqIA6kaUaIsWEQ0",
          revision: 2,
          locale: "en-US",
          updated_at: "2020-04-18T18:44:10.843Z",
          created_at: "2019-03-22T08:33:45.069Z",
          content_type: %ContentType{id: "page"}
        }
      }

      includes = %{
        "Entry" => [
          %{
            "fields" => %{
              "features" => [
                %{
                  "sys" => %{
                    "id" => "7nPDsIzj69Ey8RRvjRh5yT",
                    "linkType" => "Entry",
                    "type" => "Link"
                  }
                },
                %{
                  "sys" => %{
                    "id" => "2VzTGEENSvxVZbfnxDJv2C",
                    "linkType" => "Entry",
                    "type" => "Link"
                  }
                }
              ],
              "title" => "Some features"
            },
            "sys" => %{
              "contentType" => %{
                "sys" => %{
                  "id" => "blockIcons",
                  "linkType" => "ContentType",
                  "type" => "Link"
                }
              },
              "createdAt" => "2024-04-27T13:09:31.838Z",
              "id" => "2IqBemFvusQUTEcnB93jDO",
              "locale" => "en-GB",
              "revision" => 1,
              "type" => "Entry",
              "updatedAt" => "2024-04-27T13:55:14.757Z"
            }
          },
          %{
            "fields" => %{
              "iconEmoji" => "😋",
              "title" => "It is tasty"
            },
            "sys" => %{
              "contentType" => %{
                "sys" => %{
                  "id" => "componentFeatures",
                  "linkType" => "ContentType",
                  "type" => "Link"
                }
              },
              "createdAt" => "2024-04-27T13:50:54.844Z",
              "id" => "2VzTGEENSvxVZbfnxDJv2C",
              "locale" => "en-GB",
              "revision" => 1,
              "type" => "Entry",
              "updatedAt" => "2024-04-27T13:51:11.254Z"
            }
          },
          %{
            "fields" => %{
              "iconEmoji" => "🥳",
              "title" => "It is fun"
            },
            "sys" => %{
              "contentType" => %{
                "sys" => %{
                  "id" => "componentFeatures",
                  "linkType" => "ContentType",
                  "type" => "Link"
                }
              },
              "createdAt" => "2024-04-27T13:49:44.958Z",
              "id" => "7nPDsIzj69Ey8RRvjRh5yT",
              "locale" => "en-GB",
              "revision" => 1,
              "type" => "Entry",
              "updatedAt" => "2024-04-27T13:50:40.939Z"
            }
          }
        ]
      }

      %Entry{
        fields: %{
          "blocks" => [
            %Entry{
              fields: %{
                "features" => [
                  %Entry{
                    fields: %{
                      "iconEmoji" => "🥳",
                      "title" => "It is fun"
                    }
                  },
                  %Entry{
                    fields: %{
                      "iconEmoji" => "😋",
                      "title" => "It is tasty"
                    }
                  }
                ]
              }
            }
          ],
          "slug" => "my-page-with-content-blocks",
          "title" => "My Page with Content Blocks"
        },
        sys: %SysData{
          id: "2PtC9h1YqIA6kaUaIsWEQ0",
          revision: 2,
          locale: "en-US",
          updated_at: "2020-04-18T18:44:10.843Z",
          created_at: "2019-03-22T08:33:45.069Z",
          content_type: %ContentType{id: "page"}
        }
      } = LinkResolver.replace_in_situ(entry, includes)
    end
  end
end
