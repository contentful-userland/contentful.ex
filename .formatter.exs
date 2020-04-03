[
  inputs: [
    "{lib,config,test}/**/*.{ex,exs}",
    "mix.exs"
  ],
  line_length: 100,
  locals_without_parens: [
    # Phoenix
    action_fallback: 1,
    plug: 2,
    plug: 1,
    pipe_through: 1,
    get: 3,
    post: 3,
    patch: 3,
    put: 3,
    forward: 3,
    resources: 2,
    resources: 3
  ]
]
