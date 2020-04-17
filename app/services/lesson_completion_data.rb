class LessonCompletionData
  def initialize(course)
    @course = course
    @lessons = course.lessons
  end

  def all_completion_data
    completion_data(percentage: true, duration: true, course_duration: true, completion_count: true)
  end

  def completion_data(data_options)
    course_data = {}
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

  def self.reload_data
    @@lesson_and_avg_completion_date_pairs = LessonCompletion.all.group(:lesson_id).average('extract(epoch from created_at)')
    @@lesson_completions_count = LessonCompletion.group(:lesson_id).count
  end

  private

  attr_reader :course

  def lesson_and_avg_completion_date_pairs
    @@lesson_and_avg_completion_date_pairs ||= LessonCompletion.all.group(:lesson_id).average('extract(epoch from created_at)')
  end

  def ordered_lessons
    @ordered_lessons ||= @course.sections.includes(:lessons).map do |section|
      section.lessons.sort_by(&:position)
    end.flatten
  end

  def known_completion_durations
    lessons = ordered_lessons
    current_lesson = lessons[0]
    current_lesson_avg_completion_time = lesson_and_avg_completion_date_pairs[current_lesson.id]
    completion_durations = {}
    lessons.each do |lesson|
      next_lesson = lesson
      next_lesson_avg_completion_time = lesson_and_avg_completion_date_pairs[next_lesson.id]
      if next_lesson_avg_completion_time.nil? # if noone completed the assignment return data
        break
      else
        average_duration_to_finish_next_lesson = next_lesson_avg_completion_time - current_lesson_avg_completion_time
        completion_durations[next_lesson] = ActiveSupport::Duration.build(average_duration_to_finish_next_lesson)
        current_lesson_avg_completion_time = next_lesson_avg_completion_time
        current_lesson = next_lesson
      end
    end
    completion_durations
  end

  def lesson_completions_count
    @@lesson_completions_count ||= LessonCompletion.group(:lesson_id).count
  end

  def duration_percentage(duration)
    duration_ratio = (duration / known_lesson_times_total).to_f
    lesson_percentage = (duration_ratio * 100).round(2)
    "#{lesson_percentage}%"
  end

  def known_lesson_times_total
    @known_lesson_times_total ||= (known_completion_durations.values.inject(&:+) || 0)
  end
end