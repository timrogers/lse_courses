require 'nokogiri'

module LSECourses
  class Course
    attr_reader :code, :name, :department, :students, :average_class_size, 
      :value, :assessments, :teachers, :availability, :prerequisites, 
      :content, :teaching, :formative_coursework, :reading, :type

    def initialize(opts = {})
      opts.each { |k, v| instance_variable_set("@#{k}", v) }
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
      general_course_list = open("http://www.lse.ac.uk/resources/calendar/GeneralCourse/coursesNotAvailableToGeneralCStudents.htm")
      !general_course_list.read.include? code
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

    def self.all
      results = []

      course_lists.each_pair do |type, url|
        document = fetch_and_parse(url)
        document.css('table tr td p a').each do |link|
          course_url = URI.join(URI.parse(url), URI.parse(link['href'])).to_s

          course = fetch_and_parse course_url
          key_facts = course.css('#keyFacts-Content p')
          code = course.css('#courseCode').text

          results << course_page_to_object(course, type)
        end
      end

      results
    end

    def self.find_by_code(code)
      course_lists.each_pair do |type, url|
        document = fetch_and_parse(url)
        document.css('table tr td p a').each do |link|
          title = link.text
          course_code = title.split(" ").first

          if code == course_code
            course = fetch_and_parse(
              URI.join(URI.parse(url), URI.parse(link['href'])).to_s
            )

            return course_page_to_object(course, type)
          end
        end
      end

      nil
    end

    def self.course_page_to_object(page, type)
      key_facts = page.css('#keyFacts-Content p')

      self.new(
        type: type,
        code: page.css('#courseCode').text,
        name: page.css('span#title').text,
        department: key_facts[0].text.gsub("Department: ", ""),
        students: key_facts[1].text.gsub("Total students 2012/13:", "").to_i,
        average_class_size: key_facts[2].text.gsub("Average class size 2012/13: ", "").to_i,
        value: key_facts[3].text.gsub("Value: ", ""),
        assessments: join_p_tags(page.css('#assessment-Content p')),
        teachers: join_p_tags(page.css('#teacherResponsible-Content p')),
        availability: join_p_tags(page.css('#availability-Content p')),
        prerequisites: join_p_tags(page.css('#preRequisites-Content p')),
        content: join_p_tags(page.css('#courseContent-Content p')),
        teaching: join_p_tags(page.css('#teaching-Content p')),
        formative_coursework: join_p_tags(page.css('#formativeCoursework-Content p')),
        reading: join_p_tags(page.css('#indicativeReading-Content p'))
      )
    end

    def self.join_p_tags(elements)
      elements.map(&:text).join("\n").strip
    end

    def self.fetch_and_parse(url)
      Nokogiri::HTML(open(url, &:read), 'UTF-8')
    end
  end
end