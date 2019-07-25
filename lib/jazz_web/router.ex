defmodule JazzWeb.Router do
  use JazzWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug BasicAuth, use_config: {:basic_auth, :credentials}
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", JazzWeb do
    pipe_through :browser

    get "/", PostController, :index
    get "/notes", NoteController, :index
    get "/notes/view", NoteController, :view
    get "/notes/edit", NoteController, :edit
    get "/notes/new", NoteController, :new
    post "/notes/create", NoteController, :create
    post "/notes/edit", NoteController, :save
    get "/notes/git_diff", NoteController, :git_diff
    post "/notes/git_add_commit", NoteController, :git_add_commit
    post "/notes/git_pull", NoteController, :git_pull
    post "/notes/git_push", NoteController, :git_push

    resources "/feeds", FeedController
    post "/feeds/preview", FeedController, :preview

    get "/posts/read", PostController, :show
    get "/posts/saved", PostController, :saved
    get "/posts/podcasts", PostController, :podcasts
    get "/posts/set_read", PostController, :set_read
    get "/posts/toggle_saved", PostController, :toggle_saved
    get "/posts/toggle_podcast", PostController, :toggle_podcast
    post "/posts/all_read", PostController, :all_read

    resources "/links", LinkController, only: [:index, :create]
    get "/links/delete/:id", LinkController, :delete
    get "/links/edit/:id", LinkController, :edit
    post "/links/edit/:id", LinkController, :save
  end

  # Other scopes may use custom stacks.
  # scope "/api", JazzWeb do
  #   pipe_through :api
  # end
end
