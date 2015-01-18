class DataController < ApplicationController

  def show_park
    uri = PREFIXES[:park_resource].dup + params[:id]
    respond_to do |format|
      format.ttl { @result = dump_rdf(:ttl, uri) }
      format.rdf { @result = dump_rdf(:rdf, uri) }
      format.jsonld { @result = dump_rdf(:jsonld, uri) }
    end
  end

  protected

  def dump_rdf(format, uri)
    client = SPARQL::Client.new(OpenPark::Application.config.sparql_endpoint)
    sparql_result = client.query("DESCRIBE <#{uri}>")
    sparql_result.dump(format, :standard_prefixes => true, :prefixes => PREFIXES)
  end
end
