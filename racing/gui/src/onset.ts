import {store} from "./redux/store";
import { AnyAction } from "@reduxjs/toolkit";

/**
 * You should not edit this file this is the function to dispatch actions to the store
 * outside of a react component
 */
type ForeignAction = (...args: any[]) => AnyAction;
export const wrapAction = (fn: ForeignAction) => (...args: any[]) => store.dispatch(fn(...args));
