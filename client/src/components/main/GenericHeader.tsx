import logo from "../../assets/logo-bg.svg";
interface GenericHeaderProps {
  title: string;
}
const GenericHeader = ({ title }: GenericHeaderProps) => {
  return (
    <>
      <header className="bg-[#181818] w-full flex items-center justify-center space-x-4 p-4 border-b-2 border-[#2D2D2D]">
        <img src={logo} alt="Logo" className="w-10" />
        <span className="text-md font-bold text-white">{title}</span>
      </header>
    </>
  );
};
export default GenericHeader;
