class SubscriberListsController < ApplicationController
  def index
    subscriber_list = FindExactQuery.new(find_exact_query_params).exact_match

    # NB: This also needs to find/create an OrJoinedSubscriberList if there are any existing_subscriber_list_slugs_to_be_or_joined
    # in the same way that SubscriberListBuilderService does

    if subscriber_list
      render json: subscriber_list.to_json(existing_subscriber_list_slugs_to_be_or_joined: existing_subscriber_list_slugs_to_be_or_joined)
    else
      render json: { message: "Could not find the subscriber list" }, status: 404
    end
  end

  def show
    subscriber_list = SubscriberList.find_by(slug: params[:slug])
    if subscriber_list.nil?
      subscriber_list = OrJoinedSubscriberList.find_by(slug: params[:slug])
    end

    if subscriber_list
      render json: {
        subscribable: subscriber_list.attributes, # for backwards compatiblity
        subscriber_list: subscriber_list.attributes,
      }, status: status
    else
      render json: { message: "Could not find the subcsriber list" }, status: 404
    end
  end

  def create
    subscriber_list_builder_service = SubscriberListBuilderService.new(subcriber_list_params, existing_subscriber_list_slugs_to_be_or_joined)
    success, response = subscriber_list_builder_service.call
    if success
      render json: response, status: 201
    else
      render json: { message: response }, status: 422
    end
  end

private

  def subscriber_list_params
    title = params.fetch(:title)

    find_exact_query_params.merge(
      title: title,
      signon_user_uid: current_user.uid,
    )
  end

  def convert_legacy_params(link_or_tags)
    link_or_tags.transform_values do |link_or_tag|
      link_or_tag.is_a?(Hash) ? link_or_tag : { any: link_or_tag }
    end
  end

  def find_exact_query_params
    permitted_params = params.permit!.to_h
    {
      tags: convert_legacy_params(permitted_params.fetch(:tags, {})),
      links: convert_legacy_params(permitted_params.fetch(:links, {})),
      document_type: permitted_params.fetch(:document_type, ""),
      email_document_supertype: permitted_params.fetch(:email_document_supertype, ""),
      government_document_supertype: permitted_params.fetch(:government_document_supertype, ""),
      content_purpose_supergroup: permitted_params.fetch(:content_purpose_supergroup, nil),
      slug: params[:gov_delivery_id],
    }
  end

  def existing_subscriber_list_slugs_to_be_or_joinedor_joined_slugs
    params[:existing_subscriber_list_slugs_to_be_or_joined] || []
  end
end
