class LessonCompletionAggregator
  def initialize(lesson_completions)
    @lesson_completions = lesson_completions
  end

  def lesson_completions_count
    @lesson_completions_count ||= \
    @lesson_completions \
    .group(:lesson_id) \
    .count
  end

  def lesson_avg_completion_datetime_pairs
    @lesson_avg_completion_date_pairs ||= \
    @lesson_completions \
    .group(:lesson_id) \
    .average('extract(epoch from lesson_completions.created_at)')
  end
end