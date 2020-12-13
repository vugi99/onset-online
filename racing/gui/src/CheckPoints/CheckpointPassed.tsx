import React from "react";
import { useSelector } from "react-redux";
import { IAppState } from "../redux/reducer";
import "./checkpoints.css"

export const CheckpointPassed = () => {
    const checkpointData = useSelector((appState: IAppState) => appState.checkpointInfos);

    console.log("Checkpoints data : ", checkpointData);
    const counterValue = checkpointData.time;
    if (counterValue && checkpointData.visible) {
        const seconds = counterValue / 1000;
        const minutes = Math.floor(seconds / 60);
        const secondsLeft = Math.floor(seconds % 60);
        const msLeft = counterValue % 1000;
            
        return <div className="checkpointPassed">
            Checkpoint #{checkpointData.last} {minutes}:{secondsLeft}
        </div>;
    }
    return null;
}
