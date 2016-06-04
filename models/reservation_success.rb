class ReservationSuccess
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :exam_time, Date
  property :section, String
  property :num, String
  property :id_card, String
  property :name, String
  property :drive_school, String
  property :register, DateTime
  property :register_cycle, Date
  property :allow_exam, Date
  property :wait_value, Integer
  property :exam_count, Integer
  property :car_type, String
  property :examination, String
  property :user_id, Integer
  property :created_at, DateTime
  property :status, Integer, :default => 0
  property :note, String
  property :is_pass, Integer

  belongs_to :user

  def self.status
    {'待跟进' => 0, '未通过' => 1, '通过' => 2 }
  end

  def exam 
    if examination =~ /科目一/
      '科目一'

    elsif examination =~ /科目二/
      '科目二'

    elsif examination =~ /科目三/
      '科目三'
      
    else
      '文明考'

    end
      
  end

  def status_word
    case status 
    when 1
      '未通过'
    when 2
      '通过'
    else
      '未知'
    end
  end
  def exam_has_hours word
    puts "word"
    user_plan = UserPlan.first(:user_id => user_id)
    if user_plan

    if word =~ /科目二/
      user_plan.exam_two
    elsif word =~ /科目三/
      user_plan.exam_three

    elsif word =~ /科目一/
      '科目一不统计学时'
    else
      '未知'
    end

    else
      '未知'
    end

  end


end
