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
end