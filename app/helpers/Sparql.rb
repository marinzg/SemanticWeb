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
end
