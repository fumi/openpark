# -*- coding: utf-8 -*-
class HomeController < ApplicationController
  def index
    client = SPARQL::Client.new("http://localhost:8890/sparql")
    query = """PREFIX geo: <#{RDF::GEO.to_s}>
PREFIX rdfs: <#{RDF::RDFS.to_s}>
PREFIX schema: <#{RDF::SCHEMA.to_s}>

SELECT ?park ?label ?lat ?long
WHERE {
  ?park a schema:Park ;
    rdfs:label ?label ;
    geo:lat ?lat ;
    geo:long ?long .
}
    """
    results = client.query(query)

    @markers = []
    results.each do |solution|
      @markers << { :latlng => [solution[:lat].to_s.to_f, solution[:long].to_s.to_f],
        :popup => "<a href=\"#{solution[:park].to_s}\">#{solution[:label].to_s}</a>" }
#        :popup => "#{solution[:label].to_s}" }
    end
  end
end
