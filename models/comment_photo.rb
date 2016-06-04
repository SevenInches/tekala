class CommentPhoto
  include DataMapper::Resource

  property :id, Serial
  property :comment_id, Integer
  property :photo, String, :auto_validation => false
  
  mount_uploader :photo, TeacherCommentPhoto

  belongs_to :comment, :model => "TeacherComment", :child_key => 'comment_id'
  

  def photo_thumb_url
     photo.thumb && photo.thumb.url ? CustomConfig::HOST + photo.thumb.url : ''
  end 

  def photo_url
     photo && photo.url ? CustomConfig::HOST + photo.url : ''
  end
  
end
