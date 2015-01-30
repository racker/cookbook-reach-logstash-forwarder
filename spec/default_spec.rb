require_relative 'spec_helper'

describe 'logstash-forwarder::default' do
  let(:chef_run) { ChefSpec::SoloRunner.new(file_cache_path: '/tmp/chefspec').converge(described_recipe) }

  it 'downloads the logstash forwarder' do
    filename = '/tmp/chefspec/logstash-forwarder_0.3.1_amd64.deb'
    source = 'http:///logstash-forwarder_0.3.1_amd64.deb' # TODO: configure deafult CDN URL

    expect(chef_run).to create_remote_file(filename).with_source(source)
  end

  it 'installs the logstash forwarder' do
    expected_parameters = {
      provider: Chef::Provider::Package::Dpkg,
      options: '--force-all',
      source: '/tmp/chefspec/logstash-forwarder_0.3.1_amd64.deb'
    }

    expect(chef_run).to install_package('install logstash forwarder').with(expected_parameters)
  end

  it 'creates the logstash forwarder service' do
    expect(chef_run.service('logstash-forwarder')).to do_nothing
  end

  it 'creates the logstash forwarder config file' do
    expected_variables = {
      collector_ip: chef_run.node['logstash-forwarder']['collector_ip'],
      forwarder_port: chef_run.node['logstash-forwarder']['port'],
      ssl_cert_name: chef_run.node['logstash-forwarder']['ssl_cert_name'],
      render_template: chef_run.node['logstash-forwarder']['template'],
      render_cookbook: chef_run.node['logstash-forwarder']['cookbook']
    }

    expected_parameters = {
      source: 'forwarder.conf.erb',
      owner: 'root',
      group: 'root',
      variables: expected_variables
    }

    expect(chef_run).to create_template('/etc/logstash-forwarder').with(expected_parameters)
  end

  it 'restarts the logstash forwarder service if the config changes' do
    config_file = chef_run.template('/etc/logstash-forwarder')

    expect(config_file).to notify('service[logstash-forwarder]').to(:restart)
  end
end
