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

  #Just an example -> to slow
  def actors_born_today
    date = Time.now.strftime("-%m-%d")
    actors_birthday_query = %{
      PREFIX movie: <http://data.linkedmdb.org/resource/movie/>
      PREFIX dbo: <http://dbpedia.org/ontology/>
      PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>

      SELECT ?actorName
      WHERE {
          ?movie movie:actor ?actor .
          ?actor movie:actor_name ?name .
          SERVICE <http://dbpedia.org/sparql> {
            SELECT *
             WHERE {
               ?myActor a dbo:Person.
               ?myActor rdfs:label ?myActorName .
               ?myActor dbo:birthDate ?birthDate .
               FILTER(STR(?myActorName) = ?name)
               FILTER(REGEX(STR(?birthDate),  "#{date}")).
             }
          }
        }
    }
  end

  def dbpedia_people_born_today_query
    date = Time.now.strftime("-%m-%d")
    people = %{
      PREFIX  dbo: <http://dbpedia.org/ontology/>
      PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>

      SELECT *
      WHERE {
        ?myActor a dbo:Person.
        ?myActor rdfs:label ?myActorName .
        ?myActor dbo:birthDate ?birthDate .
        FILTER(REGEX(STR(?birthDate),  "#{date}")).
        FILTER(LANG(?myActorName) = "en")
      }
      ORDER BY (?myActorName)
    }
  end

  def actors_born_today_query(filters)
    people = %{
      PREFIX movie: <http://data.linkedmdb.org/resource/movie/>

      SELECT DISTINCT ?name
      WHERE {
        ?movie movie:actor ?actor .
        ?actor movie:actor_name ?name .
        #{filters}
      }
      ORDER BY (?name)
    }
  end

#  def people_actors_born_today(name)
#    name = name.gsub(/\"/, '\"')
#    actors = %{
#      PREFIX movie: <http://data.linkedmdb.org/resource/movie/>
#
#      SELECT ?name
#      WHERE {
#        ?movie movie:actor ?actor .
#        ?actor movie:actor_name ?name .
#        FILTER(?name = "#{name}")
#      }
#    }
#  end

