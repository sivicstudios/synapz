import { useState } from "react";
import DiamondIcon from "./assets/diamond.svg";
import HomeIcon from "./assets/home-icon.svg";

const modes = ["Game master", "Rapid fire", "Hall of fame"];

export default function SelectMode() {
  const [selectedMode, setSelectedMode] = useState<string | null>(null);

  const handleModeSelection = (index: number) => {
    setSelectedMode(selectedMode === modes[index] ? null : modes[index]);
  };
  return (
    <>
      <header className="bg-[#181818] flex items-center justify-center py-5 space-x-2">
        <img src={DiamondIcon} alt="diamond icon" />
        <p>Solo mode </p>
      </header>
      <div className="flex-1 flex flex-col justify-between items-center py-5">
        <p>Select a mode</p>
        <div className="w-full flex flex-col space-y-3 justify-center items-center">
          {modes.map((mode, index) => (
            <div
              className={`bg-[#181818] w-[70%] p-5 cursor-pointer flex items-center space-x-3 rounded-md ${
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
      <footer className="bg-[#181818] flex justify-between items-center py-5 px-3 sm:px-10">
        <div className="flex flex-col items-center cursor-pointer">
          <img src={HomeIcon} alt="home icon" />
          <p>Home</p>
        </div>
        <button className="bg-[#ED525A] flex justify-center items-center space-x-3 px-2 sm:px-5 py-3 rounded-md cursor-pointer">
          <span>
            <img src={DiamondIcon} alt="diamond icon" />
          </span>
          <span>Join Synapz</span>
        </button>
        <button className="bg-[#ED525A] flex justify-center items-center space-x-3 px-2 sm:px-5 py-3 rounded-md cursor-pointer">
          <span>
            <img src={DiamondIcon} alt="diamond icon" />
          </span>
          <span>Create Synapz</span>
        </button>
      </footer>
    </>
  );
}
