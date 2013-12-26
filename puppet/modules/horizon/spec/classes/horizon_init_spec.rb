require 'spec_helper'

describe 'horizon' do
  let :params do
    { 'secret_key' => 'elj1IWiLoWHgcyYxFVLj7cM5rGOOxWl0',
      'fqdn'       => '*'
    }
  end

  let :pre_condition do
    'include apache'
  end

  let :fixtures_path do
    File.expand_path(File.join(__FILE__, '..', '..', 'fixtures'))
  end

  let :facts do
    { :concat_basedir => '/var/lib/puppet/concat' }
  end

  describe 'on RedHat platforms' do
    before do
      facts.merge!({
        :osfamily               => 'RedHat',
        :operatingsystemrelease => '6.0'
      })
    end

    it { should contain_service('httpd').with_name('httpd') }
    it { should contain_file('/etc/httpd/conf.d/openstack-dashboard.conf') }
    describe 'with default parameters' do
      it { should contain_package('horizon').with_ensure('present') }
      it { should contain_file_line('horizon_redirect_rule').with(
         :line => "RedirectMatch permanent ^/$ \/dashboard/"
      )}
    end

    describe 'when ssl is enabled' do
      before do
        params.merge!({
          :listen_ssl => true,
          :horizon_cert => '/etc/pki/tls/certs/httpd.crt',
          :horizon_key => '/etc/pki/tls/private/httpd.key',
          :horizon_ca => '/etc/pki/tls/certs/ca.crt',
        })
      end

      it { should contain_file_line('httpd_sslcert_path').with(
         :line => "SSLCertificateFile /etc/pki/tls/certs/httpd.crt"
      )}
      it { should contain_file_line('httpd_sslkey_path').with(
         :line => "SSLCertificateKeyFile /etc/pki/tls/private/httpd.key"
      )}
    end

  end

  describe 'on Debian platforms' do
    before do
      facts.merge!({
        :osfamily               => 'Debian',
        :operatingsystemrelease => '6.0'
      })
    end

    it { should contain_service('httpd').with_name('apache2') }
    it { should_not contain_file('/etc/httpd/conf.d/openstack-dashboard.conf') }

    describe 'with default parameters' do
      it { should contain_package('horizon').with_ensure('present') }
      it { should contain_file_line('horizon_redirect_rule').with(
         :line => "RedirectMatch permanent ^/$ /horizon/"
      )}
      it 'generates local_settings.py' do
        verify_contents(subject, '/etc/openstack-dashboard/local_settings.py', [
          'DEBUG = False',
          "ALLOWED_HOSTS = ['*', ]",
          "SECRET_KEY = 'elj1IWiLoWHgcyYxFVLj7cM5rGOOxWl0'",
          'OPENSTACK_HOST = "127.0.0.1"',
          'OPENSTACK_KEYSTONE_URL = "http://%s:5000/v2.0" % OPENSTACK_HOST',
          'OPENSTACK_KEYSTONE_DEFAULT_ROLE = "Member"',
          "    'can_set_mount_point': True,",
          'API_RESULT_LIMIT = 1000',
          "LOGIN_URL = '/horizon/auth/login/'",
          "LOGOUT_URL = '/horizon/auth/logout/'",
          "LOGIN_REDIRECT_URL = '/horizon'"
        ])
      end
    end

    describe 'when overriding parameters' do
      before do
        params.merge!({
          :cache_server_ip       => '10.0.0.1',
          :keystone_host         => 'keystone.example.com',
          :keystone_port         => 4682,
          :keystone_scheme       => 'https',
          :keystone_default_role => 'SwiftOperator',
          :django_debug          => true,
          :api_result_limit      => 4682,
          :can_set_mount_point   => false,
        })
      end

      it 'generates local_settings.py' do
        verify_contents(subject, '/etc/openstack-dashboard/local_settings.py', [
          'DEBUG = True',
          "ALLOWED_HOSTS = ['*', ]",
          "SECRET_KEY = 'elj1IWiLoWHgcyYxFVLj7cM5rGOOxWl0'",
          'OPENSTACK_HOST = "keystone.example.com"',
          'OPENSTACK_KEYSTONE_URL = "https://%s:4682/v2.0" % OPENSTACK_HOST',
          'OPENSTACK_KEYSTONE_DEFAULT_ROLE = "SwiftOperator"',
          "    'can_set_mount_point': False,",
          'API_RESULT_LIMIT = 4682'
        ])
      end
    end

    describe 'with overriding local_settings_template' do
      before do
        params.merge!({
          :django_debug            => 'True',
          :local_settings_template => fixtures_path + '/override_local_settings.py.erb'
        })
      end

      it 'uses the custom local_settings.py template' do
        verify_contents(subject, '/etc/openstack-dashboard/local_settings.py', [
          '# Custom local_settings.py',
          'DEBUG = True'
        ])
      end
    end

    describe 'when ssl is enabled' do
      before do
        params.merge!({
          :listen_ssl => true,
          :horizon_cert => '/etc/ssl/localcerts/apache.crt',
          :horizon_key => '/etc/ssl/localcerts/apache.key',
          :horizon_ca => '/etc/ssl/localcerts/ca.crt',
        })
      end

      it { should contain_file_line('httpd_sslcert_path').with(
         :line => "SSLCertificateFile /etc/ssl/localcerts/apache.crt"
      )}
      it { should contain_file_line('httpd_sslkey_path').with(
         :line => "SSLCertificateKeyFile /etc/ssl/localcerts/apache.key"
      )}
    end
  end
end
