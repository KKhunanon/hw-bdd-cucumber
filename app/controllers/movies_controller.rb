Tmdb::Api.key(ENV['TMDB_KEY'])
class MoviesController < ApplicationController
  before_action :force_index_redirect, only: [:index]

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end
  def new
    # default: render 'new' template
    @movie_title = params[:name]
    @movie_rating = params[:rating]
    @movie_date = params[:date]
  end

  def search_tmdb 
      title = params[:movie][:title]
      movies = Tmdb::Movie.find(title)
      if movies.empty?
        flash[:notice] = "Movie '#{title}' was not found in TMDb."
        redirect_to movies_path
      else
        @title = movies[0].title
        @date = movies[0].release_date
        movie = Movie.where(title:@title)
        if !(movie.empty?)
          redirect_to movie_path(movie[0].id)
        else
          redirect_to new_movie_path(name:@title, date:@date)
        end 
      end
    end

  def index
    @all_ratings = Movie.all_ratings
    @movies = Movie.with_ratings(ratings_list, sort_by)
    @ratings_to_show_hash = ratings_hash
    @sort_by = sort_by
    # remember the correct settings for next time
    session['ratings'] = ratings_list
    session['sort_by'] = @sort_by
  end


  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

  # def movie_params
  #   params.require(:movie).permit(:title, :rating, :description, :release_date)
  # end
  
  #------------------------part 5 adding
  # def search_tmdb
  #   @movie_name = params[:movie][:title]
  #   movieName = Tmdb::Movie.find(@movie_name)
  #   if !(movieName.empty?)
  #     #new addintion (search in DB)
  #     Movie_title = movieName[0].title
  #     Movie_date = movieName[0].release_date
  #     Movie_name = Movie.where(title:Movie_title) #from DB
  #     if !(Movie_name.empty?)
  #       redirect_to movie_path(Movie_name[0].id)
  #     else
  #       redirect_to new_movie_path(name:Movie_title,date:Movie_date)
  #     end

  #     flash[:notice] = "#{@movie_name} was found in TMDb."
  #   else
  #     flash[:notice] = "'#{@movie_name}' was not found in TMDb."
  #     redirect_to movies_path
  #   end
  # end
  
  # ---------------------------------------------------
  private

  def force_index_redirect
    if !params.key?(:ratings) || !params.key?(:sort_by)
      flash.keep
      url = movies_path(sort_by: sort_by, ratings: ratings_hash)
      redirect_to url
    end
  end

  def ratings_list
    params[:ratings]&.keys || session[:ratings] || Movie.all_ratings
  end

  def ratings_hash
    Hash[ratings_list.collect { |item| [item, "1"] }]
  end

  def sort_by
    params[:sort_by] || session[:sort_by] || 'id'
  end

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

end
