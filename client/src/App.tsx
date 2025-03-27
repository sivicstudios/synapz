import "./App.css";

function App() {
  return (
    <main className="relative w-full min-h-screen bg-gradient-to-br from-zinc-900 via-neutral-900 to-slate-900 flex items-center justify-center">
      <div className="w-full h-full fixed z-0 bg-[url('./assets/logo-bg.svg')] bg-repeat bg-center opacity-5"></div>

      <div className="z-10 w-full max-w-[600px] bg-[#1E1E1E] min-h-screen h-full border-l-2 border-r-2 border-dashed border-[#2D2D2D] shadow-xl"></div>
    </main>
  );
}

export default App;
