class ParksController < ApplicationController
  def view
    @park = {
      uri: "http://kanazawa.openpark.jp/parks/" + params[:id]
    }
    client = SPARQL::Client.new("http://localhost:8890/sparql")
    query = """PREFIX geo: <#{RDF::GEO.to_s}>
PREFIX rdfs: <#{RDF::RDFS.to_s}>
PREFIX schema: <#{RDF::SCHEMA.to_s}>
PREFIX dcterms: <#{RDF::DC.to_s}>

SELECT ?label ?lat ?long ?description
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
        :popup => "<a href=\"#{solution[:park].to_s}\">#{solution[:label].to_s}</a>" }
      @park[:label] = solution[:label]
      @park[:lat] = solution[:lat]
      @park[:long] = solution[:long]
      @park[:description] = solution[:description]
    end
  end
end
