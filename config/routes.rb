Rails.application.routes.draw do
  post '/create_ecosystem' => 'ecosystems#create'

  post '/create_course' => 'courses#create'

  post '/update_roster' => 'rosters#update'

  post '/prepare_course_ecosystem' => 'course_ecosystems#prepare'

  post '/update_course_ecosystems' => 'course_ecosystems#update'

  post '/update_course_active_dates' => 'course_active_dates#update'

  post '/fetch_course_ecosystem_statuses' => 'course_ecosystems#status'

  post '/update_globally_excluded_exercises'  => 'global_exercise_exclusions#update'

  post '/update_course_excluded_exercises'    => 'course_exercise_exclusions#update'

  post '/create_update_assignments' => 'assignments#create_update'

  post '/fetch_assignment_pes' => 'exercises#fetch_assignment_pes'

  post '/fetch_assignment_spes' => 'exercises#fetch_assignment_spes'

  post '/fetch_practice_worst_areas_exercises' => 'exercises#fetch_practice_worst_areas'

  post '/record_responses' => 'responses#record'

  post '/fetch_response_bundles' => 'response_bundles#fetch'

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
