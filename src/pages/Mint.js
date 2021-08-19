

// import { Button, Frame, Range, ProgressBar } from '@react95/core'
import { Button, Container } from 'react-nes-component';
import { useEffect, useState } from 'react'
import softsik from './softsik.svg';

import './Mint.sass'
import { useWeb3React } from '@web3-react/core';
import { injected } from '../App';
import TheGuySoftContractABI from './../ABI/TheGuySoft.json'

const Page = () => {

    const { account, activate, active, library } = useWeb3React()

    const contractAddress = "0x11729D9EeC7186Ec6F4944ab72ef8EF65FF565ed"
    // const developer = '0x575CBC1D88c266B18f1BB221C1a1a79A55A3d3BE'
    const mintPrice = 0.01;
    const [mintAmount, setMintAmount] = useState(1)
    const mintAmountDisplay = mintAmount < 10 ? `0${mintAmount}` : mintAmount;

    const [mintTo, setMintTo] = useState('got metamask?')

    const paste = () => {
        try {
            navigator.clipboard.readText()
                .then(text => {
                    setMintTo(text)
                })
                .catch(err => {
                    // maybe user didn't grant access to read from clipboard
                    console.log('Something went wrong', err);
                });

        } catch (error) {
            console.log(error)
            alert("not available")
        }
    }

    let mintToValid;
    if (!/^(0x)?[0-9a-f]{40}|(.*).eth$/i.test(mintTo)) {
        mintToValid = false;
    } else {
        mintToValid = true;
    }
    const mintButtonText = mintToValid ? 'Mint Now!' : (<span>wtf<br/>!</span>)

    const handleMintTo = async () => {
        await connectToMetamask()
        const contract = new library.eth.Contract(TheGuySoftContractABI.abi, contractAddress)
        let res = await contract?.methods?.mintTo(mintTo, mintAmount)?.send({
            from: account,
            value: library.utils.toWei(`${mintPrice * mintAmount}`)
        })
        console.log(res)
    }



    const connectToMetamask = async () => {
        try {
            console.log(injected)
            const isAuthorized = await injected.isAuthorized()
            if (!isAuthorized) {
                console.log("not authorized")
                await injected.activate()
            }
            await activate(injected, undefined, true)
            if (account && mintTo === '') {
                setMintTo(account)
            }
        }
        catch (error) {
            console.log(error)
            alert("got metamask?")
            window.location.reload()
        }
    }


    useEffect(() => {
        (async () => {
            try {
                console.log(injected)
                const isAuthorized = await injected.isAuthorized()
                if (!isAuthorized) {
                    console.log("not authorized")
                    await injected.activate()
                }
                await activate(injected, undefined, true)
                if (account) {
                    setMintTo(account)
                }
            }
            catch (error) {
                console.log(error)
                if (window.innerWidth <= 992) {
                    window.location.replace(`https://metamask.app.link/dapp/${window.location.href}`)
                }
                // alert("please enable metamask")
                // if (window.innerWidth <= 992) {
                //     window.location.replace(`https://metamask.app.link/dapp/${window.location.href}`)
                // }
                // window.location.reload()
            }
        })()
    }, [account, active, activate])

    return (

        <header className="header">
            <Container isDark isRounded className="frame">
                <div className="rangeRow" style={{ display: 'flex' }}>
                    <Container className="mint">
                        <span className="mintAmount">{mintAmountDisplay}</span>
                        <div className="setMintAmount">
                            <Button type="success" className="setMintSign" onClick={() => setMintAmount(mintAmount + 1)}>
                                +
                            </Button>
                            <Button type="error" className="setMintSign" onClick={() => setMintAmount(Math.max(mintAmount - 1, 1))}>
                                -
                            </Button>
                        </div>
                    </Container>
                    <Container>
                        <img src={softsik} className="softsik" alt="softsik" />
                    </Container>
                    <Container>
                        <Button onClick={handleMintTo} type={mintToValid ? "warning" : ""} className="mintButton" disabled={!mintToValid} >
                            {mintButtonText}
                        </Button>
                    </Container>
                </div>
                <Container isRounded title={
                    <input min={0} minLength={1} autoFocus={true} className="softsikInput" value={mintAmount} type="number" onChange={(e) => !isNaN(e?.target?.valueAsNumber) && setMintAmount(e?.target?.valueAsNumber)} />
                }
                    className="mintTo">
                    <input
                        type="text"
                        value={mintTo}
                        onChange={(e) => setMintTo(e.target.value)}
                    />
                    <div className="mintToButtons">
                        <Button className="mintToButton" onClick={() => paste()}>
                            ctrl+v
                        </Button>
                        <Button className="mintToButton" onClick={() => setMintTo(account)}>
                            me
                        </Button>
                    </div>
                </Container>
                {/* seperator, could be necessary: <hr style={{ margin: "30px 0" }} /> */}
                <div className="leftTPs">
                    <h1>Total Price: ~{Number(mintAmount * mintPrice).toFixed(3)} ETH + Gas</h1>
                </div>
            </Container>
        </header>




    )
}

export default Page