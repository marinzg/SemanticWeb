class Sparql
  attr_accessor :number_of_triplets_query
  attr_accessor :number_of_movies_query
  attr_accessor :number_of_classes_query
  attr_accessor :number_of_directors_query


  def initialize()
    init_number_of_triplets
    init_number_of_movies
    init_number_of_classes
    init_number_of_directors
  end

  def init_number_of_triplets
    self.number_of_triplets_query = %{
      SELECT (COUNT (*) as ?numberOfTriplets)
      WHERE {
        ?s ?p ?o
      }
    }
  end

  def init_number_of_movies
    self.number_of_movies_query = %{
      PREFIX movie: <http://data.linkedmdb.org/resource/movie/>
      SELECT (COUNT(*) as ?numberOfMovies)
      WHERE {
        [] a movie:film
      }
    }
  end

  def init_number_of_classes
    self.number_of_classes_query = %{
      SELECT (COUNT(DISTINCT ?class) as ?numberOfClasses)
      WHERE {
        [] a ?class
      }
      ORDER BY ?class
    }
  end

  def init_number_of_directors
    self.number_of_directors_query = %{
      PREFIX movie: <http://data.linkedmdb.org/resource/movie/>
      SELECT (COUNT(DISTINCT ?director) as ?numberOfDirectors)
      WHERE {
        ?director a movie:director
      }
    }
  end



  def three_random_movies_query(number)
    three_random_movies_query = %{
      PREFIX movie: <http://data.linkedmdb.org/resource/movie/>
      PREFIX dc: <http://purl.org/dc/terms/>
      SELECT ?title
      WHERE {
        [] a movie:film .
        ?movie dc:title ?title
      }
      OFFSET #{number}
      LIMIT 1
    }
    return three_random_movies_query
  end

  def actors_born_today
    actors_birthday_query = %{
      PREFIX owl:  <http://www.w3.org/2002/07/owl#>
      PREFIX lmdb: <http://data.linkedmdb.org/resource/movie/>
      PREFIX dbpo: <http://dbpedia.org/ontology/>
      SELECT DISTINCT ?actorName ?birthday
      WHERE {
        ?movie lmdb:actor ?actor.
        ?actor lmdb:actor_name ?actorName.
        ?actor owl:sameAs ?url .
        FILTER(REGEX(STR(?url), "dbpedia")).
        SERVICE <http://dbpedia.org/sparql> {
          ?url a dbpo:Person.
          ?url dbpo:birthDate ?birthday .
        }
      } LIMIT 5
    }
    return actors_birthday_query
  end


  def main_query_movies(query_text)
    movies_query = %{
      PREFIX lmdb: <http://data.linkedmdb.org/resource/movie/>
      PREFIX dc: <http://purl.org/dc/terms/>
      SELECT DISTINCT ?title
      WHERE {
        ?movie dc:title ?title .
        FILTER(REGEX(?title, "#{query_text}"))
      }
    }
  end

  def main_query_actors(query_text)
    actors = %{
      PREFIX lmdb: <http://data.linkedmdb.org/resource/movie/>
      PREFIX dc: <http://purl.org/dc/terms/>
      SELECT DISTINCT ?name
      WHERE {
        ?actor a lmdb:actor .
        ?actor lmdb:actor_name ?name
        FILTER(REGEX(?name, "#{query_text}"))
      }
    }
  end

  def get_actor_query(actor)
    actor = %{
      PREFIX owl:  <http://www.w3.org/2002/07/owl#>
      PREFIX lmdb: <http://data.linkedmdb.org/resource/movie/>
      PREFIX dbpo: <http://dbpedia.org/ontology/>
      PREFIX foaf: <http://xmlns.com/foaf/0.1/>
      SELECT  DISTINCT ?birthday ?birthplace ?about ?imgUrl
      WHERE {
        {
          ?movie lmdb:actor ?actor .
          ?actor lmdb:actor_name "#{actor}" .
          ?actor owl:sameAs ?actorUrl .
          FILTER(REGEX(STR(?actorUrl), "dbpedia")).
          SERVICE <http://dbpedia.org/sparql> {
            ?actorUrl a dbpo:Person.
            ?actorUrl dbpo:birthDate ?birthday .
            ?actorUrl dbpo:birthPlace ?birthplace .
            ?actorUrl dbpo:abstract ?about .
            FILTER(LANG(?about) = "en")
          }
        }
        UNION
        {
          ?movie lmdb:actor ?actor .
          ?actor lmdb:actor_name "#{actor}" .
          ?actor owl:sameAs ?actorUrl .
          FILTER(REGEX(STR(?actorUrl), "dbpedia")).
          SERVICE <http://dbpedia.org/sparql> {
             ?actorUrl foaf:depiction ?imgUrl .
           }
        }
      }
    }
  end

  def get_dbpedia_link(name)
    get_dbpedia_link = %{
      PREFIX  dbo: <http://dbpedia.org/ontology/>
      PREFIX  dbp: <http://dbpedia.org/property/>
      PREFIX foaf: <http://xmlns.com/foaf/0.1/>
      PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
      SELECT  ?actorUrl
      WHERE {
          ?actorUrl a dbo:Person.
          ?actorUrl rdfs:label "#{name}"@en .
      }
    }
  end

  def get_actor_special(uri)
    #uri = uri.gsub(/page/, "resource")
    get_autor_special = %{
      PREFIX  dbo: <http://dbpedia.org/ontology/>
      PREFIX  dbp: <http://dbpedia.org/property/>
      PREFIX foaf: <http://xmlns.com/foaf/0.1/>
      SELECT  ?birthday ?birthplace ?about ?imgUrl
      WHERE {
        {<#{uri}> dbo:birthDate ?birthday }
        UNION
        {<#{uri}> dbo:birthPlace ?birthplace }
        UNION
        {<#{uri}> dbo:abstract ?about .
        FILTER(LANG(?about) = "en")}
        UNION
        { <#{uri}> foaf:depiction ?imgUrl }
      }
    }
  end
end
