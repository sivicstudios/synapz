import { useState } from "react";
import GenericHeader from "../main/GenericHeader";
import BottomNav from "../main/BottomNav";

const modes = ["Game master", "Rapid fire", "Hall of fame"];

export default function SelectMode() {
  const [selectedMode, setSelectedMode] = useState<string | null>(null);

  const handleModeSelection = (index: number) => {
    setSelectedMode(selectedMode === modes[index] ? null : modes[index]);
  };
  return (
    <>
      <GenericHeader title="Solo Mode" />
      <div className="w-full flex-1 flex flex-col justify-between items-center py-5">
        <p className="w-full text-center text-sm font-normal text-zinc-300">Select a mode</p>
        <div className="w-full flex flex-col space-y-3 justify-center items-center mb-24">
          {modes.map((mode, index) => (
            <div
              className={`bg-[#181818] w-[90%] p-4 cursor-pointer flex items-center space-x-3 rounded-md ${
                selectedMode === mode ? "bg-[#ED525A]" : ""
              }`}
              key={index}
              onClick={() => handleModeSelection(index)}
            >
              <span className="inline-block bg-[#D9D9D9] h-10 w-10 rounded-full"></span>
              <span>{mode}</span>
            </div>
          ))}
        </div>
      </div>
      <BottomNav />
    </>
  );
}
