module ApplicationHelper

  def to_geojson_from_sparql_results(results)
    json = {}
    json["type"] = "FeatureCollection"
    json["features"] = []
    results.each do |result|
      tmp = {}
      tmp["type"] = "Feature"
      tmp["geometry"] = {}
      tmp["geometry"]["type"] = "Point"
      tmp["geometry"]["coordinates"] = [result[:long].to_s.to_f, result[:lat].to_s.to_f]
      tmp["properties"] = {}
      result.each do |key, value|
        tmp["properties"]["#{key}".to_s] = value.to_s
      end
      json["features"] << tmp
    end
    json
  end

  def to_geojson_from_sparql_results_bak(results)
    str = '{ "type": "FeatureCollection",\n  \"features\": [\n'

    results.each do |result|
      str << '    { "type": "Feature",\n'
      str << '      "geometry":{ "type": "Point", "coordinates": [#{result[:long]}, #{result[:lat]}] }\n'
      str << '      "properties": { '
      result.each do |key, value|
        str << '"#{key}": "#{value}", '
      end
      str << '      }\n'
      str << '    }\n'
    end
    str << '  ]\n}\n'
    str.to_json
  end
  # Original is map function of Leaflet::ViewHelpers
  #
  # Copyright (c) 2010-2013, Vladimir Agafonkin
  # Copyright (c) 2010-2011, CloudMade
  # Copyright (c) 2012-2013, Akshay Joshi
  # All rights reserved.
  #
  # Redistribution and use in source and binary forms, with or without modification, are
  # permitted provided that the following conditions are met:
  #
  #   1. Redistributions of source code must retain the above copyright notice, this list of
  #      conditions and the following disclaimer.
  #
  #   2. Redistributions in binary form must reproduce the above copyright notice, this list
  #      of conditions and the following disclaimer in the documentation and/or other materials
  #      provided with the distribution.
  #
  # THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY
  # EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
  # MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
  # COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
  # EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
  # SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
  # HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
  # TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  # SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
  def map_to_leaflet(options)
    options[:tile_layer] ||= Leaflet.tile_layer
    options[:attribution] ||= Leaflet.attribution
    options[:max_zoom] ||= Leaflet.max_zoom
    options[:subdomains] ||= Leaflet.subdomains
    options[:container_id] ||= 'map'

    tile_layer = options.delete(:tile_layer) || Leaflet.tile_layer
    attribution = options.delete(:attribution) || Leaflet.attribution
    max_zoom = options.delete(:max_zoom) || Leaflet.max_zoom
    container_id = options.delete(:container_id) || 'map'
    cluster = options.delete(:cluster)
    no_container = options.delete(:no_container)
    center = options.delete(:center)
    markers = options.delete(:markers)
    circles = options.delete(:circles)
    polylines = options.delete(:polylines)
    fitbounds = options.delete(:fitbounds)

    output = []
    output << "<div id='#{container_id}'></div>" unless no_container
    output << "<script>"
    output << "var map = L.map('#{container_id}')"

    if center
      output << "map.setView([#{center[:latlng][0]}, #{center[:latlng][1]}], #{center[:zoom]})"
    end

    output << "L.tileLayer('#{tile_layer}', {
          attribution: '#{attribution}',
          maxZoom: #{max_zoom},"

    if options[:subdomains]
      output << "    subdomains: #{options[:subdomains]},"
      options.delete( :subdomains )
    end

    options.each do |key, value|
      output << "#{key.to_s.camelize(:lower)}: '#{value}',"
    end
    output << "}).addTo(map)"

    if markers
      if cluster
        puts "Cluster: #{cluster}"
        output << "var cluster = L.markerClusterGroup()"
      end
      markers.each_with_index do |marker, index|
        if marker[:icon]
          icon_settings = prep_icon_settings(marker[:icon])
          output << "var #{icon_settings[:name]}#{index} = L.icon({iconUrl: '#{icon_settings[:icon_url]}', retinaUrl: '#{icon_settings[:retina_url]}', shadowUrl: '#{icon_settings[:shadow_url]}', iconSize: #{icon_settings[:icon_size]}, shadowSize: #{icon_settings[:shadow_size]}, iconAnchor: #{icon_settings[:icon_anchor]}, shadowAnchor: #{icon_settings[:shadow_anchor]}, popupAnchor: #{icon_settings[:popup_anchor]}})"
          output << "marker = L.marker([#{marker[:latlng][0]}, #{marker[:latlng][1]}], {icon: #{icon_settings[:name]}#{index}})"
        else
          output << "marker = L.marker([#{marker[:latlng][0]}, #{marker[:latlng][1]}])"
        end
        if marker[:popup]
          output << "marker.bindPopup('#{marker[:popup]}')"
        end
        if cluster
          output << "cluster.addLayer(marker)"
        else
          output << "marker.addTo(map)"
        end
      end
      if cluster
        output << "map.addLayer(cluster)"
      end
    end

    if circles
      circles.each do |circle|
        output << "L.circle(['#{circle[:latlng][0]}', '#{circle[:latlng][1]}'], #{circle[:radius]}, {
           color: '#{circle[:color]}',
           fillColor: '#{circle[:fillColor]}',
           fillOpacity: #{circle[:fillOpacity]}
        }).addTo(map);"
      end
    end

    if polylines
      polylines.each do |polyline|
        _output = "L.polyline(#{polyline[:latlngs]}"
        _output << "," + polyline[:options].to_json if polyline[:options]
        _output << ").addTo(map);"
        output << _output.gsub(/\n/,'')
      end
    end

    if fitbounds
      output << "map.fitBounds(L.latLngBounds(#{fitbounds}));"
    end

    output << "</script>"
    output.join("\n").html_safe
  end

  private

  def prep_icon_settings(settings)
    settings[:name] = 'icon' if settings[:name].nil? or settings[:name].blank?
    settings[:retina_url] = '' if settings[:retina_url].nil?
    settings[:shadow_url] = '' if settings[:shadow_url].nil?
    settings[:icon_size] = [] if settings[:icon_size].nil?
    settings[:shadow_size] = [] if settings[:shadow_size].nil?
    settings[:icon_anchor] = [0, 0] if settings[:icon_anchor].nil?
    settings[:shadow_anchor] = [0, 0] if settings[:shadow_anchor].nil?
    settings[:popup_anchor] = [0, 0] if settings[:popup_anchor].nil?
    return settings
  end
end
