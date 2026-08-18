require 'active_record'

module ActiveRecord
  # The HashlikeAccess module simplifies querying for model records by providing
  # `find_by`-equivalent access to records (or their values) via bracket syntax.
  #
  module HashlikeAccess
    # Finds a record by the previously-configured "lookup_fields" and calls the requested "response_method" on it.
    #
    # @param * [Array]
    #   A list consisting of lookup values to match against the "lookup_fields" in search of a record.
    #   These are passed through, unaltered, to {.hashlike_access_lookup}.
    #
    # @return
    #   Returns either `nil` or the result of calling the "response_method" on the matched record.
    #
    # @raise [ActiveRecord::RecordNotFound]
    #
    def [](*)
      hashlike_access_lookup(*)&.public_send hashlike_access_config[:response_method]
    end

    # Finds a record (as in {.[]}), and calls the "assignment_method" with the remaining param.
    #
    # @param * [Array]
    #   A list consisting of lookup values as well as the actual assignment value.
    #   All but the last of these is passed through, unaltered, to {.hashlike_access_lookup}.
    #
    # @return
    #   As with all assignment methods, this returns the assignment value given.
    #
    # @raise [NoMethodError, ActiveRecord::RecordInvalid, ActiveRecord::RecordNotSaved]
    #
    def []=(*args)
      value = args.pop
      record = hashlike_access_lookup(*args) || return

      record.public_send hashlike_access_config[:assignment_method], value
      record.save!
    end

    private

    # The primary entrypoint for defining hash-like access behaviours.
    #
    # @option [Symbol, String] :to
    #   The name of the method to call on a record once found. Defaults to `:itself`, yielding the full record.
    #
    # @option [Symbol, String, Array<Symbol>, Array<String>] :by
    #   The field name (or list of names) against which lookup values should match to yield a "found record".
    #   IOW, this is the list of keys that will be passed to a `find_by` equivalent when looking for a record.
    #
    # @option [true, false] :raise_if_not_found
    #   Determines whether failing to find a requested record should raise an `ActiveRecord::RecordNotFound` error.
    #   Defaults to `false`.
    #
    # @return [Hash]
    #   Returns the resulting hash-like access config.
    #
    def hashlike_access(to: :itself, by: nil, raise_if_not_found: false)
      requested_config = { lookup_fields:      Array.wrap(by),
                           response_method:    to,
                           assignment_method:  :"#{to}=",
                           raise_if_not_found: raise_if_not_found }

      hashlike_access_config.merge! requested_config.compact_blank
    end

    # A convenience method that calls {.hashlike_access} with `raise_if_not_found: true`.
    #
    # @option [Symbol, String] :to
    #   The name of the method to call on a record once found. Defaults to `:itself`, yielding the full record.
    #
    # @option [Symbol, String, Array<Symbol>, Array<String>] :by
    #   The field name (or list of names) against which lookup values should match to yield a "found record".
    #   IOW, this is the list of keys that will be passed to a `find_by` equivalent when looking for a record.
    #
    # @return [Hash]
    #   Returns the resulting hash-like access config.
    #
    def hashlike_access!(to: :itself, by: nil)
      hashlike_access(to:, by:, raise_if_not_found: true)
    end

    # Returns the current hash-like access config, with sensible defaults if {.hashlike_access} has not been called.
    #
    # @return [Hash]
    #   Returns the current hash-like access config.
    #
    def hashlike_access_config
      @hashlike_access_config ||= { lookup_fields:      Array.wrap(primary_key),
                                    response_method:    :itself,
                                    assignment_method:  nil,
                                    raise_if_not_found: false }
    end

    # Finds a record using the configured "lookup_fields" matched to the provided "lookup_values".
    #
    # @param lookup_values [Array]
    #   A list consisting of lookup values to match against the "lookup_fields" in search of a record.
    #
    # @return [ActiveRecord::Base, nil]
    #   Returns the matching record or `nil` if none was found and the "raise_if_not_found" config is `false`.
    #
    # @raise [ActiveRecord::RecordNotFound]
    #
    def hashlike_access_lookup(*lookup_values)
      record = find_by hashlike_access_config[:lookup_fields].zip(lookup_values).to_h
      raise ActiveRecord::RecordNotFound if record.blank? && hashlike_access_config[:raise_if_not_found]

      record
    end
  end
end
