require 'ladle'
require 'citadel'

describe Citadel::Backend do
  before :all do
    ldif_path = File.expand_path File.join(File.dirname(__FILE__),'fixtures', 'default.ldif')
    @ldap = Ladle::Server.new(ldif: ldif_path, quiet: true).start
    @backend = Citadel::Backend.new host: 'localhost', port: 3897, dn: 'dc=example,dc=org'
  end

  after :all do
    @ldap.stop
  end

  describe "operating with elements" do
    it "should modify existing element" do

    end

    it "should delete existing element" do
      dn = "uid=nn297,ou=people,dc=example,dc=org"
      result = @backend.delete_element dn
      expect(result).to be_true
    end

    it "should fail on deleting non-existing element" do
      dn = "uuid=188888,ou=people,dc=example,dc=org"
      result = @backend.delete_element dn
      expect(result).to be_false
    end

    it "should return right element on search" do
      filters = [['objectClass', '=', 'person'], ['sn', '=', 'Wise']]
      result = @backend.search('dc=example,dc=org', filters)
      expect(result.first[:mail]).to include('wendy@example.org')
    end
  end
end