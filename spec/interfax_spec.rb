require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Interfax" do
  let(:session_id) { "D32EFA4297184BDF92A8393CB891F137B758A945F1D54E48869046799928C965" }
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
  describe "#start_file_upload" do
    context "authorized" do
      let(:interfax) { Interfax.new(:username => 'rafael_lima', :password => ENV['INTERFAX_PASSWORD_FOR_RSPEC']) }
      it "should assign session_id" do
        VCR.use_cassette('start_file_upload_authorized') do
          interfax.start_file_upload
          interfax.instance_variable_get(:@session_id).should == session_id
        end
      end
      it "should return session id" do
        VCR.use_cassette('start_file_upload_authorized') do
          interfax.start_file_upload.should == session_id
        end
      end
      it "should cache session id and not request twice" do
        interfax.client.should_receive(:request).once.and_return(mock("Response", :success? => true, :to_hash => {:start_file_upload_response => {:start_file_upload_result => "1", :session_id => "2FE69E6C86DB4CB4926A94E63B68039AD83BCBB7F10C407F9641FEAEF5EA38EE"}}))
        VCR.use_cassette('start_file_upload_authorized') do
          2.times { interfax.start_file_upload }
        end
      end
    end
    context "unauthorized" do
      it "should return false" do
        VCR.use_cassette('start_file_upload_unauthorized') do
          interfax.start_file_upload.should be_nil
        end
      end
      it "should not assign session_id" do
        VCR.use_cassette('start_file_upload_unauthorized') do
          interfax.start_file_upload
          interfax.instance_variable_get(:@session_id).should be_nil
        end
      end
    end
  end
  describe "#upload_file_chunk" do
    context "start_file_upload was not called" do
      it "should call start_file_upload" do
        interfax.should_receive(:start_file_upload)
        interfax.stub(:request)
        interfax.upload_file_chunk(File.join('spec','fixtures','mickey01.jpg'))
      end
    end
    context "start_file_upload was called before" do
      before(:each) do
        VCR.use_cassette('start_file_upload_authorized') do
          interfax.start_file_upload
        end
      end
      it "should not call start_file_upload" do
        interfax.should_not_receive(:start_file_upload)
        interfax.stub(:request)
        interfax.upload_file_chunk(File.join('spec','fixtures','mickey01.jpg'))
      end
      context "authorized" do
        let(:interfax) { Interfax.new(:username => 'rafael_lima', :password => ENV['INTERFAX_PASSWORD_FOR_RSPEC']) }
        it "should return true" do
          VCR.use_cassette('upload_file_chunk_authorized') do
            interfax.upload_file_chunk(File.join('spec','fixtures','mickey01.jpg'), :chunk_size => 40960).should be_true
          end
        end
        it "should request twice" do
          interfax.client.should_receive(:request).twice.and_return(mock("Response", :success? => true, :to_hash => {:upload_file_chunk_response => {:upload_file_chunk_result => "68702"}}))
          interfax.upload_file_chunk(File.join('spec','fixtures','mickey01.jpg'), :chunk_size => 40960).should be_true
        end
      end
    end
  end
  describe "#cancel_file_upload" do
    context "start_file_upload was not successfully called" do
      it "should return nil" do
        interfax.cancel_file_upload.should be_nil
      end
    end
    context "start_file_upload was successfully called" do
      before(:each) do
        VCR.use_cassette('start_file_upload_authorized') do
          interfax.start_file_upload
        end
      end
      it "should return true" do
        VCR.use_cassette('cancel_file_upload') do
          interfax.cancel_file_upload.should be_true
        end
      end
    end
  end
end
