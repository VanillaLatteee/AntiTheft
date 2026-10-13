import { connection } from "next/server";

export async function GET() {
  await connection();
  return Response.json(
    {
      status: "ok",
      service: "AntiTheft Recovery Web",
      version: "0.1.0",
    },
    {
      headers: {
        "Cache-Control": "no-store",
      },
    },
  );
}

