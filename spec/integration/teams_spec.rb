require 'spec_helper'

describe 'Teams', js: true, type: :feature do
  context 'homepage' do
    before do
      visit '/'
    end
    it 'displays index.html page' do
      expect(title).to eq('Slack Bot Server')
    end
    context 'register' do
      it 'registers a team' do
        expect do
          page.fill_in 'token', with: 'token'
          page.click_button 'register'
          expect(page.find('#messages')).to have_content 'Team successfully registered, id='
        end.to change(Team, :count).by(1)
      end
      it 'does not register with a duplicate token' do
        team = Fabricate(:team)
        expect do
          page.fill_in 'token', with: team.token
          page.click_button 'register'
          expect(page.find('#messages')).to have_content 'Token is already taken.'
        end.to_not change(Team, :count)
      end
    end
    context 'unregister' do
      it 'unregisters a team' do
        team = Fabricate(:team)
        expect do
          page.fill_in 'token', with: team.token
          page.click_button 'unregister'
          expect(page.find('#messages')).to have_content 'Team successfully unregistered.'
        end.to change(Team, :count).by(-1)
      end
      it 'invalid token' do
        page.fill_in 'token', with: 'token'
        page.click_button 'unregister'
        expect(page.find('#messages')).to have_content 'Invalid token or team not registered.'
      end
    end
  end
  context "page that doesn't exist" do
    before :each do
      visit '/invalid'
    end
    it 'displays 404 page' do
      expect(title).to eq('Page Not Found')
    end
  end
end
