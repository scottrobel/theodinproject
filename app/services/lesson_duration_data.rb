class LessonDurationData
  def initialize(lesson_completions, ordered_lessons)
    @lessons = ordered_lessons
    @aggregated_lesson_completions = LessonCompletionAggregator.new(lesson_completions)
  end
  
  def known_completion_durations
    @known_completion_durations ||= \
    lessons_with_known_completion_durations.map do |lesson|
      [lesson.id, get_lesson_duration(lesson)]
    end.to_h
  end

  def known_completion_durations_total
    @known_completion_durations_total ||= \
    known_completion_durations.values.sum
  end

  def get_lesson_duration(lesson)
    last_lesson = previous_lesson(lesson)
    calculate_lesson_duration(lesson, last_lesson)
  end

  def lesson_percentage_of_total(lesson)
    lesson_duration = get_lesson_duration(lesson)
    (lesson_duration / known_completion_durations_total * 100).to_f .round(2)
  end

  def average_lesson_duration
    @average_lesson_duration ||= \
    known_completion_durations_total / ammount_of_lessons_with_known_durations
  end

  def lesson_weight(lesson)
    (get_lesson_duration(lesson) / average_lesson_duration).to_f.round(2)
  end

  def ammount_of_lessons_with_known_durations
    lessons_with_known_completion_durations.size
  end

  def lessons_with_known_completion_durations
    @lessons_with_known_completion_durations ||= \
    (lessons_with_known_completion_times[1..-1] || [])
  end

  def previous_lesson(lesson)
    index_of_lesson = @lessons.index(lesson)
    if index_of_lesson == 0
      nil
    else
      @lessons[index_of_lesson - 1]
    end
  end

  def lessons_with_known_completion_times
    filtered_lessons = []
    @lessons.to_a.each do |lesson|
      lesson_completion_datetime_average = lesson_completion_datetime_average(lesson)
      if lesson_completion_datetime_average
        filtered_lessons << lesson
      else
        break
      end
    end
    filtered_lessons
  end

  def calculate_lesson_duration(lesson, previous_lesson)
    lesson_completion_datetime_average = lesson_completion_datetime_average(lesson)
    previous_lesson_completion_datetime_average = lesson_completion_datetime_average(previous_lesson)
    seconds_duration = lesson_completion_datetime_average - previous_lesson_completion_datetime_average
    ActiveSupport::Duration.build(seconds_duration)
  end

  def lesson_completion_datetime_average(lesson)
    @aggregated_lesson_completions.lesson_avg_completion_datetime_pairs[lesson.id]
  end
end