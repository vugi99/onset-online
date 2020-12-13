import React from "react";
import { IAppState } from "../redux/reducer";
import { useSelector } from "react-redux";
import "./counter.css"

const format = (n: number): String => n < 10 ? `0${n}` : `${n}`;

export const Counter = () => {
    const counterValue = useSelector((appState: IAppState) => appState.time)

    console.log("Time : ", counterValue);

    const seconds = counterValue / 1000;
    const minutes = Math.floor(seconds / 60);
    const secondsLeft = Math.floor(seconds % 60);
    const msLeft = counterValue % 1000;

    return counterValue !== 0 
    ?   <div className="counterContainer">
            <div className="counterBox">
                {format(minutes)}:{format(secondsLeft)}:{msLeft}
            </div>
        </div>
    : null;
}
