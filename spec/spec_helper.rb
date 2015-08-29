require 'pry'
require 'simplecov'
require 'coveralls'
SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter
]
SimpleCov.start { add_filter '/spec/' }

require 'lita-queue'
require 'lita/rspec'

# A compatibility mode is provided for older plugins upgrading from Lita 3. Since this plugin
# was generated with Lita 4, the compatibility mode should be left disabled.
Lita.version_3_compatibility_mode = false

# Backport / Monkey Patch Lita Spec Handler Helper until a new version > 4.4.3 is released.
# More info here: https://github.com/jimmycuadra/lita/pull/129
module Lita
  module RSpec
    module Handler
      # Sends a message to the robot.
      # @param body [String] The message to send.
      # @param as [Lita::User] The user sending the message.
      # @param as [Lita::Room] The room where the message is received from.
      # @return [void]
      def send_message(body, as: user, from: nil)
        message = Message.new(robot, body, Source.new(user: as, room: from))

        robot.receive(message)
      end

      # Sends a "command" message to the robot.
      # @param body [String] The message to send.
      # @param as [Lita::User] The user sending the message.
      # @param as [Lita::Room] The room where the message is received from.
      # @return [void]
      def send_command(body, as: user, from: nil)
        send_message("#{robot.mention_name}: #{body}", as: as, from: from)
      end
    end
  end
end
