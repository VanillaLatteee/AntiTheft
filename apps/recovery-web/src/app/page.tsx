const foundations = [
  "Authenticated owner sessions",
  "Server-side device ownership validation",
  "Expiring, replay-resistant commands",
  "Separate delivery and execution status",
];

export default function Home() {
  return (
    <main className="mx-auto flex min-h-screen w-full max-w-5xl flex-col px-6 py-10 sm:px-10 sm:py-16">
      <header className="flex items-center justify-between border-b border-slate-800 pb-6">
        <div>
          <p className="text-sm font-semibold uppercase tracking-[0.2em] text-teal-400">
            AntiTheft
          </p>
          <h1 className="mt-1 text-xl font-semibold text-white">
            Recovery Portal
          </h1>
        </div>
        <span className="rounded-full border border-amber-400/40 bg-amber-400/10 px-3 py-1 text-xs font-medium text-amber-200">
          Phase 0
        </span>
      </header>

      <section className="flex flex-1 flex-col justify-center py-16">
        <p className="mb-4 text-sm font-medium text-teal-300">
          Foundation ready
        </p>
        <h2 className="max-w-3xl text-4xl font-semibold tracking-tight text-white sm:text-6xl">
          Recovery controls will be secure by construction.
        </h2>
        <p className="mt-6 max-w-2xl text-lg leading-8 text-slate-300">
          This milestone establishes the portal shell and operational health
          endpoint. Sign-in, enrolled devices, and siren commands arrive in later
          phases after authorization and command-state policies are implemented.
        </p>

        <div className="mt-10 grid gap-3 sm:grid-cols-2">
          {foundations.map((foundation) => (
            <div
              key={foundation}
              className="rounded-2xl border border-slate-800 bg-slate-900/70 p-5 text-sm text-slate-200"
            >
              <span className="mr-3 text-teal-400" aria-hidden="true">
                ✓
              </span>
              {foundation}
            </div>
          ))}
        </div>
      </section>

      <footer className="border-t border-slate-800 pt-6 text-sm text-slate-500">
        Remote siren playback will always report OS and delivery limitations
        accurately.
      </footer>
    </main>
  );
}

