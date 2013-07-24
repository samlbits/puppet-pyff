class pyff ($dir = '/opt/pyff') {
  package {'build-essential': ensure => installed}
  package {'libyaml-dev': ensure => installed}
  package {'libxml2-dev': ensure => installed} 
  package {'libxslt-dev': ensure => installed}
  Package['build-essential'] -> Package['libxml2-dev'] -> Package['libxslt-dev'] -> Package['libyaml-dev']
  class { 'python':
    version    => 'system',
    dev        => true,
    virtualenv => true,
    gunicorn   => false,
  }
  Package['libyaml-dev'] -> Class['python']
  python::virtualenv { $dir:
    ensure => present
  }
  python::pip { 'pyff':
    virtualenv => $dir
  }
  file {'pyffd-upstart':
    ensure    => file,
    path      => '/etc/init/pyffd.conf',
    content   => template('pyff/pyffd-upstart.erb'),
    notify    => Service['pyffd']
  }
  file {'pyffd-defaults':
    ensure    => file,
    path      => '/etc/default/pyffd',
    content   => template('pyff/pyffd-defaults.erb'),
    notify    => Service['pyffd']
  }
  service {'pyffd':
    ensure    => 'running',
    require   => [File['pyffd-upstart'],File['pyffd-defaults']]
  }
}
