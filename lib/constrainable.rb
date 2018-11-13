module Constrainable
  class PostHookFailure < StandardError; end
  class PreHookFailure < StandardError; end

  def constrain(pre: [], post: [])
    if pre
      pre.each do |pr|
        if !pr.call
          raise PreHookFailure.new("'pre' hook failed at #{ pr }")
        end
      end
    end

    val = yield

    if post
      post.each do |po|
        if !po.call(val)
          raise PostHookFailure.new("'post' hook failed for value '#{ val }' at #{ po }")
        end
      end
    end

    val
  end
end
