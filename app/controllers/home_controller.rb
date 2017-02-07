require 'rubygems'
require 'sparql/grammar'
require 'rdf'
require 'linkeddata'
require 'set'

class HomeController < ApplicationController
  def index
    sparql_endpoint = SPARQL::Client.new("http://192.168.56.12:3030/LMDB/sparql")
    queries = Sparql.new


    #get statistic data about used sources
    @numberOfTriplets = sparql_endpoint.query(queries.number_of_triplets_query)[0].numberOfTriplets
    @numberOfMovies = sparql_endpoint.query(queries.number_of_movies_query)[0].numberOfMovies
    @numberOfClasses = sparql_endpoint.query(queries.number_of_classes_query)[0].numberOfClasses
    @numberOfDirectors = sparql_endpoint.query(queries.number_of_directors_query)[0].numberOfDirectors


    #get 3 random movies
    random_numbers = Set.new
    @three_random_movies = []

    while random_numbers.count < 3
      random_numbers << Random.rand(@numberOfMovies)
    end

    random_numbers.each do |d|
      three_random_movies_query = queries.three_random_movies_query(d)
      @three_random_movies << sparql_endpoint.query(three_random_movies_query)[0].title.humanize
    end


    #get all actors that have birthday today
    sparql_endpoint_dbpedia = SPARQL::Client.new("https://dbpedia.org/sparql")
    people_born_today = sparql_endpoint_dbpedia.query(queries.dbpedia_people_born_today_query)

    @actors_born_today = []
    actors_filter_list = "FILTER("

    people_born_today.each do |person|
      personName = person.myActorName.humanize
      personName = personName.gsub(/\"/, '\"')
      actors_filter_list << "?name = \"#{personName}\" || \n"
    end

    actors_filter_list = actors_filter_list[0..-5] + ")"
    @actors_born_today = sparql_endpoint.query(queries.actors_born_today_query(actors_filter_list))

  end

  def searchresults
    query_text = params.require(:query)
    sparql_endpoint = SPARQL::Client.new("http://192.168.56.12:3030/LMDB/sparql")
    queries = Sparql.new

    @actors = sparql_endpoint.query(queries.actor_query(query_text))
    @movies = sparql_endpoint.query(queries.movie_query(query_text))
  end


  def actor
    name = params.require(:name)
    @lang = lang = params.require(:lang)
    sparql_endpoint = SPARQL::Client.new("http://192.168.56.12:3030/LMDB/sparql")
    queries = Sparql.new

    actors = sparql_endpoint.query(queries.get_actor_use_uri_query(name, lang))

    if actors.count < 1
      actors = sparql_endpoint.query(queries.get_actor_use_name_query(name, lang))
    end

    if actors[0] != nil
      @name = actors[0].name
      @birthday = actors[0].bound?("birthday") ? actors[0].birthday : "Could not get the data!"
      @birthplace = actors[0].bound?("birthplace") ? actors[0].birthplace : "Could not get the data!"
      @about = actors[0].bound?("about") ? actors[0].about : "Could not get the data!"
      @imgUrl = actors[0].bound?("imgUrl") ? actors[0].imgUrl : "Could not get the data!"
    else
      @name = name
      @birthday = "Could not get the data!"
      @birthplace = "Could not get the data!"
      @about = "Could not get the data!"
      @imgUrl = "Could not get the data!"
    end
  end

  def movie
    title = params.require(:title)
    @lang = lang = params.require(:lang)
    sparql_endpoint = SPARQL::Client.new("http://192.168.56.12:3030/LMDB/sparql")
    queries = Sparql.new

    movies = sparql_endpoint.query(queries.get_movie_use_uri(title, lang))

    if movies.count < 1
      movies = sparql_endpoint.query(queries.get_movie_use_title(title, lang))
    end

    @title = title
    if movies[0] != nil
      @actors = []
      movies.each do |movie|
        if movie.bound?("acotrName")
          @actors << movie.actorName.humanize
        end
      end

      @date = movies[0].bound?("date") ? movies[0].date : "Could not get the data!"
      @directorName = movies[0].bound?("directorName") ? movies[0].directorName : "Could not get the data!"
      @about = movies[0].bound?("about") ? movies[0].about : "Could not get the data!"
    else
      @actors = ["Could not get the data!"]
      @date = "Could not get the data!"
      @directorName = "Could not get the data!"
      @about = "Could not get the data!"
    end
  end
end
