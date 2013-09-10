require 'ladle'

describe Citadel::Connector do
  before :all do
    ldif_path = File.expand_path File.join(File.dirname(__FILE__), '..','..','fixtures', 'default.ldif')
    @ldap = Ladle::Server.new(ldif: ldif_path, quiet: true).start
    @connection = Citadel::Connector.new(host: 'localhost', port: 3897, dn: "dc=example,dc=org")
  end

  after :all do
    @ldap.stop if @ldap
  end

  it "should retrieve connection state on auth" do
    expect(@connection.connected).to be_true
  end

  it "should retrieve results on right credentials" do
    result = @connection.init(['objectClass', '=', 'person'])
    expect(result.size).to be > 1
  end

  describe "negative tests" do
    it "should return false on wrong credentials" do
      connection = Citadel::Connector.new(host: 'localhost', port: 11122)
      expect(connection.connected).to be_false
    end
  end
end