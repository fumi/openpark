class DataController < ApplicationController

  def show_park
    params.permit(:government_id, :park_id)
    not_found unless params[:government_id] and params[:park_id]
    government_id = CGI.unescape(params[:government_id])
    park_id = CGI.unescape(params[:park_id])
    puts government_id, park_id

    uri = PREFIXES[:park_resource].dup + government_id + '/' + park_id
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
