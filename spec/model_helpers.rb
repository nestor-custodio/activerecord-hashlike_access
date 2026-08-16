# Set up database.
#
ActiveRecord::Base.establish_connection adapter:  'sqlite3',
                                        database: ':memory:'

# Helper for creating one-off models.
# (All fields given are created as strings.)
#
def one_off(with: [], primary_key: :id, hashlike_access: {})
  raise ArgumentError unless with.present?
  raise ArgumentError unless primary_key.present?

  table_name = Random.uuid_v4.underscore

  # Create the table.
  #
  ActiveRecord::Schema.define do
    # Don't clutter test output with DDL.
    #
    ActiveRecord::Migration.suppress_messages do
      create_table(table_name, primary_key:) do |table|
        Array.wrap(with).each { |field_name| table.string field_name }

        # Composite primary keys require that we specify the fields ourselves.
        #
        primary_key.each { table.integer it, null: false } if primary_key.is_a? Array
      end
    end
  end

  # Set up a model for it.
  #
  Class.new(ActiveRecord::Base) do
    extend ActiveRecord::HashlikeAccess

    self.table_name = table_name
    self.hashlike_access(**hashlike_access)
  end
end

# Helper for wrapping model tests.
# (All params are passed through as-is to `one-off`.)
#
def using_a_one_off(...)
  model = one_off(...)
  yield model if block_given?
  model.connection.drop_table model.table_name

  nil
end
