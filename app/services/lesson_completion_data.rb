class LessonCompletionData
  def initialize(course)
    @course = course
    @lessons = course.lessons
  end
end