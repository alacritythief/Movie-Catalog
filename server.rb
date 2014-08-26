require 'pg'
require 'sinatra'
require 'sinatra/reloader'
require 'pry'

### PROGRAM ###

def db_connect
  begin
    connection = PG.connect(dbname: 'movies')
    yield(connection)
  ensure
    connection.close
  end
end

def fetch_data(query)
  db_connect do |conn|
    result = conn.exec_params(query)
  end
end


### ROUTES ###

get '/' do
  redirect '/movies'
end

get '/movies' do

  query =
  "SELECT title, year, rating, genres.name AS genre, studios.name AS studio, movies.id AS id
  FROM movies JOIN genres ON movies.genre_id = genres.id
  JOIN studios ON studios.id = movies.studio_id ORDER BY title"

  @movies = fetch_data(query)

  erb  :'movies/index'
end

get '/movies/:id' do

  # Will show the details for the movie. This page should contain information about the movie
  # (including genre and studio) as well as a list of all of the actors and their roles.
  # Each actor name is a link to the details page for that actor.

  id = params[:id]
  query =
    "SELECT movies.id, movies.title, movies.year, movies.rating,
      genres.name AS genre, studios.name AS studio, actors.name AS actor, cast_members.character
    FROM movies
    JOIN genres ON movies.genre_id = genres.id
    JOIN studios ON movies.studio_id = studios.id
    JOIN cast_members ON movies.id = cast_members.movie_id
    JOIN actors ON cast_members.actor_id = actors.id
    WHERE movies.id = #{id}"

  @movie_id = fetch_data(query)

  binding.pry

  erb  :'movies/show'
end

get '/actors' do
  # will show a list of actors, sorted alphabetically by name.
  # Each actor name is a link to the details page for that actor.

  query = 'SELECT name FROM actors ORDER BY name'

  db_connect do |conn|
    @actors = conn.exec_params(query)
  end

  erb :'actors/index'
end

get '/actors/:id' do
  # Will show the details for a given actor.
  # This page should contain a list of movies that the actor has starred in and what their role was.
  # Each movie should link to the details page for that movie.

  id = params[:id]

  erb :'actors/show'
end


