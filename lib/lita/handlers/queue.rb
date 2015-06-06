module Lita
  module Handlers
    class Queue < Handler

      route /queue$/, :queue_list, command: :true
      route /queue me$/, :queue_me, command: :true
      route /unqueue me$/, :unqueue_me, command: :true
      route /queue next\?$/, :queue_list_next, command: :true
      route /queue next!$/, :queue_change_to_next, command: :true
      route /queue rotate!$/, :queue_rotate, command: :true
      route /queue = \[([^\]]*)\]\s*$$/, :queue_recreate, command: :true

      # API

      def fetch_queue(channel)
        JSON.parse(redis.get(channel))
      end

      def store_queue(channel, queue)
        redis.set channel, queue.to_json
      end

      # Commands

      def queue_list(response)
        room = response.message.source.room
        queue = fetch_queue(room)
        if queue.empty?
          response.reply "Queue is empty"
        else
          response.reply "Queue for #{room}: #{queue}"
        end
      end
    end

    Lita.register_handler(Queue)
  end
end
