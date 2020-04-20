class LessonCompletionData
  def initialize(course)
    @course = course
    @lesson_completions = lesson_completions_after(newest_lesson_creation_date)
    @lesson_duration_data = LessonDurationData.new(@lesson_completions, ordered_lessons)
    @agregated_lesson_completions = LessonCompletionAggregator.new(@lesson_completions)
  end

  def newest_lesson_creation_date
    @most_recent_lesson_creation_epoch ||= Lesson.maximum('created_at')
  end

  def course_duration_string
    @lesson_duration_data.known_completion_durations_total.inspect
  end

  def lessons_with_known_completion_durations
    @lesson_duration_data.lessons_with_known_completion_durations
  end
  
  def lesson_weight(lesson)
    @lesson_duration_data.lesson_weight(lesson)
  end

  def lesson_percentage(lesson)
    @lesson_duration_data.lesson_percentage_of_total(lesson)
  end

  def lesson_duration(lesson)
    @lesson_duration_data.get_lesson_duration(lesson).inspect
  end
  def lesson_completions_count(lesson)
    @agregated_lesson_completions.lesson_completions_count[lesson.id]
  end
  
  private

  attr_reader :course

  def lesson_completions
    @lesson_completions ||= \
    LessonCompletion.where(lesson_id: lesson_ids)
  end

  def lesson_completions_after(date)
    lesson_completions.where('lesson_completions.created_at > ?', date)
  end

  def lesson_ids
    @lesson_ids ||= course.lessons.pluck(:id)
  end

  def ordered_lessons
    Lesson\
    .order('lessons.position')\
    .where(id: lesson_ids)
  end
end
