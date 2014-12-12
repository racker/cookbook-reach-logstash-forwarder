# encoding: UTF-8

LOGSTASH_FORWARDER_VERSION = node['logstash-forwarder']['version']
LOGSTASH_FORWARDER_FILE_PREFIX = node['logstash-forwarder']['file_prefix']
LOGSTASH_FORWARDER_FILE = "#{LOGSTASH_FORWARDER_FILE_PREFIX}_#{LOGSTASH_FORWARDER_VERSION}_amd64.deb"
LOGSTASH_FORWARDER_CDN = node['logstash-forwarder']['cdn_url']
LOGSTASH_FORWARDER_URL = "http://#{LOGSTASH_FORWARDER_CDN}/#{LOGSTASH_FORWARDER_FILE}"

remote_file "#{Chef::Config[:file_cache_path]}/#{LOGSTASH_FORWARDER_FILE}" do
  source LOGSTASH_FORWARDER_URL
end

package 'install logstash forwarder' do
  provider Chef::Provider::Package::Dpkg
  source "#{Chef::Config[:file_cache_path]}/#{LOGSTASH_FORWARDER_FILE}"
  action :install
  options '--force-all'
end

service 'logstash-forwarder' do
  supports restart: true, start: true, stop: true
end

template node['logstash-forwarder']['config_file'] do
  source 'forwarder.conf.erb'
  owner 'root'
  group 'root'
  notifies :restart, 'service[logstash-forwarder]'
  variables(
    collector_ip: node['logstash-forwarder']['collector_ip'],
    forwarder_port: node['logstash-forwarder']['port'],
    ssl_cert_name: node['logstash-forwarder']['ssl_cert_name'],
    render_template: node['logstash-forwarder']['template'],
    render_cookbook: node['logstash-forwarder']['cookbook']
  )
end