#  def all_actors_query
#    actors = %{
#      PREFIX movie: <http://data.linkedmdb.org/resource/movie/>
#
#      SELECT ?name
#      WHERE {
#        ?movie movie:actor ?actor .
#        ?actor movie:actor_name ?name .
#      }
#    }
#  end

  def actor_query(query_text)
    actors = %{
      PREFIX movie: <http://data.linkedmdb.org/resource/movie/>

      SELECT DISTINCT ?name
      WHERE {
        ?actor a movie:actor .
        ?actor movie:actor_name ?name
        FILTER(REGEX(?name, "#{query_text}"))
      }
      ORDER BY (?name)
    }
  end

  def movie_query(query_text)
    movies_query = %{
      PREFIX movie: <http://data.linkedmdb.org/resource/movie/>
      PREFIX dc: <http://purl.org/dc/terms/>

      SELECT DISTINCT ?title
      WHERE {
        ?movie dc:title ?title .
        FILTER(REGEX(?title, "#{query_text}"))
      }
      ORDER BY (?title)
    }
  end




  def get_actor_use_uri_query(name, lang)
    actor = %{
      PREFIX movie: <http://data.linkedmdb.org/resource/movie/>
      PREFIX dbo: <http://dbpedia.org/ontology/>
      PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
      PREFIX owl:  <http://www.w3.org/2002/07/owl#>
      PREFIX foaf: <http://xmlns.com/foaf/0.1/>

      SELECT  DISTINCT ?name ?birthday ?birthplace ?about ?imgUrl
      WHERE {
          ?movie movie:actor ?actor .
          ?actor movie:actor_name "#{name}" .
          ?actor movie:actor_name ?name .
          ?actor owl:sameAs ?actorUrl .
          FILTER(REGEX(STR(?actorUrl), "dbpedia")).

          SERVICE <http://dbpedia.org/sparql> {
            ?actorUrl a dbo:Person.
            OPTIONAL {?actorUrl dbo:birthDate ?birthday }.
            OPTIONAL {
              ?actorUrl dbo:birthPlace ?birthplaceUrl .
              ?birthplaceUrl rdfs:label ?birthplace .
              FILTER(LANG(?birthplace) = "#{lang}")
            } .
            OPTIONAL {?actorUrl foaf:depiction ?imgUrl .}
            OPTIONAL {
              ?actorUrl dbo:abstract ?about .
              FILTER(LANG(?about) = "#{lang}")
            }
          }
      }
    }
  end

  def get_actor_use_name_query(name, lang)
    actor = %{
      PREFIX movie: <http://data.linkedmdb.org/resource/movie/>
      PREFIX dbo: <http://dbpedia.org/ontology/>
      PREFIX dbr: <http://dbpedia.org/ontology/>
      PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
      PREFIX owl:  <http://www.w3.org/2002/07/owl#>
      PREFIX foaf: <http://xmlns.com/foaf/0.1/>

      SELECT  DISTINCT ?name ?birthday ?birthplace ?about ?imgUrl
      WHERE {
          ?movie movie:actor ?actor .
          ?actor movie:actor_name "#{name}" .
          ?actor movie:actor_name ?name .

          SERVICE <http://dbpedia.org/sparql> {
            SELECT *
            WHERE {
                ?myActor a dbo:Person.
                ?myActor foaf:name ?myActorName .
                OPTIONAL {?myActor dbo:birthDate ?birthday} .
                OPTIONAL {
                  ?myActor dbo:birthPlace ?birthplaceUrl .
                  ?birthplaceUrl rdfs:label ?birthplace .
                  FILTER(LANG(?birthplace) = "#{lang}")
                } .
                OPTIONAL {?myActor foaf:depiction ?imgUrl} .
                OPTIONAL {
                  ?myActor dbo:abstract ?about .
                  FILTER(LANG(?about) = "#{lang}")
                } .
                FILTER(STR(?myActorName) = ?name) .
            }
          }
        }
    }
  end


  def get_movie_use_uri(title, lang)
    movie = %{
      PREFIX movie: <http://data.linkedmdb.org/resource/movie/>
      PREFIX dc: <http://purl.org/dc/terms/>
      PREFIX dbo: <http://dbpedia.org/ontology/>
      PREFIX owl:  <http://www.w3.org/2002/07/owl#>
      PREFIX foaf: <http://xmlns.com/foaf/0.1/>

      SELECT  DISTINCT ?title ?actorName ?date ?directorName ?about
      WHERE {
          ?movie a movie:film .
          ?movie dc:title "#{title}" .
          ?movie dc:title ?title .
          ?movie movie:actor ?actor .
          ?actor movie:actor_name ?actorName .
          OPTIONAL {?movie dc:date ?date} .
          OPTIONAL {?movie movie:director ?director} .
          OPTIONAL {?director movie:director_name ?directorName} .
          ?movie owl:sameAs ?movieURI .
          FILTER(REGEX(STR(?movieURI), "dbpedia")).

          SERVICE <http://dbpedia.org/sparql>{
            OPTIONAL {
              ?movieURI dbo:abstract ?about .
              FILTER(LANG(?about) = "#{lang}")
            }
          }
        }
    }
  end

  def get_movie_use_title(title, lang)
    movie = %{
      PREFIX movie: <http://data.linkedmdb.org/resource/movie/>
      PREFIX dc: <http://purl.org/dc/terms/>
      PREFIX dbo: <http://dbpedia.org/ontology/>
      PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
      PREFIX owl:  <http://www.w3.org/2002/07/owl#>
      PREFIX foaf: <http://xmlns.com/foaf/0.1/>

      SELECT  DISTINCT ?title ?actorName ?date ?directorName ?about
      WHERE {
          ?movie a movie:film .
          ?movie dc:title "#{title}" .
          ?movie dc:title ?title .
          OPTIONAL {?movie dc:date ?date} .

          SERVICE <http://dbpedia.org/sparql>{
            SELECT *
            WHERE {
              ?myMovie a dbo:Film.
              ?myMovie rdfs:label ?myFilmTitle .
              OPTIONAL {
                ?myMovie dbo:starring ?actor .
                ?actor dbo:birthName ?actorName .
                FILTER(LANG(?actorName) = "#{lang}")
              } .
              OPTIONAL {
                ?myMovie dbo:director ?director .
                ?director rdfs:label ?directorName .
                FILTER(LANG(?directorName) = "#{lang}")
              } .
              OPTIONAL {
                ?myMovie dbo:abstract ?about .
                FILTER(LANG(?about) = "#{lang}")
              } .
              FILTER(STR(?myFilmTitle) = ?title)
            }
          }
        }
    }
  end





#  def get_movie_from_lmdb(title, lang)
#    movie = %{
#      PREFIX movie: <http://data.linkedmdb.org/resource/movie/>
#      PREFIX dc: <http://purl.org/dc/terms/>
#
#      SELECT  DISTINCT ?title ?actorName ?date ?directorName ?about
#      WHERE {
#          ?movie a movie:film .
#          ?movie dc:title "#{title}" .
#          ?movie dc:title ?title .
#          ?movie movie:actor ?actor .
#          ?actor movie:actor_name ?actorName .
#          ?movie dc:date ?date .
#        }
#    }
#  end


#  def get_dbpedia_link(name)
#    get_dbpedia_link = %{
#      PREFIX  dbo: <http://dbpedia.org/ontology/>
#      PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
#      SELECT  ?actorUrl
#      WHERE {
#          ?actorUrl a dbo:Person.
#          ?actorUrl rdfs:label "#{name}"@en .
#      }
#    }
#  end

#  def get_actor_special(uri)
#    get_autor_special = %{
#      PREFIX  dbo: <http://dbpedia.org/ontology/>
#      PREFIX  dbp: <http://dbpedia.org/property/>
#      PREFIX foaf: <http://xmlns.com/foaf/0.1/>
#      SELECT  ?birthday ?birthplace ?about ?imgUrl
#      WHERE {
#        {<#{uri}> dbo:birthDate ?birthday }
#        UNION
#        {<#{uri}> dbo:birthPlace ?birthplace }
#        UNION
#        {<#{uri}> dbo:abstract ?about .
#        FILTER(LANG(?about) = "en")}
#        UNION
#        { <#{uri}> foaf:depiction ?imgUrl }
#      }
#    }
#  end
end
