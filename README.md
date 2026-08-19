[![Gem Version](https://img.shields.io/github/v/release/nestor-custodio/activerecord-hashlike_access?color=green&label=gem%20version)](https://rubygems.org/gems/activerecord-hashlike_access)
[![MIT License](https://img.shields.io/github/license/nestor-custodio/activerecord-hashlike_access)](https://tldrlegal.com/license/mit-license)


# ActiveRecord::HashlikeAccess

Pulling this module into your ActiveRecord models gives you Hash-like getters (`[]`) and setters (`[]=`) for _individual records/values_. This is not only slightly cleaner to read/write, but also encourages fetching items by either their `id` or a canonical "lookup field", minimizing the likelihood of pulling records by an unindexed field.

In simplest terms:
```ruby
# Given a "roles" table with
# `id`, `name`, and `display_text`...


# Hash-Like Access to Records:

class Role < ApplicationRecord
  extend ActiveRecord::HashlikeAccess
  hashlike_access by: :name
end

role = Role.find_by name: name
# ... becomes ...
role = Role[name]


# Hash-Like Access to Values:

class Role < ApplicationRecord
  extend ActiveRecord::HashlikeAccess
  hashlike_access to: :display_text, by: :name
end

role_display_text = Role.find_by(name: name).display_text
# ... becomes ...
role_display_text = Role[name]

Role.find_by(name: name).update! display_text: new_display_text
# ... becomes ...
Role[name] = new_display_text

```

Importantly, note that **this gem works on the model, not its relations**. ActiveRecord's existing bracket constructs for referencing _relations_ (i.e. resultsets) in an `Array`-like fashion will continue to work as they always have.


## Installation

- If your project uses [Bundler](https://github.com/bundler/bundler):
  - Add one of the following to your application's Gemfile:
    ```ruby
    # For on-demand usage:

    gem 'activerecord-hashlike_access'


    # To automatically `extend ActiveRecord::HashlikeAccess`
    # into all your (`ActiveRecord::Base`-descended) models:

    gem 'activerecord-hashlike_access', require: 'active_record/hashlike_access/auto_extend'
    ```
  - And then run a:
    ```shell
    $ bundle install
    ```

- Or, you can keep things simple with a manual install:
  ```shell
  $ gem install activerecord-hashlike_access
  ```


## Usage

Incorporating the `ActiveRecord::HashlikeAccess` module into a model will allow you to access it by a hash-like syntax, with the entrypoints for defining _what_ you would like access to and _how_ you would like to access it being the `hashlike_access` and `hashlike_access!` methods.

These two methods are nearly identical, the only difference being that a `hashlike_access` lookup that finds no matching records will return a `nil` (similar to ActiveRecord's `find_by`), whereas a failed `hashlike_access!` lookup will instead `raise ActiveRecord::RecordNotFound` (as a `find_by!` would).

`hashlike_access`/`hashlike_access!` take two arguments:
- `to` (optional): the field (or _arity-0_ method) whose value you would like to get back for hash-like lookups; if omitted, the full record is returned
- `by` (optional): the field by which you would like to find matching records; if omitted, the model's primary key is used

If your model pulls from `ActiveRecord::HashlikeAccess` but does not explicitly call one of these methods, the default behaviour will grant you hash-like access to records by the model's primary key.


### Hash-Like Access to _Records_

```ruby
class YourModel < ApplicationRecord
  extend ActiveRecord::HashlikeAccess

  # For implicit access to records BY the primary key,
  # you can omit the `hashlike_access` call altogether.

  # ...


  # For explicit access to records BY the primary key,
  # call `hashlike_access` while omitting the `to` option:

  hashlike_access by: primary_key


  # For access to records BY an arbitrary "lookup field",
  # give `hashlike_access` the 'by' field and no 'to' option:

  hashlike_access by: :some_lookup_field_name

end
```

Any of the above options will make hash-like access (`YourModel[some_value]`) equivalent to a `find_by` (or a `find_by!`, in the case of `hashlike_access!`) using the requested field, resulting in:
- the matching record, if one is found
- a `nil` value, in the case of `hashlike_access`
- an `ActiveRecord::RecordNotFound` error, in the case of `hashlike_access!`


### Hash-Like Access to _Values_

```ruby
class YourModel < ApplicationRecord
  extend ActiveRecord::HashlikeAccess

  # For access TO a specific value for records matched BY the primary key,
  # `hashlike_access` needs the target name via 'to', but the 'by' is optional:

  hashlike_access to: :field_or_method_name
  # ... or ...
  hashlike_access to: :field_or_method_name, by: primary_key


  # For access TO a specific value BY an arbitrary "lookup field",
  # give `hashlike_access` both the 'to' target and the 'by' field:

  hashlike_access to: :field_or_method_name, by: :some_lookup_field_name

end
```

Any of the above options will make hash-like access (`YourModel[some_value]`) equivalent to a `find_by`/`find_by!` followed by the requested method call. As with record lookups: if no matching record is found, expect a `nil` value or an `ActiveRecord::RecordNotFound` error, depending on whether you use `hashlike_access` or `hashlike_access!`.


### Hash-Like Assignment to _Values_

Requesting hash-like access to a value ([see above](#hash-like-access-to-values)) also makes hash-like _assignment_ (`[]=`) available **provided that makes sense**, i.e.:

- You have hash-like access to a field and the model is not read-only:
  ```ruby
  class YourModel < ApplicationRecord
    extend ActiveRecord::HashlikeAccess
    hashlike_access to: :field_x
  end

  # Getting a value:
  field_x = YourModel[some_key]

  # Setting a value:
  YourModel[some_key] = new_value_for_field_x
  ```

- You have hash-like access to a method and there is _also_ a corresponding `=` method for it:
  ```ruby
  class YourModel < ApplicationRecord
    extend ActiveRecord::HashlikeAccess
    hashlike_access to: :method_x

    def method_x
      # ...
    end

    def method_x=(value)
      # ...
    end
  end

  # Getting a value:
  method_x = YourModel[some_key]

  # Setting a value:
  YourModel[some_key] = value_to_pass_to_method_x_assignment
  ```
  If you attempt a hash-like value assignment and the requisite assignment method has not been defined, a `NoMethodError` will be raised.

Note hash-like value assignments are backed by an `update!` call, which will:
- run validations, possibly raising an `ActiveRecord::RecordInvalid` error
- trigger callbacks, possibly raising an `ActiveRecord::RecordNotSaved` error
- update timestamps


### Using Non-Scalar Keys

If your model uses a composite primary key, hash-like access happens by passing all the needed values:
```ruby
class YourModel < ApplicationRecord
  extend ActiveRecord::HashlikeAccess
  self.primary_key = [:primary_key_1, :primary_key_2]
end


# You need to provide as many key values
# as there are fields in the primary key:

record = YourModel[1, 2]
# ... or if you have an array:
record = YourModel[*key_values]
```

You can also do this if you want to use multiple non-primary-key lookup fields by passing an array to the `by` option:
```ruby
class YourModel < ApplicationRecord
  extend ActiveRecord::HashlikeAccess
  hashlike_access by: [:lookup_field_1, :lookup_field_2]
end


# You need to provide as many key values
# as there were fields in the "by" option:

record = YourModel[1, 2]
# ... or if you have an array:
record = YourModel[*lookup_values]
```


## Performance Considerations

Every instance of a hash-like lookup (`[some_key]`) is backed by a `find_by`/`find_by!` call, but ActiveRecord's query cache goes _a long way_ to reducing the performance penalty from repeated calls for the same record within a single worker.


## Potential Gotchas

As with anything ActiveRecord-related, there are always several ways to shoot yourself in the foot if you're not careful. Here are a few items to keep in mind and hopefully prevent this:

- The hash-like access construct is essentially syntax sugar around ActiveRecord's `find_by` mechanism. For many (most?) database engines, selecting (or _including_, in the case of a multi-field key) an unindexed field for your lookups will likely result in a full-table scan with every hash-like access. Be mindful of what field(s) you're using as your key(s).

- Selecting a lookup field with non-unique values means the matching record you get back is non-deterministic _unless you take precautions to avoid this_ (e.g. by setting a default scope with an `order` on fields that yield a unique combination of values). This should go without saying, but: maybe don't use a non-unique field to try to find a specific record?


## Contribution / Development

Bug reports and pull requests are welcome at: [https://github.com/nestor-custodio/activerecord-hashlike_access](https://github.com/nestor-custodio/activerecord-hashlike_access)

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

Linting is courtesy of [Rubocop](https://docs.rubocop.org/) (`rake rubocop`) and documentation is built using [YARD](https://yardoc.org/). Please ensure you have a clean bill of health from Rubocop and that any new features and/or changes to behaviour are reflected in the adjacent documentation before submitting a pull request.


## License

`ActiveRecord::HashlikeAccess` is available as open source under the terms of the [MIT License](https://tldrlegal.com/license/mit-license).
