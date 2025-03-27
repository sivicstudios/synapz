import React, { useState, useEffect } from "react";
import ModeInstructionScreen from "./ModeInstruction";
import GameMasterLoadingScreen from "./GameMasterLoader";
import HomeIcon from "../assets/home.svg";
import SynapzIcon from "../assets/game-master.svg";

const GameMasterScreenContainer: React.FC = () => {
  const [currentScreen, setCurrentScreen] = useState<"instruction" | "loading">("instruction");
  const [countdown, setCountdown] = useState(9);
  
  useEffect(() => {
    // Optional - add countdown timer logic if needed
    if (currentScreen === "loading" && countdown > 0) {
      const timer = setTimeout(() => {
        setCountdown(prev => prev - 1);
      }, 1000);
      
      return () => clearTimeout(timer);
    }
  }, [currentScreen, countdown]);
  
  const handleProceed = () => {
    setCurrentScreen("loading");
  };
  
  return (
    <main className="flex flex-col items-center justify-between h-full w-full pb-6">
      {currentScreen === "instruction" ? (
        <ModeInstructionScreen onProceed={handleProceed} />
      ) : (
        <GameMasterLoadingScreen countdown={countdown} />
      )}
            <div className="flex w-full justify-between items-center px-6">
        <div className="flex flex-col items-center">
          <div className="flex items-center justify-center w-12 h-12">
            <img src={HomeIcon} alt="Home" className="w-6 h-6" />
          </div>
          <span className="text-white text-xs">Home</span>
        </div>
        <div className="flex space-x-2">
          <button className="bg-[#ED525A] text-white px-4 py-1 h-[2.5rem] rounded-md flex items-center hover:bg-[#ED525A]/50 transition-colors">
            <img src={SynapzIcon} alt="Synapz" className="w-4 h-4 mr-1" />
            <span>Join Synapz</span>
          </button>
          <button className="bg-[#ED525A] text-white px-4 py-1 h-[2.5rem] rounded-md flex items-center hover:bg-[#ED525A]/50 transition-colors">
            <img src={SynapzIcon} alt="Synapz" className="w-4 h-4 mr-1" />
            <span>Create Synapz</span>
          </button>
        </div>
      </div>
    </main>
  );
};

export default GameMasterScreenContainer;