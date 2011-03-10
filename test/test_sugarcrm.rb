require 'helper'

class TestSugarCRM < ActiveSupport::TestCase
  context "A SugarCRM::Base instance" do
  
    should "return the module name" do
      assert_equal "Users", SugarCRM::User._module.name
    end
    
    should "return the module fields" do
      assert_instance_of ActiveSupport::HashWithIndifferentAccess, SugarCRM::Account._module.fields
    end
    
    should "responsd to self#methods" do
      assert_instance_of Array, SugarCRM::User.new.methods
    end
    
    should "respond to self.connection" do
      assert_respond_to SugarCRM::User, :connection
      assert_instance_of SugarCRM::Connection, SugarCRM::User.connection
    end

    should "respond to self.connection.logged_in?" do
      assert_respond_to SugarCRM::User.connection, :logged_in?
    end
    
    should "respond to self.current_user" do
      assert_instance_of SugarCRM::User, SugarCRM.current_user
    end
  
    should "respond to self.attributes_from_modules_fields" do
      assert_instance_of ActiveSupport::HashWithIndifferentAccess, SugarCRM::User.attributes_from_module
    end
  
    should "return an instance of itself when #new" do
      assert_instance_of SugarCRM::User, SugarCRM::User.new
    end
    
    should "define instance level attributes when #new" do
      u = SugarCRM::User.new
      assert SugarCRM::User.attribute_methods_generated
    end

    should "not save a record that is missing required attributes" do
      u = SugarCRM::User.new
      u.last_name = "Test"
      assert !u.save
      assert_raise SugarCRM::InvalidRecord do
        u.save!
      end
    end

    should "create, modify, and delete a record" do
      u = SugarCRM::User.new
      assert u.email1?
      u.email1 = "abc@abc.com"
      u.first_name = "Test"
      u.last_name = "User"
      u.system_generated_password = false
      u.user_name = "test_user"
      u.status = "Active"
      assert_equal "Test", u.modified_attributes[:first_name][:new]
      assert u.save!
      assert !u.new?
      m = SugarCRM::User.find_by_first_name_and_last_name("Test", "User")
      assert m.user_name != "admin"
      m.title = "Test User"
      assert m.save!
      assert m.delete
      assert m.destroyed?
    end
    
    should "support saving of records with special characters in them" do
      a = SugarCRM::Account.new
      a.name = "COHEN, WEISS & SIMON LLP"
      assert a.save!
      assert a.delete
    end
    
    should "implement Base#reload!" do
      a = SugarCRM::User.last
      b = SugarCRM::User.last
      assert_not_equal 'admin', a.user_name # make sure we don't mess up admin user
      # Save the original value, so we can set it back.
      orig_last_name = a.last_name.dup
      diff_last_name = a.last_name + 'crm'
      b.last_name    = diff_last_name
      b.save!
      # Compare the two user objects
      assert_not_equal b.last_name, a.last_name
      a.reload!
      assert_equal a.last_name, b.last_name
      # Set the name back to what it was before
      b.last_name = orig_last_name
      b.save!
    end
  end
  
  should "respond to #pretty_print" do 
    assert_respond_to SugarCRM::User.new, :pretty_print
  end
  
  should "return an instance's URL" do
    user = SugarCRM::User.first
    assert_equal "#{SugarCRM.session.config[:base_url]}/index.php?module=Users&action=DetailView&record=#{user.id}", user.url
  end
  
end
