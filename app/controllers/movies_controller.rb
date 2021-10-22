class MoviesController < ApplicationController

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    @all_ratings = Movie.all_ratings
    redirect = false
    if !(params[:ratings].nil?)
      session[:ratings] = params[:ratings]
    else
      redirect = true
    end
    
    if !(session[:ratings].nil?)
      session[:ratings] = session[:ratings]
    else
      session[:ratings] = Hash[@all_ratings.map {|r| [r, true]}]
    end
    @ratings_to_show = session[:ratings]
    
    if params[:sort]
      session[:sort] = params[:sort]
    else
      redirect = true
    end
    
    if session[:sort]
      session[:sort] = session[:sort]
    else
      session[:sort] = ""
    end
    @sort_method = session[:sort]
    
    if redirect
      redirect_to movies_path({:sort=> @sort_method, :ratings=>@ratings_to_show})
    end
    
    @movies = Movie.with_ratings(@ratings_to_show.keys).order(@sort_method)
  end

  def new
    # default: render 'new' template
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

  private
  # Making "internal" methods private is not required, but is a common practice.
  # This helps make clear which methods respond to requests, and which ones do not.
  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end
end
