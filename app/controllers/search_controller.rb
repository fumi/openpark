# -*- coding: utf-8 -*-
class SearchController < ApplicationController
  def index
    client = SPARQL::Client.new(OpenPark::Application.config.sparql_endpoint)
    prefixes = """PREFIX ic: <#{IC.to_s}>
PREFIX park: <#{PARK.to_s}>
"""

    if (params[:equipmenType] and !params[:equipmentType].empty?) ||
       (params[:age] and !params[:age].empty?)

      equipment_type = params[:equipmentType] || "全て"
      age = params[:age].to_s || "3"

      query = prefixes +
"""
SELECT DISTINCT ?park ?parkLabel ?postalCode ?address ?lat ?long ?equipment ?equipmentLabel ?age_max ?age_min
WHERE {
  ?park a ic:施設 ;
    ic:名称/ic:表記 ?parkLabel ;
    ic:設備 ?equipment ;
    ic:住所 [
      ic:郵便番号 ?postalCode ;
      ic:表記 ?address
    ] ;
    ic:地理識別子 [
      ic:経度 ?lat ;
      ic:緯度 ?long
    ] .
  ?equipment ic:名称/ic:表記 ?equipmentLabel .
"""
      unless  equipment_type.match("全て")
        query << "  ?equipment ic:種別 \"#{equipment_type}\"@ja ."
      end

  query << """
  OPTIONAL {
    ?equipment park:年齢上限 ?age_max .
    FILTER (?age_max >= #{age})
  }
  OPTIONAL {
    ?equipment park:年齢下限 ?age_min .
    FILTER (?age_min <= #{age})
  }
}
ORDER BY ?parkLabel
"""
      puts query
      @parks = client.query(query)

    elsif params[:text] and !params[:text].empty?
      text = params[:text]

      query = prefixes +
"""
SELECT DISTINCT ?park ?parkLabel ?postalCode ?address ?lat ?long
WHERE {
  ?park a ic:施設型 ;
    ic:名称/ic:表記 ?parkLabel ;
    ic:住所 [
      ic:郵便番号 ?postalCode ;
      ic:表記 ?address
    ] ;
    ic:地理識別子 [
      ic:経度 ?lat ;
      ic:緯度 ?long
    ] .
    FILTER regex(?parkLabel, '#{text}')
}
ORDER BY ?parkLabel
"""

      @parks = client.query(query)
    end
  end
end
