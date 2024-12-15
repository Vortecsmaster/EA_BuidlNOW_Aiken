"use client";

import dynamic from "next/dynamic";

const Creator = dynamic(() => import("./Creator"), { ssr: false });

export default function Client() {
  return <Creator />;
}
