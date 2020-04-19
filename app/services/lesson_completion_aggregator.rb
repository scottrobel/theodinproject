class LessonCompletionAggregator
  def initialize(lessons)
    @lessons = lessons
  end

  def lesson_ids
    @lesson_ids ||= lessons.pluck(:id)
  end
end