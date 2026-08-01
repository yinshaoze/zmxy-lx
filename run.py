"""Run-only launcher for an already-initialized game (no init needed).

Distribute this together with the pre-built `out/` folder, `.env` and
Flash Player Standalone. `init` and Playwright are intentionally not
included to keep the package small.
"""

import json
import logging
import os
import subprocess as sp
from pathlib import Path
from threading import Thread

from dotenv import load_dotenv
from rich.logging import RichHandler

from backends.server import SpeculumServer
from backends.handler import SpeculumHandler


def run():
    cwd = Path(os.getcwd()).resolve()
    out = cwd / "out"
    game_config = out / "game.json"
    if not game_config.exists():
        logging.error("Game not initialized: out/game.json not found")
        return

    flash_player = Path(os.environ.get("FLASH_PLAYER_PATH", "out/game.exe"))
    if not flash_player.exists():
        logging.error(f"Flash player not found: {flash_player}")
        return
    logging.info(f"{flash_player=}")

    config = json.loads(game_config.read_text())
    baseurl = config["baseurl"]
    logging.info(f"Proxy to {baseurl}")

    with SpeculumServer(
        ("localhost", int(os.environ.get("BACKEND_PORT", "8888"))),
        SpeculumHandler,
        base_url=baseurl,
        no_cache=False,
        inject_nested=False,
    ) as server:
        port = server.server_port
        config["server"] = f"http://localhost:{port}/+"
        game_config.write_text(json.dumps(config, ensure_ascii=False, indent=4))
        logging.info(f"Server started at http://localhost:{port}")

        def run_flash_player():
            try:
                sp.run([flash_player, out / "Main.swf"], check=True)
            finally:
                server.shutdown()

        Thread(target=run_flash_player).start()
        server.serve_forever()


if __name__ == "__main__":
    logging.basicConfig(
        level="NOTSET",
        format="%(message)s",
        datefmt="[%X]",
        handlers=[RichHandler(rich_tracebacks=True)],
    )
    load_dotenv(".env", override=True)
    run()
