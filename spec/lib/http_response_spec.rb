require 'spec_helper'

include Rapidoc

describe "When check HttpResponse class" do

  context "when create new instance" do
    before :all do
      @http_response = HttpResponse.new 200
    end

    it "should set correct code" do
      @http_response.code.should == 200
    end

    it "should set correct label" do
      @http_response.label.should == 'label label-info'
    end

    it "should set correct description" do
      @http_response.description.should == "OK"
    end
  end

  context "when check get_description function" do
    before do
      @codes = [ 200, 201, 401, 404, 422, 403, 409 ]
      @descriptions = [ 'OK', 'Created', 'Unauthorized', 'Not found',
                        'Unprocessable Entity', 'Forbidden', '' ]
    end

    it "should return correct descriptions" do
      @codes.each_index do |i|
        http_response = HttpResponse.new @codes[i]
        http_response.get_description.should == @descriptions[i]
      end
    end
  end

  context "when call get_label function" do
    context "when pass know code" do
      before do
        @codes = [ 200, 201, 204, 401, 403, 422, 404 ]
        @labels = [ 'label-info', 'label-success', 'label-info2', 'label-warning',
          'label-warning2', 'label-important', 'label-inverse' ]
      end

      it "should return correct labels" do
        @codes.each_index do |i|
          http_response = HttpResponse.new @codes[i]
          http_response.get_label.should == 'label ' + @labels[i]
        end
      end
    end

    context "when pass unknow code" do
      it "should return correct label" do
        http_response = HttpResponse.new 400
        http_response.get_label.should == 'label'
      end
    end
  end
end
