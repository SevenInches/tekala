# -*- encoding : utf-8 -*-
Tekala::Admin.controllers :questions do

  get :index do
    @questions = Question.all(:order=>:weight.asc)
    @questions = @questions.all(:type => params[:type]) if params[:type].present?
    @questions = @questions.all(:show => params[:show]) if params[:show].present?
    @questions = @questions.paginate(:page => params[:page], :per_page => 20)
    render 'questions/index'
  end

  get :new do
    @question = Question.new
    render 'questions/new'
  end

  post :create do
    @question = Question.new(params[:question])
    if @question.save
      flash[:success] = pat(:create_success, :model => 'Question')
      redirect(url(:questions, :index))
    else
      render 'questions/new'
    end
  end

  get :edit, :with => :id do
    @question = Question.get(params[:id])
    if @question
      render 'questions/edit'
    else
      halt 404
    end
  end

  put :update, :with => :id do
    @title = pat(:update_title, :model => "question #{params[:id]}")
    @question = Question.get(params[:id])
    if @question
      if @question.update(params[:question])
        redirect(url(:questions, :index))
      else
        render 'questions/edit'
      end
    else
      halt 404
    end
  end

  delete :destroy, :with => :id do
    question = Question.get(params[:id])
    if question
      if question.destroy
        flash[:success] = pat(:delete_success, :model => 'Question', :id => "#{params[:id]}")
      else
        flash[:error]   = pat(:delete_error, :model => 'question')
      end
      redirect url(:questions, :index)
    else
      flash[:warning] = pat(:delete_warning, :model => 'question', :id => "#{params[:id]}")
      halt 404
    end
  end

  delete :destroy_many do
    @title = "Questions"
    unless params[:question_ids]
      flash[:error] = pat(:destroy_many_error, :model => 'question')
      redirect(url(:questions, :index))
    end
    ids = params[:question_ids].split(',').map(&:strip)
    questions = Question.all(:id => ids)

    if questions.destroy

      flash[:success] = pat(:destroy_many_success, :model => 'Questions', :ids => "#{ids.to_sentence}")
    end
    redirect url(:questions, :index)
  end

  get :show do
    question = Question.get params[:id]
    question.show = !question.show
    if question.save
      flash[:success] = '常见问题状态修改成功'
    else
      flash[:success] = '常见问题状态修改失败'
    end
    redirect(url(params[:back]))
  end

end
