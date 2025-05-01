import React, { useState, useEffect } from "react";
import "./assets/game-master.css";
import PolygonIcon from "./assets/polygon.svg";
import Polygon1Icon from "./assets/polygon-2.svg";
import CircleIcon from "./assets/circle.svg";
import TriangleIcon from "./assets/triangle.svg";

interface Option {
  id: string;
  text: string;
  icon: string;
  color: string;
}

const GameMaster: React.FC = () => {
  const [timeLeft, setTimeLeft] = useState(20);
  const [currentQuestion] = useState(1);
  const totalQuestions = 10;

  useEffect(() => {
    if (timeLeft > 0) {
      const timer = setTimeout(() => setTimeLeft(timeLeft - 1), 1000);
      return () => clearTimeout(timer);
    }
  }, [timeLeft]);

  const options: Option[] = [
    {
      id: "starknet",
      text: "Starknet",
      icon: PolygonIcon,
      color: "#FC642A",
    },
    { id: "aztec", text: "Aztec", icon: CircleIcon, color: "#D3C5A8" },
    {
      id: "ethereum",
      text: "Ethereum",
      icon: TriangleIcon,
      color: "#7D63AB",
    },
    {
      id: "polygon",
      text: "Polygon",
      icon: PolygonIcon,
      color: "#63AB89",
    },
  ];

  return (
    <>
      <div className="progress-section">
        <div className="question-counter">
          {currentQuestion} of {totalQuestions} Questions
        </div>
        <div className="progress-bar">
          <div
            className="progress-fill"
            style={{ width: `${(currentQuestion / totalQuestions) * 100}%` }}
          />
        </div>
      </div>

      <div className="timer">
        <span className="timer-text">{timeLeft}</span>
      </div>

      <div className="question-section">
        <h2 className="question-text">Q: The following are L2 except?</h2>

        <div className="options-container">
          {options.map((option) => (
            <button
              key={option.id}
              className="option-button"
              style={{ backgroundColor: option.color }}
            >
              <img
                src={option.icon}
                alt={`${option.text} icon`}
                className="option-icon"
              />
              <span className="option-text">{option.text}</span>
            </button>
          ))}
        </div>
      </div>
    </>
  );
};

export default GameMaster;
