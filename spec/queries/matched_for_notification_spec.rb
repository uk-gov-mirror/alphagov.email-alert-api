RSpec.describe MatchedForNotification do
  describe "#call" do
    before do
      @subscriber_list1 = create(:subscriber_list, tags: {
          topics: { any: ["oil-and-gas/licensing"] }, organisations: { any: ["environment-agency", "hm-revenue-customs"] }
      })

      @subscriber_list2 = create(:subscriber_list, tags: {
          topics: { any: ["business-tax/vat", "oil-and-gas/licensing"] }
      })

      @subscriber_list3 = create(:subscriber_list, links: { topics: { any: ["uuid-123"] }, policies: { any: ["uuid-888"] } })

      @subscriber_list4 = create(:subscriber_list,
                                 links: { topics: { any: ["uuid-123"] } },
                                 tags: {
                                     topics: { any: ["environmental-management/boating"] },
                                 })

      @subscriber_list5 = create(:subscriber_list, links: { topics: { all: ["uuid-123", "uuid-234"] } })

      @subscriber_list6 = create(:subscriber_list, links: { topics: { all: ["uuid-345", "uuid-456"], any: ["uuid-567", "uuid-678"] } })

      @subscriber_list7 = create(:subscriber_list, links: { topics:
                                                                                                  {
                                                                                                      all: ["uuid-345", "uuid-456"]
                                                                                                  },
                                                                                              policies:
                                                                                                  {
                                                                                                      all: ["uuid-567", "uuid-678"]
                                                                                                  } })

      @and_joined_facet_subscriber_list1 = create(:and_joined_facet_subscriber_list, tags: {
        topics: { any: ["oil-and-gas/licensing"] }, organisations: { any: ["environment-agency", "hm-revenue-customs"] }
      })

      @and_joined_facet_subscriber_list2 = create(:and_joined_facet_subscriber_list, tags: {
        topics: { any: ["business-tax/vat", "oil-and-gas/licensing"] }
      })

      @and_joined_facet_subscriber_list3 = create(:and_joined_facet_subscriber_list, links: { topics: { any: ["uuid-123"] }, policies: { any: ["uuid-888"] } })

      @and_joined_facet_subscriber_list4 = create(:and_joined_facet_subscriber_list,
                                                  links: { topics: { any: ["uuid-123"] } },
                                                  tags: {
                                                    topics: { any: ["environmental-management/boating"] },
                                                  })

      @and_joined_facet_subscriber_list5 = create(:and_joined_facet_subscriber_list, links: { topics: { all: ["uuid-123", "uuid-234"] } })

      @and_joined_facet_subscriber_list6 = create(:and_joined_facet_subscriber_list, links: { topics: { all: ["uuid-345", "uuid-456"], any: ["uuid-567", "uuid-678"] } })

      @and_joined_facet_subscriber_list7 = create(:and_joined_facet_subscriber_list, links: { topics:
                                                   {
                                                     all: ["uuid-345", "uuid-456"]
                                                   },
                                                  policies:
                                                   {
                                                     all: ["uuid-567", "uuid-678"]
                                                   } })

      @or_joined_facet_subscriber_list1 = create(:or_joined_facet_subscriber_list, tags: {
          topics: { any: %w[topic_list_1] }, organisations: { any: %w[organisation_1_list_1 organisation_2_list_1] }
      })

      @or_joined_facet_subscriber_list2 = create(:or_joined_facet_subscriber_list, tags: {
          topics: { any: %w[topic_list_2] }, organisations: { all: %w[organisation_1_list_2 organisation_2_list_2] }
      })

      @or_joined_facet_subscriber_list3 = create(:or_joined_facet_subscriber_list, tags: {
          topics: { all: %w[topic_1_list_3 topic_2_list_3] }, organisations: { all: %w[organisation_1_list_3 organisation_2_list_3] }
      })

      @or_joined_facet_subscriber_list4 = create(:or_joined_facet_subscriber_list, tags: {
          topics: { all: %w[topic_1_list_4] }, organisations: { any: %w[organisation_1_list_4 organisation_2_list_4] }
      })
      @or_joined_facet_subscriber_list5 = create(:or_joined_facet_subscriber_list, tags: {
          topics: { any: %w[topic_1_list_5 topic_2_list_5] }, organisations: { any: %w[organisation_1_list_5 organisation_2_list_5] }
      })
    end

    def execute_query(field:, query_hash:)
      described_class.new(query_field: field).call(query_hash)
    end

    context "finds and_joined_facet_subscription_lists for the right query hash and treats a subscriber_list as and_joined" do
      it "finds and_joined facet subscriber lists where at least one value of each link in the subscription is present in the query_hash" do
        lists = execute_query(field: :tags, query_hash: { topics: ["oil-and-gas/licensing"] })
        expect(lists).to eq([@subscriber_list2, @and_joined_facet_subscriber_list2])

        lists = execute_query(field: :tags, query_hash: { topics: ["business-tax/vat"] })
        expect(lists).to eq([@subscriber_list2, @and_joined_facet_subscriber_list2])

        lists = execute_query(field: :tags, query_hash: {
          topics: ["oil-and-gas/licensing"], organisations: ["environment-agency"]
        })
        expect(lists).to eq([@subscriber_list1, @subscriber_list2, @and_joined_facet_subscriber_list1, @and_joined_facet_subscriber_list2])

        lists = execute_query(field: :links, query_hash: { topics: ["uuid-123"], policies: ["uuid-888"] })
        expect(lists).to eq([@subscriber_list3, @subscriber_list4, @and_joined_facet_subscriber_list3, @and_joined_facet_subscriber_list4])

        lists = execute_query(field: :links, query_hash: { topics: ["uuid-123"] })
        expect(lists).to eq([@subscriber_list4, @and_joined_facet_subscriber_list4])
      end

      it 'finds subscriber lists matching all topics' do
        lists = execute_query(field: :links, query_hash: { topics: ["uuid-234", "uuid-123"] })
        expect(lists).to include(@and_joined_facet_subscriber_list5)
      end

      it 'finds subscriber lists matching any and all topics' do
        lists = execute_query(field: :links, query_hash: { topics: ["uuid-345", "uuid-678", "uuid-456"] })
        expect(lists).to include(@and_joined_facet_subscriber_list6)
      end

      it 'finds subscriber lists matching a mix of any and all topics and policies' do
        lists = execute_query(field: :links, query_hash: { topics: ["uuid-345", "uuid-456", "other1"],
                                                           policies: ["uuid-567", "uuid-678", "other2"] })
        expect(lists).to include(@and_joined_facet_subscriber_list7)
      end
    end

    context "finds or joined subscription lists for the right query hash" do
      it 'will match an OrJoinedSubscriberList with multiple facets where there is only one matching facet' do
        lists = execute_query(field: :tags, query_hash: { topics: %w[topic_list_1] })
        expect(lists).to eq([@or_joined_facet_subscriber_list1])
      end

      it 'will match an OrJoinedSubscriberList with multiple facets where all facets match' do
        lists = execute_query(field: :tags, query_hash: { topics: %w[topic_list_1], organisations: %w[organisation_1_list_1 organisation_2_list_1] })
        expect(lists).to eq([@or_joined_facet_subscriber_list1])
      end

      it 'will not match an OrJoinedSubscriberList with multiple facets where no facets match' do
        lists = execute_query(field: :tags, query_hash: { format: %w[employment_tribunal_decision] })
        expect(lists).to eq([])
      end

      it 'will not match an OrJoinedSubscriberList if the query match only matches one of just one facet that has an all' do
        lists = execute_query(field: :tags, query_hash: { organisations: %w[organisation_1_list_2] })
        expect(lists).to eq([])
      end

      it 'will not match an OrJoinedSubscriberList if the query match only matches one of all facets that have alls' do
        lists = execute_query(field: :tags, query_hash: { topics: %w[topic_1_list_3], organisations: %w[organisation_1_list_3] })
        expect(lists).to eq([])
      end

      it 'will not match an OrJoinedSubscriberList if the query match does not match any of all facets that have alls' do
        lists = execute_query(field: :tags, query_hash: { format: %w[employment_tribunal_decision] })
        expect(lists).to eq([])
      end

      it 'will match an OrJoinedSubscriberList if the query match only matches one of just one facet that has an any' do
        lists = execute_query(field: :tags, query_hash: { organisations: %w[organisation_1_list_4] })
        expect(lists).to eq([@or_joined_facet_subscriber_list4])
      end

      it 'will match an OrJoinedSubscriberList if the query match only matches one of all facets that have any' do
        lists = execute_query(field: :tags, query_hash: { topics: %w[topic_1_list_5], organisations: %w[organisation_1_list_5] })
        expect(lists).to eq([@or_joined_facet_subscriber_list5])
      end

      it 'will not match an OrJoinedSubscriberList if the query match does not match any of all facets that have any' do
        lists = execute_query(field: :tags, query_hash: { topics: %w[non_existent_topic], organisations: %w[non_existent_organisation] })
        expect(lists).to eq([])
      end
    end

    context "can return or and and joined facet subscriber lists" do
      it 'will return an or_joined_facet_subscriber_list and an and_joined_facet_subscriber_list if it matches both' do
        lists = execute_query(field: :tags, query_hash: { topics: ["topic_list_1", "business-tax/vat"] })
        expect(lists).to eq([@subscriber_list2, @and_joined_facet_subscriber_list2, @or_joined_facet_subscriber_list1])
      end
    end

    context "there are other, non-matching link types in the query hash" do
      let(:lists) do
        execute_query(field: :tags, query_hash: {
          topics: ["oil-and-gas/licensing"],
          another_link_thats_not_part_of_the_subscription: %w[elephants],
        })
      end

      it "finds lists where all the link types in the subscription have a value present" do
        expect(lists).to eq([@subscriber_list2, @and_joined_facet_subscriber_list2])
      end
    end

    context "there are non-matching values in the query_hash" do
      let(:lists) {
        execute_query(field: :tags, query_hash: {
          topics: ["oil-and-gas/licensing", "elephants"],
        })
      }

      it "finds lists where all the link types in the subscription have a value present" do
        expect(lists).to eq([@subscriber_list2, @and_joined_facet_subscriber_list2])
      end
    end

    context "Specialist publisher edge case" do
      let!(:subscriber_list) { create(:and_joined_facet_subscriber_list, tags: { format: { any: %w[employment_tribunal_decision] } }) }

      it "finds the list when the criteria values is a string that is present in the subscriber list values for the field" do
        lists = execute_query(field: :tags, query_hash: {
          format: "employment_tribunal_decision",
        })

        expect(lists).to eq([subscriber_list])
      end

      it "does not find the list when the criteria values is a string that is not present in the subscriber list values for the field" do
        lists = execute_query(field: :tags, query_hash: {
          format: "drug_safety_update",
        })

        expect(lists).to eq([])
      end
    end

    it "doesn't return lists which have no tag types present in the document" do
      lists = execute_query(field: :tags, query_hash: {
        another_tag_thats_not_part_of_any_subscription: %w[elephants],
      })
      expect(lists).to eq([])
    end
  end
end
