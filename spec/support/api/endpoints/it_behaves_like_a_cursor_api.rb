shared_examples_for 'a cursor api' do |model|
  let(:model_s) { model.name.underscore.to_sym }
  let(:model_ps) { model.name.underscore.pluralize.to_sym }
  context model.name do
    let(:cursor_params) { @cursor_params || {} }

    before do
      12.times { Fabricate(model_s) }
    end

    it 'returns 10 items by default' do
      expect(client.send(model_ps, cursor_params).count).to eq 10
    end

    it 'returns 2 items' do
      expect(client.send(model_ps, cursor_params.merge(size: 2)).count).to eq 2
    end

    it 'returns a first page with a cursor' do
      response = client.send(model_ps, cursor_params.merge(size: 2))
      expect(response._links.self._url).to eq "http://example.org/api/#{model_ps}?#{cursor_params.merge(size: 2).to_query}"
      expect(response._links.next._url).to start_with "http://example.org/api/#{model_ps}?"
      expect(response._links.next._url).to match(/cursor\=.*%3A\h*/)
    end

    it 'paginates over the entire collection' do
      models_ids = []
      next_cursor = { size: 3 }
      loop do
        response = client.send(model_ps, next_cursor.merge(cursor_params))
        models_ids.concat(response.map { |instance| instance._links.self._url.gsub("http://example.org/api/#{model_ps}/", '') })
        break unless response._links[:next]
        next_cursor = Hash[CGI.parse(URI.parse(response._links.next._url).query).map { |a| [a[0], a[1][0]] }]
      end
      expect(models_ids.uniq.count).to eq model.all.count
    end

    it 'allows skipping of results via an offset query param' do
      models_ids = []
      next_cursor = { size: 3, offset: 3 }
      loop do
        response = client.send(model_ps, next_cursor.merge(cursor_params))
        models_ids.concat(response.map { |instance| instance._links.self._url.gsub("http://example.org/api/#{model_ps}/", '') })
        break unless response._links[:next]
        next_cursor = Hash[CGI.parse(URI.parse(response._links.next._url).query).map { |a| [a[0], a[1][0]] }]
      end
      expect(models_ids.uniq.count).to eq model.all.count - 3
    end

    context 'total count' do
      it "doesn't return total_count" do
        response = client.send(model_ps, cursor_params)
        expect(response).to_not respond_to(:total_count)
      end
      it 'returns total_count when total_count query string is specified' do
        response = client.send(model_ps, cursor_params.merge(total_count: true))
        expect(response.total_count).to eq model.all.count
      end
    end

    it 'returns all unique ids' do
      instances = client.send(model_ps, cursor_params)
      expect(instances.map(&:id).uniq.count).to eq 10
    end
  end
end
