class LessonCompletionDataSerializer
  def initialize(course)
    @course = course
    @lesson_completion_data = LessonCompletionData.new(@course)
  end

  def as_yaml
    {@course.title => course_data_hash.merge(lessons_data_hash)}.to_yaml
  end

  def self.as_yaml(course)
    new(course).as_yaml
  end

  private

  def lessons_data_hash
    lessons_data_hash = {}
    lessons = @lesson_completion_data.lessons_with_known_completion_durations
    lessons.map do |lesson|
      lessons_data_hash[lesson.title] = lesson_data_hash(lesson)
    end
    lessons_data_hash
  end

  def course_data_hash
    {
      'Last Lesson Creation' => \
      "Ommited Results Before #{Time.at(@lesson_completion_data.newest_lesson_creation_date)}",
      'course_duration' => @lesson_completion_data.course_duration_string
    }
  end

  def lesson_data_hash(lesson)
    {
      'lesson_weight' => @lesson_completion_data.lesson_weight(lesson),
      'percentage' => @lesson_completion_data.lesson_percentage(lesson),
      'duration' => @lesson_completion_data.lesson_duration(lesson),
      '# of Lesson Completions calculated' => @lesson_completion_data\
      .lesson_completions_count(lesson)
    }
  end
end