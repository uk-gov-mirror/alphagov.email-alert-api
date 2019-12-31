class TagsValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, tags)
    unless tag_values_are_arrays(tags)
      record.errors.add(attribute, "All tag values must be sent as Arrays")
    end

    if invalid_tags(tags).any?
      record.errors.add(attribute, "#{invalid_tags(tags).to_sentence} are not valid tags.")
    end

    if invalid_formatted_tags(tags).any?
      record.errors.add(attribute, "#{invalid_formatted_tags(tags).to_sentence} have a value with an invalid format.")
    end
  end

private

  def invalid_tags(tags)
    tags.keys - ValidTags::ALLOWED_TAGS
  end

  def tag_values_are_arrays(tags)
    tags.values.all? do |hash|
      hash.all? do |operator, values|
        %i[all any].include?(operator) && values.is_a?(Array)
      end
    end
  end

  def invalid_formatted_tags(tags)
    @invalid_formatted_tags ||= begin
      tags.reject { |_key, tag_values|
        values = tag_values.fetch(:any, []) + tag_values.fetch(:all, [])
        values.find { |tag| tag.match?(/\A[a-zA-Z0-9-_\/]*\z/) }
      }.keys
    end
  end
end
