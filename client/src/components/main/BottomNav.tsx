import home from "../../assets/home.svg";
import join_create from "../../assets/logo-bg.svg";
const BottomNav = () => {
  return (
    <footer className="fixed bottom-0 w-full max-w-[600px] grid grid-cols-3 bg-[#1E1E1E] p-4 sm:p-6 border-t border-[#2D2D2D] gap-2 sm:gap-4">
      <div className="text-white flex cursor-pointer justify-center items-center flex-col">
        <img src={home} alt="Home" className="w-6" />
        <span className="text-xs font-bold pt-1">Home</span>
      </div>

      <button
        type="button"
        className="bg-[#ED525A] py-3 cursor-pointer space-x-2 flex justify-center items-center rounded-lg text-white text-xs sm:text-base"
      >
        <img src={join_create} alt="Join" className="w-6" />
        <span className="text-xs font-bold">Join Synapz</span>
      </button>

      <button
        type="button"
        className="bg-[#ED525A] py-3 cursor-pointer space-x-2 flex justify-center items-center rounded-lg text-white text-xs sm:text-base"
      >
        <img src={join_create} alt="Create" className="w-6" />
        <span className="text-xs font-bold">Create Synapz</span>
      </button>
    </footer>
  );
};

export default BottomNav;
