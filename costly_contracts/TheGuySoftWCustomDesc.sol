// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./base64.sol";



contract TheGuySoftWCustomDesc is ERC721, ERC721URIStorage, Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    using Counters for Counters.Counter;
    
    Counters.Counter private _tokenIdCounter;
    

    
    struct Payee {
        address wallet;
        string role;
        uint256 percentage;
    }
    
    modifier onlyUser(address _sender) {
        //require(tx.origin == msg.sender, "contracts are not allowed");
        uint32 size;
        assembly {
            size := extcodesize(_sender)
        }
        require(size == 0, "contracts are not allowed");
        _;
    }
    


    uint256 public mintPrice = 0.01 ether;
    
    // mainnet
    IERC721 internal BLITMAP_CONTRACT = IERC721(0x8d04a8c79cEB0889Bdd12acdF3Fa9D207eD3Ff63);
    
    // test
    //IERC721 internal BLITMAP_CONTRACT = IERC721(0x1b4C2BA0c7Ee2AAF7710A11c3a2113C24624852B);
    



    string image = "data:image/svg+xml;base64,PHN2ZyB2ZXJzaW9uPSIxLjIiIGJhc2VQcm9maWxlPSJ0aW55LXBzIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAzMjAgMzIwIiB3aWR0aD0iMzUwIiBoZWlnaHQ9IjM1MCI+PHRpdGxlPmltYWdlPC90aXRsZT48ZGVmcz48aW1hZ2UgYXJpYS1sYWJlbD0iWW91ciBiaWQgaXMgc28gc29mdCB0aGF0Li4uIiAgd2lkdGg9IjI3MSIgaGVpZ2h0PSIyMyIgaWQ9ImltZzEiIGhyZWY9ImRhdGE6aW1hZ2UvcG5nO2Jhc2U2NCxpVkJPUncwS0dnb0FBQUFOU1VoRVVnQUFBUThBQUFBWENBTUFBQUFpQXpwT0FBQUFBWE5TUjBJQjJja3Nmd0FBQUdsUVRGUkZBQUFBLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vL3Y3Ky8vLy8vLy8vLy8vLy8vLy8vdjcrL3Y3Ky8vLy8vdjcrLy8vLy92NysvLy8vLy8vLy92NysvLy8vLy8vLy8vLy8vLy8vLy8vLy92NysvdjcrLy8vLy8vLy8vLy8vLy8vL2tNcWZGd0FBQUNOMFVrNVRBRUEvRUNBdy80REF2NzdnWUpEd3o5K2cwSENmZjI4VFVRcEdLRDRmM1gwUkR3aUpTZHBEQUFBQ0dFbEVRVlI0bk8yWWZYZUNJQlRHZ1hMQXJNeW1iYXU5MWZmL2tBTUZ1UmRFWjJVdlp6NS9ZT2ZDZlI3OFJSNVBoRkRHMkl3UU1sZlhoQXhRQWh1MHk5eDhuakZqU1l3dEcyTGJyOHF5MTNaMll2Q1RFbFZYcnE1aVNLT0FEZHFGbTgvVVdoSmorM1RDdGpwVVdmYmEwaE9ESDVvSFBKWjFkbE9JODBqOEpxU0g1Z0ZqdlgzRWVRaS9DV25pZ1hVWkhsQ0l4d2dDTzUxNGtDdnpFTktlUm03UGVyM2kyWlJUYU9zZDNJVk1iY243dlRqYkJ1RlNybHdKeGxwLzBKTEl6TnVXaTBXbXJrRGQ5a0NMM3Bqd203cDRCQzVEZUtCWXhNTk5pTERmaS9WdUxYNXpvL0hJcEpUcmFrVnlQUjRyVUVLeHQrZlI1VElhajJqczNmSEllZHJPWThNNWY0RThVcDc3UEV5cGhVZk90Ull3V0pnU2lnWHpPWnpuSEtZb09ZL0ExR3VobFUvdWVLQ21QaDdVUElJREhqbHNGSzRCOGhDdDd4K3dCSUs5VnhiMDVJY3RMU21CaDFkQUxmR1VRQnBjaXFtT3hLTW95NUtYemJlaVE2VXB4WGdVY1A0TUhyVFVLdjdDdzk0YWNCbUpoejJEb0wvMVdJSmJRL05uOEFpZUg3Zm1JU3F0SUk5bFZVcWpQR0RMSlhpc3hPWitlTUFXSk5UU3N0Tm95bUFlWFNuZFBMWXNjendZNitDUnNhMGZhMG9lRDFyOWdaTkJIbldwY0R1MXNXZytjL1AxVGdJZUJmeGZ5aFVDSHMzR1JMUG05VTNwbmV6VXVDZDdOZTVhZWRUeWZuV3RQSXl1Ly80aDhKclkrMGYwK1ZHditkQ1hUL0tseHBKOHEzRTk4Wmg0VER5Rzh2aTMrbEVpNUtER0l6bXE4ZkFMNEl4T2k2dHJQRmNBQUFBQVNVVk9SSzVDWUlJPSIvPjxpbWFnZSBhcmlhLWxhYmVsPSIuLi55b3UgaGF2ZSBiZWVuIHZpc2l0ZWQgYnkiICB3aWR0aD0iMjg0IiBoZWlnaHQ9IjI5IiBpZD0iaW1nMiIgaHJlZj0iZGF0YTppbWFnZS9wbmc7YmFzZTY0LGlWQk9SdzBLR2dvQUFBQU5TVWhFVWdBQUFSd0FBQUFkQ0FNQUFBQlBBU1BEQUFBQUFYTlNSMElCMmNrc2Z3QUFBR2xRVEZSRkFBQUEvLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vdjcrLy8vLy8vLy8vLy8vLy8vLy8vLy8vdjcrLy8vLy8vLy8vdjcrL3Y3Ky92NysvLy8vLy8vLy8vLy8vLy8vL3Y3Ky8vLy8vdjcrLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vTlhtc3NnQUFBQ04wVWs1VEFCQS9RQ0F3LzREQXY5Qmc0SkR3Y0xDZ2Y1L2ZDVkVVUERJZGI4OGV2VjRSREFxaDhMYklBQUFDVFVsRVFWUjRuTzJZNlpLQ01CQ0VJMWVDS0x1aWU4cWU3LytRUzVqRXpKaExCWTlhNlIrV0pIVFA1Qk9qRmNZR2FwWjBPc21aZHNac2FIbVcyeWx5S0kvWU1ueVBJMk1jcFVXbms1elN5QWZYRjNhS0hCSVJHOGYzT0RMRzBjM0NDVC9TZHc0bjNOZ0U1KzdoZURYQkNlaGNjS0J0NVJkbG9RUkRCY3ludUFjeUQwcFZTV1V4S1FKWDJRM2hLbms1cHlsS2RHRXBybUpaaEdrc1pWVzVNQm5Mc3Q3dmhOVEFHVkU0MXVKUGdrTklPT0RnRkJSNUtCekxRdUJ3bkdFQ2g4UEpMd0tIVkhrNEhvNWxJWEFlY1VhOWV6OGNqcjM0YzhBSnA4VGhXQllDeDFyOHFIQldmQkdFd3psWVVpNjE4c0NCRkFKSGNPR3BBcEdRc29ESUdKeStPTTh3SERPd3k4QmxFUndZT2dXT1k2VUVEdjNwOFZ0SXljT3FPUDYwK0Mxb3JkaENCbkJaWkFoMU9nNmN0SkZhZXl6clpoT0VBL1BLMGpUSHdLbkEwalM4eWR4d050RFdGZUVjdmVmNGR6YWNFb2ZqKzdVeWkxZTZNcHhhekQyV3VaQmFlcXZBZkFXVy9yM0lENFNUdyswQk9EWGNjV1U0Y1l1L2lsbThmd054d2tHUkhqak9CellHNSttNTB3dDc3VjdmMkx1OFVCdEVzalkxdGtsci9Fa1NoTk1tVzVNdlUycjllVzNsSVlJNVluSlVTZnBUSjFWRmF1YUQwMWZSVHhidno2NFMzUml5bUl3VzdxQmxFUndZS25TbmJULy8wV2V3VHpuUHZzdzhLTFFiZU9EczV2VTNYV2dTNkhKLzZPZzlwOUFEWi9tZm8rY25PRmVFSTJ3U0k4R3g5Z3VIQlhmaVdQd0Vad0FjOXQySnNaL3U5VmRmbUI1aTU5VC9WckZEK2dtT2M4WnhIblEvY2h6TDBYbjdhM2svY3V4SlJCT2NDWTViTVRnVjE2b3UzTmtOaUp2Ri93SEtQbGYwRlpteTlnQUFBQUJKUlU1RXJrSmdnZz09Ii8+PGltYWdlIGFyaWEtbGFiZWw9IlRoZSBHdXkgU29mdCwgS2luZyBvZiBjdWNrcyIgIHdpZHRoPSIzMDEiIGhlaWdodD0iMjkiIGlkPSJpbWczIiBocmVmPSJkYXRhOmltYWdlL3BuZztiYXNlNjQsaVZCT1J3MEtHZ29BQUFBTlNVaEVVZ0FBQVMwQUFBQWRDQU1BQUFESU1NckZBQUFBQVhOU1IwSUIyY2tzZndBQUFGUlFURlJGQUFBQS8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vL3Y3Ky8vLy8vLy8vL3Y3Ky8vLy8vLy8vL3Y3Ky8vLy8vdjcrLy8vLy8vLy8vLy8vL3Y3Ky92NysvLy8vLy8vLy8vLy8vLy8vLy8vL1haOTZjQUFBQUJ4MFVrNVRBRUEvTUJBZy84Q0EwTDlnMzVEdzczQ3dvT0Ivbjg5dlBGRXl2ZXdaNS9RQUFBS2ZTVVJCVkhpYzdabnJlcU1nRUlZbEprTFJwRzAwNldiMy91OXpWVTR6dzBGSWZUYnJydCtmVklYNWhqY0RFbHBWN09CVVY4ZnA0MWhGZFFTdEQ2ZDRPNjBUYkU3QzF0WTBKcVk5NWlqcU1wRmFMRUplcGw1cTRTNE5FSy9ZOU1FUzlyQzVXTFFWc0RrSnk2MXBUTVpqanFJdUU2bkZJdVJsNnFVVzd2SXlXbS9XOUtocUo1amFUZ3NiYTlOSWFqc3RiTHdwV3ZocEZxMThXOUhFMTZVR215WmFpREpURXFFUThLU2RWb21LYUpucXJhVlppYTBsR1JpYUk5eWZWb1JXS3pzVDBKdUprYm5xelVUektwMXZuZVhGUnRFNnkzZmZ3dzZkUzNXamsyZVRxWHB1VTVPeTFqeTByZWxpUFNLMHdNVTZ0TUF5dGc0dGQyRmQwSE9QVmdNNklGb2dOWVpwd1M0cFdoOVJXbHhPYXJOb3ZjOXRKUisvczg5eVd0M1l0V3ZlR0F2U3VqUXV5cXRwb1FpSUZtcXhRSXRrVVVnTDVKbUk4VXBhVjlHNzVrS3NTNnNYVjllSkN5RmExV1g4UzVCZkcxRmFKQWFudE5RdC9mdzZCbVl3cEJwZWdKWU9xenk2c2FSN0lWeU1LZE1RclFEYzlXaVJMRUZRVDFGYWdaRWlXc0hVcTR3WVlQakVGaWhGYXhnQ3RBU3N2Z1F0SnJTZXBqVlZIMis2WVZpVFZ1dEtHc2M0cVFvM3RLenRiUmdHTVdUVWxxa0xSQ3VZVklEVzhuZTZSQ3Y0VHZ3dUxUU1dTQXl0NVhVTDBlS3phdXl3Y1ZydFdDcmgyaG9mREtxMmV0NnI1d3JBSlk4V0hzQy9RU3RuM1NMREIyK1NGQzE4a3NmTXJUdHM0VHJkRDEvUXc1NEdCbG9RV3NybHgrUHgrRmxHNjNhNFVWcnFWb3pXMTV3OE43YU9sazZOMEZJbml2YzhXa3BvcmhzRmRpbGFKcm1sL1JiWjVMSHExelRXTWxwSzhUWEhvMlU2eFBlV1JmdXRuZFpPYTZmMUVscHJxdkFFakFqUnlsWHFGTzB2MTA0clQ2M3M2VXdzVmlHdHdHbmdWb1RPK3A1VUlhM0FhZUJXdEFZdHREdGQxbjlPcTFBYnBtV1BaMFRodisrZVYyc2QyejloOXhzbFVWcmIzdi8xbWdBQUFBQkpSVTVFcmtKZ2dnPT0iLz48L2RlZnM+PHN0eWxlPnRzcGFuIHsgd2hpdGUtc3BhY2U6cHJlIH0uc2hwMCB7IGZpbGw6ICNkNTdlYjEgfSAuc2hwMSB7IGZpbGw6ICNlNWFjYjMgfSAuc2hwMiB7IGZpbGw6ICNiYTczOTMgfSAuc2hwMyB7IGZpbGw6ICNlOWU5ZTkgfSA8L3N0eWxlPjxwYXRoIGNsYXNzPSJzaHAwIiBkPSJNMzIwIDMyMEwwIDMyMEwwIDBMMzIwIDBMMzIwIDMyMFoiIC8+PHBhdGggY2xhc3M9InNocDEiIGQ9Ik0zMjAgMjkwTDI5MCAyOTBMMjkwIDI4MEwyNzAgMjgwTDI3MCAyNzBMMjQwIDI3MEwyNDAgMjYwTDIzMCAyNjBMMjMwIDI1MEwyMDAgMjUwTDIwMCAyNDBMMTYwIDI0MEwxNjAgMjMwTDEzMCAyMzBMMTMwIDIyMEwxMTAgMjIwTDExMCAyMTBMODAgMjEwTDgwIDIwMEw2MCAyMDBMNjAgMTkwTDUwIDE5MEw1MCAxODBMMzAgMTgwTDMwIDE2MEwyMCAxNjBMMjAgMTQwTDEwIDE0MEwxMCAxMjBMMjAgMTIwTDIwIDkwTDMwIDkwTDMwIDgwTDQwIDgwTDQwIDcwTDYwIDcwTDYwIDYwTDgwIDYwTDgwIDUwTDE5MCA1MEwxOTAgNjBMMjMwIDYwTDIzMCA3MEwyNDAgNzBMMjQwIDgwTDI2MCA4MEwyNjAgOTBMMjgwIDkwTDI4MCAxMDBMMjkwIDEwMEwyOTAgMTEwTDMxMCAxMTBMMzEwIDEyMEwzMjAgMTIwTDMyMCAyOTBaIiAvPjxwYXRoIGNsYXNzPSJzaHAyIiBkPSJNMzIwIDExMEwzMTAgMTEwTDMxMCAxMDBMMzAwIDEwMEwzMDAgOTBMMjgwIDkwTDI4MCA4MEwyNjAgODBMMjYwIDcwTDI0MCA3MEwyNDAgNjBMMjMwIDYwTDIzMCA1MEwyMDAgNTBMMjAwIDQwTDgwIDQwTDgwIDUwTDUwIDUwTDUwIDYwTDQwIDYwTDQwIDcwTDIwIDcwTDIwIDgwTDEwIDgwTDEwIDExMEwwIDExMEwwIDE1MEwxMCAxNTBMMTAgMTcwTDIwIDE3MEwyMCAxODBMMzAgMTgwTDMwIDE5MEw0MCAxOTBMNDAgMjAwTDUwIDIwMEw1MCAyMTBMNzAgMjEwTDcwIDIyMEwxMDAgMjIwTDEwMCAyMzBMMTMwIDIzMEwxMzAgMjQwTDE1MCAyNDBMMTUwIDI1MEwxOTAgMjUwTDE5MCAyNjBMMjIwIDI2MEwyMjAgMjcwTDI0MCAyNzBMMjQwIDI4MEwyNjAgMjgwTDI2MCAyOTBMMjkwIDI5MEwyOTAgMzAwTDMxMCAzMDBMMzEwIDMxMEwzMjAgMzEwTDMyMCAyOTBMMjkxIDI5MEwyOTAgMjgwTDI3MCAyODBMMjcwIDI3MEwyNDEgMjcwTDI0MCAyNjBMMjMwIDI2MEwyMzAgMjUwTDIwMCAyNTBMMjAwIDI0MEwxNjAgMjQwTDE2MCAyMzBMMTMxIDIzMEwxMzAgMjIwTDExMCAyMjBMMTEwIDIxMEw4MCAyMTBMODAgMjAwTDYwIDIwMEw2MCAxOTBMNTAgMTkwTDUwIDE4MEwzMSAxODBMMzAgMTYwTDIwIDE2MEwyMCAxNDBMMTAgMTQwTDEwIDEyMEwyMCAxMjBMMjAgOTBMMzAgOTBMMzAgODBMNDAgODBMNDEgNzBMNjAgNzBMNjAgNjBMODAgNjBMODEgNTBMMTkwIDUwTDE5MCA2MEwyMjkgNjBMMjMwIDcwTDIzOSA3MEwyNDAgODBMMjU5IDgwTDI2MCA5MEwyNzkgOTBMMjgwIDEwMEwyOTAgMTAwTDI5MCAxMTBMMzA5IDExMEwzMTAgMTIwTDMyMCAxMjBMMzIwIDExMFpNMjIwIDE3MEwyMjAgMTUwTDIxMCAxNTBMMjEwIDE2MEw2MCAxNjBMNjAgMTUwTDUwIDE1MEw1MCAxNzBMNjAgMTcwTDYwIDE4OUw2MSAxOTBMMjAwIDE5MEwyMDAgMTgwTDcwIDE4MEw3MCAxNzBMMjAwIDE3MEwyMDAgMTc5TDIwMSAxODBMMjEwIDE4MEwyMTAgMTcwTDIyMCAxNzBaTTE2MCAxMjBMMTYwIDE0MEwxOTAgMTQwTDE5MCAxMjBMMTYwIDEyMFpNNzAgMTQwTDEwMCAxNDBMMTAwIDEyMEw3MCAxMjBMNzAgMTQwWk00MCAxMDBMNDAgMTEwTDExMCAxMTBMMTEwIDEwMEwxMjAgMTAwTDEyMCA5MEwxMTAgOTBMMTEwIDcwTDEwMCA3MEwxMDAgMTAwTDQwIDEwMFpNMTUwIDcwTDE0MCA3MEwxNDAgOTBMMTMwIDkwTDEzMCAxMDBMMTQwIDEwMEwxNDAgMTEwTDI1MCAxMTBMMjUwIDEwMEwxNTAgMTAwTDE1MCA3MFoiIC8+PHBhdGggY2xhc3M9InNocDMiIGQ9Ik02MCAxNDBMNjAgMTUwTDEwMCAxNTBMMTAwIDE0MEw2MCAxNDBaTTYwIDEwMEw2MCA5MEwxMDAgOTBMMTAwIDEwMEw2MCAxMDBaTTEyMCA5MEwxMzAgOTBMMTMwIDEwMEwxNDAgMTAwTDE0MCAxMTBMMTEwIDExMEwxMTAgMTAwTDEyMCAxMDBMMTIwIDkwWk0xMjAgNzBMMTIwIDgwTDEzMCA4MEwxMzAgNzBMMTIwIDcwWk0xNTAgMTAwTDE1MCA5MEwyMDAgOTBMMjAwIDEwMEwxNTAgMTAwWk0xNjAgMTQwTDE2MCAxNTBMMjAwIDE1MEwyMDAgMTQwTDE2MCAxNDBaTTExMCAxOTBMMTEwIDIwMEwxNDAgMjAwTDE0MCAxOTBMMTEwIDE5MFpNMjAwIDE4MEwyMDAgMTkwTDIxMCAxOTBMMjEwIDE4MEwyMDAgMTgwWk0yMjAgMTgwTDIxMSAxODBMMjEwIDE3OUwyMTAgMTcwTDIyMCAxNzBMMjIwIDE4MFoiIC8+PHVzZSAgaHJlZj0iI2ltZzEiIHg9IjE0IiB5PSI1IiAvPjx1c2UgIGhyZWY9IiNpbWcyIiB4PSI5IiB5PSIyMzYiIC8+PHVzZSAgaHJlZj0iI2ltZzMiIHg9IjkiIHk9IjI4NSIgLz48L3N2Zz4=";
    string descriptionBottom = " ## https://yourbidsucks.wtf | Original Blitmap ID: #346";



     
    function generateMetadata(string memory _description) internal view returns (string memory) {        
        return
            string(
                    Base64.encode(
                        bytes(
                            abi.encodePacked(
                                '{"name":"The Soft Bid Guy", "description":"', _description, descriptionBottom, '", "image": "', image, '"}'
                            )
                        )
                    )
                
            );
    }
    
    function withdrawToPayees(uint256 _amount) internal onlyUser(msg.sender) {
        //MAINNET
        Payee memory payee1 = Payee(0x3B99E794378bD057F3AD7aEA9206fB6C01f3Ee60, "artist", 25);
        Payee memory payee2 = Payee(0x575CBC1D88c266B18f1BB221C1a1a79A55A3d3BE, "developer", 25);
        Payee memory payee3 = Payee(BLITMAP_CONTRACT.ownerOf(346), "owner of #346", 50);
        Payee[3] memory payees = [payee1, payee2, payee3];
        
        
         // DEBUG
        /*
        Payee memory payee1 = Payee(0x3B99E794378bD057F3AD7aEA9206fB6C01f3Ee60, "artist", 50);
        Payee memory payee2 = Payee(0x575CBC1D88c266B18f1BB221C1a1a79A55A3d3BE, "developer", 50);
        Payee[2] memory payees = [payee1, payee2];
        */
        
        
        for (uint256 i = 0; i < payees.length; i++) {
            Payee memory payee = payees[i];
            address payable to = payable(payee.wallet);
            to.transfer(_amount.mul(payee.percentage).div(100));    
        }
    }


    constructor() ERC721("The Soft Bid Guy", "BIDGUY") onlyOwner {}

    function mint(string memory _description, uint256 amount) external payable nonReentrant {
        require(msg.value >= mintPrice.mul(amount), "not enough ethers");
        withdrawToPayees(msg.value);
        for (uint256 i = 0; i < amount; i++) {
            _safeMint(msg.sender, _tokenIdCounter.current());
            _setTokenURI(_tokenIdCounter.current(), generateMetadata(_description));
            _tokenIdCounter.increment();
        }
    }
    
    
    function mintTo(address to, string memory _description, uint256 amount) external payable nonReentrant {
        require(msg.value >= mintPrice.mul(amount), "not enough ethers");
        withdrawToPayees(msg.value);
        for (uint256 i = 0; i < amount; i++) {
            _safeMint(to, _tokenIdCounter.current());
            _setTokenURI(_tokenIdCounter.current(), generateMetadata(_description));
            _tokenIdCounter.increment();            
        }
        
    }

    function _baseURI() internal pure override returns (string memory) {
        return "data:application/json;base64,";
    }

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }
    
    
}