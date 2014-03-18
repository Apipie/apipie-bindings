# Based on ActiveSupport Inflector (https://github.com/rails/rails.git)
# Inflection rules taken from davidcelis's Inflections (https://github.com/davidcelis/inflections.git)
module ApipieBindings

  class Inflections
    @__instance__ = {}

    def self.instance(locale = :en)
      @__instance__[locale] ||= new
    end

    attr_reader :plurals, :singulars, :uncountables, :humans, :acronyms, :acronym_regex

    def initialize
      @plurals, @singulars, @uncountables, @humans, @acronyms, @acronym_regex = [], [], [], [], {}, /(?=a)b/
    end

    def acronym(word)
      @acronyms[word.downcase] = word
      @acronym_regex = /#{@acronyms.values.join("|")}/
    end

    def plural(rule, replacement)
      @uncountables.delete(rule) if rule.is_a?(String)
      @uncountables.delete(replacement)
      @plurals.unshift([rule, replacement])
    end

    def singular(rule, replacement)
      @uncountables.delete(rule) if rule.is_a?(String)
      @uncountables.delete(replacement)
      @singulars.unshift([rule, replacement])
    end

    def irregular(singular, plural)
      @uncountables.delete(singular)
      @uncountables.delete(plural)

      s0 = singular[0].chr
      srest = singular[1..-1]

      p0 = plural[0].chr
      prest = plural[1..-1]

      if s0.upcase == p0.upcase
        plural(/(#{s0})#{srest}$/i, '\1' + prest)
        plural(/(#{p0})#{prest}$/i, '\1' + prest)

        singular(/(#{s0})#{srest}$/i, '\1' + srest)
        singular(/(#{p0})#{prest}$/i, '\1' + srest)
      else
        plural(/#{s0.upcase}(?i)#{srest}$/, p0.upcase + prest)
        plural(/#{s0.downcase}(?i)#{srest}$/, p0.downcase + prest)
        plural(/#{p0.upcase}(?i)#{prest}$/, p0.upcase + prest)
        plural(/#{p0.downcase}(?i)#{prest}$/, p0.downcase + prest)

        singular(/#{s0.upcase}(?i)#{srest}$/, s0.upcase + srest)
        singular(/#{s0.downcase}(?i)#{srest}$/, s0.downcase + srest)
        singular(/#{p0.upcase}(?i)#{prest}$/, s0.upcase + srest)
        singular(/#{p0.downcase}(?i)#{prest}$/, s0.downcase + srest)
      end
    end

    def uncountable(*words)
      (@uncountables << words).flatten!
    end

    def human(rule, replacement)
      @humans.unshift([rule, replacement])
    end

    def clear(scope = :all)
      case scope
        when :all
          @plurals, @singulars, @uncountables, @humans = [], [], [], []
        else
          instance_variable_set "@#{scope}", []
      end
    end
  end

  class Inflector

    def self.pluralize(word, locale = :en)
      apply_inflections(word, inflections(locale).plurals)
    end

    def self.singularize(word, locale = :en)
      apply_inflections(word, inflections(locale).singulars)
    end

    def self.inflections(locale = :en)
      if block_given?
        yield ApipieBindings::Inflections.instance(locale)
      else
        ApipieBindings::Inflections.instance(locale)
      end
    end

    private

    def self.apply_inflections(word, rules)
      result = word.to_s.dup

      if word.empty? || inflections.uncountables.include?(result.downcase[/\b\w+\Z/])
        result
      else
        rules.each { |(rule, replacement)| break if result.sub!(rule, replacement) }
        result
      end
    end
  end

  Inflector.inflections(:en) do |inflect|
    inflect.clear

    inflect.plural(/$/, 's')
    inflect.plural(/([sxz]|[cs]h)$/i, '\1es')
    inflect.plural(/([^aeiouy]o)$/i, '\1es')
    inflect.plural(/([^aeiouy])y$/i, '\1ies')

    inflect.singular(/s$/i, '')
    inflect.singular(/(ss)$/i, '\1')
    inflect.singular(/([sxz]|[cs]h)es$/, '\1')
    inflect.singular(/([^aeiouy]o)es$/, '\1')
    inflect.singular(/([^aeiouy])ies$/i, '\1y')

    inflect.irregular('child', 'children')
    inflect.irregular('man', 'men')
    inflect.irregular('medium', 'media')
    inflect.irregular('move', 'moves')
    inflect.irregular('person', 'people')
    inflect.irregular('self', 'selves')
    inflect.irregular('sex', 'sexes')

    inflect.uncountable(%w(equipment information money species series fish sheep police))
  end

end
