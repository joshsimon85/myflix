require 'spec_helper'

describe ReviewsController do
  describe 'POST create' do
    context 'with authenticated users' do
      let(:alice) { Fabricate(:user) }
      before { set_current_user(alice) }

      context 'with valid inputs' do
        it 'redirects to the video show page' do
          video = Fabricate(:video)
          post :create, review: Fabricate.attributes_for(:review), video_id: video.id
          expect(response).to redirect_to video_path(video)
        end

        it 'creates a review' do
          video = Fabricate(:video)
          post :create, review: Fabricate.attributes_for(:review), video_id: video.id
          expect(Review.count).to eq(1)
        end

        it 'creates a review associated with a video' do
          video = Fabricate(:video)
          post :create, review: Fabricate.attributes_for(:review), video_id: video.id
          expect(Review.first.video).to eq(video)
        end

        it 'craetes a review with the signed in user' do
          video = Fabricate(:video)
          post :create, review: Fabricate.attributes_for(:review), video_id: video.id
          expect(Review.first.user).to eq(current_user)
        end
      end

      context 'with invalid inputs' do
        it 'does not create a review' do
          video = Fabricate(:video)
          post :create, review: { rating: 4 }, video_id: video.id
          expect(Review.count).to eq(0)
        end

        it 'renders the videos/show template' do
          video = Fabricate(:video)
          post :create, review: { rating: 4 }, video_id: video.id
          expect(response).to render_template 'videos/show'
        end

        it 'sets @video' do
          video = Fabricate(:video)
          post :create, review: { rating: 4 }, video_id: video.id
          expect(assigns(:video)).to eq(video)
        end

        it 'sets @reviews' do
          video = Fabricate(:video)
          review = Fabricate(:review, video: video)
          post :create, review: { rating: 4 }, video_id: video.id
          expect(assigns(:reviews)).to match_array([review])
        end
      end
    end

    it_behaves_like 'requires sign in' do
      let(:action) { post :create, review: Fabricate.attributes_for(:review), video_id: 3 }
    end
  end
end
