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
    sparql_endpoint_dbpedia = SPARQL::Client.new("https://dbpedia.org/sparql")
    people_born_today = sparql_endpoint_dbpedia.query(queries.people_born_today)
    all_actors = sparql_endpoint.query(queries.all_actors_query)
    #p all_actors
    @actors_born_today = []
    people_born_today.each do |person|
      personName = person.myActorName.humanize

      all_actors.each do |actor|
        if personName == actor.name.humanize
          @actors_born_today << personName
        end
      end
      p personName
    #  @actors_born_today << sparql_endpoint.query(queries.people_actors_born_today(actorName))
    end
    p @actors_born_today
  end

  def searchresults
    query_text = params.require(:query)
    sparql_endpoint = SPARQL::Client.new("http://192.168.56.12:3030/LMDB/sparql")
    queries = Sparql.new

    @actors = sparql_endpoint.query(queries.main_query_actors(query_text))
    @movies = sparql_endpoint.query(queries.main_query_movies(query_text))
  end


#napraviti združeni upit preko imena glumca paziti na ime glumca na određenom jeziku
  def actor
    name = params.require(:name)
    sparql_endpoint = SPARQL::Client.new("http://192.168.56.12:3030/LMDB/sparql")
    queries = Sparql.new
    @act = sparql_endpoint.query(queries.get_actor_by_uri_query(name))

    if @act.count < 1
      @act = sparql_endpoint.query(queries.get_actor_by_name_query(name))

      #USE THIS CODE IF PREVIOUS LINE DOESN'T WORK
      #sparql_endpoint = SPARQL::Client.new("https://dbpedia.org/sparql")
      #uri = sparql_endpoint.query(queries.get_dbpedia_link(name))[0].actorUrl.to_s
      #@act = sparql_endpoint.query(queries.get_actor_special(uri))
    end
    #?name ?birthday ?birthplace ?about ?imgUrl
    if @act[0] != nil
      @name = @act[0].name
      @birthday = @act[0].birthday
      @birthplace = @act[0].birthplace
      @about = @act[0].about
      @imgUrl = @act[0].imgUrl
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
    sparql_endpoint = SPARQL::Client.new("http://192.168.56.12:3030/LMDB/sparql")
    queries = Sparql.new
    flag = 0
    @mov = sparql_endpoint.query(queries.get_movie_by_uri(title))
    if @mov.count < 1
      @mov = sparql_endpoint.query(queries.get_movie_by_title(title))
    end

    if @mov.count < 1
      flag = 1
      @mov = sparql_endpoint.query(queries.get_movie_from_lmdb(title))
    end
    p @mov

    #?title ?actorName ?date ?directorName ?screenWriter ?about
    @title = @mov[0].title
    @actors = []
    @mov.each do |act|
      @actors << act.actorName.humanize
    end
    @date = @mov[0].date
    if flag == 0
      @directorName = @mov[0].directorName
      @about = @mov[0].about
    else
      @directorName = "No data"
      @about = "No data"
    end
  end
end
