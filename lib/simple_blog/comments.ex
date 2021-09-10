defmodule SimpleBlog.Comments do
  @moduledoc """
  The Comments context.
  """

  import Ecto.Query, warn: false
  alias SimpleBlog.Repo

  alias SimpleBlog.Comments.Comment
  alias SimpleBlog.Reactions
  alias SimpleBlog.Reactions.Reaction


  @doc """
  Returns the list of comments.

  ## Examples

      iex> list_comments()
      [%Comment{}, ...]

  """
  def list_comments do
    Repo.all(Comment)
  end

  @doc """
  Gets a single comment.

  Raises `Ecto.NoResultsError` if the Comment does not exist.

  ## Examples

      iex> get_comment!(123)
      %Comment{}

      iex> get_comment!(456)
      ** (Ecto.NoResultsError)

  """
  def get_comment!(id), do: Repo.get!(Comment, id)

  @doc """
  Creates a comment.

  ## Examples

      iex> create_comment(%{field: value})
      {:ok, %Comment{}}

      iex> create_comment(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_comment(attrs \\ %{}) do
    %Comment{}
    |> Comment.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a comment.

  ## Examples

      iex> update_comment(comment, %{field: new_value})
      {:ok, %Comment{}}

      iex> update_comment(comment, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_comment(%Comment{} = comment, attrs) do
    comment
    |> Comment.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a comment.

  ## Examples

      iex> delete_comment(comment)
      {:ok, %Comment{}}

      iex> delete_comment(comment)
      {:error, %Ecto.Changeset{}}

  """
  def delete_comment(%Comment{} = comment) do
    delete_all_reactions(comment.id) #delete all reactions for this comment before deleting the comment
    Repo.delete(comment)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking comment changes.

  ## Examples

      iex> change_comment(comment)
      %Ecto.Changeset{data: %Comment{}}

  """
  def change_comment(%Comment{} = comment, attrs \\ %{}) do
    Comment.changeset(comment, attrs)
  end
  ################################################################################
  ### get all comments post

  ################################################################################
  def get_all_comments(post_id) do
    query = from(r in Comment, where: r.post_id == ^post_id)
    Repo.all(query)
  end
  ################################################################################
  ### get number of reaction per reaction type for a specific comment_id

  ################################################################################
  def get_number_of_reactions(comment_id, reaction_id) do
    query = from(r in Reaction, where: r.type == ^reaction_id and r.comment_id == ^comment_id)
    comment = Repo.all(query)
    count = Enum.count(comment)
    IO.puts(count)
    Enum.count(comment)
  end

  ################################################################################
  ### Delete all reactions for a specific comment_id

  ################################################################################
  def delete_all_reactions (comment_id) do
    comment_reactions = Reactions.get_all_reactions(comment_id)
    for comment_reaction <- comment_reactions do
      Reactions.delete_reaction(comment_reaction)
    end
  end


end
