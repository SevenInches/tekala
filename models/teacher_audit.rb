class TeacherAudit
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :teacher_id, Serial
  property :photo, Integer, :default => 0
  property :id_card, Integer, :default => 0
  property :bank_card, Integer, :default => 0
  property :mobile, Integer, :default => 0
  property :place_confirm, Integer, :default => 0
  property :app_download, Integer, :default => 0
  property :created_at, DateTime

  belongs_to :teacher

  def self.word field
    field == 0 ? '<a class="label label-danger">未审核</a>'.html_safe : '<a class="label label-success">已审核</a>'.html_safe
  end

end
