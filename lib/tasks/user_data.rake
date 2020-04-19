namespace :user_data do
  desc 'Print User Data'
  task print_completion_data: :environment do
    Course.all.each do |course|
      puts LessonCompletionDataSerializer.as_yaml(course)
    end
  end
end
