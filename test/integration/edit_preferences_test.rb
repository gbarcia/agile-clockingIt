require File.dirname(__FILE__) + '/../test_helper'

class EditPreferencesTest < ActionController::IntegrationTest
  context "a logged in user" do
    setup do
      @user = login
      click_link "preferences"
    end

    should "be able to edit their own preferences" do
      @emails = @user.email_addresses
      @primary_email_id =  @emails.detect { |e| e.default }.id
      fill_in "emails[#{@primary_email_id}][email]", :with => "new@email.com"
      uncheck "receive notifications"
      click_button "save"
      @user.reload

      assert_equal "new@email.com", @user.primary_email
      assert !@user.receive_notifications?
    end

    context "with custom attributes on user" do
      setup do
        company = @user.company
        @attr = company.custom_attributes.build(:attributable_type => "User", :display_name => "attr1")
        @attr.save!

        # need to reload so custom attrs show up
        click_link "preferences"
      end

      should "be able to edit their own custom attributes" do
        fill_in @attr.display_name, :with => "attr1 value"
        click_button "save"
        assert_equal @user.reload.values_for(@attr).first, "attr1 value"
      end
    end
  end
end
