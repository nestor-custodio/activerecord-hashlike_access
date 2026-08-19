require 'active_record'
require 'active_record/hashlike_access'

# @api entrypoint
class ActiveRecord::Base
  extend ActiveRecord::HashlikeAccess
end
