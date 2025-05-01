import React, { useState, useEffect } from "react";
import ModeInstructionScreen from "./GameModeInstruction";
import GameMasterLoadingScreen from "./GameMasterLoader";
import BottomNav from "../main/BottomNav";

const GameMasterCountdown: React.FC = () => {
  const [currentScreen, setCurrentScreen] = useState<"instruction" | "loading">(
    "instruction"
  );
  const [countdown, setCountdown] = useState(9);

  useEffect(() => {
    // Optional - add countdown timer logic if needed
    if (currentScreen === "loading" && countdown > 0) {
      const timer = setTimeout(() => {
        setCountdown((prev) => prev - 1);
      }, 1000);

      return () => clearTimeout(timer);
    }
  }, [currentScreen, countdown]);

  const handleProceed = () => {
    setCurrentScreen("loading");
  };

  return (
    <div className="flex flex-col items-center justify-between h-full w-full pb-6">
      {currentScreen === "instruction" ? (
        <ModeInstructionScreen onProceed={handleProceed} />
      ) : (
        <GameMasterLoadingScreen countdown={countdown} />
      )}
      <BottomNav />
    </div>
  );
};

export default GameMasterCountdown;
