class LessonCompletionData
  def initialize(course)
    @course = course
    @lessons = course.lessons
  end

  private

  attr_reader :course
end