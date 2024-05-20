package main

import (
	"crypto/rand"
	"fmt"
	"math/big"
)

// Party 结构体定义了每个参与方的属性
type Party struct {
	Index int      // 参与方的索引
	Share *big.Int // 每个参与方持有的秘密份额
}

// CentralAuthority 是中央实体，负责生成秘密多项式和分发份额
type CentralAuthority struct {
	Secret     *big.Int   // 原始秘密
	Polynomial []*big.Int // 秘密多项式的系数
	Prime      *big.Int   // 大质数，用于模运算，确保计算在有限字段内
}

// GeneratePolynomial 生成一个随机的秘密多项式，多项式的常数项是秘密
func (ca *CentralAuthority) GeneratePolynomial(degree int) {
	ca.Polynomial = make([]*big.Int, degree+1)
	ca.Polynomial[0] = ca.Secret
	for i := 1; i <= degree; i++ {
		coeff, _ := rand.Int(rand.Reader, ca.Prime)
		ca.Polynomial[i] = coeff
	}
}

// EvaluatePolynomial 在给定点x上评估多项式
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

// DistributeShares 分发秘密份额给每个参与方
func (ca *CentralAuthority) DistributeShares(parties []*Party) {
	for _, party := range parties {
		x := big.NewInt(int64(party.Index + 1))
		party.Share = ca.EvaluatePolynomial(x)
	}
}

// ReconstructSecret 使用拉格朗日插值重构秘密
func (ca *CentralAuthority) ReconstructSecret(shares []*Party) *big.Int {
	if len(shares) < len(ca.Polynomial)-1 {
		fmt.Println("Not enough shares to reconstruct the secret.")
		return nil
	}

	secret := big.NewInt(0)
	prime := ca.Prime

	for i, share := range shares {
		// 计算拉格朗日基本多项式
		num := big.NewInt(1)
		den := big.NewInt(1)
		for j, otherShare := range shares {
			if i != j {
				x_i := big.NewInt(int64(share.Index + 1))
				x_j := big.NewInt(int64(otherShare.Index + 1))
				num.Mul(num, x_j) // 分子
				num.Mod(num, prime)

				tmp := new(big.Int).Sub(x_j, x_i)
				den.Mul(den, tmp) // 分母
				den.Mod(den, prime)
			}
		}

		term := new(big.Int).Mul(share.Share, num) // 当前份额的贡献
		term.Mod(term, prime)

		denInv := new(big.Int).ModInverse(den, prime) // 分母的模逆元
		term.Mul(term, denInv)
		term.Mod(term, prime)

		secret.Add(secret, term) // 累加到秘密
		secret.Mod(secret, prime)
	}

	return secret
}

func main2() {
	secret := big.NewInt(1234)  // 假设的秘密
	prime := big.NewInt(999983) // 一个大质数
	partiesCount := 8
	threshold := 3

	ca := CentralAuthority{Secret: secret, Prime: prime}
	ca.GeneratePolynomial(threshold - 1)

	parties := make([]*Party, partiesCount)
	for i := range parties {
		parties[i] = &Party{Index: i}
	}

	// 分发秘密份额
	ca.DistributeShares(parties)

	// 打印每个参与方的秘密份额
	fmt.Println("Secret shares distributed to parties:")
	for _, party := range parties {
		fmt.Printf("Party %d: %s\n", party.Index+1, party.Share.String())
	}

	// 假设我们随机选择t个份额来重构秘密
	chosenShares := make([]*Party, threshold)
	for i := 0; i < threshold; i++ {
		chosenShares[i] = parties[i]
	}

	// 重构秘密
	reconstructedSecret := ca.ReconstructSecret(chosenShares)
	if reconstructedSecret != nil {
		fmt.Println("Reconstructed Secret:", reconstructedSecret.String())
		// 验证重构的秘密是否与原始秘密相同
		if reconstructedSecret.Cmp(secret) == 0 {
			fmt.Println("Success: The reconstructed secret matches the original secret.")
		} else {
			fmt.Println("Error: The reconstructed secret does not match the original secret.")
		}
	} else {
		fmt.Println("Failed to reconstruct the secret with the provided shares.")
	}
}
