#
# Cookbook Name:: hostupgrade
# Recipe:: upgrade
#
# Copyright 2014, Stajkowski
#
# All rights reserved - Do Not Redistribute
#
#     _       _       _       _       _       _       _       _       _       _       _
#   _( )__  _( )__  _( )__  _( )__  _( )__  _( )__  _( )__  _( )__  _( )__  _( )__  _( )__
# _|     _||     _||     _||     _||     _||     _||     _||     _||     _||     _||     _|
#(_ H _ ((_ O _ ((_ S _ ((_ T _ ((_ U _ ((_ P _ ((_ G _ ((_ R _ ((_ A _ ((_ D _ ((_ E _ (_
#  |_( )__||_( )__||_( )__||_( )__||_( )__||_( )__||_( )__||_( )__||_( )__||_( )__||_( )__|

#Include for chef-solo touch
require 'fileutils'

#Check if we are updating the Repos and System
if node["hostupgrade"]["update_system"]

  #Check to see if the /tmp file flag is present
  solo_upgrade_complete = Chef::Config[:solo] ? ::File.file?('/tmp/upgrade_complete') : false

  #Select Platform
  case node[:platform]
  when "ubuntu", "debian"  #Debian based systems

    if node["hostupgrade"]["compile_time"]
      bash "apt-get-compile-time" do
        code "apt-get update"
        action :nothing
      end.run_action(:run)
    end

    unless ( node.attribute?("upgrade_complete") && node["hostupgrade"]["first_time_only"] ) || ( node["hostupgrade"]["first_time_only"] && solo_upgrade_complete )
      if node["hostupgrade"]["compile_time"]
        bash "apt-get-compile-time" do
          code "apt-get update"
          action :nothing
        end.run_action(:run)
      else
        bash "Run apt-get update" do
          code "apt-get update"
          action :nothing
        end
      end
    end

    #Check if we are upgrading the system as well
    if node["hostupgrade"]["upgrade_system"]

      #Do apt-get upgrade
      bash "apt-get-update" do
        code "apt-get update"
        action :run
      end
      bash "Run apt-get upgrade" do
        code "DEBIAN_FRONTEND=noninteractive apt-get dist-upgrade -y"
        action :run
        notifies :create, "ruby_block[Upgrade Flag Ubuntu]", :immediately
        not_if { ( node.attribute?("upgrade_complete") && node["hostupgrade"]["first_time_only"] ) || ( node["hostupgrade"]["first_time_only"] && solo_upgrade_complete ) }
      end

      #Set flag for first-run
      ruby_block "Upgrade Flag Ubuntu" do
        block do
          node.set['upgrade_complete'] = true
          Chef::Config[:solo] ? ::FileUtils.touch('/tmp/upgrade_complete') : node.save
        end
        action :nothing
      end

    end

  when "centos", "redhat", "fedora"   #Fedora based systems

    if node["hostupgrade"]["compile_time"]
      bash "Run yum update" do
        code "yum update -y"
        action :nothing
      end.run_action(:run)
    end

    #Do yum check-update
    bash "Run yum check-update" do
      code "yum check-update"
      returns [0, 100]
      action :run
      not_if { ( node.attribute?("upgrade_complete") && node["hostupgrade"]["first_time_only"] ) || ( node["hostupgrade"]["first_time_only"] && solo_upgrade_complete )  }
    end

    #Check if we are upgrading the system as well
    if node["hostupgrade"]["upgrade_system"]

      #Do yum update -y to upgrade
      bash "Run yum update" do
        code "yum update -y"
        action :run
        notifies :create, "ruby_block[Upgrade Flag Centos]", :immediately
        not_if { ( node.attribute?("upgrade_complete") && node["hostupgrade"]["first_time_only"] ) || ( node["hostupgrade"]["first_time_only"] && solo_upgrade_complete )  }
      end

      #Set flag for first-run
      ruby_block "Upgrade Flag Centos" do
        block do
          node.set['upgrade_complete'] = true
          Chef::Config[:solo] ? ::FileUtils.touch('/tmp/upgrade_complete') : node.save
        end
        action :nothing
      end

    end

  end

end
