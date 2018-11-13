module Constrainable
  class Configure
    def self.config
      @config ||= Config.new

      block_given? ? yield(@config) : @config
    end
  end

  class Config
    attr_accessor :enabled

    def initialize
      @enabled = false
    end
  end

  class PostHookFailure < StandardError; end
  class PreHookFailure < StandardError; end

  def constrain(pre: [], post: [], enable_local: false)
    if pre && (enable_local || Configure.config.enabled)
      pre.each do |pr|
        unless pr.call
          raise PreHookFailure.new("'pre' hook failed at #{ pr }")
        end
      end
    end

    val = yield

    if post && (enable_local || Configure.config.enabled)
      post.each do |po|
        unless po.call(val)
          raise PostHookFailure.new("'post' hook failed for value '#{ val }' at #{ po }")
        end
      end
    end

    val
  end
end
