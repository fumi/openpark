# -*- coding: utf-8 -*-
class ParksController < ApplicationController
  def show
    park_uri = PREFIXES[:park_resource].dup + params[:id]
    client = SPARQL::Client.new(OpenPark::Application.config.sparql_endpoint)
    
    prefixes = """PREFIX geo: <#{RDF::GEO.to_s}>
PREFIX rdfs: <#{RDF::RDFS.to_s}>
PREFIX schema: <#{RDF::SCHEMA.to_s}>
PREFIX dcterms: <#{RDF::DC.to_s}>
PREFIX ic: <http://imi.ipa.go.jp/ns/core/210#>
PREFIX park: <http://yokohama.openpark.jp/ns/park#>
"""
    park_query = prefixes + """
SELECT DISTINCT ?label ?lat ?long ?description ?address ?postalcode
WHERE {
  <#{park_uri}> a schema:Park ;
    rdfs:label ?label ;
    ic:地点_場所/ic:場所_住所/ic:住所_表記 ?address;
    ic:地点_場所/ic:場所_住所/ic:住所_郵便番号 ?postalcode ;
    geo:lat ?lat ;
    geo:long ?long .
  OPTIONAL {
    <#{park_uri}> dcterms:description ?description .
  }
}
LIMIT 1
"""
    solution = client.query(park_query)
    @markers = []
    solution.each do |solution|
      @markers << { :latlng => [solution[:lat].to_s.to_f, solution[:long].to_s.to_f],
        :popup => solution[:label].to_s,
        :icon => { :icon_url => "#{ActionController::Base.helpers.asset_path('marker-icon.png')}", :shadow_url => "#{ActionController::Base.helpers.asset_path('marker-shadow.png')}", :retina_url => "#{ActionController::Base.helpers.asset_path('marker-icon-2x.png')}" } }
      @park = solution
    end
    
    equipment_query = prefixes + """
SELECT DISTINCT *
WHERE {
  ?equipment_uri a ic:設備 ;
    rdfs:label ?label ;
    ic:設備_管理者/rdfs:label ?organization_label ;
    ic:設備_設置地点 <#{park_uri}> ;
    dcterms:subject/rdfs:label ?subject_label ;
    park:数量 ?count .
  OPTIONAL {
    ?equipment_uri ic:利用者 ?user .
  }
  OPTIONAL {
    ?equipment_uri park:仕様・規格 ?equipment_spec .
  }
  OPTIONAL {
    ?equipment_uri park:年齢上限 ?upper_age_limit .
  }
  OPTIONAL {
    ?equipment_uri park:年齢下限 ?lower_age_limit .
  }
}
"""

    @equipment_solutions = client.query(equipment_query)

  end

  def all_geojson
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
    
    render :json => view_context.to_geojson_from_sparql_results(results)
  end
end
