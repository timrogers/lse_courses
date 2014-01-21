module LSECourses
  class SurveyResult
    attr_reader :response_rate, :recommended_by, :reading_list, :materials,
      :satisfied, :lectures, :integration, :contact, :feedback

    def initialize(opts = {})
      opts.each { |k, v| instance_variable_set("@#{k}", v) }
    end
  end
end