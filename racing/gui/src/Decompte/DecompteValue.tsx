import React from "react";
import { useSelector } from "react-redux";
import { IAppState } from "../redux/reducer";
import "./decompte.css"

export const Decompte = () => {
    const decompteValue = useSelector((appState: IAppState) => appState.decompte);

    return decompteValue !== -1 ? <div className="decompte">
        ({decompteValue})
    </div> : null;
}
