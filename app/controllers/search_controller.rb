# -*- coding: utf-8 -*-
class SearchController < ApplicationController
  def index
    params.permit(:equipment_type, :age, :text)

    client = SPARQL::Client.new(OpenPark::Application.config.sparql_endpoint)
    prefixes = """PREFIX ic: <#{IC.to_s}>
PREFIX park: <#{PARK.to_s}>
"""

    if (params[:equipmen_type] and !params[:equipment_type].empty?) ||
       (params[:age] and !params[:age].empty?)

      equipment_type = params[:equipment_type] || "全て"
      age = params[:age].to_s || "3"

      query = prefixes +
"""
SELECT DISTINCT ?park ?park_label ?postal_code ?address ?lat ?long ?equipment ?equipment_label ?age_max ?age_min
WHERE {
  ?park a ic:施設型 ;
    ic:名称/ic:表記 ?park_label ;
    ic:設備 ?equipment ;
    ic:住所 [
      ic:郵便番号 ?postal_code ;
      ic:表記 ?address
    ] ;
    ic:地理識別子 [
      ic:経度 ?long ;
      ic:緯度 ?lat
    ] .
  ?equipment ic:名称/ic:表記 ?equipment_label .
"""
      unless  equipment_type.match("全て")
        query << "  ?equipment park:種別 \"#{equipment_type}\"@ja ."
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
ORDER BY ?park_label
"""
      @parks = client.query(query)

    elsif params[:text] and !params[:text].empty?
      text = params[:text]

      query = prefixes +
"""
SELECT DISTINCT ?park ?park_label ?postal_code ?address ?lat ?long
WHERE {
  ?park a ic:施設型 ;
    ic:名称/ic:表記 ?park_label ;
    ic:住所 [
      ic:郵便番号 ?postal_code ;
      ic:表記 ?address
    ] ;
    ic:地理識別子 [
      ic:経度 ?long ;
      ic:緯度 ?lat
    ] .
    FILTER regex(?park_label, '#{text}')
}
ORDER BY ?park_label
"""
      @parks = client.query(query)
    end
  end
end
