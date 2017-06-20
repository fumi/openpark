class DataController < ApplicationController

  def initialize
    @query_template = <<-EOQ
PREFIX ic: <http://imi.go.jp/ns/core/rdf#>
PREFIX park: <http://openpark.jp/ns/park#>
CONSTRUCT {
  ?root a park:公園型 ;
    ic:名称 [ a ic:名称型; ic:表記 ?label ] ;
    ic:住所 [ a ic:住所型; ic:表記 ?address ] ;
    ic:郵便番号 ?postalcode ;
    ic:地理座標 [ a ic:座標型; ic:経度 ?long ; ic:緯度 ?lat ] ;
    ic:説明 ?description ;
    ic:設備 ?equipment ;
    park:面積 [ a ic:面積型; ic:数値 ?area ]
  .
}
WHERE {
  ?root a park:公園型 ;
    ic:名称/ic:表記 ?label ;
    ic:住所/ic:表記 ?address .
  OPTIONAL { ?root ic:郵便番号 ?postalcode . }
  OPTIONAL {
    ?root ic:地理座標 [
      ic:経度 ?long ;
      ic:緯度 ?lat
    ] .
  }
  OPTIONAL {
    ?root ic:設備 ?equipment .
  }
  OPTIONAL { ?root ic:説明 ?description . }
  OPTIONAL { ?root park:面積/ic:数値 ?area . }
  BIND (<%s> AS ?root)
}
LIMIT 1
EOQ
    super
  end

  def show_park
    params.permit(:government_id, :park_id)
    not_found unless params[:government_id] and params[:park_id]
    government_id = CGI.unescape(params[:government_id])
    park_id = CGI.unescape(params[:park_id])

    uri = PREFIXES[:park_resource].dup + government_id + '/' + park_id
    respond_to do |format|
      format.ttl { @result = dump_rdf(:ttl, uri) }
      format.rdf { @result = dump_rdf(:rdf, uri) }
      format.jsonld { @result = dump_jsonld(:jsonld, uri) }
    end
  end

  protected

  def dump_jsonld(format, uri)
#    "http://openpark.jp/contexts/park"
    frame = JSON.parse %({
  "@context": "http://openpark.jp/contexts/park",
  "@type": "公園型",
  "住所": {
    "@type": "住所型"
  },
  "地理座標": {
    "@type": "座標型"
  },
  "面積": {
    "@type": "面積型"
  }
})
#  "@type": "公園型"
    client = SPARQL::Client.new(OpenPark::Application.config.sparql_endpoint)
    query = @query_template % uri
    puts query
    sparql_result = client.query(query)
    input = JSON.parse(sparql_result.dump(:jsonld))
    puts input
    test = JSON::LD::API.frame(input, frame)
    puts test
    JSON.pretty_generate(test)
    #input = sparql_result.dump(format, :standard_prefixes => true, :context => frame)
  end

  def dump_rdf(format, uri)
    client = SPARQL::Client.new(OpenPark::Application.config.sparql_endpoint)
    query = @query_template % uri
    sparql_result = client.query(query)
    input = sparql_result.dump(format, :standard_prefixes => true, :prefixes => PREFIXES)
  end

  def dump_rdf_obsolute(format, uri)
    client = SPARQL::Client.new(OpenPark::Application.config.sparql_endpoint)
    sparql_result = client.query("DESCRIBE <#{uri}>")
    sparql_result.dump(format, :standard_prefixes => true, :prefixes => PREFIXES)
  end
end
