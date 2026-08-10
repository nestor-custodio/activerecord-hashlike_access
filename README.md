[![MIT License](https://img.shields.io/github/license/nestor-custodio/activerecord-hashlike_access)](https://tldrlegal.com/license/mit-license)


# ActiveRecord::HashlikeAccess

Pulling this module into your ActiveRecord models gives you Hash-like getters (`[]`) and setters (`[]=`) for _individual records/values_. This is not only slightly cleaner to read/write, but also encourages fetching items by either their `id` or a canonical "lookup field", minimizing the likelihood of pulling records by an unindexed field.

In simplest terms:
```ruby
# Hash-Like Access to Records:

class Vehicle < ApplicationRecord
  hashlike_access by: :vin_number
  # ...
end

record = Vehicle.find_by vin_number: vin
# ... becomes ...
record = Vehicle[vin]


# Hash-Like Access to Values:

class Vehicle < ApplicationRecord
  hashlike_access to: :license_plate, by: :vin_number
  # ...
end

plate = Vehicle.find_by vin_number: vin
Vehicle.find_by(vin_number: vin).update! license_plate: new_plate
# ... becomes ...
plate = Vehicle[vin]
Vehicle[vin] = new_plate
```

Importantly, note that **this gem works on the model, not its relations**. ActiveRecord's existing bracket constructs for referencing _relations_ (i.e. resultsets) as an Array will continue to work as they always have.


## Installation

- If your project uses [Bundler](https://github.com/bundler/bundler):
  - Add the following to your application's Gemfile:
    ```ruby
    gem 'activerecord-hashlike_access'
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

### Hash-Like Access to _Records_

… TODO …


### Hash-Like Access to _Values_

… TODO …


### Hash-Like Updates to _Values_

… TODO …


### Using Non-Scalar Keys

… TODO …


## Performance Considerations

… TODO …


## Potential Gotchas

… TODO …


## Feature Roadmap / Future Development

- [ ] Allow Hash-like fetching of _records_.
- [ ] Allow Hash-like fetching of _values_.
- [ ] Allow Hash-like updating of _values_.
- [ ] Allow "record not found" behaviours.


## Contribution / Development

Bug reports and pull requests are welcome at: [https://github.com/nestor-custodio/activerecord-hashlike_access](https://github.com/nestor-custodio/activerecord-hashlike_access)

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

Linting is courtesy of [Rubocop](https://docs.rubocop.org/) (`rake rubocop`) and documentation is built using [YARD](https://yardoc.org/). Please ensure you have a clean bill of health from Rubocop and that any new features and/or changes to behaviour are reflected in the adjacent documentation before submitting a pull request.


## License

`ActiveRecord::HashlikeAccess` is available as open source under the terms of the [MIT License](https://tldrlegal.com/license/mit-license).
