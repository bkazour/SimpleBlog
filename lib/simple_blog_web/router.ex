defmodule SimpleBlogWeb.Router do
  use SimpleBlogWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", SimpleBlogWeb do
    pipe_through :browser

    #get "/", PageController, :index
    get "/", PostController, :index

    resources "/posts", PostController do
      post "/comment", PostController, :add_comment
      delete "/deleteComment", PostController, :delete_comment
      post "/addReaction", PostController, :add_reaction
      delete "/deleteReaction", PostController, :delete_reaction
      post "/loadComment", PostController, :load_comment
      post "/updateComment", PostController, :update_comment

    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", SimpleBlogWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: SimpleBlogWeb.Telemetry
    end
  end
end
