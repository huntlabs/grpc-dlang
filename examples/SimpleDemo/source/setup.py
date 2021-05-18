from os.path import expanduser

import glob
from pyd.support import setup, Extension

projName = 'client_pyd'

home = expanduser("~")
pyd_dir = '/usr/local/lib/python3.6/dist-packages/pyd/infrastructure/util/'

include_dirs=[
    "../../../source/",
    pyd_dir,
    home + "/.dub/packages/protobuf-0.6.2/protobuf/src/",
    home + "/.dub/packages/hunt-1.6.14/hunt/source/",
    home + "/.dub/packages/hunt-http-0.6.15/hunt-http/source/",
    home + "/.dub/packages/hunt-extra-1.0.10/hunt-extra/source/",
    home + "/.dub/packages/hunt-net-0.5.13/hunt-net/source/",
    ]

pkg_files = []
for pkg in include_dirs:
  pkg_files.extend(list(glob.glob(pkg + '**/*.d', recursive=True)))
# print(pkg_files)

setup(
    name=projName,
    version='0.1',
    ext_modules=[
        Extension(projName, [
            'client_pyd.d',
            "./helloworld/helloworld.d",
            './helloworld/helloworldrpc.d',
            ] + pkg_files,
            # include_dirs=include_dirs,
            extra_compile_args=['-version=HAVE_EPOLL'],
            build_deimos=True,
            d_lump=True)
    ],
)
