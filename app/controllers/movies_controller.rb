class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def getRatings()
    result = []
    ratings = Movie.select(:rating).map(&:rating).uniq
    ratings.each { |r| result.push(r) }
    return result.sort_by!{ |m| m.downcase }
  end

  def index
    @all_ratings = getRatings()
    sortBy = params[:sort]
    if session[:ratings] == nil
      session[:ratings] = @all_ratings
    end
    ratingKeys = nil
    if params[:ratings] != nil
      ratingKeys = params[:ratings].keys 
    end
    
    if ratingKeys == nil
      ratingKeys = session[:ratings]
    end

    @ratingsNow = session[:ratings]

    if sortBy == nil
      sortBy = session[:sortBy]
    end

    if ratingKeys != session[:ratings] or sortBy != session[:sortBy]
      session[:ratings] = ratingKeys
      session[:sortBy] = sortBy
      hash = Hash.new {|hash, key| hash[key] = 1 }
      redirect_to :ratings => hash, :sort => sortBy
      return
    end

    if sortBy == 'title'
      @title_header = 'hilite'
      tempMovies = Movie.with_ratings(@ratingsNow)
      @movies = tempMovies.order(:title)
    elsif sortBy == 'release_date'
      @release_date_header = 'hilite'
      tempMovies = Movie.with_ratings(@ratingsNow)
      @movies = tempMovies.order(:release_date)
    else
      @movies = Movie.with_ratings(@ratingsNow)
    end
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

end
