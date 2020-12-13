import React from "react";
import { IAppState } from "../redux/reducer";
import { useSelector } from "react-redux";
import "./win.css";

export const Win = () => {
    
    const winData = useSelector((appState: IAppState) => appState.win)

    console.log("Win Data : ", winData);

    return winData ? <div className="winDisplay">
        ( FINISHED {winData.pos} )
    </div> : null;
}
