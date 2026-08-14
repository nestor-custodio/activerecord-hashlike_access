require 'active_record'

module ActiveRecord
  module HashlikeAccess
    def [](*)
      hashlike_access_lookup(*)&.public_send hashlike_access_config[:response_method]
    end

    def []=(*args)
      value = args.pop
      record = hashlike_access_lookup(*args) || return

      record.public_send hashlike_access_config[:assignment_method], value
      record.save!
    end

    private

    def hashlike_access(to: :itself, by: nil, raise_if_not_found: false)
      requested_config = { lookup_fields:      Array.wrap(by),
                           response_method:    to,
                           assignment_method:  :"#{to}=",
                           raise_if_not_found: raise_if_not_found }

      hashlike_access_config.merge! requested_config.compact_blank
    end

    def hashlike_access!(to: :itself, by: nil)
      hashlike_access(to:, by:, raise_if_not_found: true)
    end

    def hashlike_access_config
      @hashlike_access_config ||= { lookup_fields:      Array.wrap(primary_key),
                                    response_method:    :itself,
                                    assignment_method:  nil,
                                    raise_if_not_found: false }
    end

    def hashlike_access_lookup(*lookup_values)
      record = find_by hashlike_access_config[:lookup_fields].zip(lookup_values).to_h
      raise ActiveRecord::RecordNotFound if record.blank? && hashlike_access_config[:raise_if_not_found]

      record
    end
  end
end
