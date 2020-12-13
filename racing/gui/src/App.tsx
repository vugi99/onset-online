import React from 'react';
import './App.css';
import { Provider } from 'react-redux';
import {store} from "./redux/store";
import { Speedometer } from './Speed/Speedometer';
import { Decompte } from './Decompte/DecompteValue';
import { Counter } from './Counter/Counter';
import { CheckpointPassed } from './CheckPoints/CheckpointPassed';
import { Win } from './Win/Win';
import {Position} from "./Position/Position"

// This is the main part of the application that will run as soon as the cef is ready and javascript loaded
const App: React.FC = () => {
  return (
    <Provider store={store}>
      <Counter />
      <CheckpointPassed />
      <Decompte />
      <Speedometer />
      <Position />
      <Win />
    </Provider>
  );
}

export default App;
