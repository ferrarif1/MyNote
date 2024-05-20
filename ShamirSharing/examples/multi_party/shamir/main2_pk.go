package main

import (
	"crypto/rand"
	"fmt"
	"math/big"
)

type Party struct {
	Index int
	Share *big.Int
}

type CentralAuthority struct {
	Secret     *big.Int
	Polynomial []*big.Int
	Prime      *big.Int
}

func (ca *CentralAuthority) GeneratePolynomial(degree int) {
	ca.Polynomial = make([]*big.Int, degree+1)
	ca.Polynomial[0] = ca.Secret
	for i := 1; i <= degree; i++ {
		coeff, _ := rand.Int(rand.Reader, ca.Prime)
		ca.Polynomial[i] = coeff
	}
}

func (ca *CentralAuthority) EvaluatePolynomial(x *big.Int) *big.Int {
	result := new(big.Int)
	xPow := big.NewInt(1)
	for _, coeff := range ca.Polynomial {
		term := new(big.Int).Mul(coeff, xPow)
		term.Mod(term, ca.Prime)
		result.Add(result, term)
		result.Mod(result, ca.Prime)
		xPow.Mul(xPow, x)
	}
	return result
}

func (ca *CentralAuthority) DistributeShares(parties []*Party) {
	for _, party := range parties {
		x := big.NewInt(int64(party.Index + 1))
		party.Share = ca.EvaluatePolynomial(x)
	}
}

func (ca *CentralAuthority) ReconstructSecret(shares []*Party) *big.Int {
	secret := big.NewInt(0)
	for i, share := range shares {
		num := big.NewInt(1)
		den := big.NewInt(1)
		for j, otherShare := range shares {
			if i != j {
				x_i := big.NewInt(int64(share.Index + 1))
				x_j := big.NewInt(int64(otherShare.Index + 1))
				num.Mul(num, x_j)
				num.Mod(num, ca.Prime)

				tmp := new(big.Int).Sub(x_j, x_i)
				den.Mul(den, tmp)
				den.Mod(den, ca.Prime)
			}
		}

		term := new(big.Int).Mul(share.Share, num)
		term.Mod(term, ca.Prime)

		denInv := new(big.Int).ModInverse(den, ca.Prime)
		term.Mul(term, denInv)
		term.Mod(term, ca.Prime)

		secret.Add(secret, term)
		secret.Mod(secret, ca.Prime)
	}
	return secret
}

func main() {
	secret, _ := rand.Int(rand.Reader, new(big.Int).Exp(big.NewInt(2), big.NewInt(256), nil))
	fmt.Printf("secret : %s\n", secret.String())
	// prime, _ := rand.Prime(rand.Reader, 256)

	prime := new(big.Int).Sub(new(big.Int).Exp(big.NewInt(2), big.NewInt(521), nil), big.NewInt(1))
	// fmt.Printf("prime=", prime.String())

	partiesCount := 8
	threshold := 3

	ca := CentralAuthority{Secret: secret, Prime: prime}
	ca.GeneratePolynomial(threshold - 1)

	parties := make([]*Party, partiesCount)
	for i := range parties {
		parties[i] = &Party{Index: i}
	}

	ca.DistributeShares(parties)

	fmt.Println("Secret shares distributed to parties:")
	for _, party := range parties {
		fmt.Printf("Party %d: %s\n", party.Index+1, party.Share.String())
	}

	chosenShares := make([]*Party, threshold)
	for i := 0; i < threshold; i++ {
		chosenShares[i] = parties[i]
	}

	reconstructedSecret := ca.ReconstructSecret(chosenShares)
	if reconstructedSecret != nil {
		fmt.Println("Reconstructed Secret:", reconstructedSecret.String())
		if reconstructedSecret.Cmp(secret) == 0 {
			fmt.Println("Success: The reconstructed secret matches the original secret.")
		} else {
			fmt.Println("Error: The reconstructed secret does not match the original secret.")
		}
	} else {
		fmt.Println("Failed to reconstruct the secret with the provided shares.")
	}
}
