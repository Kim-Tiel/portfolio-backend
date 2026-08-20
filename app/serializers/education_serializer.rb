class EducationSerializer
  def initialize(education)
    @education = education
  end

  def as_json
    {
      id: @education.id,
      institution: @education.institution,
      degree: @education.degree,
      field: @education.field,
      location: @education.location,
      start_date: @education.start_date,
      end_date: @education.end_date,
      is_graduated: @education.is_graduated,
      milestones: @education.education_milestones.map do |m|
        { occurred_on: m.occurred_on, description: m.description }
      end
    }
  end
end
