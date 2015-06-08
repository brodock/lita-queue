require "spec_helper"

describe Lita::Handlers::Queue, lita_handler: true do

  user1 = Lita::User.create(100, name: 'User 1')
  user2 = Lita::User.create(101, name: 'User 2')

  # Routes
  it { is_expected.to route_command("queue").to(:queue_list) }
  it { is_expected.to route_command("queue me").to(:queue_me) }
  it { is_expected.to route_command("unqueue me").to(:unqueue_me) }
  it { is_expected.to route_command("queue next?").to(:queue_list_next) }
  it { is_expected.to route_command("queue next!").to(:queue_change_to_next) }
  it { is_expected.to route_command("queue rotate!").to(:queue_rotate) }
  it { is_expected.to route_command("queue = [something,here]").to(:queue_recreate) }

  let(:channel) { source.room || '--global--' }

  # Commands
  describe "#queue_list" do
    context "when queue is empty" do
      before { subject.store_queue(channel, []) }
      it "replies with an empty queue message" do
        send_command("queue")
        expect(replies.last).to include("Queue is empty")
      end
    end

    context "when queue has elements" do
      before { subject.store_queue(channel, [user1.mention_name, user2.mention_name]) }

      it "replies with a list of queue users" do
        send_command("queue")
        expect(replies.last).to include(user1.mention_name, user2.mention_name)
      end
    end
  end

  describe "#queue_me" do
    context "when I'm already queued" do
      before { subject.store_queue(channel, [user.mention_name]) }
      it "replies with an error message" do
        send_command("queue me")
        expect(replies.last).to include("already on queue")
      end
    end

    context "when I'm not on queue" do
      it "replies with a confirmation message" do
        send_command("queue me")
        expect(replies.last).to include("#{user.name} have been added to queue")
        expect(subject.fetch_queue(channel)).to include(user.mention_name)
      end
    end
  end
end
