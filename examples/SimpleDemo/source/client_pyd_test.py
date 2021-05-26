import os.path, sys
import distutils.util

from pprint import pprint


# Append the directory in which the binaries were placed to Python's sys.path,
# then import the D DLL.
libDir = os.path.join('build', 'lib.%s-%s' % (
    distutils.util.get_platform(),
    '.'.join(str(v) for v in sys.version_info[:2])
))
sys.path.append(os.path.abspath(libDir))

import client_pyd



if __name__ == "__main__":
  client = client_pyd.PydGreeterClient()
  reply = client.SayHello("client_pyd")
  # pprint(vars(reply))
  print(reply.message) # 
  print(type(reply.message))
  assert(reply.message == 'Hello client_pyd')
  sys.exit(0)
