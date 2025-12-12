set unwindonsignal on
set history filename ~/.gdb_history
set history save on
set history size 10000000
#set history expansion on

python
import sys
import os
sys.path.insert(0, os.path.join(os.environ['HOME'],'.gdb/python/'))
sys.path.append(os.path.join(os.environ['HOME'],'.gdb/python/libstdcxx/v6/'))
from libstdcxx.v6.printers import register_libstdcxx_printers
#register_libstdcxx_printers (None)

sys.path.insert(0, os.path.join(os.environ['HOME'],'.gdb/eigen/'))
from printers import register_eigen_printers
register_eigen_printers (None)
end

source ~/dotfiles/stl-views.gdb
