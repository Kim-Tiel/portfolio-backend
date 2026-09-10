# The admin layout already renders <%= csp_meta_tag %>. Admin views have
# no inline <script> (verified) — only inline style="" on button_to forms,
# which style-src :unsafe_inline covers. script-src inherits :self from
# default_src, so an injected inline/eval script cannot run.
Rails.application.configure do
  config.content_security_policy do |policy|
    policy.default_src :self
    policy.object_src  :none
    policy.base_uri    :self
    policy.frame_ancestors :none
    policy.img_src     :self, :data, :https
    policy.style_src   :self, :unsafe_inline
  end
end
