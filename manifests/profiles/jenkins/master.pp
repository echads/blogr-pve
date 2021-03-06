class pve::profiles::jenkins::master {

  include pve::profiles::common::packages::java
  include pve::profiles::common::packages::docker

  $tags = [$::environment,
    "traefik.tags=${::environment}",
    "traefik.frontend.rule=Host:ci.dniel.in,ci"]

  ::consul::service { "${::hostname}-ci":
    service_name => 'ci',
    address      => $::ipaddress_eth0,
    port         => 8080,
    tags         => $tags
  }

  ::consul::check { 'check_jenkins_http_status':
    script   => "/usr/lib/nagios/plugins/check_http -H localhost -p 8080 -j HEAD",
    interval => '30s'
  }

  file { '/opt/ecs-deploy':
    source  => 'puppet:///modules/pve/opt/ecs-deploy',
    owner   => "jenkins",
    group   => "jenkins",
    mode    => "700",
    require => [
      User["jenkins"],
      Group["jenkins"]]
  }


  class { 'jenkins':
    version      => 'latest',
    lts          => false,
    install_java => false
  }

  class { 'jenkins::master':
    version      => '3.8'
  }

}
