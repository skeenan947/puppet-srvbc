require 'spec_helper'

describe 'neutron::agents::lbaas' do

  let :pre_condition do
    "class { 'neutron': rabbit_password => 'passw0rd' }"
  end

  let :params do
    {}
  end

  let :default_params do
    { :package_ensure   => 'present',
      :enabled          => true,
      :debug            => false,
      :interface_driver => 'neutron.agent.linux.interface.OVSInterfaceDriver',
      :device_driver    => 'neutron.plugins.services.agent_loadbalancer.drivers.haproxy.namespace_driver.HaproxyNSDriver',
      :use_namespaces   => true,
      :user_group       => 'nogroup',
    }
  end


  shared_examples_for 'neutron lbaas agent' do
    let :p do
      default_params.merge(params)
    end

    it { should include_class('neutron::params') }

    it_configures 'haproxy lbaas_driver'

    it 'configures lbaas_agent.ini' do
      should contain_neutron_lbaas_agent_config('DEFAULT/debug').with_value(p[:debug]);
      should contain_neutron_lbaas_agent_config('DEFAULT/interface_driver').with_value(p[:interface_driver]);
      should contain_neutron_lbaas_agent_config('DEFAULT/device_driver').with_value(p[:device_driver]);
      should contain_neutron_lbaas_agent_config('DEFAULT/use_namespaces').with_value(p[:use_namespaces]);
      should contain_neutron_lbaas_agent_config('DEFAULT/user_group').with_value(p[:user_group]);
    end

    it 'installs neutron lbaas agent package' do
      if platform_params.has_key?(:lbaas_agent_package)
        should contain_package('neutron-lbaas-agent').with(
          :name   => platform_params[:lbaas_agent_package],
          :ensure => p[:package_ensure]
        )
        should contain_package('neutron').with_before(/Package\[neutron-lbaas-agent\]/)
        should contain_package('neutron-lbaas-agent').with_before(/Neutron_lbaas_agent_config\[.+\]/)
        should contain_package('neutron-lbaas-agent').with_before(/Neutron_config\[.+\]/)
      else
        should contain_package('neutron').with_before(/Neutron_lbaas_agent_config\[.+\]/)
      end
    end

    it 'configures neutron lbaas agent service' do
      should contain_service('neutron-lbaas-service').with(
        :name    => platform_params[:lbaas_agent_service],
        :enable  => true,
        :ensure  => 'running',
        :require => 'Class[Neutron]'
      )
    end
  end

  shared_examples_for 'haproxy lbaas_driver' do
    it 'installs haproxy packages' do
      if platform_params.has_key?(:lbaas_agent_package)
        should contain_package('haproxy').with_before('Package[neutron-lbaas-agent]')
      end
      should contain_package('haproxy').with(
        :ensure => 'present',
        :name   => platform_params[:haproxy_package]
      )
    end
  end


  context 'on Debian platforms' do
    let :facts do
      { :osfamily => 'Debian' }
    end

    let :platform_params do
      { :haproxy_package   =>  'haproxy',
        :lbaas_agent_package => 'neutron-lbaas-agent',
        :lbaas_agent_service => 'neutron-lbaas-agent' }
    end

    it_configures 'neutron lbaas agent'
  end

  context 'on RedHat platforms' do
    let :facts do
      { :osfamily => 'RedHat' }
    end

    let :platform_params do
      { :haproxy_package   => 'haproxy',
        :lbaas_agent_service => 'neutron-lbaas-agent' }
    end

    it_configures 'neutron lbaas agent'
  end
end
