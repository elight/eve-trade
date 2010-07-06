require File.join(File.dirname(__FILE__), "..", "test_helper")

class AuditorCorpMgmtTest < ActionController::IntegrationTest
  fixtures :users

  context "An auditor, when on the corporate management page, " do
    should "see a list of all products"

    context "for products managed by the auditor" do
      should "see the typical product management controls"
    end

    context "for products not managed by the auditor" do
      should "see a 'Post Audit' button"
      should "see a 'Certify product' checkbox"
    end
  end
end
