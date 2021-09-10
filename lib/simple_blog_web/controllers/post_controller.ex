defmodule SimpleBlogWeb.PostController do
  use SimpleBlogWeb, :controller

  alias SimpleBlog.Posts
  alias SimpleBlog.Posts.Post
  alias SimpleBlog.Repo
  alias SimpleBlog.Comments
  alias SimpleBlog.Comments.Comment
  alias SimpleBlog.Reactions

  def index(conn, _params) do
    posts = Posts.list_posts()
    render(conn, "index.html", posts: posts)
  end

  def new(conn, _params) do
    changeset = Posts.change_post(%Post{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"post" => post_params}) do
    case Posts.create_post(post_params) do
      {:ok, post} ->
        conn
        |> put_flash(:info, "Post created successfully.")
        |> redirect(to: Routes.post_path(conn, :show, post))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    initial_post =
      id
      |> Posts.get_post!()
      |> Repo.preload([:comments])

    post = %{post: initial_post, comment: nil }
    changeset = Comment.changeset(%Comment{}, %{})
    render(conn, "show.html", post: post, changeset: changeset)
  end

  def edit(conn, %{"id" => id}) do
    post = Posts.get_post!(id)
    changeset = Posts.change_post(post)
    render(conn, "edit.html", post: post, changeset: changeset)
  end

  @spec update(Plug.Conn.t(), map) :: Plug.Conn.t()
  def update(conn, %{"id" => id, "post" => post_params}) do
    post = Posts.get_post!(id)

    case Posts.update_post(post, post_params) do
      {:ok, post} ->
        conn
        |> put_flash(:info, "Post updated successfully.")
        |> redirect(to: Routes.post_path(conn, :show, post))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", post: post, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    post = Posts.get_post!(id)
    {:ok, _post} = Posts.delete_post(post)

    conn
    |> put_flash(:info, "Post deleted successfully.")
    |> redirect(to: Routes.post_path(conn, :index))
  end
  ################################################################################
  ### Delete Comment based on PostID and comment ID

  ################################################################################
  def delete_comment(conn, %{"post_id" => post_id, "comment_id" => comment_id}) do
    post =
      post_id
      |> Posts.get_post!()
      |> Repo.preload([:comments])

    comment = Comments.get_comment!(comment_id) #load the post and check if it exists
    if(comment != nil) do
      Comments.delete_comment(comment)
      conn
      |> put_flash(:info, "Comment deleted successfully.")
      |> redirect(to: Routes.post_path(conn, :show, post))

    else
      conn
      |> redirect(to: Routes.post_path(conn, :show, post))
    end
  end

  ################################################################################
  ### Add Comment based on PostID

  ################################################################################
  @spec add_comment(Plug.Conn.t(), map) :: Plug.Conn.t()
  def add_comment(conn, %{"comment" => comment_params, "post_id" => post_id}) do
    post =
      post_id
      |> Posts.get_post!()
      |> Repo.preload([:comments])

    case Posts.add_comment(post_id, comment_params) do
      {:ok, _comment} ->
        conn
        |> put_flash(:info, "Comment is added successfully")
        |> redirect(to: Routes.post_path(conn, :show, post))

      {:error, _comment} ->
        conn
        |> put_flash(:info, "Comment couldn't be added")
        |> redirect(to: Routes.post_path(conn, :show, post))
    end
  end

  ################################################################################
  ### Add a Reaction based on specific comment

  ################################################################################
  def add_reaction(conn, %{"post_id" => post_id, "comment_id" => comment_id, "reaction_id" => reaction_id}) do
    post =
      post_id
      |> Posts.get_post!()
      |> Repo.preload([:comments])

    case Reactions.create_reaction(%{type: reaction_id, comment_id: comment_id}) do
      {:ok, _reaction} ->
        conn
        |> redirect(to: Routes.post_path(conn, :show, post))
      {:error, _comment} ->
        conn
        |> redirect(to: Routes.post_path(conn, :show, post))
      end
  end
  ################################################################################
  ### Delete a Reaction based on specific comment and the selected type

  ################################################################################
  def delete_reaction(conn, %{"post_id" => post_id, "comment_id" => comment_id, "reaction_id" => reaction_id}) do
    post =
      post_id
      |> Posts.get_post!()
      |> Repo.preload([:comments])
    reaction = Reactions.get_one_reaction(comment_id, reaction_id) #Extract 1 reaction based the type and the comment
    if (reaction != nil) do
      case Reactions.delete_reaction(reaction) do
        {:ok, _reaction} ->
          conn
          |> redirect(to: Routes.post_path(conn, :show, post))
        {:error, _reaction} ->
          conn
          |> redirect(to: Routes.post_path(conn, :show, post))
      end
    else
      conn
      |> redirect(to: Routes.post_path(conn, :show, post))
    end
  end
  ################################################################################
  ### Load Comment for edit based on the comment ID and the post ID

  ################################################################################
  def load_comment(conn, %{"post_id" => post_id, "comment_id" => comment_id}) do
    initial_post =
      post_id
      |> Posts.get_post!()
      |> Repo.preload([:comments])
    comment = Comments.get_comment!(comment_id)
    if (comment != nil) do
      post = %{post: initial_post, comment: comment }
      changeset = Comment.changeset(%Comment{}, %{})
      render(conn, "show.html", post: post, changeset: changeset)
    else
      post = %{post: initial_post, comment: nil }
      changeset = Comment.changeset(%Comment{}, %{})
      render(conn, "show.html", post: post, changeset: changeset)
    end
  end

  ################################################################################
  ### Update Comment for edit based on the comment ID

  ################################################################################
  def update_comment(conn, %{"comment" => comment_params, "post_id" => post_id, "comment_id" => comment_id}) do
    post =
      post_id
      |> Posts.get_post!()
      |> Repo.preload([:comments])
    comment =
      comment_id
      |> Comments.get_comment!()
    case Comments.update_comment(comment, comment_params) do
      {:ok, _comment} ->
        conn
        |> put_flash(:info, "Comment is updated successfully")
        |> redirect(to: Routes.post_path(conn, :show, post))

      {:error, _comment} ->
        conn
        |> put_flash(:info, "Comment couldn't be updated")
        |> redirect(to: Routes.post_path(conn, :show, post))
    end
  end

end
