class UserChange
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :account_id, Integer
  property :user_id, Integer
  property :hours, Integer
  property :subject, String
  property :created_at, DateTime

  belongs_to :user
  belongs_to :account

  def subject_name
    case self.subject
    when 'exam_two'
      return '科目二'
    when 'exam_three'
      return '科目三'
    end
  end

end
