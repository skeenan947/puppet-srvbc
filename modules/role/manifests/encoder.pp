class role::encoder {
    package {'libavcodec-extra-53':
        ensure => present
    }
    package {'libav-tools':
        ensure => present
    }
}
