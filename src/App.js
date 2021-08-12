import './App.css';
import { FontFace } from 'react-nes-component';
import { Web3ReactProvider } from '@web3-react/core'
import Web3 from 'web3'
import { InjectedConnector } from '@web3-react/injected-connector'
import MintPage from './pages/Mint'

export const injected = new InjectedConnector({ supportedChainIds: [1, 3, 4, 5, 42] })

function getLibrary(provider) {
  return new Web3(provider);
}

const App = () => {
  // eslint-disable-next-line no-restricted-globals
  return (
    <Web3ReactProvider getLibrary={getLibrary}>
      <FontFace />
      <MintPage />
    </Web3ReactProvider>
  );
}

export default App;
