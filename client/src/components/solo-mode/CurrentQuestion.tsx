import { useParams } from "react-router-dom";

const CurrentQuestion = () => {
    let params = useParams();
    return (
        <div className="flex items-center justify-center w-full">
            <p className="text-[32px] ubuntu-sans font-extrabold">Question {params?.id}</p>
        </div>
    );
}

export default CurrentQuestion;