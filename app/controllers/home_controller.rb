require 'rubygems'
require 'sparql/grammar'
require 'rdf'
require 'linkeddata'

class HomeController < ApplicationController
  def index
    sparql_endpoint = SPARQL::Client.new("http://192.168.56.12:3030/LMDB/sparql")

    query = %{
      PREFIX lmdb: <http://data.linkedmdb.org/resource/movie/>
      SELECT DISTINCT ?actorName
      WHERE {
         ?kb lmdb:actor_name "Kevin Bacon" .
         ?movie lmdb:actor ?kb .
         ?movie lmdb:actor ?actor .
         ?actor lmdb:actor_name ?actorName .
         FILTER (?kb != ?actor)
      }
      ORDER BY ASC(?actorName)
    }
    p @text =  sparql_endpoint.query(query)

    @text.each do |sol|
      p
      p sol.actorName.humanize(lang = :en)
      p
    end
  end
end
