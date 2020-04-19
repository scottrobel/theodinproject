class LessonCompletionData
  def initialize(course)
    @course = course
    @lesson_completions = lesson_completions_after(newest_lesson_creation_date)
    @lesson_duration_data = LessonDurationData.new(@lesson_completions, ordered_lessons)
  end

  def all_completion_data
    completion_data(percentage: true, duration: true, course_duration: true, completion_count: true)
  end

  def completion_data(data_options)
    course_data = {}
    course_data['NOTICE'] = "Lesson Completion Data before #{Time.at(most_recent_lesson_creation_epoch)} have been ommited"
    course_data['course_duration'] = known_lesson_times_total.inspect if data_options[:course_duration]
    lesson_duration_pairs = known_completion_durations
    course_lessons_data = lesson_duration_pairs.map do |lesson, duration|
      lesson_data = {}
      lesson_data['percentage'] = duration_percentage(duration) if data_options[:percentage]
      lesson_data['duration'] = duration.inspect if data_options[:duration]
      lesson_data['users who finished'] = lesson_completions_count[lesson.id] if data_options[:completion_count]
      [lesson.title, lesson_data]
    end.to_h
    course_data.merge(course_lessons_data)
  end

  def lesson_duration(lesson)
    @lesson_duration_data.known_completion_durations[lesson.id]
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

  def newest_lesson_creation_date
    @most_recent_lesson_creation_epoch ||= Lesson.maximum('created_at')
  end

  def lesson_and_avg_completion_date_pairs
    @lesson_and_avg_completion_date_pairs ||= lesson_and_avg_completion_date_pairs_query
  end

  def lesson_completions_count
    @lesson_completions_count ||= lesson_completions_count_query
  end

  def ordered_lessons
    Lesson\
    .joins('INNER JOIN sections ON lessons.section_id = sections.id')\
    .joins('INNER JOIN courses ON sections.course_id = courses.id')\
    .order('lessons.position')\
    .where('courses.id = ?', @course.id)
  end

  def duration_percentage(duration)
    duration_ratio = (duration / known_lesson_times_total).to_f
    lesson_percentage = (duration_ratio * 100).round(2)
    "#{lesson_percentage}%"
  end
end
