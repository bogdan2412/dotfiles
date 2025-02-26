local M = {}

function M.unix_domain(args)
  local name = args.remote_address
  if args.username ~= nil then
    name = args.username .. '@' .. name
  end

  local remote_wezterm_path = 'wezterm'
  if args.remote_wezterm_path ~= nil then
    remote_wezterm_path = args.remote_wezterm_path
  end

  local cmd = { 'ssh', '-TAC', name }
  if args.port ~= nil then
    table.insert(cmd, '-p')
    table.insert(cmd, tostring(args.port))
  end

  table.insert(cmd, '--')
  table.insert(cmd, remote_wezterm_path)
  table.insert(cmd, 'cli')
  table.insert(cmd, 'proxy')

  return { name = name, proxy_command = cmd }
end

function M.add_unix_domains(config, domains)
  for _, domain in ipairs(domains) do
    table.insert(config.unix_domains, M.unix_domain(domain))
  end
end

return M
