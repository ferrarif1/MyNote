pragma circom 2.0.5;

template Main() {
    signal input example;
    signal example_squared;
    signal output out;

    example_squared <-- example * example;
    out <-- example_squared - example + 9001;

    example_squared === example * example;
    out === example_squared - example + 9001;
}

component main = Main();
