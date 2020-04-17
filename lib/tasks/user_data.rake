namespace :user_data do
  desc 'Print User Data'
  task print_completion_data: :environment do
    course_lesson_data = Course.all.map do |course|
      completion_data = LessonCompletionData.new(course)
      [course.title, completion_data.all_completion_data]
    end.to_h
    puts course_lesson_data.to_yaml
  end
end
