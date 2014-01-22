require 'nokogiri'

module LSECourses
  class Course
    attr_reader :code, :name, :type
    attr_accessor :url

    def initialize(opts = {})
      opts.each { |k, v| instance_variable_set("@#{k}", v) }
    end

    def fetch_attributes
      page = self.class.fetch_and_parse(url)
      key_facts = page.css('#keyFacts-Content p')

      @survey = if page.css('#survey-Label').any?
        SurveyResult.new(
          response_rate: page.css('#survey-Label-2 span').text.gsub("Response rate: ", "").gsub("%", "").to_f,
          recommended_by: page.css('#survey-Content-Recommend p')[1].text.gsub("%", "").to_f,
          reading_list: page.css('#survey-Content table tbody td')[1].text.to_f,
          materials: page.css('#survey-Content table tbody td')[3].text.to_f,
          satisfied: page.css('#survey-Content table tbody td')[5].text.to_f,
          lectures: page.css('#survey-Content table tbody td')[7].text.to_f,
          integration: page.css('#survey-Content table tbody td')[9].text.to_f,
          contact: page.css('#survey-Content table tbody td')[11].text.to_f,
          feedback: page.css('#survey-Content table tbody td')[13].text.to_f,
        )
      end

      @code =  page.css('#courseCode').text
      @name = page.css('span#title').text
      @department = key_facts[0].text.gsub("Department: ", "")
      @students = key_facts[1].text.gsub("Total students 2012/13:", "").to_i
      @average_class_size = key_facts[2].text.gsub("Average class size 2012/13: ", "").to_i
      @value = key_facts[3].text.gsub("Value: ", "")
      @assessments = self.class.join_p_tags(page.css('#assessment-Content p'))
      @teachers = self.class.join_p_tags(page.css('#teacherResponsible-Content p'))
      @availability = self.class.join_p_tags(page.css('#availability-Content p'))
      @prerequisites = self.class.join_p_tags(page.css('#preRequisites-Content p'))
      @content = self.class.join_p_tags(page.css('#courseContent-Content p'))
      @teaching = self.class.join_p_tags(page.css('#teaching-Content p'))
      @formative_coursework = self.class.join_p_tags(page.css('#formativeCoursework-Content p'))
      @reading = self.class.join_p_tags(page.css('#indicativeReading-Content p'))

      self
    end

    def department
      if @department
        @department
      else
        fetch_attributes
        @department
      end
    end

    def students
      if @students
        @students
      else
        fetch_attributes
        @students
      end
    end

    def average_class_size
      if @average_class_size
        @average_class_size
      else
        fetch_attributes
        @average_class_size
      end
    end

    def value
      if @value
        @value
      else
        fetch_attributes
        @value
      end
    end

    def assessments
      if @assessments
        @assessments
      else
        fetch_attributes
        @assessments
      end
    end

    def teachers
      if @teachers
        @teachers
      else
        fetch_attributes
        @teachers
      end
    end

    def availability
      if @availability
        @availability
      else
        fetch_attributes
        @availability
      end
    end

    def prerequisites
      if @prerequisites
        @prerequisites
      else
        fetch_attributes
        @prerequisites
      end
    end

    def content
      if @content
        @content
      else
        fetch_attributes
        @content
      end
    end

    def teaching
      if @teaching
        @teaching
      else
        fetch_attributes
        @teaching
      end
    end

    def formative_coursework
      if @formative_coursework
        @formative_coursework
      else
        fetch_attributes
        @formative_coursework
      end
    end

    def reading
      if @reading
        @reading
      else
        fetch_attributes
        @reading
      end
    end

    def survey
      if @survey
        @survey
      else
        fetch_attributes
        @survey
      end
    end

    def undergraduate?
      type == "Undergraduate"
    end

    def graduate?
      type == "Graduate"
    end

    def research?
      type == "Research"
    end

    # Checks if this module is available to General Course students
    def general_course?
      !self.class.general_course_page.include? code
    end

    def survey?
      !!survey
    end

    alias_method :available_on_general_course?, :general_course?
    alias_method :title, :name

    # Class methods
    def self.course_lists
      {
        "Undergraduate" => "http://www.lse.ac.uk/resources/calendar/courseGuides/undergraduate.htm",
        "Graduate" => "http://www.lse.ac.uk/resources/calendar/courseGuides/graduate.htm",
        "Research" => "http://www.lse.ac.uk/resources/calendar/courseGuides/research.htm"
      }
    end

    def self.all(options = {})
      defaults = { preload: false }
      options = defaults.merge(options)

      results = []

      course_lists.each_pair do |type, url|
        document = fetch_and_parse(url)
        document.css('table tr td p a').each do |link|
          abstract = link.text.split(" ")

          course_code = abstract.shift
          name = abstract.join(" ")
          course_url = URI.join(URI.parse(url), URI.parse(link['href'])).to_s

          results << self.new(
            url: course_url,
            name: name,
            code: course_code,
            type: type
          )
        end
      end

      results.each(&:fetch_attributes) if options[:preload]
      results
    end

    def self.find_by_code(code)
      course_lists.each_pair do |type, url|
        document = fetch_and_parse(url)
        document.css('table tr td p a').each do |link|
          abstract = link.text.split(" ")

          course_code = abstract.shift
          name = abstract.join(" ")
          course_url = URI.join(URI.parse(url), URI.parse(link['href'])).to_s

          if code == course_code
            return self.new(
              url: course_url,
              name: name,
              code: course_code,
              type: type
            ).fetch_attributes
          end
        end
      end

      nil
    end

    def self.join_p_tags(elements)
      elements.map(&:text).join("\n").strip
    end

    def self.general_course_page
      @general_course_page ||= open("http://www.lse.ac.uk/resources/calendar/GeneralCourse/coursesNotAvailableToGeneralCStudents.htm").read
    end

    def self.fetch_and_parse(url)
      Nokogiri::HTML(open(url, &:read), 'UTF-8')
    end

    self.singleton_class.send(:alias_method, :find, :find_by_code)
  end
end