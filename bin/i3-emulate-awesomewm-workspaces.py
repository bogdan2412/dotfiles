#!/usr/bin/env python

from json import loads
from os import popen
from sys import argv

def ipc_query(req="command", msg=""):
    command = "i3-msg -t " + req + " " +  msg
    print(command)
    ans = popen(command).readlines()[0]
    return loads(ans)

if __name__ == "__main__":
    if (len(argv) not in (2, 3) or
        argv[1] not in map(str, range(1, 10)) or
        (len(argv) == 3 and argv[2] != "-move")):
        print("Usage: %s WORKSPACE-NUMBER-BETWEEN-1-AND-9 [-move]" % argv[0])
        exit(-1)

    new_workspace = int(argv[1])

    workspace_information = ipc_query(req="get_workspaces", msg="")
    focused_workspace = [workspace for workspace in workspace_information if workspace["focused"]]
    if len(focused_workspace) != 1:
        print("Unable to determine focused workspace", end=' ')
        if len(focused_workspace) == 0:
            print("no focused workspaces found")
        else:
            print("multiple workspaces found")
        print(json.dumps(workspace_information, indent=4))
        exit(-1)

    focused_workspace = focused_workspace[0]
    if (len(focused_workspace["name"]) != 2 or
        focused_workspace["name"][0] not in \
            (chr(i + ord('0')) for i in range(1, 5)) or
        focused_workspace["name"][1] not in \
            (chr(i + ord('0')) for i in range(1, 10))):
        print("Unexpected workspace name:", focused_workspace["name"])
        exit(-1)

    focused_output_id = int(focused_workspace["name"][0])
    focused_output = focused_workspace["output"]

    new_workspace = "%d%d" % (focused_output_id, new_workspace)

    if len(argv) == 3 and argv[2] == "-move":
        ipc_query(msg="move container to workspace %s" % new_workspace)
    else:
        ipc_query(msg="workspace %s" % new_workspace)
