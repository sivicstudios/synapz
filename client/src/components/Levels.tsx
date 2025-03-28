



export default function Levels() {


    const levelsLabel = [

        "1",
        "2",
        "3",
        "4",
        "5",
        "6",
        "7",
        "8",
        "9",
        "10",
    ]















    return (

        <div className=" w-full max-w-[600px] h-full flex items-center justify-center "  >


        <div className=" w-full max-w-[345px] h-[608px] flex flex-col items-center justify-center gap-6  " >

            <div className="w-full h-[75px] border-[1px] border-[#454545] rounded-sm p-3 bg-[#ED525A] flex items-center justify-center text-center " >
                <h2>
                Hall of fame
                </h2>
            </div>



            <ul className=" w-full h-[511px]  flex items-center justify-center flex-col gap-2 overflow-y-auto rounded-sm no-scrollbar  " >




                {levelsLabel.reverse().map((level, index) => (
                    <li key={index} className=" flex items-center justify-center w-full h-[46px] rounded-sm p-3 bg-[#313131] border-[1px] border-[#454545] text-[#FFFFFF] font-normal text-sm cursor-pointer transition duration-200 transform hover:scale-105 "   >
Question {level}
</li>
                ))}











            </ul>



        </div>
        </div>
    )
}