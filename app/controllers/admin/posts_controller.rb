module Admin
  class PostsController < ApplicationController
    before_action :set_post, only: %i[edit update destroy]

    def index
      @posts = Post.order(created_at: :desc)
    end

    def new
      @post = Post.new
    end

    def create
      @post = Post.new(post_params)
      if @post.save
        redirect_to admin_posts_path, notice: "Post criado com sucesso."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @post.update(post_params)
        redirect_to admin_posts_path, notice: "Post atualizado com sucesso."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @post.destroy!
      redirect_to admin_posts_path, notice: "Post removido."
    end

    def preview
      markdown = params[:body_markdown].to_s
      html = MarkdownRenderer.render(markdown)
      render html: html.html_safe, layout: false
    end

    private

    def set_post
      @post = Post.find_by!(slug: params[:slug])
    end

    def post_params
      params.require(:post).permit(:title, :slug, :body_markdown, :published, :published_at)
    end
  end
end
