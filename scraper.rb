#!/bin/env ruby
# frozen_string_literal: true

require 'pry'
require 'scraped'
require 'scraperwiki'
require 'wikidata_ids_decorator'

require 'open-uri/cached'
OpenURI::Cache.cache_path = '.cache'

class MembersPage < Scraped::HTML
  decorator WikidataIdsDecorator::Links

  field :members do
    member_rows.css('li a').map { |li| fragment(li => MemberItem).to_h }
  end

  private

  def member_table
    noko.xpath('//table[.//th[contains(.,"Members of Stortinget")]]')
  end

  def member_rows
    member_table.xpath('.//tr[td]')
  end
end

class MemberItem < Scraped::HTML
  field :id do
    noko.attr('wikidata')
  end

  field :name do
    noko.text.tidy
  end

  field :area do
    noko.xpath('preceding::th').last.text.tidy
  end
end

url = 'https://en.wikipedia.org/wiki/Template:Stortinget_2017%E2%80%932021'
Scraped::Scraper.new(url => MembersPage).store(:members)
