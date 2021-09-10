defmodule SimpleBlog.Repo do
  use Ecto.Repo,
    otp_app: :simple_blog,
    adapter: Ecto.Adapters.MyXQL
end
