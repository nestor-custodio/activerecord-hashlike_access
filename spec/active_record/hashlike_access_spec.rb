RSpec.describe ActiveRecord::HashlikeAccess do
  it 'has a version number' do
    expect(ActiveRecord::HashlikeAccess::VERSION).not_to be nil
  end

  describe 'gives ActiveRecord models' do
    describe 'hashlike access for fetching records' do
      it 'by (simple) primary key' do
        using_a_one_off with: :text do |model|
          records = { 1 => model.create(id: 1, text: 'abc'),
                      2 => model.create(id: 2, text: 'xyz') }

          expect(model[1]).to eq records[1]
          expect(model[2]).to eq records[2]
          expect(model[3]).to eq nil
        end
      end

      it 'by (composite) primary key' do
        using_a_one_off with: :text, primary_key: %i[id_1 id_2] do |model|
          records = { 1 => model.create(id_1: 1, id_2: 2, text: 'abc'),
                      2 => model.create(id_1: 3, id_2: 4, text: 'xyz') }

          expect(model[1, 2]).to eq records[1]
          expect(model[3, 4]).to eq records[2]
          expect(model[5, 6]).to eq nil
        end
      end

      it 'by a canonical "fetch field"' do
        using_a_one_off with: %i[lookup text], hashlike_access: { by: :lookup } do |model|
          records = { 'abc' => model.create(lookup: 'abc', text: 'def'),
                      'jkl' => model.create(lookup: 'jkl', text: 'xyz') }

          expect(model['abc']).to eq records['abc']
          expect(model['jkl']).to eq records['jkl']
          expect(model['zzz']).to eq nil
        end
      end

      it 'but raises an error if so requested' do
        using_a_one_off with: :text, hashlike_access: { raise_if_not_found: true } do |model|
          records = { 1 => model.create(id: 1, text: 'abc'),
                      2 => model.create(id: 2, text: 'xyz') }

          expect(model[1]).to eq records[1]
          expect(model[2]).to eq records[2]
          expect { model[3] }.to raise_error ActiveRecord::RecordNotFound
        end
      end
    end

    describe 'hashlike access for fetching values' do
      it 'by (simple) primary key' do
        using_a_one_off with: :text, hashlike_access: { to: :text } do |model|
          records = { 1 => model.create(id: 1, text: 'abc'),
                      2 => model.create(id: 2, text: 'xyz') }

          expect(model[1]).to eq records[1].text
          expect(model[2]).to eq records[2].text
          expect(model[3]).to eq nil
        end
      end

      it 'by (composite) primary key' do
        using_a_one_off with: :text, primary_key: %i[id_1 id_2], hashlike_access: { to: :text } do |model|
          records = { 1 => model.create(id_1: 1, id_2: 2, text: 'abc'),
                      2 => model.create(id_1: 3, id_2: 4, text: 'xyz') }

          expect(model[1, 2]).to eq records[1].text
          expect(model[3, 4]).to eq records[2].text
          expect(model[5, 6]).to eq nil
        end
      end

      it 'by a canonical "fetch field"' do
        using_a_one_off with: %i[lookup text], hashlike_access: { to: :text, by: :lookup } do |model|
          records = { 'abc' => model.create(lookup: 'abc', text: 'def'),
                      'jkl' => model.create(lookup: 'jkl', text: 'xyz') }

          expect(model['abc']).to eq records['abc'].text
          expect(model['jkl']).to eq records['jkl'].text
          expect(model['zzz']).to eq nil
        end
      end

      it 'but raises an error if so requested' do
        using_a_one_off with: :text, hashlike_access: { to: :text, raise_if_not_found: true } do |model|
          records = { 1 => model.create(id: 1, text: 'abc'),
                      2 => model.create(id: 2, text: 'xyz') }

          expect(model[1]).to eq records[1].text
          expect(model[2]).to eq records[2].text
          expect { model[3] }.to raise_error ActiveRecord::RecordNotFound
        end
      end
    end

    describe 'hashlike access for assigning values' do
      it 'by (simple) primary key' do
        using_a_one_off with: :text, hashlike_access: { to: :text } do |model|
          records = { 1 => model.create(id: 1, text: 'abc'),
                      2 => model.create(id: 2, text: 'xyz') }

          expect { model[1] = 'new_1' }.to change { model[1] }.from(records[1].text).to('new_1')
          expect { model[1] = 'new_2' }.not_to(change { model[2] })
        end
      end

      it 'by (composite) primary key' do
        using_a_one_off with: :text, primary_key: %i[id_1 id_2], hashlike_access: { to: :text } do |model|
          records = { 1 => model.create(id_1: 1, id_2: 2, text: 'abc'),
                      2 => model.create(id_1: 3, id_2: 4, text: 'xyz') }

          expect { model[1, 2] = 'new_1' }.to change { model[1, 2] }.from(records[1].text).to('new_1')
          expect { model[1, 2] = 'new_2' }.not_to(change { model[3, 4] })
        end
      end

      it 'by a canonical "fetch field"' do
        using_a_one_off with: %i[lookup text], hashlike_access: { to: :text, by: :lookup } do |model|
          records = { 'abc' => model.create(lookup: 'abc', text: 'def'),
                      'jkl' => model.create(lookup: 'jkl', text: 'xyz') }

          expect { model['abc'] = 'new_1' }.to change { model['abc'] }.from(records['abc'].text).to('new_1')
          expect { model['abc'] = 'new_2' }.not_to(change { model['jkl'] })
        end
      end

      # ---

      it 'via non-field "assignables"' do
        using_a_one_off with: :text, hashlike_access: { to: :enclosed_text } do |model|
          # Give the model custom accessors for the (non-field) `enclosed_text`.
          #
          model.class_eval do
            # Wraps the `text` in brackets.
            #
            def enclosed_text = "[#{text}]"

            # Stores the given "value" (sans the first and last chars), as `text`.
            #
            def enclosed_text=(value)
              update text: value.to_s[1..-2]
            end
          end

          records = { 1 => model.create(id: 1, text: 'abc'),
                      2 => model.create(id: 2, text: 'xyz') }

          expect { model[1] = '{new_1}' }.to change { model[1] }.from(records[1].enclosed_text).to('[new_1]')
          expect { model[1] = '-new_2-' }.not_to(change { model[2] })
        end
      end
    end
  end
end
