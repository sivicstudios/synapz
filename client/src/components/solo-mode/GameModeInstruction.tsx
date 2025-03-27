import React from "react";
import SynapzIcon from "./assets/game-master.svg";

interface ModeInstructionScreenProps {
  onProceed: () => void;
}

const ModeInstructionScreen: React.FC<ModeInstructionScreenProps> = ({
  onProceed,
}) => {
  return (
    <div className="flex flex-col items-center justify-between h-full w-fullpb-6">
      {/* Game Master Header */}
      <div className="flex justify-center items-center bg-[#181818] w-full h-[4rem]">
        <img src={SynapzIcon} alt="Game master" className="w-3.5 h-3.5 mr-2" />
        <span className="text-white text-xs font-semibold">Game master</span>
      </div>

      {/* Instruction Text */}
      <div className="text-center mt-16 mb-auto mx-6">
        <p className="text-sm text-[#797979]">
          Get all 15 questions right and secure your spot in the Hall of Fame!
        </p>
      </div>

      {/* Proceed Button */}
      <button
        onClick={onProceed}
        className="bg-[#313131] text-white py-3 mx-6 px-12 mt-auto mb-6 rounded hover:bg-[#313131]/50 transition-colors w-full max-w-xs"
      >
        Proceed
      </button>
    </div>
  );
};

export default ModeInstructionScreen;
