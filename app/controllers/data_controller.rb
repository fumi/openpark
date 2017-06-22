# -*- coding: utf-8 -*-
class DataController < ApplicationController

  def show
    params.permit(:type, :government_id, :type_id)
    not_found unless params[:type] and params[:government_id] and params[:type_id]
    type = CGI.unescape(params[:type])
    government_id = CGI.unescape(params[:government_id])
    type_id = CGI.unescape(params[:type_id])
    uri = "#{PARK_ROOT}/#{type}/#{government_id}/#{type_id}"
    query = nil
    json_frame = nil

    if /equipment/.match(type)
      query = <<-EOQ
PREFIX ic: <http://imi.go.jp/ns/core/rdf#>
PREFIX park: <http://openpark.jp/ns/park#>
CONSTRUCT {
  ?root a park:遊具型 ;
    ic:ID ?id ;
    ic:名称 ?name ;
    ic:設置地点 ?place ;
    ic:管理者 ?organizaiton ;
    park:種別 ?category ;
    park:仕様規格 ?spec ;
    park:設置数 ?count ;
    park:利用対象 ?target .
  ?id a ic:ID型; ic:識別値 ?id_value .
  ?name a ic:名称型; ic:表記 ?name_value .
  ?count a ic:数量型 ; ic:数値 ?count_value ; ic:単位表記 ?count_unit .
  ?target a ic:対象型; ic:制約 ?limit .
  ?limit a ic:範囲制約型; ic:上限値 ?upper_limit ; ic:下限値 ?lower_limit .
}
WHERE {
  VALUES ?root {<#{uri}>}
  ?root ic:ID ?id ;
    ic:名称 ?name ;
    ic:設置地点 ?place ;
    ic:管理者 ?organization .
  ?id ic:識別値 ?id_value .
  ?name ic:表記 ?name_value .
  OPTIONAL { ?root park:種別 ?category . }
  OPTIONAL { ?root park:仕様規格 ?spec . }
  OPTIONAL {
    ?root park:設置数 ?count .
    ?count ic:数値 ?count_value .
  }
  OPTIONAL {
    ?count ic:単位表記 ?count_unit .
  }
  OPTIONAL {
    ?root park:利用対象 ?target .
    ?target ic:制約 ?limit .
  }
  OPTIONAL {
    ?limit ic:上限値 ?upper_limit .
  }
  OPTIONAL {
    ?limit ic:下限値 ?lower_limit .
  }
}
EOQ

      json_frame = JSON.parse %({
  "@context": "https://openpark.jp/contexts/park",
  "@type": "遊具型"
})
    elsif /organizations/.match(type)
      query = <<-EOQ
PREFIX ic: <http://imi.go.jp/ns/core/rdf#>
CONSTRUCT {
  ?root a ic:組織型 ;
    ic:ID ?id ;
    ic:名称 ?name ;
    ic:連絡先 ?contact .
  ?id a ic:ID型; ic:ID ?id_value .
  ?name a ic:名称型; ic:表記 ?name_value .
  ?contact a ic:連絡先型; ic:電話番号 ?phone .
}
WHERE {
  VALUES ?root {<#{uri}>}
  ?root a ic:組織型 ;
    ic:ID ?id ;
    ic:名称 ?name .
  ?id ic:識別値 ?id_value .
  ?name ic:表記 ?name_value .
  OPTIONAL {
    ?root ic:連絡先 ?contact .
    ?contact ic:電話番号 ?phone .
  }
}
EOQ
      json_frame = JSON.parse %({
  "@context": "https://openpark.jp/contexts/park",
  "@type": "組織型"
})
    else
      query = <<-EOQ
PREFIX ic: <http://imi.go.jp/ns/core/rdf#>
PREFIX park: <http://openpark.jp/ns/park#>
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
CONSTRUCT {
  ?root a park:公園型 ;
    ic:ID ?park_id ;
    ic:名称 ?park_name ;
    ic:種別 ?category ;
    ic:住所 ?address ;
    ic:地理座標 ?geometry ;
    ic:説明 ?description ;
    ic:設備 ?equipment ;
    park:面積 ?area ;
    park:flickrID ?flickrID ;
    owl:sameAs ?sameAs .
  ?park_id a ic:ID型; ic:識別値 ?park_id_value .
  ?park_name a ic:名称型; ic:表記 ?park_name_value .
  ?address a ic:住所型;
    ic:表記 ?address_value ;
    ic:郵便番号 ?postalcode ;
    ic:都道府県 ?prefecture ;
    ic:市区町村 ?city ;
    ic:区 ?ward .
  ?geometry a ic:座標型; ic:経度 ?long ; ic:緯度 ?lat .
  ?area a ic:面積型; ic:数値 ?area_value .
}
WHERE {
  VALUES ?root {<#{uri}>}
  ?root a park:公園型 ;
    ic:ID ?park_id ;
    ic:名称 ?park_name ;
    ic:住所 ?address .
  ?park_id ic:識別値 ?park_id_value .
  ?park_name ic:表記 ?park_name_value .
  ?address ic:表記 ?address_value .
  OPTIONAL { ?address ic:郵便番号 ?postalcode . }
  OPTIONAL { ?address ic:都道府県 ?prefecture . }
  OPTIONAL { ?address ic:市区町村 ?city . }
  OPTIONAL { ?address ic:区 ?ward . }
  OPTIONAL { ?root ic:種別 ?category . }
  OPTIONAL {
    ?root ic:地理座標 ?geometry .
    ?geometry ic:経度 ?long ; ic:緯度 ?lat .
  }
  OPTIONAL { ?root ic:説明 ?description . }
  OPTIONAL { ?root ic:設備 ?equipment . }
  OPTIONAL { ?root park:面積 ?area . ?area ic:数値 ?area_value . }
  OPTIONAL { ?root park:flickrID ?flickrID . }
  OPTIONAL { ?root owl:sameAs ?sameAs . }
}
EOQ

      json_frame = JSON.parse %({
  "@context": "https://openpark.jp/contexts/park",
  "@type": "公園型"
})

    end

    respond_to do |format|
      format.ttl { @result = dump_rdf(:ttl, query) }
      format.rdf { @result = dump_rdf(:rdf, query) }
      format.jsonld { @result = dump_jsonld(:jsonld, query, json_frame) }
    end
  end

  protected

  def dump_jsonld(format, query, frame)
    client = SPARQL::Client.new(OpenPark::Application.config.sparql_endpoint)
    sparql_result = client.query(query)
    input = JSON.parse(sparql_result.dump(:jsonld))
    result = JSON::LD::API.frame(input, frame)
    JSON.pretty_generate(result)
  end

  def dump_rdf(format, query)
    client = SPARQL::Client.new(OpenPark::Application.config.sparql_endpoint)
    sparql_result = client.query(query)
    sparql_result.dump(format, :standard_prefixes => true, :prefixes => PREFIXES)
  end
end
