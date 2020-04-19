class LessonCompletionAggregator
  def initialize(lessons, lesson_completion_filter = nil)
    @lessons = lessons
  end

  def lesson_completions_count
    filtered_lesson_completions\
    .group(:lesson_id)\
    .count
  end

  private

  def filtered_lesson_completions
    if lesson_completion_filter
      lesson_completions.where(**lesson_completion_filter)
    else
      lesson_completions
    end
  end

  def lesson_completions
    LessonCompletions.where(id: lesson_ids)
  end

  def lesson_ids
    @lesson_ids ||= lessons.pluck(:id)
  end
end