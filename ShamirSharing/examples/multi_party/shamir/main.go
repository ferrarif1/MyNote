package main

import (
	"fmt"

	"github.com/tuneinsight/lattigo/v5/core/rlwe"
	"github.com/tuneinsight/lattigo/v5/he/heint"
	"github.com/tuneinsight/lattigo/v5/mhe"
)

// 参与方
type party struct {
	i                 int //表示第i个参与方
	sk                *rlwe.SecretKey
	Thresholdizer     mhe.Thresholdizer
	shares            []mhe.ShamirSecretShare
	ShamirPoly        mhe.ShamirPolynomial
	ShamirPublicPoint mhe.ShamirPublicPoint
	mhe.Combiner
}

func main1() {
	//*****初始化参数*****
	fmt.Println("> Parameter initialization Phase")
	// 创建参数字面量
	params, err := heint.NewParametersFromLiteral(heint.ParametersLiteral{
		LogN:             13,
		LogQ:             []int{54, 54, 54},
		LogP:             []int{55},
		PlaintextModulus: 65537,
	})
	if err != nil {
		fmt.Println("Error creating parameters:", err)
		return
	}
	fmt.Println("Parameters created successfully:", params)

	//*****私钥生成*****
	fmt.Println("> Private key generation Phase")
	// 创建密钥生成器
	kgen := rlwe.NewKeyGenerator(params)

	//假设有N个参与方，自定义输入
	var N int
	fmt.Println("输入参与方数量：")
	N = 3

	//设置每个参与方的私钥
	parties := make([]*party, N)
	for i := 0; i < N; i++ {
		sk := kgen.GenSecretKeyNew()
		parties[i] = &party{i: i, sk: sk}
		fmt.Printf("Party %d: Secret key generated successfully\n", i)
	}

	//*****秘密共享*****
	fmt.Println("> Shamir Secret Share Phase")

	//秘密共享的初始化操作
	shamirPublicPoints := make([]mhe.ShamirPublicPoint, 0)
	//设置阈值
	t := 2

	for i := 0; i < N; i++ {
		//阈值生成器
		parties[i].Thresholdizer = mhe.NewThresholdizer(params)
		parties[i].shares = make([]mhe.ShamirSecretShare, N)

		//用于接收私钥，将私钥放在切片gen的第0个位置
		var err error
		parties[i].ShamirPoly, err = parties[i].Thresholdizer.GenShamirPolynomial(t, parties[i].sk)
		if err != nil {
			panic(err)
		}
		//设置公共点
		parties[i].ShamirPublicPoint = mhe.ShamirPublicPoint(i + 1)
		shamirPublicPoints = append(shamirPublicPoints, parties[i].ShamirPublicPoint)
	}
	if t != N {

		for _, pi := range parties {
			//设置combiner
			params_rlwe := rlwe.ParameterProvider(params)
			pi.Combiner = mhe.NewCombiner(*params_rlwe.GetRLWEParameters(), pi.ShamirPublicPoint, shamirPublicPoints, t)
		}

		// shares := make(map[*party]map[*party]mhe.ShamirSecretShare, len(parties))

		for _, pi := range parties {

			// shares[pi] = make(map[*party]mhe.ShamirSecretShare)

			for _, pj := range parties {
				share := pi.Thresholdizer.AllocateThresholdSecretShare()
				pi.Thresholdizer.GenShamirSecretShare(pj.ShamirPublicPoint, pi.ShamirPoly, &share)
				// shares[pi][pj] = share
				// pj.shares[pi.i] = shares[pi][pj]
				pj.shares[pi.i] = share
			}

		}

	}
	parties_oline := parties[:2]
	// 重构
	x := 2 //离线的参与方
	sk_combine := parties[x].combine(x, N, parties_oline, params)
	bool := parties[x].sk.Equal(sk_combine)
	fmt.Println(bool)

}

func (p *party) combine(x int, N int, parties_oline []*party, params heint.Parameters) *rlwe.SecretKey {

	sk1 := rlwe.NewSecretKey(params)

	for _, pi := range parties_oline {
		activePublicPoint := make([]mhe.ShamirPublicPoint, 0)
		for _, pj := range parties_oline {
			activePublicPoint = append(activePublicPoint, pj.ShamirPublicPoint)
		}
		sk := rlwe.NewSecretKey(params)
		if err := p.Combiner.GenAdditiveShare(activePublicPoint, pi.ShamirPublicPoint, pi.shares[x], sk); err != nil {
			panic(err)
		}
		params.RingQP().Add(sk.Value, sk1.Value, sk1.Value)
	}
	return sk1

}
