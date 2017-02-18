Rails.application.routes.draw do
  post '/create_ecosystem' => 'ecosystems#create'

  post '/create_course' => 'courses#create'

  post '/fetch_ecosystem_metadatas' => 'ecosystems#fetch_metadatas'
  post '/fetch_course_metadatas' => 'courses#fetch_metadatas'

  post '/update_rosters' => 'rosters#update'
  post '/update_course_active_dates' => 'course_active_dates#update'

  post '/prepare_course_ecosystem' => 'course_ecosystems#prepare'
  post '/update_course_ecosystems' => 'course_ecosystems#update'
  post '/fetch_course_ecosystem_statuses' => 'course_ecosystems#status'

  post '/update_globally_excluded_exercises' => 'global_exercise_exclusions#update'
  post '/update_course_excluded_exercises'   => 'course_exercise_exclusions#update'

  post '/create_update_assignments' => 'assignments#create_update'
  post '/record_responses' => 'responses#record'

  post '/fetch_assignment_pes' => 'exercises#fetch_assignment_pes'
  post '/fetch_assignment_spes' => 'exercises#fetch_assignment_spes'
  post '/fetch_practice_worst_areas_exercises' => 'exercises#fetch_practice_worst_areas'

  post '/update_assignment_pes' => 'exercises#update_assignment_pes'
  post '/update_assignment_spes' => 'exercises#update_assignment_spes'
  post '/update_practice_worst_areas_exercises' => 'exercises#update_practice_worst_areas'

  post '/fetch_student_clues' => 'clues#fetch_student'
  post '/fetch_teacher_clues' => 'clues#fetch_teacher'

  post '/update_student_clues' => 'clues#update_student'
  post '/update_teacher_clues' => 'clues#update_teacher'

  post '/fetch_ecosystem_events' => 'ecosystem_events#fetch'
  post '/fetch_course_events' => 'course_events#fetch'
end
