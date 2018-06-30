module PKGBuild
  VERSION = '1.0.0'.freeze
  TAG = %w[pkgbase pkgname pkgver pkgrel epoch
           pkgdesc url install changelog groups
           arch license depends optdepends
           makedepends checkdepends provides
           conflicts replaces backup options
           source noextract validpgpkeys sha1sums
           sha256sums sha224sums sha384sums
           sha512sums md5sums].freeze
  FUNC = %w[package prepare build check].freeze
  SCRIPT = %w[pre_install post_install pre_upgrade
              post_upgrade pre_remove post_remove].freeze
end
