import React from "react";
import "./index.css";
import App from "./App.tsx";
import ReactDOM from "react-dom/client";
import { createBrowserRouter, RouterProvider } from "react-router-dom";

import NotFound from "./pages/NotFound.tsx";
import SoloModeGameMaster from "./pages/solo-mode/game-master.tsx";
import SoloModeHome from "./pages/solo-mode/home.tsx";
import SoloModeInstructions from "./pages/solo-mode/instructions.tsx";
import SoloModeSelectMode from "./pages/solo-mode/select-mode.tsx";
import SoloModeScore from "./pages/solo-mode/score.tsx";
import SoloModeLevels from "./pages/solo-mode/levels.tsx";
import SoloModeGetReady from "./pages/solo-mode/get-ready.tsx";
import SoloModeCurrentQuestion from "./pages/solo-mode/current-question.tsx";

const router = createBrowserRouter([
  {
    path: "/",
    element: <App />,
    errorElement: <NotFound />,
    children: [],
  },
  {
    path: "/solo-mode",
    element: <SoloModeHome />,
  },
  {
    path: "/solo-mode/home",
    element: <SoloModeHome />,
  },
  {
    path: "/solo-mode/game-master",
    element: <SoloModeGameMaster />,
  },
  {
    path: "/solo-mode/instructions",
    element: <SoloModeInstructions />,
  },
  {
    path: "/solo-mode/select-mode",
    element: <SoloModeSelectMode />,
  },
  {
    path: "/solo-mode/levels",
    element: <SoloModeLevels />,
  },
  {
    path: "/solo-mode/get-started/:id",
    element: <SoloModeGetReady />,
  },
  {
    path: "/solo-mode/current-question/:id",
    element: <SoloModeCurrentQuestion />,
  },
  {
    path: "/solo-mode/score",
    element: <SoloModeScore />,
  },
]);


ReactDOM.createRoot(document.getElementById("root")).render(
  <React.StrictMode>
    <RouterProvider router={router} />
  </React.StrictMode>
);
