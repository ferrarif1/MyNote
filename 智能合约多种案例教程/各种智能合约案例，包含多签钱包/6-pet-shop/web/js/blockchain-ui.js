// UI elements
const divNoEthereum = document.querySelector('.no-ethereum')
const divBlockchainInfo = document.querySelector('.blockchain-info')

const tdChainId = document.querySelector('.chain-id')
const tdSelectedAccount = document.querySelector('.selected-account')
const tdContractAddress = document.querySelector('.contract-address')
const tdLastBlock = document.querySelector('.last-block')
const tdPreviousEvents = document.querySelector('.previous-events')
const tdLiveEvents = document.querySelector('.live-events')


// Common network names
const chainName = {
  '0x1': '#1 (MainNet)',
  '0x3': '#3 (Ropsten)',
  '0x4': '#4 (Rinkeby)'
}


// Hide the banner saying the browser cannot connect to the blockchain and
// show the blockchain info table.
function showBlockchainInfo() {
  divNoEthereum.style.display = 'none'
  divBlockchainInfo.removeAttribute('style')
}

/* Chain Id */

function updateChainId(chainId) {
  tdChainId.textContent = chainName[chainId] ?? `#${parseInt(chainId)}`
}

function setChainIdError(error) {
  tdChainId.textContent = error.message
}

/* Last block */

function updateLastBlock(block) {
  tdLastBlock.textContent = `${parseInt(block.number)} (${block.hash})`
}

function setLastBlockError(error) {
  tdLastBlock.textContent = error.message
}

/* Contract address */

function updateContractAddress(address) {
  tdContractAddress.textContent = address
}

function setContractAddressError(error) {
  tdContractAddress.textContent = error.message
}

/* Selected account */

function updateAccount(account) {
  tdSelectedAccount.textContent = account ?? 'No account selected'
}

function setAccountError(error) {
  tdSelectedAccount.textContent = error.message
}

/* Events */

function addPreviousEvent(message) {
  tdPreviousEvents.appendChild(document.createTextNode(message))
  tdPreviousEvents.appendChild(document.createElement('br'))
}

function addLiveEvent(message) {
  tdLiveEvents.appendChild(document.createTextNode(message))
  tdLiveEvents.appendChild(document.createElement('br'))
}


export {
  showBlockchainInfo,
  updateChainId,
  setChainIdError,
  updateLastBlock,
  setLastBlockError,
  updateContractAddress,
  setContractAddressError,
  updateAccount,
  setAccountError,
  addPreviousEvent,
  addLiveEvent
}
