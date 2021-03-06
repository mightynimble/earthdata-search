require "spec_helper"

describe "Project dataset list", reset: true do

  before(:each) do
    load_page :search
    first_dataset_result.click_link "Add dataset to the current project"
    nth_dataset_result(10).click_link "Add dataset to the current project"

    dataset_results.click_link "View Project"
  end

  it "displays datasets that have been added to the project" do
    expect(project_overview).to have_css('.panel-list-item', count: 2)
  end

  it 'hides the "Browse Datasets" pane' do
    expect(page).to have_css('#datasets-overlay.is-master-overlay-parent-hidden')
  end

  it "provides navigation back to the dataset search" do
    expect(page).to have_visible_project_overview
    expect(page).to have_link("Back to Dataset Search")
    click_link("Back to Dataset Search")
    expect(page).to have_visible_dataset_results
  end

  context "when clicking on a dataset's \"View dataset details\" link" do
    it "shows the dataset's details" do
      first_project_dataset.click_link 'View dataset details'
      expect(page).to have_visible_dataset_details
      dataset_details.click_link "Back to Datasets"
      expect(page).to have_visible_project_overview
    end
  end

  context 'when clicking the "Remove" button' do
    before(:each) do
      first_project_dataset.click_link "View dataset"
      first_project_dataset.click_link "Remove dataset from the current project"
    end

    it "removes the selected dataset from the project list" do
      expect(project_overview).to have_css('.panel-list-item', count: 1)
    end

    it "removes the selected dataset's visualizations" do
      expect(project_overview).to have_no_link('Hide dataset')
    end
  end

  context "when clicking the 'View dataset' button" do
    before(:each) do
      first_project_dataset.click_link "View dataset"
    end

    it "highlights the selected dataset" do
      expect(project_overview).to have_link('Hide dataset', count: 1)
    end

    it "un-highlights the selected dataset when clicking the button again" do
      first_project_dataset.click_link "Hide dataset"
      expect(project_overview).to have_no_link('Hide dataset')
    end

    it "keeps the selected dataset highlighted when returning to the project" do
      click_link "Back to Dataset Search"
      sleep(1) # Wait for sliding transition
      dataset_results.click_link "View Project"
      expect(project_overview).to have_link('Hide dataset', count: 1)
    end

    it "highlights the View all datasets button when individually showing all datasets" do
      second_project_dataset.click_link 'View dataset'
      expect(project_overview).to have_link 'Hide all datasets'
    end
  end

  context "when clicking the 'View all datasets' button" do
    before :each do
      click_link 'View all datasets'
    end

    it "highlights all project datasets" do
      expect(project_overview).to have_css('.master-overlay-global-actions a.button-active', count: 1)
      expect(project_overview).to have_link('Hide dataset', count: 2)
    end

    it "un-highlights all project datasets when clicking the button again" do
      click_link 'Hide all datasets'
      expect(project_overview).to have_no_link('Hide dataset')
    end

    it "un-highlights the View all datasets button when hiding an individual dataset" do
      first_project_dataset.click_link 'Hide dataset'
      expect(project_overview). to have_no_link('Hide all datasets')
    end
  end

end
