require 'spec_helper.rb'

include Rapidoc

describe ActionDoc do

  before :all do
    extractor = ControllerExtractor.new "users_controller.rb"
    @resource = :users
    @urls = [ "/url1", "/url2" ]
    @info = extractor.get_actions_info.first
    @action_doc = ActionDoc.new @resource, @info, @urls
  end

  context "when initialize ActionDoc" do

    it "should set correct action info" do
      @action_doc.action.should == @info["action"]
    end

    it "should set correct resource" do
      @action_doc.resource.should == @resource
    end

    it "should set correct urls" do
      @action_doc.urls.should == @urls
    end

    it "should set correct action method" do
      @action_doc.action_method.should == @info["method"]
    end

    it "should set correct description" do
      @action_doc.description.should == @info["description"]
    end

    it "should set correct http responses" do
      http_responses = @action_doc.get_http_responses( @info["http_responses"] )

      @action_doc.http_responses.each_index do |i|
        @action_doc.http_responses[i].code.should == http_responses[i].code
        @action_doc.http_responses[i].description.should == http_responses[i].description
        @action_doc.http_responses[i].label.should == http_responses[i].label
      end
    end

    it "should set correct file" do
      @action_doc.file.should == @resource.to_s + "_" + @info["action"].to_s
    end
  end

  context "when executing get_http_responses method" do
    before do
      @codes = [ 200, 401 ]
      @http_responses = @action_doc.get_http_responses @codes
    end

    it "should return new HttpResponse Array" do
      @http_responses.each do |r|
        r.class.should == HttpResponse
      end
    end

    it "each HttpResponse element should include correct code" do
      @http_responses.each_index do |i|
        @http_responses[i].code.should == @codes[i]
      end
    end

    it "each HttpResponse element should include description" do
      @http_responses.each{ |http_r| http_r.methods.should be_include( :description ) }
    end

    it "each HttpResponse element should include label" do
      @http_responses.each{ |http_r| http_r.methods.should be_include( :label ) }
    end
  end
end