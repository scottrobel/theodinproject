class LessonDurationCalcutator
  def initialize(lesson_completions)
    @aggregated_lesson_completions = LessonCompletionAggregator.new(lesson_completions)
  end

  def known_completion_durations
    lessons = ordered_lessons
    current_lesson = lessons[0]
    current_lesson_avg_completion_time = @aggregated_lesson_completions.lesson_avg_completion_datetime_pairs[current_lesson.id]
    completion_durations = {}
    lessons.each do |lesson|
      next_lesson = lesson
      next_lesson_avg_completion_time = lesson_and_avg_completion_date_pairs[next_lesson.id]
      if next_lesson_avg_completion_time.nil? # if noone completed the assignment return data
        break
      else
        average_duration_to_finish_next_lesson = next_lesson_avg_completion_time - current_lesson_avg_completion_time
        completion_durations[next_lesson] = ActiveSupport::Duration.build(average_duration_to_finish_next_lesson)
        current_lesson_avg_completion_time = next_lesson_avg_completion_time
        current_lesson = next_lesson
      end
    end
    completion_durations
  end
end