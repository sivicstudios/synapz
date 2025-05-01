import Score from "../../components/solo-mode/Score";

export default function SoloModeScore() {
  return (
    <div className="container">
      <Score is_correct={false} points={0} />
    </div>
  );
}
