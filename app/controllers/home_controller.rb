# -*- coding: utf-8 -*-
class HomeController < ApplicationController
  def index
    client = SPARQL::Client.new(OpenPark::Application.config.sparql_endpoint)
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
      link = solution[:park].to_s.gsub(/http:\/\/.*?\//, '')
      @markers << { :latlng => [solution[:lat].to_s.to_f, solution[:long].to_s.to_f],
        :popup => "<a href=\"#{link}\">#{solution[:label].to_s}</a>",
        :icon => { :icon_url => "#{ActionController::Base.helpers.asset_path('marker-icon.png')}", :shadow_url => "#{ActionController::Base.helpers.asset_path('marker-shadow.png')}", :retina_url => "#{ActionController::Base.helpers.asset_path('marker-icon-2x.png')}" } }
    end
  end
end
