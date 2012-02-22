require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Interfax" do
  before(:each) do
    ENV['INTERFAX_USERNAME'] = 'defaultusername'
    ENV['INTERFAX_PASSWORD'] = 'defaultpassword'
  end
  let(:interfax) { Interfax.new }
  context "username and password is not passed" do
    let(:interfax) { Interfax.new }
    it "should store username and password from environment variables" do
      interfax.instance_variable_get(:@username).should == 'defaultusername'
      interfax.instance_variable_get(:@password).should == 'defaultpassword'
    end
  end
  context "username and password is passed" do
    let(:interfax) { Interfax.new(:username => 'myusername', :password => 'mypassword') }
    it "should store username and password from values passed" do
      interfax.instance_variable_get(:@username).should == 'myusername'
      interfax.instance_variable_get(:@password).should == 'mypassword'
    end
  end
  it "should have WSDL_URL" do
    Interfax::WSDL_URL.should == "https://ws.interfax.net/dfs.asmx?WSDL"
  end
  describe "#client" do
    it "should return savon client" do
      interfax.client.should be_kind_of(Savon::Client)
    end
    it "should have correct document" do
      interfax.client.wsdl.document.should == "https://ws.interfax.net/dfs.asmx?WSDL"
    end
  end
end
