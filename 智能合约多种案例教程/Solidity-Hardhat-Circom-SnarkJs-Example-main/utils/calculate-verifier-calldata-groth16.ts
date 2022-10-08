const { groth16 } = require("snarkjs");
export const exportCallDataGroth16 = async (
  input: any,
  wasmPath: any,
  zkeyPath: any
) => {
  const { proof: _proof, publicSignals: _publicSignals } =
    await groth16.fullProve(input, wasmPath, zkeyPath);
  const calldata = await groth16.exportSolidityCallData(_proof, _publicSignals);

  const argv = calldata
    .replace(/["[\]\s]/g, "")
    .split(",")
    .map((x: any) => BigInt(x).toString());

  const a = [argv[0], argv[1]];
  const b = [
    [argv[2], argv[3]],
    [argv[4], argv[5]],
  ];
  const c = [argv[6], argv[7]];
  const Input = [];

  for (let i = 8; i < argv.length; i++) {
    Input.push(argv[i]);
  }

  return { a, b, c, Input };
};

module.exports = {
  exportCallDataGroth16,
};
