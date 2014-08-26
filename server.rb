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

id = params[:id]
query = "SELECT title FROM movies WHERE id = #{id}"

db_connect do |conn|
  conn.exec_params(query)
end



### ROUTES ###

get '/movies' do
  # Will show a table of movies, sorted alphabetically by title.
  # The table includes the movie title, the year it was released,
  # the rating, the genre, and the studio that produced it.
  # Each movie title is a link to the details page for that movie.
end

get '/movies/:id' do
  # Will show the details for the movie. This page should contain information about the movie
  # (including genre and studio) as well as a list of all of the actors and their roles.
  # Each actor name is a link to the details page for that actor.
end

get '/actors' do
  # will show a list of actors, sorted alphabetically by name.
  # Each actor name is a link to the details page for that actor.
end

get '/actors/:id' do
  # Will show the details for a given actor.
  # This page should contain a list of movies that the actor has starred in and what their role was.
  # Each movie should link to the details page for that movie.
end
