import React from "react";
import { useSelector } from "react-redux";
import { IAppState } from "../redux/reducer";
import "./position.css"

export const Position = () => {

    const {pos, total} = useSelector((appState: IAppState) => ({pos: appState.position, total: appState.total}));
    
    return <div className="position">
        {pos} / {total}
    </div>
}
