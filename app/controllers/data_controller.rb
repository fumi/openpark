class DataController < ApplicationController

  def show_park
    uri = PREFIXES[:park_resource].dup + params[:id]
    respond_to do |format|
      format.ttl { @result = dump_rdf(:ttl, uri) }
      format.n3 { @result = dump_rdf(:n3, uri) }
      format.rdf { @result = dump_rdf(:rdf, uri) }
      format.json { @result = dump_rdf(:jsonld, uri) }
      format.jsonld { @result = dump_rdf(:jsonld, uri) }
    end
  end

  protected

  def dump_rdf(format, uri)
    client = SPARQL::Client.new(OpenPark::Application.config.sparql_endpoint)
    sparql_result = client.query("DESCRIBE <#{uri}>")
    puts sparql_result
    #graph = RDF::Graph.new 
    #graph << RDF::Statement.new(RDF::Node.new, RDF::DC.title, "Hello, World")
    sparql_result.dump(format, :standard_prefixes => true, :prefixes => PREFIXES)
  end
end
