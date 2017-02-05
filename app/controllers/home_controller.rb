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
    #@numberOfMovies = 10
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
    #this query has to be fixed on faster internet
    #@actors_birthday = sparql_endpoint.query(query.actors_born_today)
  end

  def searchresults
    query_text = params.require(:query)
    sparql_endpoint = SPARQL::Client.new("http://192.168.56.12:3030/LMDB/sparql")
    queries = Sparql.new

    @actors = sparql_endpoint.query(queries.main_query_actors(query_text))
    @movies = sparql_endpoint.query(queries.main_query_movies(query_text))
  end

  def actor
    name = params.require(:name)
    sparql_endpoint = SPARQL::Client.new("http://192.168.56.12:3030/LMDB/sparql")
    queries = Sparql.new
    @act = sparql_endpoint.query(queries.get_actor_query(name))

    if @act.count < 1
      sparql_endpoint = SPARQL::Client.new("https://dbpedia.org/sparql")
      uri = sparql_endpoint.query(queries.get_dbpedia_link(name))[0].actorUrl.to_s
      @act = sparql_endpoint.query(queries.get_actor_special(uri))
    end
  end

  def movie
    title = params.require(:title)
  end
end
