import BottomNav from "../main/BottomNav";
import GenericHeader from "../main/GenericHeader";
export default function Levels() {
  const levelsLabel = [
    "1",
    "2",
    "3",
    "4",
    "5",
    "6",
    "7",
    "8",
    "9",
    "10",
    "11",
    "12",
    "13",
    "14",
    "15",
  ];

  return (
    <div className="flex flex-col items-center justify-between h-full w-full relative">
      <GenericHeader title="Game Master" />
      <div className=" w-full h-full flex flex-col items-center justify-center gap-6">
        <div className="w-full h-[64px] border-[1px] border-[#454545] rounded-sm p-3 bg-[#ED525A] flex items-center justify-center text-center">
          <h2 className=" text-[#FFFFFF] font-normal text-sm ">Hall of fame</h2>
        </div>

        <div className="w-full mb-24 h-auto flex flex-col gap-2 items-center justify-center overflow-y-scroll py-3 px-2 no-scrollbar">
          {levelsLabel.reverse().map((level, index) => (
            <button
              key={index}
              type="button"
              className="flex items-center justify-center w-full h-[46px] rounded-sm p-3 bg-[#313131] border-[1px] border-[#454545] text-[#FFFFFF] font-normal text-sm cursor-pointer"
            >
              Question {level}
            </button>
          ))}
        </div>
      </div>

      <BottomNav />
    </div>
  );
}
