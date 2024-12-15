import { useEffect } from "react";
import { useRouter } from "next/navigation";
import { Link } from "@nextui-org/link";
import { ToastContainer } from "react-toastify";

import { useWallet } from "@/components/contexts/wallet/WalletContext";
import { title } from "@/components/primitives";
import CreatorDashboard from "@/components/pages/creator/CreatorDashboard";
import DisconnectButton from "@/components/pages/DisconnectButton";

import "react-toastify/dist/ReactToastify.css";

export default function Creator() {
  const router = useRouter();
  const [{ address }] = useWallet();

  let isPushed = false;

  useEffect(() => {
    if (!address && !isPushed) {
      router.push("/");
      isPushed = true;
    }
  }, [address]);
  if (!address) return <></>;

  return (
    <>
      {/* Title */}
      <div className="inline-block max-w-lg text-center justify-center">
        <h1 className={title()}>
          <span className={title({ color: "violet" })}>Creator</span> Dashboard
        </h1>
      </div>

      <div className="flex flex-col items-center gap-4 mt-4">
        <CreatorDashboard />
        <Link href="/">&laquo; Go Back</Link>
      </div>

      <ToastContainer position="bottom-right" theme="dark" />
      <DisconnectButton />
    </>
  );
}
