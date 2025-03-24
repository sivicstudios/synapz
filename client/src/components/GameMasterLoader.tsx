import React from "react";;
import SynapzIcon from "../assets/game-master.svg";

interface GameMasterLoadingScreenProps {
  countdown: number;
}

const GameMasterLoadingScreen: React.FC<GameMasterLoadingScreenProps> = ({ countdown }) => {
  return (
    <div className="flex flex-col items-center justify-between h-full w-full pb-6">
        {/* Game Master Header */}
        <div className="flex justify-center items-center bg-[#181818] w-full h-[4rem]">
          <img src={SynapzIcon} alt="Game master" className="w-3.5 h-3.5 mr-2" />
          <span className="text-white text-xs font-semibold">Game master</span>
        </div>
      
      {/* Game Master Logo Center */}
      <div className="flex flex-col items-center justify-center flex-grow px-6">
  <div 
    className="font-['BOWLBY_ONE'] text-5xl text-center relative z-10"
    style={{
      color: '#F5E9CB',
      textShadow: `
        -3px -3px 0px #333,  
         3px -3px 0px #333,
        -3px  3px 0px #333,
         3px  3px 0px #333,
        -3px  0px 0px #333,
         3px  0px 0px #333,
         0px -3px 0px #333,
         0px  3px 0px #333
      `,
    }}
  >
    Game
  </div>
  <div 
    className="font-['BOWLBY_ONE'] text-5xl text-center relative -top-3"
    style={{
      color: '#F5E9CB',
      textShadow: `
        -3px -3px 0px #333,  
         3px -3px 0px #333,
        -3px  3px 0px #333,
         3px  3px 0px #333,
        -3px  0px 0px #333,
         3px  0px 0px #333,
         0px -3px 0px #333,
         0px  3px 0px #333
      `,
    }}
  >
    master
  </div>
</div>

      
      {/* Loading Text */}
      <div className="text-center text-white mb-6  px-6">
        <p>Loading questions in {countdown < 10 ? `0${countdown}` : countdown}</p>
      </div>
    </div>
  );
};

export default GameMasterLoadingScreen;

