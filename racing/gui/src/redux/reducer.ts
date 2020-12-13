import { createAction, AnyAction, createReducer } from "@reduxjs/toolkit";
import { wrapAction } from "../onset";

// Here I create an action that takes no argument
export const notifySpeed = createAction("NOTIFY_SPEED");
export const notifyDecompte = createAction("NOTIFY_DECOMPTE");
export const notifyTime = createAction("NOTIFY_TIME");
export const notifyPosition = createAction("NOTIFY_POSITION");
export const playerFinished = createAction("PLAYER_FINISHED");
export const passCheckpoint = createAction("PASS_CHECKPOINT");
export const hideCheckpoint = createAction("HIDE_CHECKPOINT");
export const clearFinishTime  = createAction("CLEAR_FINISH_TIME");

// I want this action to be available to Onset so I attach it globally
(window as any).NotifySpeed = wrapAction(notifySpeed);
(window as any).NotifyDecompte = wrapAction(notifyDecompte);
(window as any).NotifyTime = wrapAction(notifyTime);
(window as any).PlayerFinished = wrapAction(playerFinished);
(window as any).PlayerPassedCheckpoint = wrapAction(passCheckpoint);
(window as any).HideCheckPoint = wrapAction(hideCheckpoint);
(window as any).ClearFinishTime = wrapAction(clearFinishTime);
(window as any).NotifyPosition = wrapAction(notifyPosition);

// Here I declare the state of my whole application
// I only have one of course because this is only counting
export interface IAppState {
    speed: number;
    decompte: number;
    time: number;
    total: number;
    position: number;
    checkpointInfos: {
        last?: number;
        time?: number;
        visible?: boolean;
        all: {
            id: number;
            time: number;
        }[]
    },
    win?: {
        time: number;
        pos: number;
    }
}

const initialState: IAppState = {
    speed: 0,
    decompte: -1,
    time: 0,
    total: 0,
    position: 0,
    checkpointInfos: {
        all: []
    }
};

// Here it is my reducer, his tasks is to merge the future state with
export const counterReducer = createReducer(initialState, {
    [notifySpeed.type]: (state, action) => ({ ...state, 
        speed: Math.abs(Number.parseFloat(action.payload)),
    }),
    [notifyDecompte.type]: (state, action) => ({ ...state,
        decompte: Number.parseInt(action.payload),
        win: undefined
    }),
    [notifyTime.type]: (state, action) => ({ ...state,
        time: Number.parseInt(action.payload)
    }),
    [notifyPosition.type]: (state, action) => {
        const data = JSON.parse(action.payload);
        return {...state,
            position: data.pos,
            total: data.total
        }
    },
    [passCheckpoint.type]: (state, action) => {
        const data = JSON.parse(action.payload);
        return {...state,
            checkpointInfos: {
                last: data.nb,
                time: state.time,
                visible: true,
                all: [...state.checkpointInfos.all, {
                    id: data.nb,
                    time: state.time
                }]
            },
        }
    },
    [hideCheckpoint.type]: (state) => ({...state,
        checkpointInfos: {
            ...state.checkpointInfos,
            visible: false
        }
    }),
    [playerFinished.type]: (state, action) => {
        const data = JSON.parse(action.payload);

        return {...state,
            speed: 0,
            decompte: -1,
            time: 0,
            win: {
                time: data.time,
                pos: data.place
            },
            checkpointInfos: {
                all: []
            }
        }
    },
    [clearFinishTime.type]: (state) => ({...state,
        win: undefined,
    })
});
