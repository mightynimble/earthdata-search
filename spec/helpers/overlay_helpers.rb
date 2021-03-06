module Helpers
  module OverlayHelpers
    def reset_overlay
      page.execute_script """
        overlay = $('.master-overlay')
        overlay.masterOverlay('level', 0)
        overlay.masterOverlay('show')
        overlay.masterOverlay('showParent')
        overlay.masterOverlay('hideSecondary')
      """
    end

    def reset_visible_datasets
      page.evaluate_script("""
        var i, len, visible = edsc.models.data.Dataset.visible();
        for (i = 0, len = visible.length; i < len; i++) {
          visible[i].visible(false);
        }
        edsc.models.page.current.datasets.allDatasetsVisible(false)
        null
      """)
    end

    def have_visible_facets
      have_css('.is-master-overlay-parent-hidden')
    end

    def dataset_results
      page.find('#dataset-results')
    end

    def unfeatured_dataset_results
      page.find('#dataset-results-list')
    end

    def featured_dataset_results
      page.find('#dataset-featured-list')
    end

    def first_featured_dataset
      nth_panel(featured_dataset_results, 1)
    end

    def first_dataset_result
      nth_panel(unfeatured_dataset_results, 1)
    end

    def second_dataset_result
      nth_panel(unfeatured_dataset_results, 2)
    end

    def nth_dataset_result(n)
      nth_panel(unfeatured_dataset_results, n)
    end

    def dataset_details
      page.find('#dataset-details')
    end

    def granule_details
      page.find('#granule-details')
    end

    def project_overview
      page.find('#project-overview')
    end

    def first_project_dataset
      nth_panel(project_overview, 1)
    end

    def second_project_dataset
      nth_panel(project_overview, 2)
    end

    def nth_project_dataset(n)
      nth_panel(project_overview, n)
    end

    def granule_list
      page.find('#granule-list')
    end

    def first_granule_list_item
      nth_panel(granule_list, 1)
    end

    def second_granule_list_item
      nth_panel(granule_list, 2)
    end

    def nth_granule_list_item(n)
      nth_panel(granule_list, n)
    end

    private

    def nth_panel(root, n)
      root.find(".panel-list-item:nth-child(#{n})")
    end
  end
end
