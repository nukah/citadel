module Citadel
  class Backend
    class Unconnected < Exception; end;
    class ConfigNotFound < Exception; end;

    def initialize config
      raise ConfigNotFound, "Provided config path #{config} not found." unless File.exists?(config)
      cnf = YAML::load(File.open(File.expand_path(config)))['fort']
      @connection = Fort::Connector.new host: cnf[:host], port: cnf[:port], username: cnf[:username], password: cnf[:password], dn: cnf[:dn]
    end

    def delete_element dn
      @connection.delete dn
    end

    def update_element dn, changed = {}
      raise Unconnected, 'Not connected to server.' unless @connection
      operations = []
      changed.each { |k,v| operations << [:replace, k.to_sym, v] }
      @connection.modify dn: dn, operations: operations
    end

    def get_elements
      raise Unconnected, 'Not connected to server.' unless @connection
      @connection.init
    end

    def search dn, filters
      raise Unconnected, 'Not connected to server.' unless @connection
      @connection.search dn, filters
    end
  end
end