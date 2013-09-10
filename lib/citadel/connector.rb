require 'net/ldap'

module Citadel
  class Connector
    attr_reader :session, :connected

    def initialize attributes = {}
      ldap_hostname = attributes[:host]
      ldap_port = attributes[:port]

      ldap_username = attributes[:username]
      ldap_password = attributes[:password]

      @base_dn = attributes[:dn]

      @session = Net::LDAP.new host: ldap_hostname, port: ldap_port
      @session.auth(ldap_username, ldap_password) if (ldap_username && ldap_password)
      begin
        @session.bind
        @connected = true
      rescue
        @connected = false
      end
    end

    def init
      search @base_dn, nil
    end

    def search dn, filters
      filter = Citadel::Filter.transform(filters) if filters
      repository = Array.new
      @session.search(base: dn, filter: filter) do |entry|
        repository << {
          name: entry['name'].first,
          mail: entry['mail'].first,
          departments: entry.dn.split(',').keep_if { |entry| /OU=/.match(entry) }.map { |entry| entry.sub /OU=/, '' },
          phone: entry['telephoneNumber'].first,
          title: entry['title'].first,
          mobile_phone: entry['mobile'].first,
          dn: entry.dn
        }
      end
      return repository
    end

    def delete dn
      @session.delete dn: dn
    end
  end

  class Filter
    def self.transform filters
      raise TypeError, 'Array of [attribute, operand, value] is expected.' unless filters.is_a?(Array)
      filter_chain = nil
      filters = [filters] unless filters.first.is_a?(Array)
      filters.each do |rule|
        attribute = rule[0].to_s
        operand = rule[1].to_s
        value = rule[2].to_s

        operation = case operand
        when "=" then :eq
        when "!=" then :ne
        when "has" then :contains
        end

        if filter_chain
          filter_chain = filter_chain & Net::LDAP::Filter.send(operation, attribute, value)
        else
          filter_chain = Net::LDAP::Filter.send(operation, attribute, value)
        end
      end
      filter_chain
    end
  end
end
