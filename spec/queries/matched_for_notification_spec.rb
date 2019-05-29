RSpec.describe MatchedForNotification do
  describe "#call" do
    before do
      @subscriber_list_that_should_never_match = create(:subscriber_list, tags: {
        topics: { any: ["Badical Turbo Radness"] }, organisations: { any: ["Sirius Cybernetics Corporation"] }
      })
    end

    def create_subscriber_list_with_tags_facets(facets)
      create(:subscriber_list, tags: facets)
    end

    def create_subscriber_list_with_links_facets(facets)
      create(:subscriber_list, links: facets)
    end

    def create_or_joined_facet_subscriber_list_with_tags_facets(facets)
      create(:or_joined_facet_subscriber_list, tags: facets)
    end

    def create_or_joined_facet_subscriber_list_with_links_facets(facets)
      create(:or_joined_facet_subscriber_list, links: facets)
    end

    def execute_query(query_hash, field: :tags)
      described_class.new(query_field: field).call(query_hash)
    end

    context "subscriber_lists match on tag and links keys" do
      before do
        @lists = {
          tags:
            {
              any_topic_paye_any_org_defra_hmrc: create_subscriber_list_with_tags_facets(topics: { any: %w(paye) }, organisations: { any: %w(defra hmrc) }),
              any_topic_vat_licensing: create_subscriber_list_with_tags_facets(topics: { any: %w(vat licensing) }),
            },
          links:
            {
              any_topic_paye_any_org_defra_hmrc: create_subscriber_list_with_links_facets(topics: { any: %w(paye) }, organisations: { any: %w(defra hmrc) }),
              any_topic_vat_licensing: create_subscriber_list_with_links_facets(topics: { any: %w(vat licensing) }),
            }
        }
      end

      %i(links tags).each do |key|
        it "finds subscriber lists where at least one value of each #{key} in the subscription is present in the query_hash" do
          lists = execute_query({ topics: %w(paye), organisations: %w(defra) }, field: key)
          expect(lists).to eq([@lists[key][:any_topic_paye_any_org_defra_hmrc]])

          lists = execute_query({ topics: %w(paye), organisations: %w(hmrc) }, field: key)
          expect(lists).to eq([@lists[key][:any_topic_paye_any_org_defra_hmrc]])

          lists = execute_query({ topics: %w(vat) }, field: key)
          expect(lists).to eq([@lists[key][:any_topic_vat_licensing]])

          lists = execute_query({ topics: %w(licensing) }, field: key)
          expect(lists).to eq([@lists[key][:any_topic_vat_licensing]])
        end
      end
    end

    context "matches on all topics" do
      before do
        @all_topics_tax_vat = create_subscriber_list_with_tags_facets(topics: { all: %w(vat tax) })
        @all_topics_tax_vat_licensing = create_subscriber_list_with_tags_facets(topics: { all: %w(vat tax licensing) })
      end

      it "finds subscriber lists matching all topics" do
        lists = execute_query(topics: %w(vat tax))
        expect(lists).to eq([@all_topics_tax_vat])
      end
    end

    context "matches on any and all topics" do
      before do
        @all_topics_tax_vat_any_topics_licensing_paye = create_subscriber_list_with_tags_facets(topics: { all: %w(vat tax), any: %w(licensing paye) })
        @all_topics_tax_vat_licensing_any_topics_paye = create_subscriber_list_with_tags_facets(topics: { all: %w(vat tax schools), any: %w(paye) })
      end

      it "finds subscriber lists matching on both of all and one of any topics" do
        lists = execute_query(topics: %w(vat tax licensing))
        expect(lists).to eq([@all_topics_tax_vat_any_topics_licensing_paye])
      end
    end

    context "matches on all of both topics and organisations" do
      before do
        @all_topics_tax_vat_all_orgs_defra_hmrc = create_subscriber_list_with_tags_facets(topics: { all: %w(vat tax) }, organisations: { all: %w(defra hmrc) })
        @all_topics_vat_organisations_defra_hmrc = create_subscriber_list_with_tags_facets(topics: { all: %w(paye schools) }, organisations: { all: %w(defra dfe) })
      end

      it "finds subscriber lists matching a mix of all topics and organisations" do
        lists = execute_query(topics: %w(vat tax licensing), organisations: %w(defra hmrc oft))
        expect(lists).to eq([@all_topics_tax_vat_all_orgs_defra_hmrc])
      end
    end


    context "or_joined_subscriber_lists match on tag and links keys" do
      before do
        @lists = {
          tags:
            {
              any_topic_paye_any_org_defra_hmrc: create_or_joined_facet_subscriber_list_with_tags_facets(topics: { any: %w(paye) }, organisations: { any: %w(defra hmrc) }),
              any_topic_vat_licensing: create_or_joined_facet_subscriber_list_with_tags_facets(topics: { any: %w(vat licensing) }),
            },
          links:
            {
              any_topic_paye_any_org_defra_hmrc: create_or_joined_facet_subscriber_list_with_links_facets(topics: { any: %w(paye) }, organisations: { any: %w(defra hmrc) }),
              any_topic_vat_licensing: create_or_joined_facet_subscriber_list_with_links_facets(topics: { any: %w(vat licensing) }),
            }
        }
      end

      %i(links tags).each do |key|
        it "finds subscriber lists where at least one value of each #{key} in the subscription is present in the query_hash" do
          lists = execute_query({ topics: %w(paye), organisations: %w(defra) }, field: key)
          expect(lists).to eq([@lists[key][:any_topic_paye_any_org_defra_hmrc]])

          lists = execute_query({ topics: %w(paye), organisations: %w(hmrc) }, field: key)
          expect(lists).to eq([@lists[key][:any_topic_paye_any_org_defra_hmrc]])

          lists = execute_query({ topics: %w(vat) }, field: key)
          expect(lists).to eq([@lists[key][:any_topic_vat_licensing]])

          lists = execute_query({ topics: %w(licensing) }, field: key)
          expect(lists).to eq([@lists[key][:any_topic_vat_licensing]])
        end
      end
    end

    context "finds or_joined_subscription lists for the right query hash for 'any' facets" do
      before do
        @lists = {
          tags: {
            or_joined_topics_vat_organisations_hrmc_defra: create_or_joined_facet_subscriber_list_with_tags_facets(topics: { any: %w(vat) }, organisations: { any: %w(hmrc defra) }),
          },
          links: {
            or_joined_topics_vat_organisations_hrmc_defra: create_or_joined_facet_subscriber_list_with_links_facets(topics: { any: %w(vat) }, organisations: { any: %w(hmrc defra) }),
          }
        }
      end

      %i(links tags).each do |key|
        it "will match an or_joined_facet_subscriber_list with multiple facets where there is only one matching facet for #{key}" do
          lists = execute_query({ topics: %w(paye), organisations: %w(defra) }, field: key)
          expect(lists).to eq([@lists[key][:or_joined_topics_vat_organisations_hrmc_defra]])

          lists = execute_query({ topics: %w(paye), organisations: %w(hmrc) }, field: key)
          expect(lists).to eq([@lists[key][:or_joined_topics_vat_organisations_hrmc_defra]])

          lists = execute_query({ topics: %w(vat) }, field: key)
          expect(lists).to eq([@lists[key][:or_joined_topics_vat_organisations_hrmc_defra]])
        end

        it "will match an or_joined_facet_subscriber_list with multiple facets where all facets has at least one match for #{key}" do
          lists = execute_query({ topics: %w(vat), organisations: %w(hmrc) }, field: key)
          expect(lists).to eq([@lists[key][:or_joined_topics_vat_organisations_hrmc_defra]])
        end

        it "will not match an or_joined_facet_subscriber_list with multiple facets where no facets match for #{key}" do
          lists = execute_query({ topics: %w(licensing) }, field: key)
          expect(lists).to eq([])
        end
      end
    end

    context "finds or_joined_subscription lists for the right query hash for 'all' facets" do
      before do
        @lists = {
          tags: {
            or_joined_topics_vat_organisations_hrmc_defra: create_or_joined_facet_subscriber_list_with_tags_facets(topics: { all: %w(vat) }, organisations: { all: %w(hmrc defra) }),
          },
          links: {
            or_joined_topics_vat_organisations_hrmc_defra: create_or_joined_facet_subscriber_list_with_links_facets(topics: { all: %w(vat) }, organisations: { all: %w(hmrc defra) }),
          }
        }
      end

      %i(links tags).each do |key|
        it "will match an or_joined_facet_subscriber_list with multiple facets where there is one facet completely matches for #{key}" do
          lists = execute_query({ topics: %w(vat) }, field: key)
          expect(lists).to eq([@lists[key][:or_joined_topics_vat_organisations_hrmc_defra]])

          lists = execute_query({ topics: %w(vat), organisations: %w(dfe) }, field: key)
          expect(lists).to eq([@lists[key][:or_joined_topics_vat_organisations_hrmc_defra]])

          lists = execute_query({ topics: %w(paye), organisations: %w(hmrc defra) }, field: key)
          expect(lists).to eq([@lists[key][:or_joined_topics_vat_organisations_hrmc_defra]])
        end

        it "will match an or_joined_facet_subscriber_list with multiple facets where all facets completely match for #{key}" do
          lists = execute_query({ topics: %w(vat), organisations: %w(hmrc defra) }, field: key)
          expect(lists).to eq([@lists[key][:or_joined_topics_vat_organisations_hrmc_defra]])
        end

        it "will not match an or_joined_facet_subscriber_list with multiple facets where no facets match for #{key}" do
          lists = execute_query({ topics: %w(paye) }, field: key)
          expect(lists).to eq([])

          lists = execute_query({ organisations: %w(hmrc) }, field: key)
          expect(lists).to eq([])

          lists = execute_query({ topics: %w(paye), organisations: %w(hmrc) }, field: key)
          expect(lists).to eq([])
        end
      end
    end


    context "can return subscriber_lists and or_joined_facet_subscriber_lists" do
      before do
        @or_joined_topics_vat_paye = create_or_joined_facet_subscriber_list_with_tags_facets(topics: { any: %w(vat paye) })
        @topics_vat_paye = create_subscriber_list_with_tags_facets(topics: { any: %w(vat paye) })
      end

      it "will return an or_joined_facet_subscriber_list and an subscriber_list if it matches both" do
        lists = execute_query(topics: %w(vat))
        expect(lists).to eq([@topics_vat_paye, @or_joined_topics_vat_paye])
      end
    end

    context "there are other, non-matching link types in the query hash" do
      before do
        @topics_any_licensing = create_subscriber_list_with_tags_facets(topics: { any: %w(licensing) })
      end

      it "finds lists where all the link types in the subscription have a value present" do
        lists = execute_query(topics: %w(licensing), another_link_thats_not_part_of_the_subscription: %w(elephants))
        expect(lists).to eq([@topics_any_licensing])
      end
    end

    context "there are non-matching values in the query_hash" do
      before do
        @topics_any_licensing = create_subscriber_list_with_tags_facets(topics: { any: %w(licensing) })
      end

      it "finds lists where all the link types in the subscription have a value present" do
        lists = execute_query(topics: %w(licensing elephants))
        expect(lists).to eq([@topics_any_licensing])
      end

      it "doesn't return lists which have no tag types present in the document" do
        lists = execute_query(another_tag_thats_not_part_of_any_subscription: %w(elephants))
        expect(lists).to eq([])
      end
    end

    context "Specialist publisher edge case in format tag" do
      before do
        @subscriber_list = create_subscriber_list_with_tags_facets(format: { any: %w[employment_tribunal_decision] })
      end

      it "finds the list when the criteria values is a string that is present in the subscriber list values for the field" do
        lists = execute_query(format: "employment_tribunal_decision")
        expect(lists).to eq([@subscriber_list])
      end

      it "does not find the list when the criteria values is a string that is not present in the subscriber list values for the field" do
        lists = execute_query(format: "drug_safety_update")
        expect(lists).to eq([])
      end
    end
  end
end
