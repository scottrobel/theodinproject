class LessonCompletionData
  def initialize(course)
    @course = course
    @lessons = course.lessons
  end

  private

  attr_reader :course

  def lesson_and_avg_completion_date_pairs
    @lesson_and_avg_completion_date_pairs ||= LessonCompletion.all.group(:lesson_id).average('extract(epoch from created_at)')
  end

  def ordered_lessons
    @ordered_lessons ||= @course.sections.includes(:lessons).map do |section|
      section.lessons.sort_by(&:position)
    end.flatten
  end

  def known_completion_durations
    lessons = ordered_lessons
    current_lesson = lessons.shift
    current_lesson_avg_completion_time = lesson_and_avg_completion_date_pairs[current_lesson.id]
    completion_durations = {}
    lessons.each do |lesson|
      next_lesson = lesson
      next_lesson_avg_completion_time = lesson_and_avg_completion_date_pairs[next_lesson.id]
      if next_lesson_avg_completion_time.nil? # if noone completed the assignment return data
        break
      else
        average_duration_to_finish_current_lesson = next_lesson_avg_completion_time - current_lesson_avg_completion_time
        completion_durations[current_lesson] = ActiveSupport::Duration.build(average_duration_to_finish_current_lesson)
        current_lesson_avg_completion_time = next_lesson_avg_completion_time
        current_lesson = next_lesson
      end
    end
    completion_durations
  end
end