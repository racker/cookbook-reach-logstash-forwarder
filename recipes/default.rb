# encoding: UTF-8

LUMBERJACK_VERSION = node['logstash-forwarder']['version']
LUMBERJACK_FILE_PREFIX = node['logstash-forwarder']['file_prefix']
LUMBERJACK_FILE = "#{LUMBERJACK_FILE_PREFIX}_#{LUMBERJACK_VERSION}_amd64.deb"
LUMBERJACK_CDN = node['logstash-forwarder']['cdn_url']
LUMBERJACK_URL = "http://#{LUMBERJACK_CDN}/#{LUMBERJACK_FILE}"

remote_file "#{Chef::Config[:file_cache_path]}/#{LUMBERJACK_FILE}" do
  source LUMBERJACK_URL
end

package 'install logstash forwarder' do
  provider Chef::Provider::Package::Dpkg
  source "#{Chef::Config[:file_cache_path]}/#{LUMBERJACK_FILE}"
  action :install
  options '--force-all'
end

service 'lumberjack' do
  supports restart: true, start: true, stop: true
end

template '/etc/lumberjack.conf' do
  source 'forwarder.conf.erb'
  owner 'root'
  group 'root'
  notifies :restart, 'service[lumberjack]'
  variables(
    collector_ip: node['logstash-forwarder']['collector_ip'],
    forwarder_port: node['logstash-forwarder']['port'],
    ssl_cert_name: node['logstash-forwarder']['ssl_cert_name'],
    render_template: node['logstash-forwarder']['template'],
    render_cookbook: node['logstash-forwarder']['cookbook']
  )
end
