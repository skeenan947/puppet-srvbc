class apache::mod::passenger (

  $passenger_high_performance     = "On",
  $passenger_pool_idle_time       = undef,
  $passenger_max_requests         = undef,
  $passenger_stat_throttle_rate   = "120",
  $rack_autodetect                = undef,
  $rails_autodetect               = "On",
  $passenger_root                 = $apache::params::passenger_root,
  $passenger_ruby                 = $apache::params::passenger_ruby,
  $passenger_max_pool_size        = undef,
  $passenger_use_global_queue     = undef,
) {
  if $::osfamily == 'FreeBSD' {
    apache::mod { 'passenger':
      lib_path => "${passenger_root}/buildout/apache2"
    }
  } else {
    apache::mod { 'passenger': }
  }
  # Template uses:
  # - $passenger_root
  # - $passenger_ruby
  # - $passenger_max_pool_size
  # - $passenger_high_performance
  # - $passenger_max_requests
  # - $passenger_stat_throttle_rate
  # - $passenger_use_global_queue
  # - $rack_autodetect
  # - $rails_autodetect
  file { 'passenger.conf':
    ensure  => file,
    path    => "${apache::mod_dir}/passenger.conf",
    content => template('apache/mod/passenger.conf.erb'),
    require => Exec["mkdir ${apache::mod_dir}"],
    before  => File[$apache::mod_dir],
    notify  => Service['httpd'],
  }
}
