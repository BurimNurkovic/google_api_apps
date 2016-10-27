#!/usr/bin/env ruby
# Encoding: utf-8
#
# Copyright:: Copyright 2011, Google Inc. All Rights Reserved.
#
# License:: Licensed under the Apache License, Version 2.0 (the "License");
#           you may not use this file except in compliance with the License.
#           You may obtain a copy of the License at
#
#           http://www.apache.org/licenses/LICENSE-2.0
#
#           Unless required by applicable law or agreed to in writing, software
#           distributed under the License is distributed on an "AS IS" BASIS,
#           WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
#           implied.
#           See the License for the specific language governing permissions and
#           limitations under the License.
#
# This example gets all users sorted by name. To create new users, run
# create_users.rb.

require 'dfp_api'


API_VERSION = :v201602

def get_users_by_statement()
  # Get DfpApi instance and load configuration from ~/dfp_api.yml.
  dfp = DfpApi::Api.new

  # To enable logging of SOAP requests, set the log_level value to 'DEBUG' in
  # the configuration file or provide your own logger:
  # dfp.logger = Logger.new('dfp_xml.log')

  # Get the UserService.
  user_service = dfp.service(:UserService, API_VERSION)

  # Create a statement to get all users sorted by id.
  statement = DfpApi::FilterStatement.new('ORDER BY name ASC')

  begin
    # Get users by statement.
    page = user_service.get_users_by_statement(statement.toStatement())

    if page and page[:results]
      page[:results].each_with_index do |user, index|
        puts "%d) User ID: %d, name: %s, email: %s, role: %s." % [
            index + statement.offset, user[:id], user[:name], user[:email],
            user[:role_name]]
      end
    end
    statement.offset += DfpApi::SUGGESTED_PAGE_LIMIT
  end while statement.offset < page[:total_result_set_size]

  # Print a footer.
  if page.include?(:total_result_set_size)
    puts "Number of results found: %d" % page[:total_result_set_size]
  end
end

if __FILE__ == $0
  begin
    get_users_by_statement()

  # HTTP errors.
  rescue AdsCommon::Errors::HttpError => e
    puts "HTTP Error: %s" % e

  # API errors.
  rescue DfpApi::Errors::ApiException => e
    puts "Message: %s" % e.message
    puts 'Errors:'
    e.errors.each_with_index do |error, index|
      puts "\tError [%d]:" % (index + 1)
      error.each do |field, value|
        puts "\t\t%s: %s" % [field, value]
      end
    end
  end
end
