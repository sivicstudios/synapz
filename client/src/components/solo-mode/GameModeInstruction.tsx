import React from "react";
import GenericHeader from "../main/GenericHeader";

interface ModeInstructionScreenProps {
  onProceed: () => void;
}

const ModeInstructionScreen: React.FC<ModeInstructionScreenProps> = ({
  onProceed,
}) => {
  return (
    <div className="flex flex-col items-center justify-between h-full w-full relative">
      <GenericHeader title="Game Master" />

      <p className="text-sm text-[#797979] text-center w-full p-4">
        Get all 15 questions right and secure your spot in the Hall of Fame!
      </p>

      <div className="w-[90%] mt-[65vh]">
        <button
          onClick={onProceed}
          type="button"
          className="bg-[#313131] w-full text-white py-3 rounded hover:bg-[#313131]/80 transition-colors"
        >
          Proceed
        </button>
      </div>
    </div>
  );
};

export default ModeInstructionScreen;
