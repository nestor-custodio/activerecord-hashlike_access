require 'active_record'
require 'active_record/hashlike_access'

# @api entrypoint
module ActiveRecord
  class Base
    extend ActiveRecord::HashlikeAccess
  end
end
