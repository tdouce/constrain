module Constrainable
  def constrain(pre: [], post: [])
    if pre
      pre.each do |pr|
        pred, msg = pr.call

        if !pred
          if msg
            raise msg
          else
            raise "'pre' hook failed"
          end
        end
      end
    end

    val = yield

    if post
      post.each do |po|
        pred, msg = po.call(val)
          if !pred
            if msg
              raise "'#{ val }' " + msg
            else
              raise "'post' hook failed"
            end
         end
      end
    end

    val
  end
end
