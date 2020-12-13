import React from "react";
import { useSelector } from "react-redux";
import { IAppState } from "../redux/reducer";
import "./speedometer.css"

export const Speedometer = () => {

    const playerSpeed = useSelector((appState: IAppState) => appState.speed);
    const rotationFromSpeed = playerSpeed <= 20
        ? -140
        : -140 + (playerSpeed - 20);

    console.log("Player Speed : ", playerSpeed);

    return (
        <div className="gauge">
            <div className="needle" style={{transform: `rotate(${rotationFromSpeed}deg)`}}>
                <div className="needleBody"></div>
            </div>
            <div className="textSpeed">
                {playerSpeed}
            </div>
        </div>
    );

}
