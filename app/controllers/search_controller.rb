# -*- coding: utf-8 -*-
class SearchController < ApplicationController
  def index
    client = SPARQL::Client.new(OpenPark::Application.config.sparql_endpoint)
    prefixes = """PREFIX geo: <#{RDF::GEO.to_s}>
PREFIX rdfs: <#{RDF::RDFS.to_s}>
PREFIX schema: <#{RDF::SCHEMA.to_s}>
PREFIX ic: <#{IC.to_s}>
PREFIX park: <#{PARK.to_s}>
PREFIX dcterms: <#{RDF::DC.to_s}>
"""

    if (params[:equipmenType] and !params[:equipmentType].empty?) ||
       (params[:age] and !params[:age].empty?)

      equipment_type = params[:equipmentType] || "全て"
      age = params[:age].to_s || "3"

      query = prefixes +
"""
SELECT DISTINCT ?park ?parkLabel ?postalCode ?address ?lat ?long ?equipment ?equipmentLabel ?age_max ?age_min
WHERE {
  ?park a park:公園 ;
    rdfs:label ?parkLabel ;
    ic:地点_設備 ?equipment ;
    ic:地点_場所/ic:場所_住所 [
      ic:住所_郵便番号 ?postalCode ;
      ic:住所_表記 ?address 
    ] ;
    geo:lat ?lat ;
    geo:long ?long .
  ?equipment rdfs:label ?equipmentLabel .
"""
      unless  equipment_type.match("全て")
        query << "  ?equipment dcterms:subject park:#{equipment_type} ."
      end

  query << """
  OPTIONAL {
    ?equipment park:年齢上限 ?age_max .
  FILTER (?age_max > #{age})
  }
  OPTIONAL {
    ?equipment park:年齢下限 ?age_min .
    FILTER (?age_min < #{age})
  }
}
ORDER BY ?parkLabel
"""
      puts query
      @parks = client.query(query)

    elsif params[:text] and !params[:text].empty?
      text = params[:text]

      query = prefixes +
"""
SELECT DISTINCT ?park ?parkLabel ?postalCode ?address ?lat ?long
WHERE {
  ?park a park:公園 ;
    rdfs:label ?parkLabel ;
    ic:地点_場所/ic:場所_住所 [
      ic:住所_郵便番号 ?postalCode ;
      ic:住所_表記 ?address 
    ] ;
    geo:lat ?lat ;
    geo:long ?long .
  FILTER regex(?parkLabel, '#{text}')
}
ORDER BY ?parkLabel
"""

      @parks = client.query(query)
    end
  end
end
