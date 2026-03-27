# 0. build the documentation
# In a shell, run the following commands in the `docs` directory:
# $ cd docs
# $ julia --project make.jl
# $ npm run docs:build

# 1. serve the documentation
# To view the documentation locally, run this script in the docs environment:
# $ julia --project local-view.jl
using LiveServer

LiveServer.serve(dir = "build/.documenter/.vitepress/dist")
