module ApipieBindings

  module Utilities

    def self.params_hash_tree(params_hash, &block)
      block ||= lambda { |_| true }
      params_hash.inject([]) do |tree, par|
        if block.call(par)
          subtree = par.expected_type == :hash ? { par.name => par.tree(&block) } : par.name
          tree << subtree
        end
        tree
      end
    end

  end

end
