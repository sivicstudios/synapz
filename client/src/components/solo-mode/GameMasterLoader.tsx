import React from "react";
import GenericHeader from "../main/GenericHeader";

interface GameMasterLoadingScreenProps {
  countdown: number;
}

const GameMasterLoadingScreen: React.FC<GameMasterLoadingScreenProps> = ({
  countdown,
}) => {
  return (
    <div className="flex flex-col items-center justify-between h-full w-full relative">
      <GenericHeader title="Game Master" />
      <div className="w-full flex flex-col items-center justify-center h-full min-h-[80vh] space-y-0">
        <div className="flex flex-col items-center justify-center flex-grow px-6">
          <div
            className="font-['BOWLBY_ONE'] text-5xl text-center relative z-10"
            style={{
              color: "#F5E9CB",
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
              color: "#F5E9CB",
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

        <div className="w-[90%] mx-auto">
          <p className="w-full text-center">
            Loading questions in {countdown < 10 ? `0${countdown}` : countdown}
          </p>
        </div>
      </div>
    </div>
  );
};

export default GameMasterLoadingScreen;
