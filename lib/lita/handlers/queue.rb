module Lita
  module Handlers
    class Queue < Handler

      route(/^queue$/, :queue_list, command: :true)
      route(/^queue me$/, :queue_me, command: :true)
      route(/^unqueue me$/, :unqueue_me, command: :true)
      route(/^queue next\?$/, :queue_list_next, command: :true)
      route(/^queue next!$/, :queue_change_to_next, command: :true)
      route(/^queue rotate!$/, :queue_rotate, command: :true)
      #route(/^queue = \[([^\]]*)\]\s*$$/, :queue_recreate, command: :true)

      # API

      def fetch_queue(room)
        raise ArgumentError, 'must be a Lita::Room object' unless room.is_a? Lita::Room

        serialized = redis.get(room.id)

        if serialized
          MultiJson.load(serialized)
        else
          []
        end
      end

      def store_queue(room, queue)
        redis.set room.id, MultiJson.dump(queue)
      end

      # Commands

      def queue_list(response)
        room = room_for(response)
        queue = fetch_queue(room)

        response.reply display_queue(queue, room)
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
          response.reply "#{me} have been added to queue."
        end
      end

      def unqueue_me(response)
        room = room_for(response)
        queue = fetch_queue(room)
        me = response.user.mention_name

        if queue.include? me
          queue.delete(me)
          store_queue(room, queue)
          response.reply "#{me} have been removed from queue."
        else
          response.reply "You are not on queue!"
        end
      end

      def queue_list_next(response)
        room = room_for(response)
        queue = fetch_queue(room)

        if queue.empty?
          response.reply "Queue is empty"
        elsif queue.size == 1
          response.reply "#{queue.first} is the last one on queue."
        else
          response.reply "#{queue[1]} will be the next!"
        end
      end

      def queue_change_to_next(response)
        room = room_for(response)
        queue = fetch_queue(room)

        unless queue.empty?
          removed = queue.shift
          store_queue(room, queue)
          response.reply "#{removed} have been removed from queue."
          response.reply "#{queue.first} is the next. Go ahead!" unless queue.empty?
        end

        response.reply display_queue(queue, room)
      end

      def queue_rotate(response)
        room = room_for(response)
        queue = fetch_queue(room)

        unless queue.empty?
          new_queue = queue.rotate
          store_queue(room, new_queue)
          response.reply "#{queue.first} has been moved to the end of the queue."
          response.reply "#{new_queue.first} is the next. Go ahead!"
        end

        response.reply display_queue(queue, room)
      end

      private

      def room_for(response)
        response.message.source.room_object
      end

      def display_queue(queue, room)
        log.debug "displaying info for queue: #{queue.inspect} at #{room.inspect}"

        if queue.empty?
          "Queue is empty!"
        else
          "Queue for #{room.name}: #{queue}"
        end
      end
    end

    Lita.register_handler(Queue)
  end
end
