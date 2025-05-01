import challenger_mode from "./assets/challenger_mode.svg";
import community from "./assets/community.svg";
import daily from "./assets/daily.svg";
import events1 from "./assets/events.svg";
import events2 from "./assets/events2.svg";
import events3 from "./assets/events3.svg";
import solo_icon from "./assets/solo_icon.svg";
import solo from "./assets/solo.svg";
import BottomNav from "../main/BottomNav";
import HeaderNav from "../main/HeaderNav";

interface Event {
  icon: React.ReactNode;
  title: string;
}

interface GameMode {
  icon: React.ReactNode;
  gradient: string;
  title: string;
  iconWidth: string;
}

const events: Event[] = [
  {
    icon: <img className="w-[47px] max-w-full" src={events1} alt="icon" />,
    title: "Leaderboard",
  },
  {
    icon: <img className="w-[35px] max-w-full" src={events2} alt="icon" />,
    title: "Events",
  },
  {
    icon: <img className="w-[35px] max-w-full" src={events3} alt="icon" />,
    title: "Events",
  },
];

const game_modes: GameMode[] = [
  {
    icon: solo_icon,
    gradient: "from-[#FFCED2] to-[#99A1D7]",
    title: "Solo Mode",
    iconWidth: "w-[24px]",
  },
  {
    icon: challenger_mode,
    gradient: "from-[#5A29ED] to-[#99A1D7]",
    title: "Challenger Mode",
    iconWidth: "w-[59px]",
  },
  {
    icon: community,
    gradient: "from-[#29EDCC] to-[#99A1D7]",
    title: "Community Mode",
    iconWidth: "w-[55px]",
  },
];

const Home = () => {
  return (
    <>
      <HeaderNav />
      <div className="px-4 py-8">
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4 mb-6 bg-[#313131] p-1 rounded-lg">
          <div className="p-4 rounded-lg text-white text-center">
            <h1 className="mb-4 text-lg sm:text-xl">Recent Game</h1>
            <div>
              <div className="bg-gradient-to-b rounded-tl-lg rounded-tr-lg from-[#212F73] to-[#3E59D9] flex justify-center items-center p-4 sm:p-5">
                <img className="max-w-full" src={solo} alt="Solo Mode" />
              </div>
              <div className="bg-black p-4 sm:p-5 rounded-bl-lg rounded-br-lg text-sm sm:text-base">
                Solo Mode <br /> 159 Pts
              </div>
            </div>
          </div>

          <div className="p-4 rounded-lg text-white text-center">
            <h1 className="mb-4 text-lg sm:text-xl">Daily Challenge</h1>
            <div>
              <div className="bg-gradient-to-b rounded-tl-lg rounded-tr-lg from-[#0E4C66] to-[#1C98CC] flex justify-center items-center p-4 sm:p-5">
                <img className="max-w-full" src={daily} alt="Daily Challenge" />
              </div>
              <div className="bg-black p-4 sm:p-5 rounded-bl-lg rounded-br-lg text-sm sm:text-base">
                Daily Challenge <br /> 100 Pts
              </div>
            </div>
          </div>
        </div>

        <div className="mb-6 bg-[#313131] p-4 sm:p-5 rounded-lg">
          <h2 className="text-gray-300 text-center mb-4 text-lg sm:text-xl">
            Game Mode
          </h2>
          <div className="space-y-3">
            {game_modes.map((mode, index) => (
              <div key={index} className="rounded-lg text-white">
                <div className="flex items-center justify-normal w-full">
                  <span
                    className={`bg-gradient-to-r rounded-tl-lg rounded-bl-lg ${mode.gradient} w-[92px] h-[70px] flex justify-center items-center`}
                  >
                    <img
                      className={`${mode.iconWidth} max-w-full`}
                      src={mode.icon}
                      alt={`${mode.title} icon`}
                    />
                  </span>
                  <div className="bg-black py-[24px] rounded-tr-lg rounded-br-lg px-6 w-full text-sm sm:text-base">
                    {mode.title}
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>

        <div className="text-white grid grid-cols-2 sm:grid-cols-3 gap-4 mb-16">
          {events.map((event, id) => (
            <div
              key={id}
              className="bg-[#181818] p-3 sm:p-4 rounded-lg space-y-4 text-white text-center flex justify-center items-center flex-col"
            >
              <span>{event.icon}</span>
              <p className="text-sm sm:text-base">{event.title}</p>
            </div>
          ))}
        </div>
      </div>

      <BottomNav />
    </>
  );
};
export default Home;
