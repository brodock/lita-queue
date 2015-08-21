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
          response.reply t('messages.already_on_queue')
        else
          queue << me
          store_queue(room, queue)
          response.reply t('messages.added_to_queue', mention: me)
        end
      end

      def unqueue_me(response)
        room = room_for(response)
        queue = fetch_queue(room)
        me = response.user.mention_name

        if queue.include? me
          queue.delete(me)
          store_queue(room, queue)
          response.reply t('messages.removed_from_queue', mention: me)
        else
          response.reply t('messages.not_on_queue')
        end
      end

      def queue_list_next(response)
        room = room_for(response)
        queue = fetch_queue(room)

        if queue.empty?
          response.reply t('messages.queue_is_empty')
        elsif queue.size == 1
          response.reply t('messages.is_the_last_on_queue', mention: queue.first)
        else
          response.reply t('messages.is_the_next_on_queue', mention: queue[1])
        end
      end

      def queue_change_to_next(response)
        room = room_for(response)
        queue = fetch_queue(room)

        unless queue.empty?
          removed = queue.shift
          store_queue(room, queue)
          response.reply t('messages.removed_from_queue', mention: removed)
          response.reply t('messages.is_the_next_on_queue_motivate', mention: queue.first) unless queue.empty?
        end

        response.reply display_queue(queue, room)
      end

      def queue_rotate(response)
        room = room_for(response)
        queue = fetch_queue(room)

        unless queue.empty?
          new_queue = queue.rotate
          store_queue(room, new_queue)
          response.reply t('messages.moved_to_the_end_of_queue', mention: queue.first)
          response.reply t('messages.is_the_next_on_queue_motivate', mention: new_queue.first)
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
          t('messages.queue_is_empty')
        else
          t('messages.list_queue_for_room', room: room.name, queue: queue)
        end
      end
    end

    Lita.register_handler(Queue)
  end
end
