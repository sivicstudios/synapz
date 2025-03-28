import SynapzIcon from "./assets/game-master.svg";
import HomeIcon from "./assets/home.svg";

export default function Levels() {
  const levelsLabel = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11"];

  return (
    <div className="Kumbh-sans w-full max-w-[600px] h-full flex flex-col gap-3 items-center justify-between  py-2 ">
      <div className=" w-full max-w-[345px] h-[608px] flex flex-col items-center justify-center gap-6   ">
        <div className="w-full h-[75px] border-[1px] border-[#454545] rounded-sm p-3 bg-[#ED525A] flex items-center justify-center text-center ">
          <h2 className=" text-[#FFFFFF] font-normal text-sm ">Hall of fame</h2>
        </div>

        <div className=" w-full h-[511px] flex flex-col gap-2 items-center justify-center overflow-y-scroll   py-3 px-2 no-scrollbar  ">
          {levelsLabel.reverse().map((level, index) => (
            <button
              key={index}
              className="  flex items-center justify-center w-full h-[46px] rounded-sm p-3 bg-[#313131] border-[1px] border-[#454545] text-[#FFFFFF] font-normal text-sm cursor-pointer transition duration-200 transform hover:scale-105 "
            >
              Question {level}
            </button>
          ))}
        </div>
      </div>

      <div className="flex w-full justify-between items-center px-6 max-w-[393px] ">
        <div className="flex flex-col gap-[5px] items-center  w-[34px] h-8  ">
          <div className="flex items-center justify-center w-[13px] h-3">
            <img src={HomeIcon} alt="Home" className="w-6 h-6" />
          </div>
          <span className="text-white text-xs">Home</span>
        </div>
        <div className="flex space-x-2">
          <button className="bg-[#313131] text-white px-4 py-1 h-[2.5rem] text-xs font-semibold rounded-md flex items-center cursor-pointer hover:bg-[#313131]/50 transition-colors">
            <img src={SynapzIcon} alt="Synapz" className="w-4 h-4 mr-1" />
            <span>Join Synapz</span>
          </button>
          <button className="bg-[#313131] text-white px-4 py-1 h-[2.5rem] text-xs font-semibold rounded-md flex items-center cursor-pointer hover:bg-[#313131]/50 transition-colors">
            <img src={SynapzIcon} alt="Synapz" className="w-4 h-4 mr-1" />
            <span>Create Synapz</span>
          </button>
        </div>
      </div>
    </div>
  );
}
