module PKGBuild
  # redefine String with two additional methods
  class Tag < String
    def strip_colon
      gsub(/"|'/, '')
    end

    def strip_brackets
      gsub(/\(|\)/, '')
    end
  end

  # PKGBUILD Main Package
  class Package
    def initialize(file)
      f = open(file.to_s).read
      @subpackages = split_package(f)
      @text = remaining_text(f)
    end

    CONST = TAG + SCRIPT + FUNC
    attr_reader :subpackages

    def respond_to_missing?(tag)
      CONST.include?(tag.to_s) || super
    end

    def method_missing(tag)
      tag = tag.to_s
      super unless CONST.include?(tag)
      %w[tags funcs scripts].each do |type|
        next unless ['PKGBuild', type.upcase].inject(Object) do |o, c|
                      o.const_get(c)
                    end.include?(tag)
	return send(('parse_' + type[0..-2]).to_sym, tag)
      end
    end

    private

    # TODO: handle install and changelog tag here
    # we need to open the specified files and read contents
    def parse_tag(tag)
      prefix = self.class =~ /::Sub/ ? "\s+" : ''
      # only ^ or \s can be ahead of tag, or optdepends
      # will be recognized to depends
      return [] unless @text =~ /^#{prefix + tag.to_s}=(((?!^\w).)*)\n/m
      sep = Regexp.last_match[1].index(':') ? "\n" : "\s"
      PKGBuild::Tag.new(Regexp.last_match[1])
                   .strip_brackets
                   .split(sep)
                   .map(&:strip_colon)
    end

    def parse_func(func)
      regex = /^#{func}\(\) {\n(.*?)^}\n/m
      return "" unless @text =~ regex
      Regexp.last_match(1)
    end

    def split_package(text, raw = false)
      regex = /^package_(\w+)\(\) {\n(.*?)^}\n/m
      return {} unless text =~ regex
      m = text.to_enum(:scan, regex).map { Regexp.last_match }
      return m.map { |i| i[0] } if raw
      Hash[m.map! { |i| [i[1], PKGBuild::Subpackage.new(i[1], i[2])] }]
    end

    def remaining_text(text)
      split_package(text, true).each do |i|
        text = text.gsub(i, '')
      end
      text
    end
  end

  # PKGBUILD Splitted Package
  class Subpackage < Package
    def initialize(name, text)
      @pkgname = name
      @text = text
    end

    def respond_to_missing?(tag)
      super
    end

    def method_missing(tag)
      return @pkgname if tag == :pkgname
      # Splitted package doesn't have all four funcs
      return parse_func(tag) if FUNC.include?(tag)
      # if empty? use the one from its parent
      super
    end
  end
end
