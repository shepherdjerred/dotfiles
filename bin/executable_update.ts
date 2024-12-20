#!/usr/bin/env -S deno run --allow-env

import * as R from "https://esm.sh/remeda@2.2.0";

type Command = {
  executable: string;
  args: string[];
};

const stderr = Deno.stderr.writable.getWriter();
const stdout = Deno.stdout.writable.getWriter();

async function run({ executable, args }: Command) {
  const prefix = "[" + executable + " " + args.join(" ") + "]";

  const denoCommand = new Deno.Command(executable, {
    args,
    stdout: "piped",
    stderr: "piped",
  });

  const process = denoCommand.spawn();
  await pipeThrough(`[${prefix}]`, process.stdout, stdout);
  await pipeThrough(`[${prefix}]`, process.stderr, stderr);
}

async function pipeThrough(
  prefix: string,
  readable: ReadableStream<Uint8Array>,
  writable: WritableStreamDefaultWriter<Uint8Array>,
) {
  const decoder = new TextDecoder();
  for await (const chunk of readable) {
    const text = decoder.decode(chunk);
    writable.write(new TextEncoder().encode(prefix + text));
  }
}

const commands: Command[] = [
  {
    executable: "mise",
    args: ["upgrade"],
  },
  {
    executable: "fish",
    args: ["-c", "fisher update"],
  },
  {
    executable: "fish",
    args: ["-c", "fish_update_completions"],
  },
  {
    executable: "lvim",
    args: ["+LvimUpdate", "+q"],
  },
  {
    executable: "lvim",
    args: ["+LvimSyncCorePlugins", "+q", "+q"],
  },
  {
    executable: "brew",
    args: ["update"],
  },
  {
    executable: "brew",
    args: ["upgrade"],
  },
];

R.pipe(commands, R.map(run));
