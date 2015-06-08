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

      def fetch_queue(room)
        serialized = redis.get(room)

        if serialized
          JSON.parse(serialized)
        else
          []
        end
      end

      def store_queue(room, queue)
        redis.set room, queue.to_json
      end

      # Commands

      def queue_list(response)
        room = room_for(response)
        queue = fetch_queue(room)

        if queue.empty?
          response.reply "Queue is empty"
        else
          response.reply "Queue for #{room}: #{queue}"
        end
      end

      def queue_me(response)
        room = room_for(response)
        queue = fetch_queue(room)
        me = response.user.mention_name

        if queue.include? me
          response.reply "You are already on queue!"
        else
          queue << me
          store_queue(room, queue)
          response.reply "#{me} have been added to queue: #{queue}"
        end
      end

      private

      def room_for(response)
        response.message.source.room || '--global--'
      end
    end

    Lita.register_handler(Queue)
  end
end
