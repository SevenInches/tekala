node(:status) { 'success' }
child(@orders => :data){
      attributes :id, :created_at, :updated_at, :commission
      child(:user){ attribute :id, :name }
      child(:school){ attribute :id, :name }
      child(:product){ attribute :id, :name }
}