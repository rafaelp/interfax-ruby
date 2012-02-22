require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Interfax" do
  it "should store username and password" do
    interfax = Interfax.new(:username => 'myusername', :password => 'mypassword')
    interfax.instance_variable_get(:@username).should == 'myusername'
    interfax.instance_variable_get(:@password).should == 'mypassword'
  end
end
