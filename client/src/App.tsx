import QuestionAnswer from './components/QuestionAnswer';
import './App.css';
function App() {
  return (
    <main className="relative w-screen min-h-screen bg-gradient-to-br from-zinc-900 via-neutral-900 to-slate-900 flex items-start mx-auto justify-center">
      <div className="w-full h-full fixed z-[0] bg-[url('./assets/logo-bg.svg')] bg-repeat bg-center opacity-2"></div>
      <div className="z-[1] absolute mx-auto w-full max-w-[600px] bg-[#1E1E1E] min-h-screen h-full border-l-2 border-r-2 border-dashed border-[#2D2D2D]"></div>
    </main>
  );
}

export default App;
