require 'spec_helper'

describe 'Dataset NRT Filtering', reset: false do
  before :all do
    Capybara.reset_sessions!
    load_page :search, facets: true
    find("h3.facet-title", text: 'Features').click
  end

  context 'when selecting the NRT filter' do
    before :all do
      find('.facets-item', text: 'Near Real Time').click
      wait_for_xhr
    end

    it 'shows only NRT datasets' do
      expect(dataset_results).to have_css('.badge-nrt', count: 22)
    end

    context 'when un-selecting the NRT filter' do
      before :all do
          find('.applied-facets .facets-item', text: 'Near Real Time').click
        wait_for_xhr
      end

      it 'shows all datasets' do
        expect(dataset_results).to have_css('.badge-nrt', count: 2)
      end

      it 'shows recent and featured datasets' do
        expect(dataset_results).to have_content('Recent and Featured')
      end
    end
  end

end
