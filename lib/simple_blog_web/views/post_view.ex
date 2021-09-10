defmodule SimpleBlogWeb.PostView do
  use SimpleBlogWeb, :view

  alias SimpleBlog.Posts
  alias SimpleBlog.Comments

  def get_comments_count(post_id) do
    Posts.get_number_of_comments(post_id)
  end

  def get_reaction_count(comment_id, reaction_id) do
    Comments.get_number_of_reactions(comment_id, reaction_id)
  end
end
