# 0. build the documentation
# in bash run following command in `docs` directory
# $ cd docs
# $ npm run docs:build

# 1. serve the documentation
# To view the documentation locally, run this script in docs environment:
# julia --project local-view.jl
using LiveServer

LiveServer.serve(dir = "build/1")
