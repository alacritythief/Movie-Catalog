require 'pg'
require 'sinatra'
require 'sinatra/reloader'

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
  LEFT OUTER JOIN studios ON studios.id = movies.studio_id ORDER BY title"

  @movies = fetch_data(query)

  erb  :'movies/index'
end

get '/movies/:id' do
  id = params[:id]

  query =
    "SELECT movies.id, movies.title, movies.year, movies.rating,
      genres.name AS genre, studios.name AS studio, actors.name AS actor,
      cast_members.character, actors.id AS actors_id
    FROM movies
    JOIN genres ON movies.genre_id = genres.id
    LEFT OUTER JOIN studios ON movies.studio_id = studios.id
    LEFT OUTER JOIN cast_members ON movies.id = cast_members.movie_id
    LEFT OUTER JOIN actors ON cast_members.actor_id = actors.id
    WHERE movies.id = #{id} ORDER BY actors.name"

  @movie_id = fetch_data(query)
  erb  :'movies/show'
end

get '/actors' do
  query = 'SELECT name, id FROM actors ORDER BY name'
  @actors = fetch_data(query)
  erb :'actors/index'
end

get '/actors/:id' do
  id = params[:id]
  name = "SELECT name, id FROM actors WHERE actors.id = #{id}"

  query = "
  SELECT movies.title, cast_members.character, movies.id
  FROM movies
  JOIN cast_members ON movies.id = cast_members.movie_id
  WHERE cast_members.actor_id = #{id}"

  @actor = fetch_data(query)
  @name = fetch_data(name)

  erb :'actors/show'
end


