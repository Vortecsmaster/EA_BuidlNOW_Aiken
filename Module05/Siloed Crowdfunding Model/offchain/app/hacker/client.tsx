"use client";

import dynamic from "next/dynamic";

const Hacker = dynamic(() => import("./Hacker"), { ssr: false });

export default function Client() {
  return <Hacker />;
}
