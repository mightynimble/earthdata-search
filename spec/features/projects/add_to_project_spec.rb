require "spec_helper"

describe "Add to project", reset: false do
  before(:all) do
    Capybara.reset_sessions!
    load_page :search
  end

  context "in the dataset results list" do
    it 'displays "Add" buttons for datasets not in the current project' do
      within '#dataset-results-list > :first-child' do
        expect(page).to have_link("Add dataset to the current project")
        expect(page).to have_no_link("Remove dataset from the current project")
      end
    end

    it 'displays "Remove" buttons for datasets not in the current project' do
      within '#dataset-results-list > :first-child' do
        click_link "Add dataset to the current project"
        expect(page).to have_no_link("Add dataset to the current project")
        expect(page).to have_link("Remove dataset from the current project")
      end

      reset_project
    end

    it 'initially displays information about adding items to projects' do
      expect(page).to have_text('Add datasets to your project to compare and retrieve their data.')
    end

    it 'initially displays no link to view the current project' do
      expect(page).to have_no_link('View Project')
    end

    context 'clicking on an "Add" button' do
      before(:all) do
        within '#dataset-results-list > :first-child' do
          click_link "Add dataset to the current project"
          wait_for_xhr
        end
      end

      after(:all) do
        reset_project
      end

      # EDSC-146: As a user, I want to see how long my granule searches take,
      #           so that I may understand the performance of the system
      it "searches for granules, displaying a granule count and search time" do
        within '#dataset-results-list > :first-child' do
          expect(page).to have_text("Granules")
          granules_info = find('.dataset-granules-info')
          expect(granules_info.text).to match(/\d Granules in \d+\.\d+s/)
        end
      end

      it 'adds the dataset to the current project' do
        expect(project_dataset_ids).to match_array(['15 Minute Stream Flow Data: USGS (FIFE)'])
      end

      it 'updates the button for the dataset to be a remove button' do
        within '#dataset-results-list > :first-child' do
          expect(page).to have_no_link("Add dataset to the current project")
          expect(page).to have_link("Remove dataset from the current project")
        end
      end

      it 'displays a summary of the datasets in the project' do
        expect(page).to have_text("You have 1 dataset in your project.")
      end

      it 'displays a link to view the project' do
        expect(page).to have_link("View Project")
      end
    end

    context 'clicking on a "Remove" button' do
      context 'when the removed dataset was the last one in the project' do
        before(:all) do
          within '#dataset-results-list > :first-child' do
            click_link "Add dataset to the current project"
            click_link "Remove dataset from the current project"
          end
        end

        after(:all) do
          reset_project
        end

        it 'removes the summary of the datasets in the project' do
          expect(page).to have_no_text("You have 1 dataset in your project.")
          expect(page).to have_text('Add datasets to your project to compare and retrieve their data.')
        end

        it 'hides the link to view the project' do
          expect(page).to have_no_link("View Project")
        end

        it 'removes the dataset from the current project' do
          expect(project_dataset_ids).to match_array([])
        end

        it 'updates the button for the dataset to be an add button' do
          within '#dataset-results-list > :first-child' do
            expect(page).to have_link("Add dataset to the current project")
            expect(page).to have_no_link("Remove dataset from the current project")
          end
        end
      end

      context 'when datasets remain in the project' do
        before(:all) do
          within '#dataset-results-list > :first-child' do
            click_link "Add dataset to the current project"
          end
          within '#dataset-results-list > :nth-child(2)' do
            click_link "Add dataset to the current project"
            click_link "Remove dataset from the current project"
          end
        end

        after(:all) do
          reset_project
        end

        it 'updates the summary of the datasets in the project' do
          expect(page).to have_text("You have 1 dataset in your project.")
          expect(page).to have_no_text('Add datasets to your project to compare and retrieve their data.')
        end

        it 'continues to show the link to view the project' do
          expect(page).to have_link("View Project")
        end

        it 'removes the dataset from the current project' do
          expect(project_dataset_ids).to match_array(['15 Minute Stream Flow Data: USGS (FIFE)'])
        end

        it 'updates the button for the dataset to be an add button' do
          within '#dataset-results-list > :nth-child(2)' do
            expect(page).to have_link("Add dataset to the current project")
            expect(page).to have_no_link("Remove dataset from the current project")
          end
        end
      end
    end
  end
end
