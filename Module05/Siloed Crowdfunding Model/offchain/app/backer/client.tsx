"use client";

import dynamic from "next/dynamic";

const Creator = dynamic(() => import("./Backer"), { ssr: false });

export default function Client() {
  return <Creator />;
}
