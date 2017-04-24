# This file is used by Rack-based servers to start the application.
UNICORN_WORKER_MEMORY_LIMIT_MIN = 256 * (1024**2)                     # 256 MB
UNICORN_WORKER_MEMORY_LIMIT_MAX = 2 * UNICORN_WORKER_MEMORY_LIMIT_MIN # 512 MB
UNICORN_WORKER_MEMORY_CHECK_CYCLE = 16                                # Check every 16 requests

# Restart unicorn workers when their memory usage exceeds a random value between
# UNICORN_WORKER_MEMORY_LIMIT_MIN and UNICORN_WORKER_MEMORY_LIMIT_MAX
require 'unicorn/worker_killer'
use Unicorn::WorkerKiller::Oom,
    UNICORN_WORKER_MEMORY_LIMIT_MIN,
    UNICORN_WORKER_MEMORY_LIMIT_MAX,
    UNICORN_WORKER_MEMORY_CHECK_CYCLE

require_relative 'config/environment'

run Rails.application
