require 'spec_helper'

describe VideosController do
  describe 'GET show' do
    it 'sets @video for authenticated users' do
      session[:user_id] = Fabricate(:user).id
      video = Fabricate(:video)
      get :show, id: video.id
      expect(assigns(:video)).to eq(video)
    end

    it 'redirects the user to the sign in page if unauthenticated' do
      video = Fabricate(:video)
      get :show, id: video.id
      expect(response).to redirect_to sign_in_path
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
    it 'sets results for authenticated users' do
      session[:user_id] = Fabricate(:user).id
      futurama = Fabricate(:video, title: 'Futurama')
      post :search, query: 'rama'
      expect(assigns(:videos)).to eq([futurama])
    end

    it 'redirects to sign in page for unauthenticated users' do
      futurama = Fabricate(:video, title: 'Futurama')
      post :search, query: 'rama'
      expect(response).to redirect_to sign_in_path
    end
  end
end
