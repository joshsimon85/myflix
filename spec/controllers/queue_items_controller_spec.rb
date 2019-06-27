require 'spec_helper'

describe QueueItemsController do
  describe 'GET index' do
    it 'sets @queue_items to the queue items of the logged in user' do
      alice = Fabricate(:user)
      set_current_user(alice)
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
      before { set_current_user(alice) }

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
      before { set_current_user(alice) }

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

      it 'normalizes the remaining queue items' do
        queue_item1 = Fabricate(:queue_item, user: alice, position: 1)
        queue_item2 = Fabricate(:queue_item, user: alice, position: 2)
        queue_item3 = Fabricate(:queue_item, user: alice, position: 3)
        post :destroy, id: queue_item2.id
        expect(queue_item3.reload.position).to eq(2)
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

  describe 'POST update_queue' do
    context 'unauthenticated user' do
      it 'redirects to the sign in page' do
        post :update_queue, queue_items: [{ id: 2, position: 3 },
                                          { id: 5, position: 2 }]
        expect(response).to redirect_to sign_in_path
      end
    end

    context 'with valid inputs' do
      let(:video) { Fabricate(:video) }
      let(:queue_item1) { Fabricate(:queue_item, user: alice, position: 1, video: video) }
      let(:queue_item2) { Fabricate(:queue_item, user: alice, position: 2, video: video) }
      let(:alice) { Fabricate(:user) }

      before do
        session[:user_id] = alice.id
      end

      it 'reorders the queue items' do
        post :update_queue, queue_items: [
                                          { id: queue_item1.id, position: 2 },
                                          { id: queue_item2.id, position: 1 }
                                        ]
        expect(alice.queue_items).to eq([queue_item2, queue_item1])
      end

      it 'redirects to the my queue page' do
        post :update_queue, queue_items: [
                                          { id: queue_item1.id, position: 2 },
                                          { id: queue_item2.id, position: 1 }
                                        ]
        expect(response).to redirect_to my_queue_path
      end

      it 'normalizes the position numbers' do
        post :update_queue, queue_items: [
                                          { id: queue_item1.id, position: 3 },
                                          { id: queue_item2.id, position: 2 }
                                        ]
        expect(alice.queue_items.map(&:position)).to eq([1, 2])
      end
    end

    context 'with invalid inputs' do
      let(:alice) { Fabricate(:user) }
      let(:video) { Fabricate(:video) }
      let(:queue_item1) { Fabricate(:queue_item, user: alice, position: 1, video: video) }
      let (:queue_item2) { Fabricate(:queue_item, user: alice, position: 2, video: video) }

      before do
        session[:user_id] = alice.id
      end

      it 'redirects to the my queue page' do
        post :update_queue, queue_items: [
                                           { id: queue_item1.id, position: 3.4 },
                                           { id: queue_item2.id, position: 2 }
                                         ]
        expect(response).to redirect_to my_queue_path
      end

      it 'sets the flash error message' do
        post :update_queue, queue_items: [
                                           { id: queue_item1.id, position: 3.4 },
                                           { id: queue_item2.id, position: 2 }
                                         ]
        expect(flash[:error]).to be_present
      end

      it 'does not change the queue items' do
        post :update_queue, queue_items: [
                                           { id: queue_item1.id, position: 3 },
                                           { id: queue_item2.id, position: 2.1 }
                                         ]
        expect(queue_item1.reload.position).to eq(1)
      end
    end

    context 'with queue items that do not belong to the current user' do
      it 'does not change the queue items' do
        alice = Fabricate(:user)
        bob = Fabricate(:user)
        session[:user_id] = alice.id
        queue_item1 = Fabricate(:queue_item, user: bob, position: 1)
        queue_item2 = Fabricate(:queue_item, user: alice, position: 2)
        post :update_queue, queue_items: [ {id: queue_item1.id, position: 3 }]
        expect(queue_item1.reload.position).to eq(1)
      end
    end
  end
end
