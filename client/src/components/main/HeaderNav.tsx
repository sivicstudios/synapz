import { useState } from "react";
import profile from "../../assets/profile.svg";
import logo from "../../assets/logo-bg.svg";
import menu from "../../assets/menu.svg";
const HeaderNav = () => {
  const [isMenuOpen, setIsMenuOpen] = useState(false);

  const toggleMenu = () => {
    setIsMenuOpen(!isMenuOpen);
  };
  return (
    <>
      <header className="bg-[#181818] w-full flex items-center justify-between p-4 border-b-2 border-[#2D2D2D]">
        <img src={profile} alt="Profile" className="w-10" />
        <img src={logo} alt="Logo" className="w-10" />
        <button type="button" onClick={toggleMenu}>
          <img className="cursor-pointer w-8" src={menu} alt="Menu" />
        </button>
      </header>
      {isMenuOpen && (
        <div className="max-w-[600px] mx-auto flex items-center justify-center fixed inset-0 bg-[#000000b4] bg-opacity-50 z-50">
          <div className="bg-[#1E1E1E] w-3/4 h-full absolute right-0 p-6">
            <button
              type="button"
              className="text-white mb-6 text-right w-full"
              onClick={toggleMenu}
            >
              Close
            </button>
            <nav className="space-y-8">
              <div className="text-white text-xl font-bold">Home</div>
              <div className="text-white text-xl font-bold">Join Synapz</div>
              <div className="text-white text-xl font-bold">Create Synapz</div>
            </nav>
          </div>
        </div>
      )}
    </>
  );
};
export default HeaderNav;
