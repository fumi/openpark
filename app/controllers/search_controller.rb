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

    if params[:equipmentType] and !params[:equipmentType].empty?
      equipment_type = params[:equipmentType]

      query = prefixes +
"""
SELECT DISTINCT ?uri ?label ?postalCode ?address ?lat ?long
WHERE {
  ?uri a park:公園 ;
    rdfs:label ?label ;
    """
      unless  equipment_type.match("全て")
        query << "    ic:地点_設備/dcterms:subject park:#{equipment_type} ;"
      end
      query << """
    ic:地点_場所/ic:場所_住所 [
      ic:住所_郵便番号 ?postalCode ;
      ic:住所_表記 ?address 
    ] ;
    geo:lat ?lat ;
    geo:long ?long .
}
ORDER BY ?label
"""
      @parks = client.query(query)
    elsif params[:age] and !params[:age].empty?
      # 結果は年齢制限が明示的にあるものだけにする
      age = params[:age].to_s
      query = prefixes +
"""
SELECT DISTINCT ?uri ?label ?postalCode ?address ?lat ?long
WHERE {
  ?uri a park:公園 ;
    rdfs:label ?label ;
    ic:地点_場所/ic:場所_住所 [
      ic:住所_郵便番号 ?postalCode ;
      ic:住所_表記 ?address 
    ] ;
    ic:地点_設備/dcterms:subject ?equipment ;
    geo:lat ?lat ;
    geo:long ?long .
  OPTIONAL {
    ?equipment park:年齢上限 ?upper_age_limit .
    FILTER (?upper_age_limit > #{age})
  }
  OPTIONAL {
    ?equipment park:年齢下限 ?lower_age_limit .
    FILTER (?lower_age_limit < #{age})
  }
}
ORDER BY ?label
"""
      @parks = client.query(query)
    elsif params[:text] and !params[:text].empty?
      text = params[:text]

      query = prefixes +
"""
SELECT DISTINCT ?uri ?label ?postalCode ?address ?lat ?long
WHERE {
  ?uri a park:公園 ;
    rdfs:label ?label ;
    ic:地点_場所/ic:場所_住所 [
      ic:住所_郵便番号 ?postalCode ;
      ic:住所_表記 ?address 
    ] ;
    geo:lat ?lat ;
    geo:long ?long .
  FILTER regex(?label, '#{text}')
}
ORDER BY ?label
"""

      @parks = client.query(query)
    end
  end
end
