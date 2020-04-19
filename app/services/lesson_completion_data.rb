class LessonCompletionData
  def initialize(course)
    @course = course
    @lesson_completions = lesson_completions_after(newest_lesson_creation_date)
    @lesson_duration_data = LessonDurationData.new(@lesson_completions, ordered_lessons)
    @agregated_lesson_completions = LessonCompletionAggregator.new(@lesson_completions)
  end

  def all_completion_data
    completion_data(percentage: true, duration: true, course_duration: true, completion_count: true, lesson_weight: true)
  end

  def completion_data(data_options)
    course_data = {}
    course_data['NOTICE'] = "Lesson Completion Data before #{Time.at(newest_lesson_creation_date)} have been ommited"
    course_data['course_duration'] = course_duration_string if data_options[:course_duration]
    lessons = lessons_with_known_completion_durations
    course_lessons_data = lessons.map do |lesson|
      lesson_data = {}
      lesson_data['lesson_weight'] = lesson_weight(lesson) if data_options[:lesson_weight]
      lesson_data['percentage'] = lesson_percentage(lesson) if data_options[:percentage]
      lesson_data['duration'] = lesson_duration(lesson) if data_options[:duration]
      lesson_data['Counted Users Who Finished'] = lesson_completions_count(lesson) if data_options[:completion_count]
      [lesson.title, lesson_data]
    end.to_h
    course_data.merge(course_lessons_data)
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
    .joins('INNER JOIN sections ON lessons.section_id = sections.id')\
    .joins('INNER JOIN courses ON sections.course_id = courses.id')\
    .order('lessons.position')\
    .where('courses.id = ?', @course.id)
  end
end
