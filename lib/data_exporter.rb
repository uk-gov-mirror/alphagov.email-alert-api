require "csv"

class DataExporter
  BUSINESS_READINESS_FINDER_SLUG_PREFIX = "find-eu-exit-guidance-for-your-business-with-sector".freeze

  def export_csv_from_ids(ids)
    export_csv(SubscriberList.where(id: ids))
  end

  def export_csv_from_ids_at(date, ids)
    export_csv(SubscriberList.where(id: ids), at: date)
  end

  def export_csv_from_slugs(slugs)
    export_csv(SubscriberList.where(slug: slugs))
  end

  def export_csv_from_slugs_at(date, slugs)
    export_csv(SubscriberList.where(slug: slugs), at: date)
  end

  def export_csv_from_living_in_europe
    export_csv(living_in_europe_subscriber_lists)
  end

  def export_csv_from_sectors_in_business_readiness
    business_sectors.each do |sector|
      CSV($stdout, headers: %i(title count), write_headers: true) do |csv|
        csv << {
          title: sector["label"],
          count: SubscriberList
                  .where("slug LIKE '#{BUSINESS_READINESS_FINDER_SLUG_PREFIX}%'")
                  .where("tags->>'sector_business_area' LIKE ?", "%#{sector['value']}%")
                  .map(&:subscribers).flatten.count,
        }
      end
    end
  end

private

  CSV_HEADERS = %i(id title count).freeze

  EUROPEAN_COUNTRIES = %w(
    austria belgium bulgaria croatia cyprus czech-republic denmark estonia finland france germany greece hungary
    ireland italy latvia lithuania luxembourg malta netherlands poland portugal slovakia slovenia spain sweden
    switzerland iceland norway liechtenstein
  ).freeze

  def living_in_europe_subscriber_lists
    slugs = EUROPEAN_COUNTRIES.map { |country| "living-in-#{country}" }
    SubscriberList.where(slug: slugs)
  end

  def business_sectors
    facets_filename = File.join(Rails.root, "config", "find-eu-exit-guidance-business.yml")
    if File.exist?(facets_filename)
      @facet_config ||= YAML.load_file(facets_filename)
      @facet_config["details"]["facets"].first["allowed_values"]
    end
  end

  def subscriber_list_count(subscriber_list, date)
    return subscriber_list.active_subscriptions_count unless date

    subscriber_list
      .subscriptions
      .where("created_at < ?", date)
      .where("ended_at IS NULL OR ended_at >= ?", date)
      .count
  end

  def present_subscriber_list(subscriber_list, at:)
    {
      id: subscriber_list.id,
      title: subscriber_list.title,
      count: subscriber_list_count(subscriber_list, at),
    }
  end

  def export_csv(subscriber_lists, at: nil)
    CSV($stdout, headers: CSV_HEADERS, write_headers: true) do |csv|
      subscriber_lists.find_each do |subscriber_list|
        csv << present_subscriber_list(subscriber_list, at: at)
      end
    end
  end
end
