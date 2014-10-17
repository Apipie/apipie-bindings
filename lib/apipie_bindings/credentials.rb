module ApipieBindings

  # AbstractCredentials class can hold your logic to get
  # users credentials. It defines interface that can be used
  # by ApipieBindings when the credentials are needed to create connection
  class AbstractCredentials

    # Convert credentials to hash usable for merging to RestClient configuration
    # @return [Hash]
    def to_params
      {}
    end

    # Check that credentials storage is empty
    def empty?
    end

    # Clear credentials storage
    def clear
    end
  end
end
