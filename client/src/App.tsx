import React, { useState } from "react";
import "./App.css";
import profile from "../public/profile.svg";
import challenger_mode from "../public/challenger_mode.svg";
import community from "../public/community.svg";
import daily from "../public/daily.svg";
import events1 from "../public/events.svg";
import events2 from "../public/events2.svg";
import events3 from "../public/events3.svg";
import home from "../public/home.svg";
import join_create from "../public/join_create.svg";
import menu from "../public/menu.svg";
import solo_icon from "../public/solo_icon.svg";
import solo from "../public/solo.svg";

interface Event {
  icon: React.ReactNode;
  title: string;
}

const events: Event[] = [
  {
    icon: <img className="w-[47px] max-w-full" src={events1} alt="icon" />,
    title: "Events",
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

function App() {
  const [isMenuOpen, setIsMenuOpen] = useState(false);

  const toggleMenu = () => {
    setIsMenuOpen(!isMenuOpen);
  };

  return (
    <main className="relative w-full min-h-screen bg-gradient-to-br from-zinc-900 via-neutral-900 to-slate-900 flex items-center justify-center">
      <div className="w-full h-full fixed z-0 bg-[url('./assets/logo-bg.svg')] bg-repeat bg-center opacity-5"></div>

      <div className="z-10 w-full max-w-[600px] bg-[#1E1E1E] min-h-screen h-full border-l-2 border-r-2 border-dashed border-[#2D2D2D] shadow-xl">
        <header className="flex items-center justify-between p-4 sm:p-6 border-b border-[#2D2D2D]">
          <img src={profile} alt="Profile" className="w-10 sm:w-auto" />
          <img src={join_create} alt="Join/Create" className="w-10 sm:w-auto" />
          <img
            className="cursor-pointer w-8 sm:w-auto"
            src={menu}
            alt="Menu"
            onClick={toggleMenu}
          />
        </header>

        {isMenuOpen && (
          <div className="fixed inset-0 bg-[#000000b4] bg-opacity-50 z-50 md:hidden">
            <div className="bg-[#1E1E1E] w-3/4 h-full absolute right-0 p-6">
              <button
                className="text-white mb-6 text-right w-full"
                onClick={toggleMenu}
              >
                Close
              </button>
              <nav className="space-y-4">
                <div className="text-white">Home</div>
                <div className="text-white">Join Synapz</div>
                <div className="text-white">Create Synapz</div>
              </nav>
            </div>
          </div>
        )}

        <div className="p-4 sm:p-6">
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
                  <img
                    className="max-w-full"
                    src={daily}
                    alt="Daily Challenge"
                  />
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
              {[
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
              ].map((mode, index) => (
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

        <footer className="fixed bottom-0 w-full max-w-[600px] grid grid-cols-3 bg-[#1E1E1E] p-4 sm:p-6 border-t border-[#2D2D2D] gap-2 sm:gap-4">
          <div className="text-white flex cursor-pointer justify-center items-center flex-col">
            <img src={home} alt="Home" className="w-6 sm:w-auto" />
            <span className="text-xs sm:text-sm mt-1">Home</span>
          </div>

          <button className="bg-[#ED525A] px-2 py-2 sm:px-4 sm:py-3 cursor-pointer space-x-2 flex justify-center items-center rounded-lg text-white text-xs sm:text-base">
            <img src={join_create} alt="Join" className="w-4 sm:w-auto" />
            <span>Join Synapz</span>
          </button>

          <button className="bg-[#ED525A] px-2 py-2 sm:px-4 sm:py-3 cursor-pointer space-x-2 flex justify-center items-center rounded-lg text-white text-xs sm:text-base">
            <img src={join_create} alt="Create" className="w-4 sm:w-auto" />
            <span>Create Synapz</span>
          </button>
        </footer>
      </div>
    </main>
  );
}

export default App;
