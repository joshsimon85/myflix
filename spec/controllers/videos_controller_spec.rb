require 'spec_helper'

describe VideosController do
  describe 'GET show' do
    it_behaves_like 'requires sign in' do
      let(:action) { get :show, id: 3 }
    end

    it 'sets @video for authenticated users' do
      session[:user_id] = Fabricate(:user).id
      video = Fabricate(:video)
      get :show, id: video.id
      expect(assigns(:video)).to eq(video)
    end

    it 'sets @reviews for authenticated users' do
      session[:user_id] = Fabricate(:user).id
      video = Fabricate(:video)
      review = Fabricate(:review, video: video)
      review_2 = Fabricate(:review, video: video)
      get :show, id: video.id
      assigns(:reviews).should =~ [review, review_2]
    end
  end

  describe 'POST search' do
    it_behaves_like 'requires sign in' do
      let(:action) { post :search, query: 'rama' }
    end

    it 'sets results for authenticated users' do
      session[:user_id] = Fabricate(:user).id
      futurama = Fabricate(:video, title: 'Futurama')
      post :search, query: 'rama'
      expect(assigns(:videos)).to eq([futurama])
    end
  end
end
