import { useEffect, useState } from "react";
import { useNavigate, useParams } from "react-router-dom";

export default function GetReady() {
    const [count, setCount] = useState(3);
    let params = useParams();
    const navigate = useNavigate()

    useEffect(() => {
        if (count === 0) {
            navigate(`/solo-mode/current-question/${params?.id}`);
            return;
        }

        const timer = setTimeout(() => {
            setCount((prev) => prev - 1);
        }, 1000);

        return () => clearTimeout(timer);
    }, [count]);

    return (
         <div className="Kumbh-sans w-full max-w-[600px] text-[32px] flex flex-col items-center justify-center h-[728px] relative ">
            <p className="text-[#ED525A] ubuntu-sans text-center font-extrabold">Get Ready!</p>
            <p className="text-center ubuntu-sans font-medium bg-[#313131] rounded-full w-[59px] h-[58px] flex items-center justify-center absolute bottom-[100px]  ">
                {count > 0 ? count : "0"}
            </p>
        </div>
    );
}
