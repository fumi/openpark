# -*- coding: utf-8 -*-
class ParksController < ApplicationController
  def show
    params.permit(:government_id, :park_id)
    not_found unless params[:government_id] and params[:park_id]
    government_id = CGI.unescape(params[:government_id])
    park_id = CGI.unescape(params[:park_id])
    respond_to do |format|
      format.html { show_html(government_id, park_id) }
      format.ttl { redirect_to "/data/parks/#{government_id}/#{park_id}.ttl" , :status => :see_other }
      format.jsonld { redirect_to "/data/parks/#{government_id}/#{park_id}.jsonld" , :status => :see_other }
      format.rdf { redirect_to "/data/parks/#{government_id}/#{park_id}.rdf" , :status => :see_other }
    end
  end

  def all_geojson
    client = SPARQL::Client.new(OpenPark::Application.config.sparql_endpoint)
    query = """PREFIX ic: <#{PREFIXES[:ic]}>
PREFIX park: <#{PREFIXES[:park]}>
SELECT ?park ?label ?lat ?long
WHERE {
  ?park a park:公園型 ;
    ic:名称/ic:表記 ?label ;
    ic:地理座標 [
      ic:経度 ?long ;
      ic:緯度 ?lat
    ] .
}
    """
    results = client.query(query)

    render :json => view_context.to_geojson_from_sparql_results(results)
  end

  protected

  def show_html(government_id, park_id)
    park_uri = PREFIXES[:park_resource].dup + government_id + '/' + park_id
    client = SPARQL::Client.new(OpenPark::Application.config.sparql_endpoint)

    prefixes = """PREFIX ic: <#{PREFIXES[:ic]}>
PREFIX park: <#{PREFIXES[:park]}>
"""

    park_query = prefixes + """
SELECT DISTINCT ?label ?lat ?long ?description ?address ?postalcode
WHERE {
  <#{park_uri}> a park:公園型 ;
  ic:名称/ic:表記 ?label ;
  ic:住所 [
    ic:表記 ?address;
    ic:郵便番号 ?postalcode ;
  ] ;
  ic:地理座標 [
    ic:経度 ?long ;
    ic:緯度 ?lat
  ] .
  OPTIONAL {
    <#{park_uri}> ic:説明 ?description .
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
  ?equipment_uri a park:遊具型 ;
    ic:名称/ic:表記 ?label ;
    ic:管理者/ic:名称/ic:表記 ?organization_label ;
    ic:設置地点 <#{park_uri}> ;
    park:種別 ?subject_label ;
    park:設置数 [
      ic:数値 ?count
    ] .
  OPTIONAL {
    ?equipment_uri ic:利用者 ?user .
  }
  OPTIONAL {
    ?equipment_uri park:仕様規格 ?equipment_spec .
  }
  OPTIONAL {
    ?equipment_uri park:利用対象/ic:制限/park:上限値 ?upper_age_limit .
  }
  OPTIONAL {
    ?equipment_uri park:利用対象/ic:制限/park:下限値 ?lower_age_limit .
  }
}
"""
    @equipment_solutions = client.query(equipment_query)

  end

end
