# Declaratively set shell recipes a.k.a commands should run in
set shell := ["bash", "-uc"]

# Load environment variables
set dotenv-load := true
# apikey:
#    echo " from .env"

# set positional-arguments := true
# foo:
#   echo justinit
#   echo

# Colours

RED:= "\\033[31m"
GREEN:= "\\033[32m"
YELLOW:= "\\033[33m"
BLUE:= "\\033[34m"
MAGNETA:= "\\033[35m"
CYAN:= "\\033[36m"
WHITE:= "\\033[37m"
BOLD:= "\\033[1m"
UNDERLINE:= "\\033[4m"
INVERTED_COLOURS:= "\\033[7m"
RESET := "\\033[0m"
NEWLINE := "\n"

# Recipes

default:
    @#This recipe will be the default if you run just without an argument, e.g list out available commands
    @just --list --unsorted --list-heading $'{{BOLD}}{{GREEN}}Available recipes:{{NEWLINE}}{{RESET}}'
install *PACKAGES:
	@npm install {{PACKAGES}}
snarkjs-calc-witness:
	@echo "Calculating witness..."
	@snarkjs wtns calculate ./circuits/example.wasm ./circuits/example.json ./circuits/example.wtns
snarkjs-gen-proof:
	@echo "Generating proof..."
	@snarkjs groth16 prove ./circuits/example.zkey ./circuits/example.wtns ./circuits/example.proof.json ./circuits/example.public.json
snarkjs-verify-proof:
	@echo "Verifying proof..."
	@snarkjs groth16 verify ./circuits/example.vkey.json ./circuits/example.public.json ./circuits/example.proof.json
snarkjs-calc-gen-verify:
	just snarkjs-calc-witness && just snarkjs-gen-proof && just snarkjs-verify-proof
update:
	@npm update
compile-circuit:
	@npm run circom-dev && just snarkjs-calc-gen-verify
compile-contracts:
	@just _bold_red "If you get this error MalformedAbiError: Not a valid ABI, run rm -r ./artifacts/contracts"
	@npm run compile
deploy-localhost:
	@npm run deploy-localhost
deploy-testnet:
	@npm run deploy-testnet
verify-testnet:
	@npm run verify-testnet
test:
	@npm run test
lint:
	@npm run lint
start:
	@#Start a local hardhat blockchain instance localhost:8545
	@npm run node
format:
	@npm run format
audit:
	@npm run audit
print-audit:
	@npm run print-audit
print-gas-usage:
	@npm run print-gas-usage
print-deployments:
	@cat deployments/deploy.ts
clean:
    @just _bold_red "WARNING: this operation will delete the contracts, caches etc and reset this repo to a blank state for starting a new solidity project. This operation can't be undone."
    @just _bold_red "Would you like to proceed?"
    ./scripts/clean.sh

_bold_red message:
    @#Hidden recipes have _ in front, i.e these can be helpers such as pretty printer below
    @echo -e "{{BOLD}}{{RED}}{{message}}{{RESET}}"
