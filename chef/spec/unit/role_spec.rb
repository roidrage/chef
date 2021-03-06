#
# Author:: Adam Jacob (<adam@opscode.com>)
# Copyright:: Copyright (c) 2008 Opscode, Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require File.expand_path(File.join(File.dirname(__FILE__), "..", "spec_helper"))
require 'chef/role'

describe Chef::Role do
  before(:each) do
    @role = Chef::Role.new
  end

  describe "initialize" do
    it "should be a Chef::Role" do
      @role.should be_a_kind_of(Chef::Role)
    end
  end

  describe "name" do
    it "should let you set the name to a string" do
      @role.name("ops_master").should == "ops_master"
    end

    it "should return the current name" do
      @role.name "ops_master"
      @role.name.should == "ops_master"
    end

    it "should not accept spaces" do
      lambda { @role.name "ops master" }.should raise_error(ArgumentError)
    end

    it "should throw an ArgumentError if you feed it anything but a string" do
      lambda { @role.name Hash.new }.should raise_error(ArgumentError)
    end
  end

  describe "recipes" do
    it "should let you set the recipe array" do
      @role.recipes([ "one", "two" ]).should == [ "one", "two" ]
    end

    it "should let you return the recipe array" do
      @role.recipes([ "one", "two" ])
      @role.recipes.should == [ "one", "two" ]
    end

    it "should throw an ArgumentError if you feed it anything but an array" do
      lambda { @role.recipes Hash.new }.should raise_error(ArgumentError)
    end
  end

  describe "default_attributes" do
    it "should let you set the default attributes hash explicitly" do
      @role.default_attributes({ :one => 'two' }).should == { :one => 'two' }
    end

    it "should let you return the default attributes hash" do
      @role.default_attributes({ :one => 'two' })
      @role.default_attributes.should == { :one => 'two' }
    end

    it "should throw an ArgumentError if we aren't a kind of hash" do
      lambda { @role.default_attributes(Array.new) }.should raise_error(ArgumentError)
    end
  end

  describe "override_attributes" do
    it "should let you set the override attributes hash explicitly" do
      @role.override_attributes({ :one => 'two' }).should == { :one => 'two' }
    end

    it "should let you return the override attributes hash" do
      @role.override_attributes({ :one => 'two' })
      @role.override_attributes.should == { :one => 'two' }
    end

    it "should throw an ArgumentError if we aren't a kind of hash" do
      lambda { @role.override_attributes(Array.new) }.should raise_error(ArgumentError)
    end
  end

  describe "serialize" do
    before(:each) do
      @role.name('mars_volta')
      @role.description('Great band!')
      @role.recipes('one', 'two')
      @role.default_attributes({ :el_groupo => 'nuevo' })
      @role.override_attributes({ :deloused => 'in the comatorium' })
      @serial = @role.to_json
    end

    it "should serialize to a json hash" do
      @role.to_json.should match(/^\{.+\}$/)
    end

    %w{
      name
      description
    }.each do |t| 
      it "should include '#{t}'" do
        @serial.should =~ /"#{t}":"#{@role.send(t.to_sym)}"/
      end
    end

    it "should include 'default_attributes'" do
      @serial.should =~ /"default_attributes":\{"el_groupo":"nuevo"\}/
    end

    it "should include 'override_attributes'" do
      @serial.should =~ /"override_attributes":\{"deloused":"in the comatorium"\}/
    end

    it "should include 'recipes'" do
      @serial.should =~ /"recipes":\["one","two"\]/
    end
  end

  describe "deserialize" do
    before(:each) do
      @role.name('mars_volta')
      @role.description('Great band!')
      @role.recipes('one', 'two')
      @role.default_attributes({ 'el_groupo' => 'nuevo' })
      @role.override_attributes({ 'deloused' => 'in the comatorium' })
      @deserial = JSON.parse(@role.to_json)
    end

    it "should deserialize to a Chef::Role object" do
      @deserial.should be_a_kind_of(Chef::Role)
    end

    %w{
      name
      description
      default_attributes
      override_attributes
      recipes
    }.each do |t| 
      it "should match '#{t}'" do
        @deserial.send(t.to_sym).should == @role.send(t.to_sym)
      end
    end

  end
end

