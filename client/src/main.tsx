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
    path: "/solo-mode/score",
    element: <SoloModeScore />,
  },
]);

ReactDOM.createRoot(document.getElementById("root")).render(
  <React.StrictMode>
    <RouterProvider router={router} />
  </React.StrictMode>
);
