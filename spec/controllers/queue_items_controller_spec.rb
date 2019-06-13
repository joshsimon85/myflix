require 'spec_helper'

describe QueueItemsController do
  describe 'GET index' do
    it 'sets @queue_items to the queue items of the logged in user' do
      alice = Fabricate(:user)
      session[:user_id] = alice.id
      queue_item = Fabricate(:queue_item, user: alice)
      queue_item_2 = Fabricate(:queue_item, user: alice)
      get :index
      expect(assigns(:queue_items)).to match_array([queue_item, queue_item_2])
    end

    it 'redirects to the sign in page for unauthenticated users' do
      get :index
      expect(response).to redirect_to sign_in_path
    end
  end

  describe 'POST create' do
    context 'authenticated users' do
      let(:alice) { Fabricate(:user) }
      before { session[:user_id] = alice.id }

      it 'redirects to the my queue page' do
        video = Fabricate(:video)
        post :create, video_id: video.id
        expect(response).to redirect_to my_queue_path
      end

      it 'creates a queue item' do
        video = Fabricate(:video)
        post :create, video_id: video.id
        expect(QueueItem.count).to eq(1)
      end

      it 'creates a queue item that is associated with the video' do
        video = Fabricate(:video)
        post :create, video_id: video.id
        expect(QueueItem.first.video).to eq(video)
      end

      it 'creates a queue item that is associated with the signed in user' do
        video = Fabricate(:video)
        post :create, video_id: video.id
        expect(QueueItem.first.user).to eq(alice)
      end

      it 'puts the video as the last one in the queue' do
        video = Fabricate(:video)
        video_2 = Fabricate(:video)
        Fabricate(:queue_item, video: video, user: alice)
        post :create, video_id: video_2.id
        video_2_queue_item = QueueItem.where(video_id: video_2.id, user_id: alice.id).first
        expect(video_2_queue_item.position).to eq(2)
      end

      it 'does not add the video to the queue if the video is in the queue' do
        video = Fabricate(:video)
        Fabricate(:queue_item, video: video, user: alice)
        post :create, video_id: video.id
        expect(alice.queue_items.count).to eq(1)
      end
    end

    context 'unauthenticated user' do
      it 'redirects to the sign in page for unauthenticated users' do
        video = Fabricate(:video)
        post :create, video_id: video.id
        expect(response).to redirect_to sign_in_path
      end
    end
  end


  describe 'GET destroy' do
    context 'authenticated user' do
      let(:alice) { Fabricate(:user) }
      before { session[:user_id] = alice.id }

      it 'redirects to my queue page' do
        queue_item = Fabricate(:queue_item)
        post :destroy, id: queue_item.id
        expect(response).to redirect_to my_queue_path
      end

      it 'deletes the selected queue item' do
        queue_item = Fabricate(:queue_item, user_id: alice.id)
        post :destroy, id: queue_item.id
        expect(alice.queue_items.length).to eq(0)
      end

      it 'does not delete the queue item if the current user does not own the queue item' do
        bob = Fabricate(:user)
        queue_item = Fabricate(:queue_item, user_id: bob.id)
        post :destroy, id: queue_item.id
        expect(bob.queue_items.length).to eq(1)
      end
    end

    context 'unauthenticated user' do
      it 'redirects the user to the sign in path' do
        queue_item = Fabricate(:queue_item)
        post :destroy, id: queue_item.id
        expect(response).to redirect_to sign_in_path
      end
    end
  end
end
