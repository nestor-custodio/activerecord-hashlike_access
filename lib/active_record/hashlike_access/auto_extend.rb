require 'active_record'
require 'active_record/hashlike_access'

class ActiveRecord::Base
  extend ActiveRecord::HashlikeAccess
end
