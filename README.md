// Start Anvil
anvil


// Deploy the contracts to Anvil:
forge script script/Deployer.s.sol --broadcast -f 127.0.0.1:8545 --sender 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266 --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80


// Create the message hash:
cast call 0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512 "getMessage(address,uint256)" 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266 25000000000000000000 --rpc-url http://localhost:8545


// Sign the message hash:
cast wallet sign --no-hash 0xc60241dc211b73f06770abbd122aa16944c349c00b0d3e1005e7f09351611af8 --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80


// Send the signed message, with another user's private key
forge script script/Interact.s.sol --rpc-url http://localhost:8545 --private-key 0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d --broadcast


// Check the user's balance:
cast call 0x5FbDB2315678afecb367f032d93F642f64180aa3 "balanceOf(address)" 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266