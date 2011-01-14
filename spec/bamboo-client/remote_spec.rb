require File.expand_path("../../spec_helper", __FILE__)

module Bamboo
  module Client
    describe Remote do
      let(:url)  { "http://bamboo.example.com" }
      let(:http) { mock(Http::Xml) }
      let(:client) { Remote.new(http) }

      it "logs in" do
        mock_xml_doc = mock(Http::Xml::Doc)
        mock_xml_doc.should_receive(:text_for).with("response success").and_return "token"

        http.should_receive(:post).
             with("/api/rest/login.action", :username => "user", :password => "pass").
             and_return mock_xml_doc

        client.login "user", "pass"
        client.token.should == "token"
      end

      it "logs out" do
        http.should_receive(:post).
             with("/api/rest/logout.action", :token => "foo")

        client.instance_variable_set "@token", "foo"
        client.logout
        client.token.should be_nil
      end

      it "updates and builds" do
        mock_xml_doc = mock(Http::Xml::Doc)
        mock_xml_doc.should_receive(:text_for).
                     with("response success").
                     and_return "true"

        http.should_receive(:post).
             with("/api/rest/updateAndBuild.action", :buildName => "fake-name").
             and_return(mock_xml_doc)

        client.update_and_build("fake-name").should == "true"
      end

      it "executes a build" do
        mock_xml_doc = mock(Http::Xml::Doc)
        mock_xml_doc.should_receive(:text_for).with("response string").and_return "true"

        http.should_receive(:post).
             with("/api/rest/executeBuild.action", :auth => "fake-token",
                                                   :buildKey => "fake-build-key").
             and_return(mock_xml_doc)

        client.stub :token => "fake-token"
        client.execute_build("fake-build-key").should == "true"
      end

    end # Remote
  end # Client
end # Bamboo
