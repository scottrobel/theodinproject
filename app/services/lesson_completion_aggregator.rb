class LessonCompletionAggregator
  def initialize(lessons, lesson_completion_filter = default_lesson_completion_filter)
    @lessons = lessons
  end

  def lesson_completions_count
    @lesson_completions_count ||= \
    filtered_lesson_completions \
    .group(:lesson_id) \
    .count
  end

  def lesson_avg_completion_date_pairs
    @lesson_avg_completion_date_pairs ||= \
    filtered_lesson_completions \
    .group(:lesson_id) \
    .average('extract(epoch from lesson_completions.created_at)')
  end

  private

  def default_lesson_completion_filter
    ['lesson_completions.created_at > ?', last_lesson_creation_time]
  end

  def last_lesson_creation_time
    @most_recent_lesson_creation_epoch ||= Lesson.maximum(:created_at)
  end

  def filtered_lesson_completions
    lesson_completions.where(**lesson_completion_filter)
  end

  def lesson_completions
    LessonCompletions.where(id: lesson_ids)
  end

  def lesson_ids
    @lesson_ids ||= @lessons.pluck(:id)
  end
end