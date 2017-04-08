class pve::profiles::config::agent {
  class { '::consul':
    init_style  => 'debian',
    config_hash => {
      'data_dir'   => '/opt/consul',
      'datacenter' => 'pve',
      'log_level'  => 'INFO',
      'node_name'  => "${::hostname}-agent",
      'retry_join' => ['10.0.50.106'],
    }
  }

  ::consul::check { 'check_disk_usage':
    script   => '/usr/lib/nagios/plugins/check_disk -w 50% -c 20%',
    interval => '30s'
  }

  ::consul::check { 'check_cpuload':
    script   => '/usr/lib/nagios/plugins/check_load -r',
    interval => '30s'
  }
}
