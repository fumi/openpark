class ParksController < ApplicationController
  def view
    @park = {
      uri: "http://yokohama.openpark.jp/parks/" + params[:id]
    }
    client = SPARQL::Client.new("http://localhost:8890/sparql")
    query = """PREFIX geo: <#{RDF::GEO.to_s}>
PREFIX rdfs: <#{RDF::RDFS.to_s}>
PREFIX schema: <#{RDF::SCHEMA.to_s}>
PREFIX dcterms: <#{RDF::DC.to_s}>
PREFIX openpark: <http://openpark.jp/ns/openpark#>

SELECT ?label ?lat ?long ?description ?flickrID
WHERE {
  <#{@park[:uri]}> a schema:Park ;
    rdfs:label ?label ;
    geo:lat ?lat ;
    geo:long ?long .
  OPTIONAL {
    <#{@park[:uri]}> dcterms:description ?description .
  }
}
    """
    puts query
    results = client.query(query)
    @markers = []
    results.each do |solution|
      @markers << { :latlng => [solution[:lat].to_s.to_f, solution[:long].to_s.to_f],
        :popup => solution[:label].to_s,
        :icon => { :icon_url => "#{ActionController::Base.helpers.asset_path('marker-icon.png')}", :shadow_url => "#{ActionController::Base.helpers.asset_path('marker-shadow.png')}", :retina_url => "#{ActionController::Base.helpers.asset_path('marker-icon-2x.png')}" } }
      @park[:label] = solution[:label]
      @park[:lat] = solution[:lat]
      @park[:long] = solution[:long]
      @park[:description] = solution[:description]
    end
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
