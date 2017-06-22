# -*- coding: utf-8 -*-
class OrganizationsController < ApplicationController
  def show
    params.permit(:government_id, :type_id)
    not_found unless params[:government_id] and params[:type_id]
    government_id = CGI.unescape(params[:government_id])
    type_id = CGI.unescape(params[:type_id])
    respond_to do |format|
      format.html { redirect_to "/data/organizations/#{government_id}/#{type_id}.jsonld" , :status => :see_other }
      format.ttl { redirect_to "/data/organizations/#{government_id}/#{type_id}.ttl" , :status => :see_other }
      format.jsonld { redirect_to "/data/organizations/#{government_id}/#{type_id}.jsonld" , :status => :see_other }
      format.rdf { redirect_to "/data/organizations/#{government_id}/#{type_id}.rdf" , :status => :see_other }
    end
  end
end
