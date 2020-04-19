class LessonCompletionAggregator
  def initialize(lessons)
    @lessons = lessons
  end

  private

  def lesson_completions
    LessonCompletions.where(id: lesson_ids)
  end

  def lesson_ids
    @lesson_ids ||= lessons.pluck(:id)
  end
end