local wezterm = require 'wezterm'

local M = {}

function M.init(config)
  config.exec_domains = {
    wezterm.exec_domain('with-ssh-agent', function(cmd)
      local cmd_args = { wezterm.config_dir .. '/run-with-ssh-agent.sh' }
      for _, arg in ipairs(cmd.args or {}) do
        table.insert(cmd_args, arg)
      end
      cmd.args = cmd_args
      return cmd
    end),
  }

  config.default_mux_server_domain = 'with-ssh-agent'
  config.mux_env_remove = {
    'SSH_AGENT_PID',
    'SSH_AUTH_SOCK',
    'SSH_CLIENT',
    'SSH_CONNECTION',
    'SSH_TTY',
  }
end

return M
