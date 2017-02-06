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
    date = Time.now.strftime("%m-%d")
    actors_birthday_query = %{
      PREFIX owl:  <http://www.w3.org/2002/07/owl#>
      PREFIX lmdb: <http://data.linkedmdb.org/resource/movie/>
      PREFIX dbpo: <http://dbpedia.org/ontology/>
      PREFIX foaf: <http://xmlns.com/foaf/0.1/>
      PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
      SELECT ?actorName
      WHERE {
          ?movie lmdb:actor ?actor .
          ?actor lmdb:actor_name ?name .
          SERVICE <http://dbpedia.org/sparql> {
            SELECT *
             WHERE {
               ?myActor a dbpo:Person.
               ?myActor rdfs:label ?myActorName .
               ?myActor dbpo:birthDate ?birthDate .
               FILTER(STR(?myActorName) = ?name)
               FILTER(REGEX(STR(?birthDate),  "02-19")).
             }
          }
        }
    }
    return actors_birthday_query
  end

  def people_born_today
    date = Time.now.strftime("%m-%d")
    people = %{
      PREFIX  dbpo: <http://dbpedia.org/ontology/>
      PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
      SELECT *
      WHERE {
        ?myActor a dbpo:Person.
        ?myActor rdfs:label ?myActorName .
        ?myActor dbpo:birthDate ?birthDate .
        FILTER(REGEX(STR(?birthDate),  "#{date}")).
        FILTER(LANG(?myActorName) = "en")
      }
    }
  end

  def people_actors_born_today(name)
    actors = %{
      PREFIX lmdb: <http://data.linkedmdb.org/resource/movie/>
      SELECT ?name
      WHERE {
        ?movie lmdb:actor ?actor .
        ?actor lmdb:actor_name ?name .
        FILTER(?name = "#{name}")
      }
    }
  end

  def all_actors_query
    actors = %{
      PREFIX lmdb: <http://data.linkedmdb.org/resource/movie/>
      SELECT ?name
      WHERE {
        ?movie lmdb:actor ?actor .
        ?actor lmdb:actor_name ?name .
      }
    }
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


  def get_actor_by_uri_query(name)
    actor = %{
      PREFIX owl:  <http://www.w3.org/2002/07/owl#>
      PREFIX lmdb: <http://data.linkedmdb.org/resource/movie/>
      PREFIX dbpo: <http://dbpedia.org/ontology/>
      PREFIX foaf: <http://xmlns.com/foaf/0.1/>
      PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
      SELECT  DISTINCT ?name ?birthday ?birthplace ?about ?imgUrl
      WHERE {
          ?movie lmdb:actor ?actor .
          ?actor lmdb:actor_name "#{name}" .
          ?actor lmdb:actor_name ?name .
          ?actor owl:sameAs ?actorUrl .
          FILTER(REGEX(STR(?actorUrl), "dbpedia")).
          SERVICE <http://dbpedia.org/sparql> {
            ?actorUrl a dbpo:Person.
            ?actorUrl dbpo:birthDate ?birthday .
            ?actorUrl dbpo:birthPlace ?birthplaceUrl .
            ?birthplaceUrl rdfs:label ?birthplace .
            ?actorUrl dbpo:abstract ?about .
            ?actorUrl foaf:depiction ?imgUrl .
            FILTER(LANG(?about) = "en")
          }

      }
    }
  end

  def get_actor_by_name_query(name)
    actor = %{
      PREFIX owl:  <http://www.w3.org/2002/07/owl#>
      PREFIX lmdb: <http://data.linkedmdb.org/resource/movie/>
      PREFIX dbpo: <http://dbpedia.org/ontology/>
      PREFIX foaf: <http://xmlns.com/foaf/0.1/>
      PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
      SELECT  DISTINCT ?name ?birthday ?birthplace ?about ?imgUrl
      WHERE {
          ?movie lmdb:actor ?actor .
          ?actor lmdb:actor_name "#{name}" .
          ?actor lmdb:actor_name ?name .
          SERVICE <http://dbpedia.org/sparql> {
            SELECT *
            WHERE {
                ?myActor a dbpo:Person.
                ?myActor rdfs:label ?myActorName .
                ?myActor dbpo:birthDate ?birthday .
                ?myActor dbpo:birthPlace ?birthplaceUrl .
                ?birthplaceUrl rdfs:label ?birthplace .
                ?myActor dbpo:abstract ?about .
                ?myActor foaf:depiction ?imgUrl .
                FILTER(LANG(?about) = "en")
                FILTER(STR(?myActorName) = ?name)
            }
          }
        }
    }
  end


  def get_movie_by_uri(title)
    movie = %{
      PREFIX owl:  <http://www.w3.org/2002/07/owl#>
      PREFIX lmdb: <http://data.linkedmdb.org/resource/movie/>
      PREFIX dbpo: <http://dbpedia.org/ontology/>
      PREFIX foaf: <http://xmlns.com/foaf/0.1/>
      PREFIX dc: <http://purl.org/dc/terms/>
      SELECT  DISTINCT ?title ?actorName ?date ?directorName ?about
      WHERE {
          ?movie a lmdb:film .
          ?movie dc:title "#{title}" .
          ?movie dc:title ?title .
          ?movie lmdb:actor ?actor .
          ?actor lmdb:actor_name ?actorName .
          ?movie dc:date ?date .
          ?movie lmdb:director ?director .
          ?director lmdb:director_name ?directorName .

          ?movie owl:sameAs ?movieURI .
          FILTER(REGEX(STR(?movieURI), "dbpedia")).
          SERVICE <http://dbpedia.org/sparql>{
            ?movieURI dbpo:abstract ?about
            FILTER(LANG(?about) = "en")
          }
        }
    }
  end

  def get_movie_by_title(title)
    p "by title"
    movie = %{
      PREFIX owl:  <http://www.w3.org/2002/07/owl#>
      PREFIX lmdb: <http://data.linkedmdb.org/resource/movie/>
      PREFIX dbpo: <http://dbpedia.org/ontology/>
      PREFIX foaf: <http://xmlns.com/foaf/0.1/>
      PREFIX dc: <http://purl.org/dc/terms/>
      PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
      SELECT  DISTINCT ?title ?actorName ?date ?directorName ?about
      WHERE {
          ?movie a lmdb:film .
          ?movie dc:title "#{title}" .
          ?movie dc:title ?title .
          ?movie dc:date ?date .
          SERVICE <http://dbpedia.org/sparql>{
            SELECT *
            WHERE {
              ?myMovie a dbpo:Film.
              ?myMovie rdfs:label ?myFilmTitle .
              ?myMovie dbpo:starring ?actor .
              ?actor dbpo:birthName ?actorName .
              ?myMovie dbpo:director ?director .
              ?director rdfs:label ?directorName .
              ?myMovie dbpo:abstract ?about .
              FILTER(LANG(?about) = "en")
              FILTER(LANG(?actorName) = "en")
              FILTER(LANG(?directorName) = "en")
              FILTER(STR(?myFilmTitle) = ?title)
            }
          }
        }
    }
  end

  def get_movie_from_lmdb(title)
    movie = %{
      PREFIX owl:  <http://www.w3.org/2002/07/owl#>
      PREFIX lmdb: <http://data.linkedmdb.org/resource/movie/>
      PREFIX dbpo: <http://dbpedia.org/ontology/>
      PREFIX foaf: <http://xmlns.com/foaf/0.1/>
      PREFIX dc: <http://purl.org/dc/terms/>
      SELECT  DISTINCT ?title ?actorName ?date ?directorName ?about
      WHERE {
          ?movie a lmdb:film .
          ?movie dc:title "#{title}" .
          ?movie dc:title ?title .
          ?movie lmdb:actor ?actor .
          ?actor lmdb:actor_name ?actorName .
          ?movie dc:date ?date .
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
