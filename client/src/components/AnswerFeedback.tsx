





interface FeedbackProps {
  is_correct: boolean,
  points: number,
}




export default function AnswerFeedback({ is_correct, points }: FeedbackProps) {
  return (
    <div className="ubuntu-sans text-white w-full h-full flex items-center justify-center text-center">
      <div className="w-full max-w-[200px] flex items-center justify-center flex-col gap-5">
        <h3 className="text-[#FFFFFF] text-sm font-extrabold">
          {is_correct ? "Right Answer" : "Wrong Answer"}
        </h3>
        <h1
          className={`font-normal text-[32px] text-border bowlby-one ${is_correct ? "text-[#A2EE84]" : "text-[#EE8F84]"
            }`}
        >
          {is_correct ? "YAY!!!" : "NAH!!!"}
        </h1>

        <div className="bg-[#313131] w-[91px] h-[102px] flex items-center justify-center flex-col rounded-[4px]">
          <h4 className="text-[#ffffff] font-medium text-[17px]">Points</h4>
          <h2 className="font-extrabold text-[#FFFFFF] text-[32px]">
            {is_correct ? points : 0}
          </h2>
        </div>
        <p className="text-sm text-[14px] font-medium">
          {is_correct ? "You are amazing!" : "Give up! This is not for you"}
        </p>
      </div>
    </div>
  );
}
