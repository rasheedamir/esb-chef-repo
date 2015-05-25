#
# Cookbook Name:: esbapp
# Recipe:: default
#
# Copyright 2015, Aurora Solutions
#
# All rights reserved - Do Not Redistribute
#

include_recipe "java"
include_recipe "maven"
include_recipe "postgresql"
include_recipe "postgresql::server"
include_recipe "mule"
include_recipe "activemq"
