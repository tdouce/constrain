module Constrainable
  class PostHookFailure < StandardError; end
  class PreHookFailure < StandardError; end

  def constrain(pre: [], post: [])
    if pre
      pre.each do |pr|
        pred, msg = pr.call

        if !pred
          if msg
            raise msg
          else
            raise PreHookFailure.new("'pre' hook failed at #{ pr }")
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
              raise PostHookFailure.new("'post' hook failed for value '#{ val }' at #{ po }")
            end
         end
      end
    end

    val
  end
end
