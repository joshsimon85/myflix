require 'spec_helper'

describe RelationshipsController do
  describe 'GET index' do
    it "sets @relationships to the current user's following relationships" do
      alice = Fabricate(:user)
      set_current_user(alice)
      bob = Fabricate(:user)
      relationship = Fabricate(:relationship, follower: alice, leader: bob)
      get :index
      expect(assigns(:relationships)).to eq([relationship])
    end

    it_behaves_like 'requires sign in' do
      let(:action) {get :index}
    end
  end

  describe 'DELETE destroy' do
    it_behaves_like 'requires sign in' do
      let(:action) { delete :destroy, id: 4 }
    end

    it 'deletes the relationship if the current user if the follower' do
      alice = Fabricate(:user)
      set_current_user(alice)
      bob = Fabricate(:user)
      relationship = Fabricate(:relationship, follower: alice, leader: bob)
      delete :destroy, id: relationship
      expect(Relationship.count).to eq(0)
    end

    it 'redirects to the people page' do
      alice = Fabricate(:user)
      set_current_user(alice)
      bob = Fabricate(:user)
      relationship = Fabricate(:relationship, follower: alice, leader: bob)
      delete :destroy, id: relationship
      expect(response).to redirect_to people_path
    end

    it 'does not delete the relationship it the current user is not the follower' do
      alice = Fabricate(:user)
      set_current_user(alice)
      bob = Fabricate(:user)
      charlie = Fabricate(:user)
      relationship = Fabricate(:relationship, follower: charlie, leader: bob)
      delete :destroy, id: relationship
      expect(Relationship.count).to eq(1)
    end
  end

  describe 'POST create' do
    it_behaves_like 'requires sign in' do
      let(:action) { post :create, id: 2 }
    end

    it 'redirects to the peoples path' do
      alice = Fabricate(:user)
      bob = Fabricate(:user)
      set_current_user(alice)
      post :create, id: bob.id
      expect(response).to redirect_to people_path
    end

    it 'creates a new relationship where the leader is the current user' do
      alice = Fabricate(:user)
      bob = Fabricate(:user)
      set_current_user(alice)
      post :create, leader_id: bob.id
      expect(Relationship.first.follower).to eq(alice)
    end

    it 'creates a new relationship where the follower is the user to be followed' do
      alice = Fabricate(:user)
      bob = Fabricate(:user)
      set_current_user(alice)
      post :create, leader_id: bob.id
      expect(Relationship.first.leader).to eq(bob)
    end

    it 'does not create a relationship if one already exists' do
      alice = Fabricate(:user)
      bob = Fabricate(:user)
      relationship = Fabricate(:relationship, follower: alice, leader: bob )
      set_current_user(alice)
      post :create, leader_id: bob.id
      expect(Relationship.count).to eq(1)
    end
  end
end
